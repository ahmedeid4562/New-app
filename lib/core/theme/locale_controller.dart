import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends ChangeNotifier {
  static const String _localeKey = 'app_locale';

  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  bool get isArabic => _locale.languageCode == 'ar';

  Future<void> loadLocale() async {
    final preferences = await SharedPreferences.getInstance();
    final languageCode = preferences.getString(_localeKey);

    if (languageCode == 'ar' || languageCode == 'en') {
      _locale = Locale(languageCode!);
    }

    notifyListeners();
  }

  Future<void> changeLocale(String languageCode) async {
    if (languageCode != 'ar' && languageCode != 'en') {
      return;
    }

    if (_locale.languageCode == languageCode) {
      return;
    }

    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(_localeKey, languageCode);

    _locale = Locale(languageCode);

    notifyListeners();
  }
}