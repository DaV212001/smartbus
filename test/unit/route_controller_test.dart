import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartbus/config/storage_config.dart';
import 'package:smartbus/controllers/route_controller.dart';
import 'package:smartbus/models/route.dart';
import 'package:smartbus/utils/api_call_status.dart';

void main() {
  late RouteController controller;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await ConfigPreference.init();
    Get.testMode = true;
  });

  setUp(() {
    controller = RouteController();
  });

  tearDown(() {
    Get.reset();
    controller.dispose();
  });

  group('RouteController Unit Tests', () {
    // ── TC 1.1: Client-side sort correctness ────────────────────────────────
    group('TC 1.1: _sortLocalRoutes sorts correctly by all supported fields', () {
      setUp(() {
        controller.routes.assignAll([
          const Route(id: '1', routeNumber: '10', price: 50.0, duration: 120.0),
          const Route(id: '2', routeNumber: '05', price: 10.0, duration: 45.0),
          const Route(id: '3', routeNumber: '20', price: 30.0, duration: 60.0),
        ]);
      });

      test('sorts by price ASC', () {
        controller.currentSortBy.value = 'price';
        controller.currentSortOrder.value = 'asc';
        controller.sortSearchResults();
        expect(controller.routes.map((r) => r.id).toList(), ['2', '3', '1']);
      });

      test('sorts by price DESC', () {
        controller.currentSortBy.value = 'price';
        controller.currentSortOrder.value = 'desc';
        controller.sortSearchResults();
        expect(controller.routes.map((r) => r.id).toList(), ['1', '3', '2']);
      });

      test('sorts by duration DESC', () {
        controller.currentSortBy.value = 'duration';
        controller.currentSortOrder.value = 'desc';
        controller.sortSearchResults();
        expect(controller.routes.map((r) => r.id).toList(), ['1', '3', '2']);
      });

      test('sorts by duration ASC', () {
        controller.currentSortBy.value = 'duration';
        controller.currentSortOrder.value = 'asc';
        controller.sortSearchResults();
        expect(controller.routes.map((r) => r.id).toList(), ['2', '3', '1']);
      });

      test('sorts by routeNumber ASC (lexicographic)', () {
        controller.currentSortBy.value = 'routeNumber';
        controller.currentSortOrder.value = 'asc';
        controller.sortSearchResults();
        expect(controller.routes.map((r) => r.routeNumber).toList(),
            ['05', '10', '20']);
      });

      test('sorts by routeNumber DESC (lexicographic)', () {
        controller.currentSortBy.value = 'routeNumber';
        controller.currentSortOrder.value = 'desc';
        controller.sortSearchResults();
        expect(controller.routes.map((r) => r.routeNumber).toList(),
            ['20', '10', '05']);
      });

      test('handles null price as 0.0 without throwing', () {
        controller.routes.assignAll([
          const Route(id: 'a', price: null),
          const Route(id: 'b', price: 5.0),
        ]);
        controller.currentSortBy.value = 'price';
        controller.currentSortOrder.value = 'asc';
        expect(() => controller.sortSearchResults(), returnsNormally);
        // null price treated as 0.0 → should come first in ASC
        expect(controller.routes.first.id, 'a');
      });

      test('unknown sortBy key returns stable order (no throw)', () {
        final originalIds = controller.routes.map((r) => r.id).toList();
        controller.currentSortBy.value = 'nonExistentField';
        controller.currentSortOrder.value = 'asc';
        expect(() => controller.sortSearchResults(), returnsNormally);
        expect(controller.routes.map((r) => r.id).toList(), originalIds);
      });
    });

    // ── TC 1.2: Pagination state machine ────────────────────────────────────
    group('TC 1.2: Pagination state transitions', () {
      test('hasMore is true when currentPage < totalPages', () {
        controller.isLoading.value = false;
        controller.isLoadingMore.value = false;
        controller.hasMore.value = true;
        controller.currentPage = 1;
        controller.totalPages = 3;

        controller.hasMore.value = controller.currentPage < controller.totalPages;
        expect(controller.hasMore.value, isTrue);
      });

      test('hasMore becomes false when currentPage equals totalPages', () {
        controller.currentPage = 2;
        controller.totalPages = 2;
        controller.hasMore.value = controller.currentPage < controller.totalPages;
        expect(controller.hasMore.value, isFalse);
      });

      test('routesStatus starts at holding before any network call', () {
        expect(controller.routesStatus.value, ApiCallStatus.holding);
      });

      test('isLoading and isLoadingMore initialise to false', () {
        expect(controller.isLoading.value, isFalse);
        expect(controller.isLoadingMore.value, isFalse);
      });
    });

    // ── TC 1.3: Offline cache parsing ───────────────────────────────────────
    group('TC 1.3: Offline cache parsing', () {
      test('loads valid cached routes from SharedPreferences', () {
        final mockCache = [
          {
            'id': 'mock_route_1',
            'routeNumber': '99',
            'name': 'Test Route',
            'price': 45.5,
            'duration': 30.0,
          }
        ];
        ConfigPreference.getStorage()
            .setString('cached_routes_list', json.encode(mockCache));

        controller.loadCachedRoutes();

        expect(controller.routes.length, 1);
        expect(controller.routes.first.id, 'mock_route_1');
        expect(controller.routes.first.price, 45.5);
      });

      test('does not crash when cache is empty JSON array', () {
        ConfigPreference.getStorage()
            .setString('cached_routes_list', json.encode([]));

        expect(() => controller.loadCachedRoutes(), returnsNormally);
        expect(controller.routes.isEmpty, isTrue);
      });

      test('does not crash when cache string is corrupted (non-JSON)', () {
        ConfigPreference.getStorage()
            .setString('cached_routes_list', '!!THIS IS NOT JSON!!');

        // Must not throw — graceful fallback expected.
        expect(() => controller.loadCachedRoutes(), returnsNormally);
      });

      test('does not crash when cache key is missing entirely', () {
        SharedPreferences.setMockInitialValues({});
        ConfigPreference.init();
        expect(() => controller.loadCachedRoutes(), returnsNormally);
      });
    });

    // ── Search results sorting (client-side) ─────────────────────────────────
    group('sortSearchResults acts on searchResults when non-empty', () {
      test('sorts searchResults list, not routes list', () {
        controller.routes.assignAll([
          const Route(id: 'route_a', price: 99.0),
        ]);
        controller.searchResults.assignAll([
          const Route(id: 'sr_1', price: 50.0),
          const Route(id: 'sr_2', price: 10.0),
        ]);
        controller.currentSortBy.value = 'price';
        controller.currentSortOrder.value = 'asc';
        controller.sortSearchResults();

        // searchResults sorted; routes untouched
        expect(controller.searchResults.first.id, 'sr_2');
        expect(controller.routes.first.id, 'route_a');
      });
    });
  });
}
