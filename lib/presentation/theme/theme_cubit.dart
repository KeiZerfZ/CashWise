// lib/presentation/theme/theme_cubit.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static const String _themeKey = 'app_theme_mode';

  ThemeCubit() : super(ThemeMode.system) {
    _loadTheme(); // Langsung load tema pas app nyala
  }

  void _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey);
      if (themeIndex != null) {
        emit(ThemeMode.values[themeIndex]);
      }
    } catch (e) {
      // Kalo ada error, biarin aja pake default system
      debugPrint("Error loading theme: $e");
    }
  }

  Future<void> toggleTheme(bool isDark) async {
    final newMode = isDark ? ThemeMode.dark : ThemeMode.light;
    emit(newMode);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, newMode.index);
    } catch (e) {
      debugPrint("Error saving theme: $e");
    }
  }

  Future<void> setSystemTheme() async {
    emit(ThemeMode.system);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_themeKey); // Hapus settingan, biar ngikutin sistem
    } catch (e) {
      debugPrint("Error setting system theme: $e");
    }
  }
}