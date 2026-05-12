import 'package:dio/dio.dart' as dio_lib;
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../config/dio_config.dart';
import '../models/ticket.dart';
import '../utils/templates/dio_template.dart';

class TicketController extends GetxController {
  final isLoading = false.obs;
  final activeTicket = Rxn<Ticket>(null);
  final ticketHistory = <Ticket>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchTickets();
  }

  Future<void> fetchTickets() async {
    isLoading.value = true;
    await DioService.dioGet(
      path: '/v1/tickets',
      onSuccess: (response) {
        final List items = response.data['data']['items'] ?? [];
        ticketHistory.value = items.map((e) => Ticket.fromJson(e)).toList();

        // Filter for active ticket based on status
        activeTicket.value = ticketHistory
            .where((t) => t.status.toUpperCase() == 'ACTIVE')
            .firstOrNull;
      },
      onFailure: (error, response) => _handleError(error, response),
    );
    isLoading.value = false;
  }

  Future<void> purchaseTicket({
    required String routeId,
    required String boardingStopId,
    required String dropoffStopId,
  }) async {
    isLoading.value = true;
    final idempotencyKey = const Uuid().v4();

    await DioService.dioPost(
      path: '/v1/tickets/purchase',
      options: dio_lib.Options(
        headers: {
          'idempotency-key': idempotencyKey,
          'Idempotency-Key': idempotencyKey,
        },
      ),
      data: {
        'routeId': routeId,
        'boardingStopId': boardingStopId,
        'dropoffStopId': dropoffStopId,
      },
      onSuccess: (response) {
        Get.snackbar('Success', 'Ticket purchased successfully');
        fetchTickets();
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
