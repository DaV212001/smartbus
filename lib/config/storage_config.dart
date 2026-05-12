import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ConfigPreference {
  // prevent making instance
  ConfigPreference._();

  // get storage
  static late SharedPreferences sharedPreferencesInstance;

  // STORING KEYS
  static const String _lightThemeKey = 'is_theme_light';
  static const String _isFirstLaunchKey = 'is_first_launch';
  static const String _appLanguageCode = 'app_language_code';
  static const String _appLanguageCountryCode = 'app_language_country_code';
  static const String _accessToken = 'access_token';
  static const String _showCase = "show_case";

  /// init get storage services
  static Future<void> init() async {
    sharedPreferencesInstance = await SharedPreferences.getInstance();
  }

  static const String _refreshToken = 'refresh_token';
  static const String _accessTokenExpiry = 'access_token_expiry';
  static const String _userToken = 'user_token';
  // static const String _accessToken = 'access_token';

  static Future<void> setTokens(
    dynamic data,
    String accessToken,
    String refreshToken,
    int expiresIn,
  ) async {
    final expiryTimestamp = DateTime.now()
        .add(Duration(seconds: expiresIn))
        .millisecondsSinceEpoch;

    await sharedPreferencesInstance.setString(_accessToken, accessToken);
    await sharedPreferencesInstance.setString(_refreshToken, refreshToken);
    await sharedPreferencesInstance.setInt(_accessTokenExpiry, expiryTimestamp);
    await sharedPreferencesInstance.setString(_userToken, json.encode(data));
  }

  static Future<void> updateTokens(
    String accessToken,
    String refreshToken,
    int expiresIn,
  ) async {
    final expiryTimestamp = DateTime.now()
        .add(Duration(seconds: expiresIn))
        .millisecondsSinceEpoch;

    await sharedPreferencesInstance.setString(_accessToken, accessToken);
    await sharedPreferencesInstance.setString(_refreshToken, refreshToken);
    await sharedPreferencesInstance.setInt(_accessTokenExpiry, expiryTimestamp);
  }

  static bool isAccessTokenExpired() {
    final expiry = sharedPreferencesInstance.getInt(_accessTokenExpiry);
    if (expiry == null) return true;
    return DateTime.now().millisecondsSinceEpoch > expiry;
  }

  // static String? getAccessToken() =>
  //     sharedPreferencesInstance.getString(_accessToken);

  static String? getRefreshToken() =>
      sharedPreferencesInstance.getString(_refreshToken);

  // static Future<void> clearTokens() async {
  //   await sharedPreferencesInstance.remove(_accessToken);
  //   await sharedPreferencesInstance.remove(_refreshToken);
  // }

  static SharedPreferences getStorage() => sharedPreferencesInstance;

  static setStorage(SharedPreferences sharedPreferences) {
    sharedPreferencesInstance = sharedPreferences;
  }

  static Future<void> setShowCase(bool showCase) =>
      sharedPreferencesInstance.setBool(_showCase, showCase);
  static bool showCase() =>
      sharedPreferencesInstance.getBool(_showCase) ?? true;

  /// set theme current type as light theme
  static Future<void> setThemeIsLight(bool lightTheme) =>
      sharedPreferencesInstance.setBool(_lightThemeKey, lightTheme);

  /// get if the current theme type is light
  static bool getThemeIsLight() =>
      sharedPreferencesInstance.getBool(_lightThemeKey) ?? true;

  /// check if the app is first launch
  static bool isFirstLaunch() =>
      sharedPreferencesInstance.getBool(_isFirstLaunchKey) ?? true;

  /// est first launch flag to false
  static Future<void> setFirstLaunchCompleted() =>
      sharedPreferencesInstance.setBool(_isFirstLaunchKey, false);

  static String getAppLanguageCode() =>
      sharedPreferencesInstance.getString(_appLanguageCode) ?? 'am';

  static Future<void> setAppLanguageCode(String appLanguage) =>
      sharedPreferencesInstance.setString(_appLanguageCode, appLanguage);
  static Future<void> setLanguage(String appLanguage) =>
      sharedPreferencesInstance.setString(_appLanguageCode, appLanguage);

  static String getAppLanguageCountryCode() =>
      sharedPreferencesInstance.getString(_appLanguageCountryCode) ?? 'ET';

  static String getLanguage() =>
      sharedPreferencesInstance.getString(_appLanguageCode) ?? 'en';

  static Future<void> setAppLanguageCountryCode(String appLanguageCountry) =>
      sharedPreferencesInstance.setString(
        _appLanguageCountryCode,
        appLanguageCountry,
      );

  static Future<void> setAccessToken(String token) =>
      sharedPreferencesInstance.setString(_accessToken, token);

  static bool isUserLoggedIn() =>
      sharedPreferencesInstance.getString(_accessToken) != null;

  static String? getAccessToken() =>
      sharedPreferencesInstance.getString(_accessToken);
  static String? getUserToken() =>
      sharedPreferencesInstance.getString(_userToken);

  // static Widget checkToken() {
  //   print('was called');
  //   final String? token = getUserToken();
  //   if (token == null) {
  //     print('signup');
  //     // return SignUpScreen();
  //   } else {
  //     print('mamito');
  //     // return Mamito();
  //   }
  // }

  static Future<void> clearTokens() async {
    await sharedPreferencesInstance.remove(_accessToken);
    await sharedPreferencesInstance.remove((_refreshToken));
  }

  /// clear all data from shared pref
  static Future<void> clear() async => await sharedPreferencesInstance.clear();
  static Future<void> logOut() async =>
      sharedPreferencesInstance
        ..getKeys().forEach((key) {
          if (key != 'is_first_launch' && key != 'is_theme_light') {
            ConfigPreference.getStorage().remove(key);
          }
        });
}
