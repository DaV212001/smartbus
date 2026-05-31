import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartbus/models/route.dart' as models;

import 'package:smartbus/config/dio_config.dart';
import 'package:smartbus/config/storage_config.dart';
import 'package:smartbus/controllers/route_controller.dart';
import 'package:smartbus/controllers/ticket_controller.dart';
import 'package:smartbus/controllers/wallet_controller.dart';
import 'package:smartbus/models/ticket.dart';
import 'package:smartbus/utils/api_call_status.dart';

/// Mutable flags controlled per-test to switch mock interceptor behaviour.
bool _trigger401Error = false;
bool _triggerInsufficientFunds = false;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late RouteController routeController;
  late TicketController ticketController;
  late WalletController walletController;

  setUpAll(() async {
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({'access_token': 'mock_token'});
    await ConfigPreference.init();

    // ── Reset the Dio singleton so we control the interceptor stack cleanly ──
    DioConfig.isTestMode = true;
    DioConfig.resetDio();

    final dio = await DioConfig.dio();
    // Insert our mock interceptor at position 0 so it runs first.
    dio.interceptors.insert(
      0,
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // ── TC 2.1: Inject 401 Unauthorized ───────────────────────────────
          if (_trigger401Error) {
            _trigger401Error = false;
            return handler.reject(
              DioException(
                requestOptions: options,
                response: Response(
                  requestOptions: options,
                  statusCode: 401,
                  data: {'message': 'Unauthorized'},
                ),
                type: DioExceptionType.badResponse,
              ),
            );
          }

          // ── TC 2.2: Route Search returns a mock result ─────────────────────
          if (options.path.contains('/v1/routes/search')) {
            final query = options.queryParameters['q']?.toString() ?? '';
            if (query.toLowerCase() == 'bole') {
              return handler.resolve(Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'data': {
                    'items': [
                      {
                        'id': 'route_bole',
                        'routeNumber': 'B12',
                        // NOTE: Route.fromJson reads json['name'] as a plain
                        // String, not a localised map – match that expectation.
                        'name': 'Piazza - Bole',
                        'price': 15.0,
                        'stops': [],
                        'duration': 45.0,
                      }
                    ]
                  }
                },
              ));
            }
            // No query match → empty result
            return handler.resolve(Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'data': {'items': []}
              },
            ));
          }

          // ── TC 2.4: Insufficient Funds – reject before touching wallet ─────
          if (options.path.contains('/v1/tickets/purchase')) {
            if (_triggerInsufficientFunds) {
              _triggerInsufficientFunds = false;
              return handler.reject(
                DioException(
                  requestOptions: options,
                  response: Response(
                    requestOptions: options,
                    statusCode: 400,
                    data: {'message': 'Insufficient funds'},
                  ),
                  type: DioExceptionType.badResponse,
                ),
              );
            }
            return handler.resolve(Response(
              requestOptions: options,
              statusCode: 200,
              data: {'message': 'Ticket purchased successfully'},
            ));
          }

          // ── TC 2.3: Wallet top-up returns a Chapa checkout URL ─────────────
          if (options.path.contains('/v1/wallet/topup')) {
            return handler.resolve(Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'data': {
                  'paymentUrl': 'https://checkout.chapa.co/mock-url',
                }
              },
            ));
          }

          // ── Paginated routes list ──────────────────────────────────────────
          if (options.path.contains('/v1/routes')) {
            return handler.resolve(Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'data': {
                  'items': [],
                  'meta': {'page': 1, 'totalPages': 1},
                }
              },
            ));
          }

          // ── Default: empty success for all other endpoints ─────────────────
          return handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'data': {'items': []}
            },
          ));
        },
      ),
    );

    routeController = Get.put(RouteController());
    ticketController = Get.put(TicketController());
    walletController = Get.put(WalletController());

    // Wait for onInit calls to settle.
    await Future.delayed(const Duration(milliseconds: 300));
  });

  tearDownAll(() {
    Get.reset();
    DioConfig.resetDio();
  });

  group('Backend Simulation Tests', () {
    // ─────────────────────────────────────────────────────────────────────────
    // TC 2.1 – Auth Loop: 401 triggers graceful error state, no hard crash.
    // ─────────────────────────────────────────────────────────────────────────
    test(
        'TC 2.1: Auth Loop Simulation handles 401 Unauthorized gracefully',
        () async {
      // Pre-seed the route list so routes.isEmpty is false.
      // This bypasses the `if (routes.isEmpty) _handleError(...)` branch in
      // fetchRoutes.onFailure — which calls Get.snackbar and crashes in a
      // headless test that has no overlay context.
      routeController.routes.assignAll([
        const models.Route(id: 'seed_1', routeNumber: '00'),
      ]);
      routeController.routesStatus.value = ApiCallStatus.holding;
      routeController.isLoading.value = false;

      _trigger401Error = true;

      // Drive a fresh fetch so the mock interceptor fires.
      try {
        await routeController.fetchRoutes(page: 1);
      } catch (_) {
        // Swallow any navigation exception from the session-expired handler.
      }

      // Allow any pending async callbacks (e.g. _getErrorData) to settle
      // so the error status assignment completes before we assert.
      await Future.delayed(const Duration(milliseconds: 300));

      // The controller must not crash; it must signal an error status.
      expect(
        routeController.routesStatus.value,
        ApiCallStatus.error,
        reason: 'A 401 response must set routesStatus to error',
      );

      // Reset loading flags so subsequent tests are unaffected.
      routeController.isLoading.value = false;
    });

    // ─────────────────────────────────────────────────────────────────────────
    // TC 2.2 – Advanced Route Search: verify query string and response mapping.
    // ─────────────────────────────────────────────────────────────────────────
    test(
        'TC 2.2: Advanced Route Search processes query parameters and maps responses',
        () async {
      try {
        await routeController.searchRoutesAdvanced(
            q: 'Bole', departure: 'Mexico');
      } catch (_) {}

      expect(
        routeController.searchStatus.value,
        ApiCallStatus.success,
        reason: 'Mocked /v1/routes/search must return success',
      );
      expect(
        routeController.searchResults.length,
        1,
        reason: 'Exactly one route item in the mock payload',
      );
      expect(
        routeController.searchResults.first.routeNumber,
        'B12',
      );
    });

    // ─────────────────────────────────────────────────────────────────────────
    // TC 2.3 – Wallet Funding Flow: idempotency key generated, topupStatus
    // transitions to success after the mock responds with a paymentUrl.
    // ─────────────────────────────────────────────────────────────────────────
    test(
        'TC 2.3: Wallet Funding Flow generates idempotency key and handles checkout URL',
        () async {
      walletController.prepareNewTopUp();

      // addFunds calls the POST /v1/wallet/topup which our interceptor resolves
      // with a paymentUrl.  dioPost does NOT await the onSuccess callback, so
      // addFunds() returns while onSuccess is still running asynchronously.
      // Inside onSuccess, topupStatus = success is set synchronously BEFORE the
      // first await (Get.to), so by the time addFunds() returns the value is
      // already propagated.  We catch any navigation exception that follows.
      try {
        await walletController.addFunds(100.0);
      } catch (_) {}

      // Yield once so the synchronous portion of onSuccess has definitely run.
      await Future.delayed(Duration.zero);

      // Assert before the async Get.to chain fires the snackbar.
      expect(
        walletController.topupStatus.value,
        ApiCallStatus.success,
        reason:
            'topupStatus must be success once the mock paymentUrl is received',
      );
    });

    // ─────────────────────────────────────────────────────────────────────────
    // TC 2.4 – Insufficient Funds: purchase returns 400; controller sets error
    // state and retains existing ticket list.
    // ─────────────────────────────────────────────────────────────────────────
    testWidgets(
        'TC 2.4: Insufficient Funds Purchase triggers correct controller error states',
        (WidgetTester tester) async {
      // Provide an overlay so Get.snackbar inside _handleError has a context.
      await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));
      await tester.pumpAndSettle();
      // Pre-populate ticket list to verify it is NOT wiped on failure.
      ticketController.ticketHistory.add(
        Ticket(
          id: 'existing_1',
          passengerId: 'p1',
          routeId: 'r1',
          boardingStopId: 'bs1',
          dropoffStopId: 'ds1',
          fareAmount: 15.0,
          status: 'ACTIVE',
          purchasedAt: DateTime.now(),
        ),
      );

      // Reset purchase status so we can cleanly observe the transition.
      ticketController.purchaseStatus.value = ApiCallStatus.holding;

      _triggerInsufficientFunds = true;

      try {
        await ticketController.purchaseTicket(
          routeId: 'r_1',
          boardingStopId: 's_1',
          dropoffStopId: 's_2',
        );
      } catch (_) {}

      // Settle all pending async work: onFailure callback, snackbar queue.
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(
        ticketController.purchaseStatus.value,
        ApiCallStatus.error,
        reason: 'A 400 response must set purchaseStatus to error',
      );

      // Ticket history must be unaffected by the failed purchase attempt.
      expect(
        ticketController.ticketHistory.any((t) => t.id == 'existing_1'),
        isTrue,
        reason: 'Existing tickets must be retained after a failed purchase',
      );
    });
  });
}
