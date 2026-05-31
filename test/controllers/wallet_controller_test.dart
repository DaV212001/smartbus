import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:smartbus/config/dio_config.dart';
import 'package:smartbus/config/storage_config.dart';
import 'package:smartbus/controllers/wallet_controller.dart';
import 'package:smartbus/models/transaction.dart';
import 'package:smartbus/utils/api_call_status.dart';

void main() {
  late DioAdapter dioAdapter;
  late WalletController controller;

  setUpAll(() async {
    Get.testMode = true;
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({'access_token': 'test_token'});
    await ConfigPreference.init();
    DioConfig.isTestMode = true;
    DioConfig.cookieJar = PersistCookieJar(storage: FileStorage('.cookies/'));
  });

  setUp(() async {
    final dio = await DioConfig.dio();
    dioAdapter = DioAdapter(dio: dio);
    dioAdapter.onGet('/v1/wallet/balance', (server) => server.reply(200, {
      'data': {'balance': 0, 'transactions': []}
    }), headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer test_token',
    });
    dioAdapter.onGet('/v1/wallet/transactions', (server) => server.reply(200, {
      'data': {'items': []}
    }), headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer test_token',
    });
    controller = WalletController();
    Get.put(controller);
  });

  tearDown(() {
    Get.delete<WalletController>();
    dioAdapter.reset();
  });

  test('fetchWalletData updates balance and status correctly', () async {
    final mockResponse = {
      'data': {
        'balance': 15050, // This is in minor units (santims). Should be 150.50
        'transactions': []
      }
    };

    dioAdapter.onGet('/v1/wallet/balance', (server) => server.reply(200, mockResponse), headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer test_token',
    });

    await controller.fetchWalletData();

    expect(controller.isBalanceLoading.value, false);
    expect(controller.balanceStatus.value, ApiCallStatus.success);
    expect(controller.balance.value, 150.50);
  });

  test('getSuggestedTopUpAmounts calculates AI suggestions correctly based on history', () async {
    // Override the transactions list with dummy data
    controller.transactions.addAll([
      WalletTransaction(
        id: '1',
        walletId: 'w1',
        amount: 50.0,
        type: 'TOPUP',
        status: 'COMPLETED',
        createdAt: DateTime.now(),
      ),
      WalletTransaction(
        id: '2',
        walletId: 'w1',
        amount: 50.0,
        type: 'TOPUP',
        status: 'COMPLETED',
        createdAt: DateTime.now(),
      ),
      WalletTransaction(
        id: '3',
        walletId: 'w1',
        amount: 100.0,
        type: 'TOPUP',
        status: 'COMPLETED',
        createdAt: DateTime.now(),
      ),
      WalletTransaction(
        id: '4',
        walletId: 'w1',
        amount: 10.0,
        type: 'PAYMENT', // Should be ignored
        status: 'COMPLETED',
        createdAt: DateTime.now(),
      ),
    ]);

    final suggestions = controller.getSuggestedTopUpAmounts();
    
    expect(suggestions.length, 3);
    expect(suggestions, [50.0, 100.0, 200.0]);

    // Wait for onInit async requests to finish before tearDown clears mocks
    await Future.delayed(const Duration(milliseconds: 100));
  });
}
