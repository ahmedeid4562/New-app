import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/news_model.dart';

class FavoritesService {
  static const String _key = 'favorites';

  Future<List<NewsModel>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();

    final savedNews = prefs.getStringList(_key) ?? [];

    return savedNews
        .map(
          (item) => NewsModel.fromSavedJson(
            jsonDecode(item),
          ),
        )
        .toList();
  }

  Future<void> addFavorite(NewsModel news) async {
    final prefs = await SharedPreferences.getInstance();

    final favorites = await getFavorites();

    if (favorites.any((item) => item.url == news.url)) {
      return;
    }

    favorites.add(news);

    final data = favorites
        .map((item) => jsonEncode(item.toJson()))
        .toList();

    await prefs.setStringList(_key, data);
  }

  Future<void> removeFavorite(String url) async {
    final prefs = await SharedPreferences.getInstance();

    final favorites = await getFavorites();

    favorites.removeWhere(
      (item) => item.url == url,
    );

    final data = favorites
        .map((item) => jsonEncode(item.toJson()))
        .toList();

    await prefs.setStringList(_key, data);
  }

  Future<bool> isFavorite(String url) async {
    final favorites = await getFavorites();

    return favorites.any(
      (item) => item.url == url,
    );
  }
}
