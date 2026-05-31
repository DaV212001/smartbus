import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:smartbus/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('End-to-end smoke test', (tester) async {
    // Start the app
    app.main();
    await tester.pumpAndSettle();

    // Verify app starts and shows some initial content
    // Typically we look for a login screen or home screen depending on state.
    // For a simple smoke test, we verify that the app builds without crashing.
    expect(find.byType(app.MyApp), findsOneWidget);
  });
}
