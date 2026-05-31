import 'package:dio/dio.dart' as dio_lib;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/dio_config.dart';
import '../constants/assets.dart';
import '../models/ticket.dart';
import '../utils/templates/dio_template.dart';
import '../utils/api_call_status.dart';
import '../utils/error_data.dart';
import '../utils/error_utils.dart';

class TicketDetailController extends GetxController {
  final isLoading = false.obs;
  final ticket = Rxn<Ticket>();

  // Reactive state trackers
  final detailStatus = ApiCallStatus.holding.obs;
  final detailError = Rxn<ErrorData>();
  final isRequestingDropSignal = false.obs;

  Future<void> fetchTicketDetail(String id) async {
    isLoading.value = true;
    detailStatus.value = ApiCallStatus.loading;
    detailError.value = null;
    await DioService.dioGet(
      path: '/v1/tickets/$id',
      onSuccess: (response) {
        ticket.value = Ticket.fromJson(response.data['data']);
        isLoading.value = false;
        detailStatus.value = ApiCallStatus.success;
      },
      onFailure: (error, response) async {
        isLoading.value = false;
        detailStatus.value = ApiCallStatus.error;
        final err = await _getErrorData(error);
        detailError.value = err;
        _handleError(error, response);
      },
    );
  }

  Future<bool> requestDropSignal(String id) async {
    isRequestingDropSignal.value = true;
    bool success = false;
    await DioService.dioPost(
      path: '/v1/tickets/$id/drop-signal',
      data: {},
      onSuccess: (response) {
        success = true;
        _fetchTicketDetailSilently(id);
        Get.snackbar(
          'success'.tr,
          response.data['message'] ?? 'Drop signal sent successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFE8F5E9),
          colorText: const Color(0xFF2E7D32),
        );
      },
      onFailure: (error, response) async {
        _handleError(error, response);
      },
    );
    isRequestingDropSignal.value = false;
    return success;
  }

  Future<void> _fetchTicketDetailSilently(String id) async {
    await DioService.dioGet(
      path: '/v1/tickets/$id',
      onSuccess: (response) {
        ticket.value = Ticket.fromJson(response.data['data']);
      },
      onFailure: (error, response) {
        // Silently ignore background fetch failure
      },
    );
  }

  Future<ErrorData> _getErrorData(Object error) async {
    try {
      return await ErrorUtil.getErrorData(error.toString());
    } catch (_) {
      return ErrorData(
        title: 'error'.tr,
        body: 'unexpected_error'.tr,
        image: Assets.errorsUnknown,
        buttonText: 'refresh'.tr,
      );
    }
  }

  void _handleError(dynamic error, dynamic response) {
    isLoading.value = false;
    if (DioConfig.isSessionExpiredError(error)) return;

    String errorMsg = "An error occurred while processing your request";

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
