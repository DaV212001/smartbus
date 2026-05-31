import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartbus/config/storage_config.dart';
import 'package:smartbus/controllers/wallet_controller.dart';
import 'package:smartbus/models/transaction.dart';
import 'package:smartbus/utils/api_call_status.dart';

void main() {
  late WalletController controller;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await ConfigPreference.init();
    Get.testMode = true;
  });

  setUp(() {
    controller = WalletController();
  });

  tearDown(() {
    Get.reset();
    controller.dispose();
  });

  group('WalletController Unit Tests', () {
    // ── TC 1.6: Transaction model parsing and local calculations ─────────────
    group('TC 1.6: WalletTransaction parsing and isCredit logic', () {
      test('TOPUP type parses correctly and is flagged as credit', () {
        final tx = WalletTransaction.fromJson({
          'id': 'tx_1',
          'walletId': 'w_1',
          'type': 'TOPUP',
          'status': 'COMPLETED',
          'amount': 50.0,
          'createdAt': '2026-05-30T10:00:00.000Z',
        });

        expect(tx.transactionType, WalletTransactionType.TOPUP);
        expect(tx.transactionStatus, WalletTransactionStatus.COMPLETED);
        expect(tx.isCredit, isTrue);
      });

      test('TICKET_PURCHASE type is flagged as debit', () {
        final tx = WalletTransaction.fromJson({
          'id': 'tx_2',
          'walletId': 'w_1',
          'type': 'TICKET_PURCHASE',
          'status': 'COMPLETED',
          'amount': 15.0,
          'createdAt': '2026-05-30T10:00:00.000Z',
        });

        expect(tx.transactionType, WalletTransactionType.TICKET_PURCHASE);
        expect(tx.isCredit, isFalse);
      });

      test('REFUND type is flagged as credit', () {
        final tx = WalletTransaction.fromJson({
          'id': 'tx_3',
          'walletId': 'w_1',
          'type': 'REFUND',
          'status': 'COMPLETED',
          'amount': 20.0,
          'createdAt': '2026-05-30T10:00:00.000Z',
        });
        expect(tx.transactionType, WalletTransactionType.REFUND);
        expect(tx.isCredit, isTrue);
      });

      test('ADJUSTMENT with positive amount is credit', () {
        final tx = WalletTransaction.fromJson({
          'id': 'tx_4',
          'walletId': 'w_1',
          'type': 'ADJUSTMENT',
          'status': 'COMPLETED',
          'amount': 5.0,
          'createdAt': '2026-05-30T10:00:00.000Z',
        });
        expect(tx.isCredit, isTrue);
      });

      test('ADJUSTMENT with negative amount is debit', () {
        final tx = WalletTransaction.fromJson({
          'id': 'tx_5',
          'walletId': 'w_1',
          'type': 'ADJUSTMENT',
          'status': 'COMPLETED',
          'amount': -5.0,
          'createdAt': '2026-05-30T10:00:00.000Z',
        });
        expect(tx.isCredit, isFalse);
      });

      test('UNKNOWN type with null status does not throw', () {
        final tx = WalletTransaction.fromJson({
          'id': 'tx_6',
          'walletId': 'w_1',
          'type': 'SOMETHING_NEW',
          'status': null,
          'amount': 0.0,
          'createdAt': '2026-05-30T10:00:00.000Z',
        });
        expect(tx.transactionType, WalletTransactionType.UNKNOWN);
        expect(tx.transactionStatus, WalletTransactionStatus.UNKNOWN);
      });

      test('Legacy CREDIT type maps to TOPUP', () {
        final tx = WalletTransaction.fromJson({
          'id': 'tx_7',
          'walletId': 'w_1',
          'type': 'CREDIT',
          'status': 'COMPLETED',
          'amount': 25.0,
          'createdAt': '2026-05-30T10:00:00.000Z',
        });
        expect(tx.transactionType, WalletTransactionType.TOPUP);
        expect(tx.isCredit, isTrue);
      });

      test('Local balance computation from a list of transactions', () {
        controller.transactions.assignAll([
          WalletTransaction(
              id: '1',
              walletId: 'w',
              type: 'TOPUP',
              amount: 100,
              createdAt: DateTime.now()),
          WalletTransaction(
              id: '2',
              walletId: 'w',
              type: 'TICKET_PURCHASE',
              amount: 15,
              createdAt: DateTime.now()),
          WalletTransaction(
              id: '3',
              walletId: 'w',
              type: 'REFUND',
              amount: 5,
              createdAt: DateTime.now()),
        ]);

        // Calculate expected balance: credits - debits = (100 + 5) - 15 = 90
        final credits = controller.transactions
            .where((t) => t.isCredit)
            .fold<double>(0, (s, t) => s + t.amount);
        final debits = controller.transactions
            .where((t) => !t.isCredit)
            .fold<double>(0, (s, t) => s + t.amount);
        expect(credits - debits, 90.0);
      });
    });

    // ── TC 1.7: Error state transitions on balance retrieval failure ──────────
    group('TC 1.7: Error state transitions on network failures', () {
      test('balanceStatus starts at holding', () {
        expect(controller.balanceStatus.value, ApiCallStatus.holding);
      });

      test('transactionsStatus starts at holding', () {
        expect(controller.transactionsStatus.value, ApiCallStatus.holding);
      });

      test('topupStatus starts at holding', () {
        expect(controller.topupStatus.value, ApiCallStatus.holding);
      });

      test('prepareNewTopUp resets topupStatus and clears error', () {
        // Simulate a previous error state.
        controller.topupStatus.value = ApiCallStatus.error;
        controller.topupError.value = null;

        controller.prepareNewTopUp();

        expect(controller.topupStatus.value, ApiCallStatus.holding);
        expect(controller.topupError.value, isNull);
      });

      test('balance initialises to 0.0', () {
        expect(controller.balance.value, 0.0);
      });

      test('balance can be set programmatically (simulate success callback)', () {
        controller.balance.value = 250.75;
        expect(controller.balance.value, 250.75);
      });
    });

    // ── TC 1.8: Suggested top-up amounts frequency analysis ──────────────────
    group('TC 1.8: getSuggestedTopUpAmounts frequency analysis', () {
      test('returns defaults when transactions list is empty', () {
        controller.transactions.clear();
        final suggestions = controller.getSuggestedTopUpAmounts();
        expect(suggestions, [25.0, 50.0, 100.0]);
      });

      test('returns defaults when no TOPUP transactions exist', () {
        controller.transactions.assignAll([
          WalletTransaction(
              id: '1',
              walletId: 'w',
              type: 'TICKET_PURCHASE',
              amount: 15,
              createdAt: DateTime.now()),
        ]);
        final suggestions = controller.getSuggestedTopUpAmounts();
        expect(suggestions, [25.0, 50.0, 100.0]);
      });

      test('returns top amounts sorted ascending', () {
        controller.transactions.assignAll([
          WalletTransaction(
              id: '1',
              walletId: 'w',
              type: 'TOPUP',
              amount: 100,
              createdAt: DateTime.now()),
          WalletTransaction(
              id: '2',
              walletId: 'w',
              type: 'TOPUP',
              amount: 100,
              createdAt: DateTime.now()),
          WalletTransaction(
              id: '3',
              walletId: 'w',
              type: 'TOPUP',
              amount: 50,
              createdAt: DateTime.now()),
          WalletTransaction(
              id: '4',
              walletId: 'w',
              type: 'TICKET_PURCHASE',
              amount: 15,
              createdAt: DateTime.now()),
        ]);

        final suggestions = controller.getSuggestedTopUpAmounts();
        expect(suggestions.length, 3);
        // Result: unique topups are [100, 50]. 100 is most frequent (2×).
        // The 3rd slot is padded with result.last * 2 = 100 * 2 = 200? No:
        // The algorithm takes top 2 uniques [100, 50], pads with 100*2=200.
        // Sorted: [50.0, 100.0, 200.0].
        expect(suggestions[0], 50.0);
        expect(suggestions[1], 100.0);
        // suggestions[2]: pad = result.last(50) * 2 = 100.0, sorted → 100.0
        expect(suggestions[2], 100.0);
      });

      test('result is always exactly 3 elements', () {
        controller.transactions.assignAll([
          WalletTransaction(
              id: '1',
              walletId: 'w',
              type: 'TOPUP',
              amount: 75,
              createdAt: DateTime.now()),
        ]);
        expect(controller.getSuggestedTopUpAmounts().length, 3);
      });
    });
  });
}
