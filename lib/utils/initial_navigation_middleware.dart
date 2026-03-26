import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '../config/storage_config.dart';

class InitialNavigationMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // Check if the user is logged in
    bool isAuthenticated = ConfigPreference.isUserLoggedIn();
    if (!isAuthenticated) {
      Logger().i('Unauthenticated access attempted');
      return const RouteSettings(name: '/login'); // Redirect to login page
    }
    return null; // Allow the navigation
  }
}
