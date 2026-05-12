import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbus/config/storage_config.dart';
import 'package:smartbus/controllers/auth_controller.dart';
import 'package:smartbus/controllers/theme_mode_controller.dart';
import 'package:smartbus/screens/login_screen.dart';
import 'package:smartbus/screens/main_layout_screen.dart';
import 'package:smartbus/screens/signup_screen.dart';
import 'package:smartbus/screens/verify_otp_screen.dart';
import 'package:smartbus/screens/route_search_screen.dart';
import 'package:smartbus/screens/route_detail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ConfigPreference.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize Controllers
    // ThemeModeController requires context for its theme generation logic
    Get.put(ThemeModeController(context));
    Get.put(AuthController());

    return Obx(
      () => GetMaterialApp(
        title: 'SmartBus',
        debugShowCheckedModeBanner: false,
        theme: ThemeModeController.getThemeMode(),
        locale: ThemeModeController.getLocale(),
        // Route Management
        initialRoute: ConfigPreference.isUserLoggedIn() ? '/home' : '/login',
        getPages: [
          GetPage(
            name: '/login',
            page: () => const LoginScreen(),
            transition: Transition.fadeIn,
          ),
          GetPage(
            name: '/signup',
            page: () => const SignupScreen(),
            transition: Transition.rightToLeft,
          ),
          GetPage(
            name: '/verify-otp',
            page: () => const OtpScreen(),
            transition: Transition.rightToLeft,
          ),
          GetPage(
            name: '/home',
            page: () => const MainLayoutScreen(),
            transition: Transition.fadeIn,
          ),
          GetPage(
            name: '/route-search',
            page: () => const RouteSearchScreen(),
            transition: Transition.rightToLeft,
          ),
          GetPage(
            name: '/route-detail',
            page: () => const RouteDetailScreen(),
            transition: Transition.rightToLeft,
          ),
        ],
      ),
    );
  }
}
