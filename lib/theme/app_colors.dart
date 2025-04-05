import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF0277BD);
  static const Color primaryLight = Color(0xFF58A5F0);
  static const Color primaryDark = Color(0xFF004C8C);

  // Secondary colors (renamed from Accent to follow Material 3 naming)
  static const Color secondary = Color(0xFF26A69A);
  static const Color secondaryLight = Color(0xFF64D8CB);
  static const Color secondaryDark = Color(0xFF00766C);

  // Background colors
  static const Color background = Color(0xFFF5F7FA);
  static const Color backgroundWhite = Colors.white;
  static const Color surfaceVariant = Color(0xFFEEF2F6);
  static const Color card = Colors.white;

  // Text colors
  static const Color textDark = Color(0xFF263238);
  static const Color textMedium = Color(0xFF546E7A);
  static const Color textLight = Color(0xFF78909C);
  static const Color textSecondary = Color(
    0xFF757575,
  ); // Used in TextField icons

  // Utility colors
  static const Color error = Color(0xFFD32F2F);
  static const Color errorLight = Color(0xFFFDE7E0);
  static const Color success = Color(0xFF388E3C);
  static const Color successLight = Color(0xFFDFF6DD);
  static const Color warning = Color(0xFFFFA000);
  static const Color warningLight = Color(0xFFFFF4CE);
  static const Color info = Color(0xFF1976D2);

  // Border & divider
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEEEEEE);
  static const Color lightGrey = Color(
    0xFFF5F5F5,
  ); // Used for disabled TextField

  // Specialized colors for fishing app
  static const Color water = Color(0xFF64B5F6);
  static const Color waterDark = Color(0xFF0D47A1);
  static const Color land = Color(0xFF8BC34A);
  static const Color bait = Color(0xFFFFB74D);
  static const Color fish = Color(0xFF81D4FA);
  static const Color equipment = Color(0xFF90A4AE);

  // Button states
  static const Color buttonDisabled = Color(0xFFBDBDBD);
  static const Color buttonPressed = Color(0xFF01579B);
  static const Color buttonHover = Color(0xFF0288D1);

  // Overlay and shadow
  static const Color shadow = Color.fromRGBO(0, 0, 0, 0.1);
  static const Color overlay = Color.fromRGBO(0, 0, 0, 0.5);

  static const Color maritimeBoundaryColor = Color.fromARGB(255, 182, 6, 6);

  // Chart colors
  static const List<Color> chartColors = [
    Color(0xFF0277BD),
    Color(0xFF26A69A),
    Color(0xFF8BC34A),
    Color(0xFFFFA000),
    Color(0xFFF44336),
    Color(0xFF9C27B0),
  ];
}
