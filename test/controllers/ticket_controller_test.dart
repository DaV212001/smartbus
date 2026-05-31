import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:smartbus/config/dio_config.dart';
import 'package:smartbus/config/storage_config.dart';
import 'package:smartbus/controllers/ticket_controller.dart';
import 'package:smartbus/utils/api_call_status.dart';

void main() {
  late DioAdapter dioAdapter;
  late TicketController controller;

  setUpAll(() async {
    Get.testMode = true;
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({'access_token': 'test_token'});
    await ConfigPreference.init();
    
    DioConfig.isTestMode = true;
    
    // Bypass getApplicationDocumentsDirectory in DioConfig
    DioConfig.cookieJar = PersistCookieJar(storage: FileStorage('.cookies/'));
  });

  setUp(() async {
    // Get the singleton dio instance and attach adapter
    final dio = await DioConfig.dio();
    dioAdapter = DioAdapter(dio: dio);
    
    // Controller onInit calls fetchTickets, so mock it here
    dioAdapter.onGet('/v1/tickets', (server) => server.reply(200, {
      'data': {'items': []}
    }));
    
    controller = TicketController();
    Get.put(controller);
  });

  tearDown(() {
    Get.delete<TicketController>();
    dioAdapter.reset();
  });

  test('fetchTickets populates history and active ticket on success', () async {
    final mockResponse = {
      'data': {
        'items': [
          {
            'id': '1',
            'passengerId': 'p1',
            'routeId': 'r1',
            'boardingStopId': 'bs1',
            'dropoffStopId': 'ds1',
            'fareAmount': 1000,
            'status': 'ACTIVE',
            'purchasedAt': '2023-10-10T10:00:00Z',
          },
          {
            'id': '2',
            'passengerId': 'p1',
            'routeId': 'r1',
            'boardingStopId': 'bs1',
            'dropoffStopId': 'ds1',
            'fareAmount': 1000,
            'status': 'EXPIRED',
            'purchasedAt': '2023-10-09T10:00:00Z',
          }
        ]
      }
    };

    dioAdapter.onGet('/v1/tickets', (server) => server.reply(200, mockResponse));

    await controller.fetchTickets();

    expect(controller.isLoading.value, false);
    expect(controller.ticketsStatus.value, ApiCallStatus.success);
    expect(controller.ticketHistory.length, 2);
    expect(controller.activeTicket.value, isNotNull);
    expect(controller.activeTicket.value?.id, '1');
    expect(controller.activeTicket.value?.status, 'ACTIVE');
  });

  test('fetchTickets handles empty response correctly', () async {
    final mockResponse = {
      'data': {
        'items': []
      }
    };

    dioAdapter.onGet('/v1/tickets', (server) => server.reply(200, mockResponse));

    await controller.fetchTickets();

    expect(controller.isLoading.value, false);
    expect(controller.ticketsStatus.value, ApiCallStatus.empty);
    expect(controller.ticketHistory.isEmpty, true);
    expect(controller.activeTicket.value, isNull);
  });

  testWidgets('purchaseTicket succeeds and updates status', (tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));

    // Mock the purchase endpoint
    dioAdapter.onPost('/v1/tickets/purchase', (server) => server.reply(201, {
      'message': 'Success'
    }), data: Matchers.any);

    // The GET /v1/tickets mock is already handled in setUp()

    await controller.purchaseTicket(
      routeId: 'r1',
      boardingStopId: 'bs1',
      dropoffStopId: 'ds1',
    );

    expect(controller.purchaseStatus.value, ApiCallStatus.success);
  });
}
