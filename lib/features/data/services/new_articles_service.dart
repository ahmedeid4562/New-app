import 'package:hive_ce_flutter/hive_flutter.dart';

import '../models/news_model.dart';

class NewArticlesService {
  NewArticlesService._();

  static final NewArticlesService instance = NewArticlesService._();

  static const String _boxName = 'new_articles';
  static const String _seenArticlesKey = 'seen_articles';
  static const int _maxStoredArticles = 2000;

  Box<dynamic> get _box => Hive.box<dynamic>(_boxName);

  String _getArticleId(NewsModel article) {
    final url = article.url.trim();

    if (url.isNotEmpty) {
      return url;
    }

    return '${article.title.trim()}_${article.publishedAt.trim()}';
  }

  Future<List<NewsModel>> findNewArticles(List<NewsModel> articles) async {
    final storedArticles = _box.get(_seenArticlesKey);

    final seenArticles = <String>{
      if (storedArticles is List) ...storedArticles.whereType<String>(),
    };

    final newArticles = <NewsModel>[];

    for (final article in articles) {
      final id = _getArticleId(article);

      if (id == '_' || id.trim().isEmpty) {
        continue;
      }

      if (seenArticles.add(id)) {
        newArticles.add(article);
      }
    }

    final idsToStore = seenArticles.toList();

    if (idsToStore.length > _maxStoredArticles) {
      idsToStore.removeRange(0, idsToStore.length - _maxStoredArticles);
    }

    await _box.put(_seenArticlesKey, idsToStore);

    return newArticles;
  }

  Future<void> initializeKnownArticles(List<NewsModel> articles) async {
    final storedArticles = _box.get(_seenArticlesKey);

    if (storedArticles is List && storedArticles.isNotEmpty) {
      return;
    }

    final ids = articles
        .map(_getArticleId)
        .where((id) => id.trim().isNotEmpty && id != '_')
        .toSet()
        .toList();

    final initialIds = ids.length > _maxStoredArticles
        ? ids.sublist(ids.length - _maxStoredArticles)
        : ids;

    await _box.put(_seenArticlesKey, initialIds);
  }
}
