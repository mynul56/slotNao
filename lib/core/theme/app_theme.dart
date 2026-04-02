import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ─── Brand Colors ───────────────────────────────────────────────────
  static const Color primaryGreen = Color(0xFF00C853);
  static const Color primaryGreenDark = Color(0xFF00A844);
  static const Color primaryGreenLight = Color(0xFF69F0AE);
  static const Color accentAmber = Color(0xFFFFAB00);
  static const Color accentBlue = Color(0xFF0091EA);
  static const Color errorRed = Color(0xFFD32F2F);
  static const Color successGreen = Color(0xFF388E3C);
  static const Color warningOrange = Color(0xFFF57C00);

  // ─── Dark Palette ────────────────────────────────────────────────────
  static const Color dark900 = Color(0xFF0A0F0A);
  static const Color dark800 = Color(0xFF111811);
  static const Color dark700 = Color(0xFF1A221A);
  static const Color dark600 = Color(0xFF223022);
  static const Color dark500 = Color(0xFF2E3E2E);

  static const Color neutralGrey = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFE0E0E0);
  static const Color white = Color(0xFFFFFFFF);

  // ─── Dark Theme ───────────────────────────────────────────────────────
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Outfit',
    colorScheme: const ColorScheme.dark(
      primary: primaryGreen,
      primaryContainer: primaryGreenDark,
      secondary: accentAmber,
      secondaryContainer: Color(0xFF614A00),
      surface: dark800,
      error: errorRed,
      onPrimary: dark900,
      onSecondary: dark900,
      onSurface: white,
      outline: dark500,
    ),
    scaffoldBackgroundColor: dark900,
    appBarTheme: const AppBarTheme(
      backgroundColor: dark800,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Outfit',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: white,
        letterSpacing: 0.3,
      ),
      iconTheme: IconThemeData(color: white),
    ),
    cardTheme: CardThemeData(
      color: dark700,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: dark900,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontFamily: 'Outfit', fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.5),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryGreen,
        minimumSize: const Size(double.infinity, 52),
        side: const BorderSide(color: primaryGreen, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontFamily: 'Outfit', fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: dark700,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: dark500),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: dark500),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primaryGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: errorRed),
      ),
      labelStyle: const TextStyle(color: neutralGrey, fontFamily: 'Outfit'),
      hintStyle: TextStyle(color: neutralGrey.withValues(alpha: 0.7), fontFamily: 'Outfit'),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: dark600,
      selectedColor: primaryGreen.withValues(alpha: 0.2),
      labelStyle: const TextStyle(fontFamily: 'Outfit', color: white),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: dark800,
      selectedItemColor: primaryGreen,
      unselectedItemColor: neutralGrey,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    dividerTheme: const DividerThemeData(color: dark600, thickness: 1),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: primaryGreen),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: dark700,
      contentTextStyle: const TextStyle(color: white, fontFamily: 'Outfit'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
  );

  // ─── Light Theme ─────────────────────────────────────────────────────
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'Outfit',
    colorScheme: ColorScheme.light(
      primary: primaryGreen,
      primaryContainer: primaryGreenLight,
      secondary: accentAmber,
      surface: Colors.grey.shade50,
      error: errorRed,
      onPrimary: white,
      onSurface: const Color(0xFF1A1A1A),
    ),
    scaffoldBackgroundColor: Colors.grey.shade100,
    appBarTheme: const AppBarTheme(
      backgroundColor: white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(fontFamily: 'Outfit', fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
    ),
  );
}
