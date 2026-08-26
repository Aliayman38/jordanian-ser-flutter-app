import 'package:flutter/material.dart';

class AppTheme {
  // Brand palette - Modern Jordanian Emerald, Jade, Warm Amber & Jewel Tones
  static const Color primary = Color(0xFF006D5B); // Emerald Teal
  static const Color primaryLight = Color(0xFF0A8754); // Rich Jade
  static const Color primaryDark = Color(0xFF004D40); // Deep Teal
  static const Color primaryContainer = Color(0xFFE6F4F1);
  
  static const Color accent = Color(0xFFFFB703); // Warm Jordanian Amber
  static const Color accentLight = Color(0xFFFFD166);
  static const Color accentOrange = Color(0xFFFB8500); // Sunset Orange
  
  static const Color coralRed = Color(0xFFE63946);
  static const Color royalIndigo = Color(0xFF3F51B5);
  static const Color softSlate = Color(0xFF607771);

  static const Color background = Color(0xFFF6FAF8);
  static const Color surface = Colors.white;
  static const Color surfaceElevated = Color(0xFFFAFCFB);
  
  static const Color textDark = Color(0xFF102A24);
  static const Color textMuted = Color(0xFF536E67);
  static const Color textLight = Color(0xFF8BA6A0);
  
  static const Color borderLight = Color(0xFFE2EBE8);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [Color(0xFF006D5B), Color(0xFF064E41)],
  );

  static const LinearGradient amberGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFB703), Color(0xFFFB8500)],
  );

  // Card & Ambient Shadows
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0xFF102A24).withOpacity(0.06),
          blurRadius: 20,
          offset: const Offset(0, 8),
          spreadRadius: -2,
        ),
        BoxShadow(
          color: const Color(0xFF102A24).withOpacity(0.03),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> glowShadow(Color color, {double opacity = 0.35, double blur = 22}) => [
        BoxShadow(
          color: color.withOpacity(opacity),
          blurRadius: blur,
          offset: const Offset(0, 8),
        ),
      ];

  static BoxDecoration glassDecoration({
    Color? color,
    BorderRadius? borderRadius,
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: color ?? surface.withOpacity(0.85),
      borderRadius: borderRadius ?? BorderRadius.circular(24),
      border: Border.all(
        color: borderColor ?? Colors.white.withOpacity(0.4),
        width: 1.5,
      ),
      boxShadow: cardShadow,
    );
  }

  static ThemeData get theme {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: primaryLight,
        tertiary: accent,
        surface: surface,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: background,
      fontFamilyFallback: const ['Noto Sans Arabic', 'Roboto', 'Arial', 'sans-serif'],
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textDark,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textDark,
        ),
      ),
      cardTheme: CardTheme(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: borderLight, width: 1.2),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: surface,
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 3,
          shadowColor: primary.withOpacity(0.4),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
