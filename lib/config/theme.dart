import 'package:flutter/material.dart';

import '../constants/constants.dart';

ColorScheme appColor([bool? isDark]) => ColorScheme.fromSeed(
    seedColor: const Color(0xFF6D28D9),
    primary: const Color(0xFF6D28D9),
    secondary: const Color(0xFF030712),
    dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    surface:
        (isDark ?? false) ? const Color(0xFF010810) : const Color(0xFFF1EFEF),
    brightness: isDark == null
        ? Brightness.light
        : isDark
            ? Brightness.dark
            : Brightness.light);

// Cache to store the theme based on the isDark parameter
Map<bool?, ThemeData> _themeCache = {};

ThemeData appTheme(BuildContext context, {bool? isDark}) {
  // Check if the theme for this isDark parameter is already cached
  if (_themeCache.containsKey(isDark)) {
    return _themeCache[isDark]!;
  }

  // If not cached, create the theme
  ColorScheme themeColor = appColor(isDark);
  ThemeData theme = ThemeData(
    primaryColor: themeColor.primary,
    colorScheme: themeColor,
    fontFamily: 'Geist',
    useMaterial3: true,
    appBarTheme: AppBarTheme(
        color: isDark == true ? themeColor.secondary : null,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontFamily: 'Montserrat',
          color: isDark == true ? Colors.white : Colors.black,
        )),
    cardColor: isDark == true ? const Color(0xFF111823) : Colors.white,
    tabBarTheme: TabBarThemeData(
      labelStyle: TextStyle(
          color: (isDark ?? true) ? Colors.white : themeColor.primary,
          fontFamily: 'Montserrat',
          fontSize: 12),
      unselectedLabelStyle: TextStyle(
        color: (isDark ?? true) ? maincolor.withOpacity(0.5) : Colors.black,
        fontFamily: 'Montserrat',
      ),
      unselectedLabelColor:
          (isDark ?? true) ? themeColor.primary.withOpacity(0.5) : Colors.black,
    ),
    scaffoldBackgroundColor:
        (isDark ?? true) ? themeColor.surface : const Color(0xFFF8F6F6),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        backgroundColor: WidgetStatePropertyAll(themeColor.primary),
      ),
    ),
  );

  // Cache the newly created theme
  _themeCache[isDark] = theme;

  // Return the newly created theme
  return theme;
}
