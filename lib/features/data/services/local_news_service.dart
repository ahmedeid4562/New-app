import 'package:hive_ce_flutter/hive_flutter.dart';

import '../models/news_model.dart';

class LocalNewsService {
  static const String _boxName = 'cached_news';
  static const String _articlesKey = 'articles';
  static const String _savedAtKey = 'savedAt';

  Box<Map> get _newsBox => Hive.box<Map>(_boxName);

  Future<void> saveNews(List<NewsModel> news) async {
    if (news.isEmpty) return;

    final articles = news.map((article) => article.toJson()).toList();

    await _newsBox.put(_articlesKey, {
      'items': articles,
      _savedAtKey: DateTime.now().toIso8601String(),
    });
  }

  List<NewsModel> getCachedNews() {
    final cachedData = _newsBox.get(_articlesKey);

    if (cachedData == null) {
      return [];
    }

    final items = cachedData['items'];

    if (items is! List) {
      return [];
    }

    final cachedNews = <NewsModel>[];

    for (final item in items) {
      if (item is Map) {
        try {
          cachedNews.add(
            NewsModel.fromSavedJson(Map<String, dynamic>.from(item)),
          );
        } catch (error) {
          // Skip invalid cached articles.
        }
      }
    }

    return cachedNews;
  }

  DateTime? getLastSavedTime() {
    final cachedData = _newsBox.get(_articlesKey);
    final savedAt = cachedData?[_savedAtKey];

    if (savedAt is! String) {
      return null;
    }

    return DateTime.tryParse(savedAt);
  }

  Future<void> clearCache() async {
    await _newsBox.delete(_articlesKey);
  }
}
