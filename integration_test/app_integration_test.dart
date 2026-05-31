import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:smartbus/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End Passenger App UI Integration Tests', () {
    testWidgets('Full passenger journey and layout validation flow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final hasLoginText = find.text('Login').evaluate().isNotEmpty || find.text('LOGIN').evaluate().isNotEmpty;
      
      if (hasLoginText) {
        expect(find.byType(TextField), findsWidgets);
      } else {
        // We are logged in. Test Core Layouts.
        
        // --- TC 3.1: Home Dashboard ---
        expect(find.byIcon(Icons.home), findsWidgets);
        expect(find.byIcon(Icons.map), findsWidgets);
        expect(find.byIcon(Icons.confirmation_num), findsWidgets);
        expect(find.byIcon(Icons.account_balance_wallet), findsWidgets);

        // --- TC 3.2: Route Search UI Interaction ---
        await tester.tap(find.byIcon(Icons.map));
        await tester.pumpAndSettle(const Duration(seconds: 1));
        
        // Find search field
        final searchField = find.byType(TextField).first;
        expect(searchField, findsOneWidget);
        
        // Type 'Bole' and verify interaction doesn't crash
        await tester.enterText(searchField, 'Bole');
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        
        final hasList = find.byType(ListView).evaluate().isNotEmpty;
        final hasEmptyState = find.text('No routes found').evaluate().isNotEmpty || find.text('Search routes').evaluate().isNotEmpty;
        expect(hasList || hasEmptyState, isTrue);

        // --- TC 3.3: Tickets Tab Rendering ---
        await tester.tap(find.byIcon(Icons.confirmation_num));
        await tester.pumpAndSettle(const Duration(seconds: 1));
        
        final hasTicketsText = find.text('My Tickets').evaluate().isNotEmpty || find.text('MY TICKETS').evaluate().isNotEmpty;
        expect(hasTicketsText, isTrue);

        // --- TC 3.4: Wallet Interactive Flows ---
        await tester.tap(find.byIcon(Icons.account_balance_wallet));
        await tester.pumpAndSettle(const Duration(seconds: 1));
        
        final hasWalletText = find.text('Wallet Balance').evaluate().isNotEmpty || find.text('WALLET BALANCE').evaluate().isNotEmpty;
        expect(hasWalletText, isTrue);
        
        // Look for the "Add Funds" or Top-Up button
        final addFundsBtn = find.text('Add Funds');
        if (addFundsBtn.evaluate().isNotEmpty) {
          await tester.tap(addFundsBtn);
          await tester.pumpAndSettle(const Duration(milliseconds: 500));
          // Should open a bottom sheet or dialog with amount input
          expect(find.byType(TextField), findsWidgets);
          // Tap outside to dismiss so we can finish cleanly
          await tester.tapAt(const Offset(10, 10));
          await tester.pumpAndSettle();
        }
      }
    });
  });
}
