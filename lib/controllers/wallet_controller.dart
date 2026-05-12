import 'package:dio/dio.dart' as dio_lib;
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../config/dio_config.dart';
import '../config/storage_config.dart';
import '../models/transaction.dart';
import '../utils/templates/dio_template.dart';

class WalletController extends GetxController {
  final isLoading = false.obs;
  final balance = 0.0.obs;
  final transactions = <WalletTransaction>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchWalletData();
    fetchTransactions();
  }

  Future<void> fetchWalletData() async {
    isLoading.value = true;
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
        transactions.value = items
            .map((e) => WalletTransaction.fromJson(e))
            .toList();
        isLoading.value = false;
      },
      onFailure: (error, response) => _handleError(error, response),
    );
  }

  Future<void> fetchTransactions() async {
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
    isLoading.value = true;
    final idempotencyKey = const Uuid().v4();

    await DioService.dioPost(
      path: '/v1/wallet/topup',
      options: dio_lib.Options(
        headers: {
          'idempotency-key': idempotencyKey,
          'Idempotency-Key': idempotencyKey,
        },
      ),
      data: {
        'amount': (amount * 100).toInt(), // Convert to santim (minor units)
        'paymentMethod': 'card', // Default payment method
      },
      onSuccess: (response) {
        Get.snackbar('Success', 'Funds added successfully');
        fetchWalletData();
      },
      onFailure: (error, response) => _handleError(error, response),
    );
  }

  void _handleError(dynamic error, dynamic response) {
    isLoading.value = false;
    String errorMsg = "An error occurred";

    if (error is dio_lib.DioException) {
      errorMsg = DioConfig.convertDioError(error);
      if (error.response?.data != null) {
        final backendMsg = _parseMessage(error.response!.data);
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
