import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF00695C);
  static const Color primaryLight = Color(0xFF26A69A);
  static const Color background = Color(0xFFF7F9F9);
  static const Color surface = Colors.white;
  static const Color textDark = Color(0xFF1B2B2A);
  static const Color textMuted = Color(0xFF6B7A79);

  static ThemeData get theme {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: primaryLight,
        surface: surface,
      ),
      scaffoldBackgroundColor: background,
      fontFamily: 'Tajawal',
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: textDark,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
