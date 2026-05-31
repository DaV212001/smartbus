import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:smartbus/config/dio_config.dart';
import 'package:smartbus/config/storage_config.dart';
import 'package:smartbus/controllers/route_controller.dart';
import 'package:smartbus/models/route.dart' as smartbus_route;
import 'package:smartbus/utils/api_call_status.dart';

void main() {
  late DioAdapter dioAdapter;
  late RouteController controller;

  setUpAll(() async {
    Get.testMode = true;
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({
      'access_token': 'test_token',
    });
    await ConfigPreference.init();
    DioConfig.isTestMode = true;
    DioConfig.cookieJar = PersistCookieJar(storage: FileStorage('.cookies/'));
  });

  setUp(() async {
    final dio = await DioConfig.dio();
    dioAdapter = DioAdapter(dio: dio);
    dioAdapter.onGet(
      '/v1/routes',
      queryParameters: {
        'page': '1',
        'limit': '20',
        'sortBy': 'createdAt',
        'sortOrder': 'desc',
      },
      (server) => server.reply(200, {
        'data': {
          'items': [],
          'meta': {'page': 1, 'totalPages': 1}
        }
      })
    );

    controller = RouteController();
    Get.put(controller);
  });

  tearDown(() {
    Get.delete<RouteController>();
    dioAdapter.reset();
  });

  test('fetchRoutes loads first page and applies meta data', () async {
    final mockResponse = {
      'data': {
        'items': [
          {'id': 'r1', 'routeNumber': '1A', 'name': 'Route A', 'price': 10, 'duration': 30},
          {'id': 'r2', 'routeNumber': '1B', 'name': 'Route B', 'price': 15, 'duration': 40}
        ],
        'meta': {
          'page': 1,
          'totalPages': 2,
        }
      }
    };

    dioAdapter.onGet(
      '/v1/routes',
      queryParameters: {
        'page': '1',
        'limit': '20',
        'sortBy': 'createdAt',
        'sortOrder': 'desc',
      },
      (server) => server.reply(200, mockResponse)
    );

    await controller.fetchRoutes(page: 1);

    expect(controller.isLoading.value, false);
    expect(controller.routesStatus.value, ApiCallStatus.success);
    expect(controller.routes.length, 2);
    expect(controller.hasMore.value, true);
    expect(controller.currentPage, 1);
  });

  test('searchRoutesAdvanced updates query params and state', () async {
    final mockResponse = {
      'data': {
        'items': [
          {'id': 'r1', 'routeNumber': '1A', 'name': 'Search Route A', 'price': 10}
        ]
      }
    };

    // The advanced search uses direct query concatenation inside path as well as queryParameters in the Dio call
    dioAdapter.onGet(
      '/v1/routes/search',
      queryParameters: {'q': 'test_query', 'departure': '', 'destination': ''},
      (server) => server.reply(200, mockResponse)
    );

    await controller.searchRoutesAdvanced(q: 'test_query');

    expect(controller.searchKeyword.value, 'test_query');
    expect(controller.searchStatus.value, ApiCallStatus.success);
    expect(controller.searchResults.length, 1);
    expect(controller.searchResults.first.name, 'Search Route A');
  });

  test('sortSearchResults applies client side sorting correctly', () {
    // Populate fake search results
    controller.searchResults.addAll([
      smartbus_route.Route(id: '1', price: 50.0, duration: 60.0),
      smartbus_route.Route(id: '2', price: 20.0, duration: 120.0),
      smartbus_route.Route(id: '3', price: 30.0, duration: 40.0),
    ]);

    // Test sort by price ascending
    controller.currentSortBy.value = 'price';
    controller.currentSortOrder.value = 'asc';
    controller.sortSearchResults();
    
    expect(controller.searchResults[0].id, '2'); // 20.0
    expect(controller.searchResults[1].id, '3'); // 30.0
    expect(controller.searchResults[2].id, '1'); // 50.0

    // Test sort by duration descending
    controller.currentSortBy.value = 'duration';
    controller.currentSortOrder.value = 'desc';
    controller.sortSearchResults();

    expect(controller.searchResults[0].id, '2'); // 120.0
    expect(controller.searchResults[1].id, '1'); // 60.0
    expect(controller.searchResults[2].id, '3'); // 40.0
  });
}
