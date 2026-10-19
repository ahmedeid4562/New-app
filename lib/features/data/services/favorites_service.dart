import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/news_model.dart';

class FavoritesService {
static const String _key = 'favorites';

Future<List<NewsModel>> getFavorites() async {
final prefs = await SharedPreferences.getInstance();
final savedNews = prefs.getStringList(_key) ?? [];

return savedNews.map((item) {
  return NewsModel.fromSavedJson(
    jsonDecode(item) as Map<String, dynamic>,
  );
}).toList();

}

Future<void> addFavorite(NewsModel news) async {
final prefs = await SharedPreferences.getInstance();

final savedNews = prefs.getStringList(_key) ?? [];

final alreadyExists = savedNews.any((item) {
  try {
    final json = jsonDecode(item) as Map<String, dynamic>;
    return json['url'] == news.url;
  } catch (_) {
    return false;
  }
});

if (alreadyExists) return;

savedNews.add(jsonEncode(news.toJson()));

await prefs.setStringList(_key, savedNews);

}

Future<void> removeFavorite(String url) async {
final prefs = await SharedPreferences.getInstance();

final savedNews = prefs.getStringList(_key) ?? [];

savedNews.removeWhere((item) {
  try {
    final json = jsonDecode(item) as Map<String, dynamic>;
    return json['url'] == url;
  } catch (_) {
    return false;
  }
});

await prefs.setStringList(_key, savedNews);

}

Future<bool> isFavorite(String url) async {
final prefs = await SharedPreferences.getInstance();

final savedNews = prefs.getStringList(_key) ?? [];

return savedNews.any((item) {
  try {
    final json = jsonDecode(item) as Map<String, dynamic>;
    return json['url'] == url;
  } catch (_) {
    return false;
  }
});

}
}
