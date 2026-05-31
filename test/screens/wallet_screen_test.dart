import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:smartbus/controllers/wallet_controller.dart';
import 'package:smartbus/screens/wallet_screen.dart';

class FakeWalletController extends WalletController {
  @override
  void onInit() {
    balance.value = 100.0;
  }
}

void main() {
  setUp(() {
    Get.testMode = true;
    Get.put<WalletController>(FakeWalletController());
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('WalletScreen renders balance card and add funds button', (WidgetTester tester) async {
    await tester.pumpWidget(const GetMaterialApp(
      home: WalletScreen(),
    ));

    await tester.pumpAndSettle();

    // Verify "My Wallet" title exists
    expect(find.text('my_wallet'.tr), findsOneWidget);

    // Verify "Add Funds" button exists
    expect(find.text('add_funds'.tr), findsOneWidget);
    
    // Verify transaction history section exists
    expect(find.text('recent_transactions'.tr), findsOneWidget);
  });
}
