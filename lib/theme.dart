import 'package:flutter/material.dart';

/// Rachnakaar brand colors — burgundy + gold + ivory.
class RKColors {
  static const burgundy     = Color(0xFF7B1E2B);
  static const burgundyDark = Color(0xFF5C1620);
  static const gold         = Color(0xFFC8A24B);
  static const goldLight    = Color(0xFFE0C77E);
  static const ink          = Color(0xFF1A1A1A);
  static const text         = Color(0xFF3D3D3D);
  static const muted        = Color(0xFF6B6B6B);
  static const ivory        = Color(0xFFFAF7F2);
  static const champagne    = Color(0xFFF4ECE0);
  static const border       = Color(0xFFEAE5DD);
}

ThemeData buildRachnakaarTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: RKColors.burgundy,
      primary: RKColors.burgundy,
      secondary: RKColors.gold,
      surface: Colors.white,
      background: RKColors.ivory,
      onPrimary: Colors.white,
      onSecondary: RKColors.ink,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: RKColors.ivory,
    appBarTheme: const AppBarTheme(
      backgroundColor: RKColors.burgundy,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'serif',
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: 0.2,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: RKColors.burgundy,
      unselectedItemColor: RKColors.muted,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
      unselectedLabelStyle: TextStyle(fontSize: 11),
      elevation: 8,
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: RKColors.border, width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: RKColors.burgundy,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        elevation: 0,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontFamily: 'serif', fontSize: 32, fontWeight: FontWeight.w700, color: RKColors.ink, height: 1.1),
      headlineMedium: TextStyle(fontFamily: 'serif', fontSize: 22, fontWeight: FontWeight.w700, color: RKColors.ink, height: 1.2),
      titleLarge: TextStyle(fontFamily: 'serif', fontSize: 18, fontWeight: FontWeight.w600, color: RKColors.ink, height: 1.25),
      titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: RKColors.ink),
      bodyLarge: TextStyle(fontSize: 15, color: RKColors.text, height: 1.6),
      bodyMedium: TextStyle(fontSize: 14, color: RKColors.text, height: 1.5),
      bodySmall: TextStyle(fontSize: 12, color: RKColors.muted),
      labelLarge: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.12, color: RKColors.gold),
    ),
  );
}
