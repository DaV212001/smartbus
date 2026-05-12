import 'package:dio/dio.dart' as dio_lib;
import 'package:get/get.dart';

import '../config/dio_config.dart';
import '../models/ticket.dart';
import '../utils/templates/dio_template.dart';

class TicketDetailController extends GetxController {
  final isLoading = false.obs;
  final ticket = Rxn<Ticket>();

  Future<void> fetchTicketDetail(String id) async {
    isLoading.value = true;
    await DioService.dioGet(
      path: '/v1/tickets/$id',
      onSuccess: (response) {
        ticket.value = Ticket.fromJson(response.data['data']);
        isLoading.value = false;
      },
      onFailure: (error, response) => _handleError(error, response),
    );
  }

  void _handleError(dynamic error, dynamic response) {
    isLoading.value = false;
    String errorMsg = "An error occurred while fetching ticket details";

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
