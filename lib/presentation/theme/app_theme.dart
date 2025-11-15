// lib/presentation/theme/app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  // Warna utama biru lu
  static const Color _primaryColor = Color(0xFF3A86FF);
  // Font utama lu
  static const String _fontFamily = 'Poppins';

  // ==================
  // PALET LIGHT MODE
  // ==================
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true, // Kita pake Material 3 biar lebih modern
    brightness: Brightness.light,
    fontFamily: _fontFamily,
    primaryColor: _primaryColor,
    scaffoldBackgroundColor: Colors.grey.shade100, // Background abu-abu
    cardColor: Colors.white, // Warna kartu
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white, // Appbar putih
      foregroundColor: Colors.black87, // Ikon & Teks appbar hitam
      elevation: 1,
      shadowColor: Colors.grey.shade200,
      titleTextStyle: const TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
        fontSize: 20,
      ),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: Brightness.light,
      background: Colors.grey.shade100, // Background utama
      surface: Colors.white, // Warna kartu/container
      onSurface: Colors.black87, // Warna teks utama
    ),
    textTheme: const TextTheme(
      // Buat judul seksi
      titleSmall: TextStyle(
          fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600),
      // Buat judul item
      titleMedium: TextStyle(fontWeight: FontWeight.w500),
    ),
  );

  // ==================
  // PALET DARK MODE
  // ==================
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: _fontFamily,
    primaryColor: _primaryColor,
    scaffoldBackgroundColor: const Color(0xFF121212), // Background gelap
    cardColor: const Color(0xFF1E1E1E), // Warna kartu
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF1E1E1E), // Appbar gelap
      foregroundColor: Colors.white, // Ikon & Teks appbar putih
      elevation: 0,
      titleTextStyle: const TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        fontSize: 20,
      ),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: Brightness.dark,
      background: const Color(0xFF121212), // Background utama
      surface: const Color(0xFF1E1E1E), // Warna kartu/container
      onSurface: Colors.white, // Warna teks utama
    ),
    textTheme: const TextTheme(
      titleSmall: TextStyle(
          fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(fontWeight: FontWeight.w500),
    ),
  );
}