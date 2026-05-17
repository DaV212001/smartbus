import 'package:dio/dio.dart' as dio_lib;
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import '../config/dio_config.dart';
import '../config/storage_config.dart';
import '../models/transaction.dart';
import '../utils/templates/dio_template.dart';

class WalletController extends GetxController {
  final isLoading = false.obs;
  final isWalletLoading = false.obs;
  final isBalanceLoading = false.obs;
  final balance = 0.0.obs;
  final transactions = <WalletTransaction>[].obs;
  String? _activeIdempotencyKey;
  double? _lastAttemptedAmount;

  /// Call this when starting a new top-up session (e.g., opening a dialog)
  void prepareNewTopUp() {
    _activeIdempotencyKey = const Uuid().v4();
    _lastAttemptedAmount = null;
  }

  @override
  void onInit() {
    super.onInit();
    fetchTransactions();
    fetchWalletData();
  }

  Future<void> fetchWalletData() async {
    isBalanceLoading.value = true;
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
      },
      onFailure: (error, response) => _handleError(error, response),
    );
  }

  Future<void> fetchTransactions() async {
    isLoading.value = true;
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
      },
      onFailure: (error, response) => _handleError(error, response),
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
      onSuccess: (response) {
        Get.snackbar('Success', 'Funds added successfully');
        _activeIdempotencyKey = null; // Clear on success
        _lastAttemptedAmount = null;
        isWalletLoading.value = false;
        fetchWalletData();
      },
      onFailure: (error, response) {
        Logger().d(response);
        isWalletLoading.value = false;
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
}
