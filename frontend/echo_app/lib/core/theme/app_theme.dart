import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF6C63FF),
      secondary: Color(0xFF00C2FF),
      surface: Color(0xFF1E1E2E),
    ),

    scaffoldBackgroundColor: const Color(0xFF0F0F1A),

    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF1E1E2E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide.none,
      ),
    ),
  );
}