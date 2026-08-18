import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

class ThemeNotifier extends Notifier<ThemeMode> {
  static const String _themeKey = 'theme_mode';
  late final SharedPreferences _prefs;
  @override
  ThemeMode build() {
    _prefs = ref.read(sharedPreferencesProvider);
    final savedTheme = _prefs.getString(_themeKey);
    if (savedTheme == 'dark') {
      return ThemeMode.dark;
    }
    return ThemeMode.system;
  }

  Future<void> toggleTheme() async {
    final newTheme = state == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    state = newTheme;
    await _prefs.setString(
      _themeKey,
      newTheme == ThemeMode.dark ? 'dark' : 'light',
    );
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);
