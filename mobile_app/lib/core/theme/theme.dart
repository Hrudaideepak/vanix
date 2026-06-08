import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Color Palette
  static const Color deepBlack = Color(0xFF000000);
  static const Color cardGrey = Color(0xFF0A0A0A);
  static const Color royalPurple = Color(0xFFFF0000); // Primary Red Accent
  static const Color electricBlue = Color(0xFFCC0000); // Secondary Red Accent
  static const Color softWhite = Color(0xFFFFFFFF);
  static const Color silverAccent = Color(0xFFE5E2E1); // on-surface
  static const Color errorRed = Color(0xFFFFB4AB);

  // Gradient Colors
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [royalPurple, electricBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [
      deepBlack,
      cardGrey,
      deepBlack,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Playful dynamic gradient for Kids Mode space (retains cyberpunk contrast)
  static const LinearGradient kidsBackgroundGradient = LinearGradient(
    colors: [
      Color(0xFF0A0714), // Deep indigo-black
      deepBlack,
      Color(0xFF050A1A), // Deep navy-black
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: deepBlack,
      primaryColor: royalPurple,
      colorScheme: const ColorScheme.dark(
        primary: royalPurple,
        secondary: electricBlue,
        surface: cardGrey,
        error: errorRed,
        onPrimary: deepBlack,
        onSecondary: softWhite,
        onSurface: silverAccent,
      ),
      fontFamily: 'SpaceGrotesk',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: softWhite,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'SpaceGrotesk',
        ),
        iconTheme: IconThemeData(color: softWhite),
      ),
      cardTheme: const CardThemeData(
        color: cardGrey,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, // strictly sharp corners (0px)
          side: BorderSide(
            color: Color(0x33FF0000), // rgba(255, 0, 0, 0.2)
            width: 1,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: softWhite.withValues(alpha: 0.05),
        hintStyle: TextStyle(color: silverAccent.withValues(alpha: 0.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: Color(0x33FF0000), width: 1),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: royalPurple, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: errorRed, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: softWhite,
          shadowColor: royalPurple.withValues(alpha: 0.3),
          elevation: 8,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'SpaceGrotesk',
          ),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: softWhite, fontSize: 32, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: softWhite, fontSize: 28, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: softWhite, fontSize: 22, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: softWhite, fontSize: 18, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: silverAccent, fontSize: 16),
        bodyMedium: TextStyle(color: silverAccent, fontSize: 14),
        labelLarge: TextStyle(color: softWhite, fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Fallback light theme, matching our elegance
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF1F5F9),
      primaryColor: royalPurple,
      colorScheme: const ColorScheme.light(
        primary: royalPurple,
        secondary: electricBlue,
        surface: Colors.white,
        error: errorRed,
      ),
      fontFamily: 'SpaceGrotesk',
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: deepBlack, fontSize: 32, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: deepBlack, fontSize: 22, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: deepBlack, fontSize: 16),
        bodyMedium: TextStyle(color: deepBlack, fontSize: 14),
      ),
    );
  }

  // Custom Glassmorphism Box Decoration helper
  static BoxDecoration glassDecoration({
    required BuildContext context,
    double blur = 12.0,
    double opacity = 0.8,
    double borderRadius = 0.0,
    Color? color,
  }) {
    return BoxDecoration(
      color: (color ?? cardGrey).withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: const Color(0x33FF0000), // rgba(255, 0, 0, 0.2)
        width: 1.0,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 10,
          spreadRadius: -2,
        ),
      ],
    );
  }
}
