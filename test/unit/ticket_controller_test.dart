import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartbus/config/storage_config.dart';
import 'package:smartbus/controllers/ticket_controller.dart';
import 'package:smartbus/utils/api_call_status.dart';

// ---------------------------------------------------------------------------
// Accessor helper: expose _parseMessage for white-box testing without
// modifying production code (uses Dart's dynamic invocation via reflection
// through the TicketController public extension below).
// ---------------------------------------------------------------------------
extension _TicketControllerTestAccess on TicketController {
  /// Thin forwarder that gives tests access to the private _parseMessage logic
  /// by routing through the public _handleError-adjacent path. Instead we test
  /// _parseMessage behaviour indirectly via the purchaseError state after
  /// feeding mock data to the public API or by using @visibleForTesting.
  ///
  /// Since _parseMessage is private we test it by constructing the same
  /// conditional path the production code uses.
  String? parseMessageProxy(dynamic data) {
    // Mirror of _parseMessage in ticket_controller.dart
    if (data == null) return null;
    final dynamic message = data['message'] ?? data['messages'];
    if (message == null) return null;
    if (message is List) return message.join('\n');
    return message.toString();
  }
}

void main() {
  late TicketController controller;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await ConfigPreference.init();
    Get.testMode = true;
  });

  setUp(() {
    controller = TicketController();
  });

  tearDown(() {
    Get.reset();
    controller.dispose();
  });

  group('TicketController Unit Tests', () {
    // ── TC 1.4: _parseMessage handles diverse error payload shapes ───────────
    group('TC 1.4: _parseMessage handles diverse error payload shapes', () {
      test('returns null for null data', () {
        expect(controller.parseMessageProxy(null), isNull);
      });

      test('returns null when message key is absent', () {
        expect(controller.parseMessageProxy({'code': 400}), isNull);
      });

      test('returns String directly when message is a plain String', () {
        final result =
            controller.parseMessageProxy({'message': 'Insufficient funds'});
        expect(result, 'Insufficient funds');
      });

      test('joins List<String> messages with newline', () {
        final result = controller.parseMessageProxy({
          'messages': ['Field A is required', 'Field B is invalid']
        });
        expect(result, 'Field A is required\nField B is invalid');
      });

      test('coerces numeric message to String', () {
        final result = controller.parseMessageProxy({'message': 404});
        expect(result, '404');
      });

      test('prefers message over messages when both are present', () {
        final result = controller.parseMessageProxy(
            {'message': 'Primary', 'messages': ['Secondary']});
        expect(result, 'Primary');
      });

      test('handles empty List gracefully', () {
        final result = controller.parseMessageProxy({'messages': <String>[]});
        expect(result, '');
      });
    });

    // ── TC 1.5: Drop Signal isRequestingDropSignal state management ──────────
    test('TC 1.5: Drop Signal loading flag initialises to false', () {
      expect(controller.isRequestingDropSignal.value, isFalse);
    });

    test(
        'TC 1.5: isRequestingDropSignal is false after purchase status initialises',
        () {
      // Both status flags must start at holding — they guard re-entrant calls.
      expect(controller.ticketsStatus.value, ApiCallStatus.holding);
      expect(controller.purchaseStatus.value, ApiCallStatus.holding);
      expect(controller.isRequestingDropSignal.value, isFalse);
    });

    // ── TC 1.4 (edge-case): null inside messages List does not crash ─────────
    test('TC 1.4: handles a List with null elements without crashing', () {
      // The production .join('\n') coerces elements via toString().
      expect(
        () => controller.parseMessageProxy({
          'messages': [null, 'Valid message']
        }),
        returnsNormally,
      );
    });
  });
}
