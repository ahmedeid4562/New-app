import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
static const String _themeKey = 'isDarkMode';

bool _isDarkMode = true;

bool get isDarkMode => _isDarkMode;

ThemeMode get themeMode =>
_isDarkMode ? ThemeMode.dark : ThemeMode.light;

Future<void> loadTheme() async {
final prefs = await SharedPreferences.getInstance();

_isDarkMode = prefs.getBool(_themeKey) ?? true;

notifyListeners();

}

Future<void> toggleTheme(bool value) async {
_isDarkMode = value;

notifyListeners();

final prefs = await SharedPreferences.getInstance();
await prefs.setBool(_themeKey, value);

}
}
