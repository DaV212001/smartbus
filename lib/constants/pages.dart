import 'package:get/get_navigation/src/routes/get_route.dart';

import '../screens/ticket_detail_screen.dart';

class AppRoutes {
  static String get profileRoute => '/profile';
  static String get forgotPasswordRoute => '/forgot-password';
  static String get changePasswordRoute => '/change-password';
  static String get termsAndConditionsRoute => '/terms-and-conditions';
  static String get privacyPolicyRoute => '/privacy-policy';
  static String get contactUsRoute => '/contact-us';
  static String get aboutUsRoute => '/about-us';
  static String get settingsRoute => '/settings';
  static String get routeDetailRoute => '/route-detail';
  static String get homeRoute => '/home-screens';
  static String get tripHistoryRoute => '/trip-history';
  static String get tripHistoryDetailRoute => '/trip-history-detail';
  static String get signupRoute => '/signup';
  static String get loginRoute => '/login';
  static String get mainLayoutRoute => '/home';
  static String get ticketDetailRoute => '/ticket-detail';
}

class Pages {
  static final pages = [
    GetPage(
      name: AppRoutes.ticketDetailRoute,
      page: () => TicketDetailScreen(),
    ),
    // GetPage(
    //   name: AppRoutes.profileRoute,
    //   page: () => const ProfileScreen(),
    // ),
    // GetPage(
    //   name: AppRoutes.forgotPasswordRoute,
    //   page: () => const ForgotPasswordScreen(),
    // ),
    // GetPage(
    //   name: AppRoutes.changePasswordRoute,
    //   page: () => const ChangePasswordScreen(),
    // ),
    // GetPage(
    //   name: AppRoutes.termsAndConditionsRoute,
    //   page: () => const TermsAndConditionsScreen(),
    // ),
    // GetPage(
    //   name: AppRoutes.privacyPolicyRoute,
    //   page: () => const PrivacyPolicyScreen(),
    // ),
    // GetPage(
    //   name: AppRoutes.contactUsRoute,
    //   page: () => const ContactUsScreen(),
    // ),
    // GetPage(
    //   name: AppRoutes.aboutUsRoute,
    //   page: () => const AboutUsScreen(),
    // ),
    // GetPage(
    //   name: AppRoutes.settingsRoute,
    //   page: () => SettingsScreen(),
    // ),
    // GetPage(
    //   name: AppRoutes.routeDetailRoute,
    //   page: () => RouteDetailScreen(),
    // ),
    // GetPage(
    //   name: AppRoutes.homeRoute,
    //   page: () => const HomeScreen(),
    // ),
    // GetPage(
    //   name: AppRoutes.tripHistoryRoute,
    //   page: () => const TripHistoryScreen(),
    // ),
    // GetPage(
    //   name: AppRoutes.tripHistoryDetailRoute,
    //   page: () => const TripHistoryDetailScreen(),
    // ),
    // GetPage(
    //   name: AppRoutes.signupRoute,
    //   page: () => const SignupScreen(),
    // ),
    // GetPage(
    //   name: AppRoutes.loginRoute,
    //   page: () => const LoginScreen(),
    // ),
    // GetPage(
    //     name: AppRoutes.mainLayoutRoute,
    //     page: () => MainLayoutScreen(),
    //     middlewares: [InitialNavigationMiddleware()]),
  ];
}
