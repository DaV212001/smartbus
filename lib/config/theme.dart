import 'package:flutter/material.dart';

import '../constants/constants.dart';

ColorScheme appColor([bool? isDark]) => ColorScheme.fromSeed(
  seedColor: const Color(0xFF0B66B2),
  primary: const Color(0xFF0B66B2),
  onPrimary: Colors.white,
  secondary: const Color(0xFFEAF4FF),
  onSecondary: const Color(0xFF0B2A4A),
  surface: (isDark ?? false)
      ? const Color(0xFF010810)
      : const Color(0xFFF6FBFF),
  error: const Color(0xFFE03E3E),
  onError: Colors.white,
  brightness: isDark == null
      ? Brightness.light
      : isDark
      ? Brightness.dark
      : Brightness.light,
);

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
    fontFamily: 'Inter',
    useMaterial3: true,
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: isDark == true ? Colors.white : Colors.black,
      ),
      headlineMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isDark == true ? Colors.white : Colors.black,
      ),
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: isDark == true ? Colors.white : Colors.black,
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: isDark == true ? Colors.white : Colors.black,
      ),
      bodyLarge: TextStyle(
        fontSize: 14,
        color: isDark == true ? Colors.white : Colors.black,
      ),
      bodyMedium: TextStyle(
        fontSize: 12,
        color: isDark == true ? Colors.white70 : Colors.black87,
      ),
      bodySmall: TextStyle(
        fontSize: 11,
        color: isDark == true ? Colors.white54 : Colors.grey[600],
      ),
    ),
    appBarTheme: AppBarTheme(
      color: isDark == true ? themeColor.secondary : null,
      titleTextStyle: TextStyle(
        fontSize: 16,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w600,
        color: isDark == true ? Colors.white : Colors.black,
      ),
    ),
    cardColor: isDark == true ? const Color(0xFF111823) : Color(0xFFF6FBFF),
    tabBarTheme: TabBarThemeData(
      labelStyle: TextStyle(
        color: (isDark ?? true) ? Colors.white : themeColor.primary,
        fontFamily: 'Inter',
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        color: (isDark ?? true) ? maincolor.withOpacity(0.5) : Colors.black,
        fontFamily: 'Inter',
        fontSize: 11,
      ),
      unselectedLabelColor: (isDark ?? true)
          ? themeColor.primary.withOpacity(0.5)
          : Colors.black,
    ),
    scaffoldBackgroundColor: (isDark ?? false)
        ? themeColor.surface
        : const Color(0xFFF6FBFF),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        textStyle: const WidgetStatePropertyAll(
          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        ),
        backgroundColor: WidgetStatePropertyAll(themeColor.primary),
        foregroundColor: const WidgetStatePropertyAll(Colors.white),
      ),
    ),
    dividerColor: const Color(0x10000014),
    cardTheme: CardThemeData(
      color: (isDark ?? false) ? const Color(0xFF111823) : Color(0xFFF6FBFF),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: (isDark ?? false)
              ? Colors.white.withOpacity(0.1)
              : const Color(0x14000000),
        ),
      ),
    ),
  );

  // Cache the newly created theme
  _themeCache[isDark] = theme;

  // Return the newly created theme
  return theme;
}
