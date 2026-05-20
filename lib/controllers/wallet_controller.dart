import 'package:dio/dio.dart' as dio_lib;
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import '../config/dio_config.dart';
import '../config/storage_config.dart';
import '../models/transaction.dart';
import '../screens/chapa_payment_screen.dart';
import '../utils/api_call_status.dart';
import '../utils/error_data.dart';
import '../utils/error_utils.dart';
import '../utils/templates/dio_template.dart';

class WalletController extends GetxController {
  final isLoading = false.obs;
  final isWalletLoading = false.obs;
  final isBalanceLoading = false.obs;
  final balance = 0.0.obs;
  final transactions = <WalletTransaction>[].obs;
  String? _activeIdempotencyKey;
  double? _lastAttemptedAmount;

  // Split reactive state trackers
  final balanceStatus = ApiCallStatus.holding.obs;
  final balanceError = Rxn<ErrorData>();

  final transactionsStatus = ApiCallStatus.holding.obs;
  final transactionsError = Rxn<ErrorData>();

  final topupStatus = ApiCallStatus.holding.obs;
  final topupError = Rxn<ErrorData>();

  /// Call this when starting a new top-up session (e.g., opening a dialog)
  void prepareNewTopUp() {
    _activeIdempotencyKey = const Uuid().v4();
    _lastAttemptedAmount = null;
    topupStatus.value = ApiCallStatus.holding;
    topupError.value = null;
  }

  @override
  void onInit() {
    super.onInit();
    fetchTransactions();
    fetchWalletData();
  }

  Future<void> fetchWalletData() async {
    isBalanceLoading.value = true;
    balanceStatus.value = ApiCallStatus.loading;
    balanceError.value = null;
    await DioService.dioGet(
      path: '/v1/wallet/balance',
      options: dio_lib.Options(
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${ConfigPreference.getAccessToken()}',
        },
      ),
      onSuccess: (response) {
        final data = response.data['data'];
        balance.value =
            (data['balance'] is num ? data['balance'].toDouble() : 0.0) / 100;
        final List items = data['transactions'] ?? [];
        // transactions.value = items
        //     .map((e) => WalletTransaction.fromJson(e))
        //     .toList();
        isBalanceLoading.value = false;
        balanceStatus.value = ApiCallStatus.success;
      },
      onFailure: (error, response) async {
        isBalanceLoading.value = false;
        final err = await ErrorUtil.getErrorData(error.toString());
        balanceError.value = err;
        balanceStatus.value = ApiCallStatus.error;
        _handleError(error, response);
      },
    );
  }

  Future<void> fetchTransactions() async {
    isLoading.value = true;
    transactionsStatus.value = ApiCallStatus.loading;
    transactionsError.value = null;
    await DioService.dioGet(
      path: '/v1/wallet/transactions',
      options: dio_lib.Options(
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${ConfigPreference.getAccessToken()}',
        },
      ),
      onSuccess: (response) {
        final List items = response.data['data']['items'] ?? [];
        transactions.value = items
            .map((e) => WalletTransaction.fromJson(e))
            .toList();
        isLoading.value = false;
        if (transactions.isEmpty) {
          transactionsStatus.value = ApiCallStatus.empty;
        } else {
          transactionsStatus.value = ApiCallStatus.success;
        }
      },
      onFailure: (error, response) async {
        isLoading.value = false;
        final err = await ErrorUtil.getErrorData(error.toString());
        transactionsError.value = err;
        transactionsStatus.value = ApiCallStatus.error;
        _handleError(error, response);
      },
    );
  }

  Future<void> addFunds(double amount) async {
    // If we're already loading and have a key, don't start a new request
    if (isWalletLoading.value && _activeIdempotencyKey != null) return;

    // If the amount changes, we MUST use a new idempotency key
    if (_lastAttemptedAmount != amount) {
      _activeIdempotencyKey = const Uuid().v4();
      _lastAttemptedAmount = amount;
    }

    // Ensure we have a key (for the first attempt)
    _activeIdempotencyKey ??= const Uuid().v4();
    _lastAttemptedAmount ??= amount;

    isWalletLoading.value = true;
    topupStatus.value = ApiCallStatus.loading;
    topupError.value = null;

    await DioService.dioPost(
      path: '/v1/wallet/topup',
      options: dio_lib.Options(
        headers: {
          'idempotency-key': _activeIdempotencyKey,
          'Idempotency-Key': _activeIdempotencyKey,
          'Authorization': 'Bearer ${ConfigPreference.getAccessToken()}',
        },
      ),
      data: {
        'amount': (amount * 100).toDouble(), // Convert to santim (minor units)
        'paymentMethod': 'card', // Default payment method
      },
      onSuccess: (response) async {
        isWalletLoading.value = false;
        topupStatus.value = ApiCallStatus.success;

        if (Get.isDialogOpen ?? false) {
          Get.back();
        }

        final dynamic resData = response.data['data'] ?? response.data;
        final String? paymentUrl = resData != null
            ? resData['paymentUrl']
            : null;

        if (paymentUrl != null && paymentUrl.isNotEmpty) {
          final bool? isPaymentSuccess = await Get.to<bool>(
            () => ChapaPaymentScreen(paymentUrl: paymentUrl),
          );

          if (isPaymentSuccess == true) {
            Get.snackbar('Success', 'Funds added successfully');
            _activeIdempotencyKey = null; // Clear on success
            _lastAttemptedAmount = null;
            fetchWalletData();
            fetchTransactions();
          } else {
            Get.snackbar('Payment', 'Payment not completed or cancelled');
          }
        } else {
          Get.snackbar('Error', 'Payment URL not found in response');
        }
      },
      onFailure: (error, response) async {
        Logger().d(response);
        isWalletLoading.value = false;
        final err = await ErrorUtil.getErrorData(error.toString());
        topupError.value = err;
        topupStatus.value = ApiCallStatus.error;
        // Note: We do NOT clear the idempotency key on failure.
        // This allows the next call (retry) to use the same key.
        _handleError(error, response);
      },
    );
  }

  void _handleError(dynamic error, dynamic response) {
    isLoading.value = false;
    String errorMsg = "An error occurred";

    if (error is dio_lib.DioException) {
      errorMsg = DioConfig.convertDioError(error);

      if (error.response?.data != null) {
        final backendMsg = _parseMessage(error.response!.data);
        Logger().d(error.response!.data);
        if (backendMsg != null) errorMsg = backendMsg;
      }
    } else if (response != null && response.data != null) {
      final backendMsg = _parseMessage(response.data);
      if (backendMsg != null) errorMsg = backendMsg;
    }

    Get.snackbar('Error', errorMsg, snackPosition: SnackPosition.BOTTOM);
  }

  String? _parseMessage(dynamic data) {
    if (data == null) return null;
    final dynamic message = data['message'] ?? data['messages'];
    if (message == null) return null;

    if (message is List) {
      return message.join('\n');
    }
    return message.toString();
  }

  /// AI Feature: Returns the most frequent top-up amounts from history
  List<double> getSuggestedTopUpAmounts() {
    if (transactions.isEmpty) return [25.0, 50.0, 100.0];

    final topups = transactions
        .where((tx) => tx.transactionType == WalletTransactionType.TOPUP)
        .map((tx) => tx.amount)
        .toList();

    if (topups.isEmpty) return [25.0, 50.0, 100.0];

    // Count frequencies
    final counts = <double, int>{};
    for (var amount in topups) {
      counts[amount] = (counts[amount] ?? 0) + 1;
    }

    // Sort by frequency
    final sortedAmounts = counts.keys.toList()
      ..sort((a, b) => counts[b]!.compareTo(counts[a]!));

    // Return top 3 or default if less than 3
    final result = sortedAmounts.take(3).toList();
    while (result.length < 3) {
      final last = result.isEmpty ? 50.0 : result.last * 2;
      result.add(last);
    }
    return result..sort();
  }
}
