import 'package:get/get.dart';

import '../utils/templates/dio_template.dart';

class AlertController extends GetxController {
  final alerts = <dynamic>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAlerts();
  }

  Future<void> fetchAlerts() async {
    isLoading.value = true;
    await DioService.dioGet(
      path: '/v1/alerts',
      onSuccess: (response) {
        alerts.value = response.data['data'] ?? [];
        isLoading.value = false;
      },
      onFailure: (error, response) {
        isLoading.value = false;
        // Fallback to mock data if API fails or for testing
        if (alerts.isEmpty) {
          alerts.value = _getMockAlerts();
        }
      },
    );
  }

  List<dynamic> _getMockAlerts() {
    return [
      {
        'id': '1',
        'title': 'Route R-42 Delayed',
        'message':
            'Due to heavy traffic at Stadium area, expect a 15-min delay.',
        'time': 'Just now',
        'type': 'warning',
        'isUnread': true,
      },
      {
        'id': '2',
        'title': 'Top Up Successful',
        'message': 'Your wallet has been credited with 100.00 ETB.',
        'time': '2 hours ago',
        'type': 'success',
        'isUnread': true,
      },
      {
        'id': '3',
        'title': 'Ticket Expired',
        'message': 'Your ticket for R-05 Piassa has expired unused.',
        'time': 'Yesterday',
        'type': 'muted',
        'isUnread': false,
      },
    ];
  }

  void markAllAsRead() {
    for (var alert in alerts) {
      alert['isUnread'] = false;
    }
    alerts.refresh();
    // Potentially call API: /v1/alerts/mark-read
  }
}
