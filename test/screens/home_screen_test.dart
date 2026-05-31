import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:smartbus/controllers/intelligence_controller.dart';
import 'package:smartbus/controllers/route_controller.dart';
import 'package:smartbus/controllers/theme_mode_controller.dart';
import 'package:smartbus/controllers/ticket_controller.dart';
import 'package:smartbus/screens/home_screen.dart';
import 'package:mocktail/mocktail.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartbus/config/storage_config.dart';

class MockBuildContext extends Mock implements BuildContext {}

class FakeIntelligenceController extends IntelligenceController {
  @override
  void onInit() {
    travelAdvice.value = 'Fake advice';
    userPersona.value = UserPersona.commuter;
  }
}

class FakeRouteController extends RouteController {
  @override
  void onInit() {}
}

class FakeTicketController extends TicketController {
  @override
  void onInit() {}
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({'theme_is_light': true});
    await ConfigPreference.init();
  });

  setUp(() {
    Get.testMode = true;
    Get.put<IntelligenceController>(FakeIntelligenceController());
    Get.put<RouteController>(FakeRouteController());
    Get.put<ThemeModeController>(ThemeModeController(MockBuildContext()));
    Get.put<TicketController>(FakeTicketController());
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('HomeScreen renders correctly and shows search bar', (WidgetTester tester) async {
    await tester.pumpWidget(const GetMaterialApp(
      home: HomeScreen(),
    ));

    // Verify header exists
    expect(find.text('SmartBus'), findsOneWidget);

    // Verify search bar exists (looking for search icon)
    expect(find.byIcon(Icons.search), findsOneWidget);

    // Verify section title exists
    expect(find.byType(ListView), findsWidgets); // Filters list and Routes list
  });
}
