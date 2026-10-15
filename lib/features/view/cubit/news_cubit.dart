import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/news_model.dart';
import '../../data/services/local_news_service.dart';
import '../../data/services/news_api.dart';
import '../states/news_state.dart';

class NewsCubit extends Cubit<NewsState> {
  NewsCubit({NewsApi? newsApi, LocalNewsService? localNewsService})
    : _newsApi = newsApi ?? NewsApi(),
      _localNewsService = localNewsService ?? LocalNewsService(),
      super(const NewsState());

  final NewsApi _newsApi;
  final LocalNewsService _localNewsService;

  int _requestId = 0;

  // =========================
  // Language
  // =========================

  void setLanguage(String languageCode) {
    _newsApi.setLanguage(languageCode);
  }

  // =========================
  // Load News
  // =========================

  Future<void> loadNews() async {
    final requestId = ++_requestId;

    emit(
      state.copyWith(
        status: NewsStatus.loading,
        isLoadingMore: false,
        hasMore: true,
        isOffline: false,
        clearError: true,
      ),
    );

    try {
      final articles = await _fetchNews(loadMore: false);

      if (isClosed || requestId != _requestId) return;

      final uniqueArticles = _removeDuplicates(articles);

      emit(
        state.copyWith(
          status: NewsStatus.success,
          news: uniqueArticles,
          hasMore: _newsApi.hasMore,
          isLoadingMore: false,
          isOffline: false,
          clearError: true,
        ),
      );

      if (uniqueArticles.isNotEmpty) {
        try {
          await _localNewsService.saveNews(uniqueArticles);

          final savedTime = _localNewsService.getLastSavedTime();

          if (!isClosed && requestId == _requestId) {
            emit(state.copyWith(lastSavedTime: savedTime));
          }
        } catch (error) {
          debugPrint('Failed to save cached news: $error');
        }
      }
    } catch (error) {
      if (isClosed || requestId != _requestId) return;

      debugPrint('News loading error: $error');

      List<NewsModel> cachedArticles = [];
      DateTime? savedTime;

      try {
        cachedArticles = _localNewsService.getCachedNews();
        savedTime = _localNewsService.getLastSavedTime();
      } catch (cacheError) {
        debugPrint('Local cache error: $cacheError');
      }

      if (isClosed || requestId != _requestId) return;

      if (cachedArticles.isNotEmpty) {
        emit(
          state.copyWith(
            status: NewsStatus.success,
            news: _removeDuplicates(cachedArticles),
            hasMore: false,
            isLoadingMore: false,
            isOffline: true,
            error: error,
            lastSavedTime: savedTime,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: NewsStatus.failure,
            news: [],
            hasMore: false,
            isLoadingMore: false,
            isOffline: false,
            error: error,
          ),
        );
      }
    }
  }

  // =========================
  // Fetch News
  // =========================

  Future<List<NewsModel>> _fetchNews({required bool loadMore}) {
    if (state.isSearching && state.searchQuery.trim().isNotEmpty) {
      return _newsApi.searchNews(state.searchQuery.trim(), loadMore: loadMore);
    }

    if (state.selectedCategory == 'general') {
      return _newsApi.getTopHeadlines(loadMore: loadMore);
    }

    return _newsApi.getCategoryNews(state.selectedCategory, loadMore: loadMore);
  }

  // =========================
  // Load More News
  // =========================

  Future<void> loadMoreNews() async {
    if (isClosed ||
        state.isLoading ||
        state.isLoadingMore ||
        state.hasError ||
        state.isOffline ||
        !state.hasMore ||
        !_newsApi.hasMore ||
        state.news.isEmpty) {
      return;
    }

    final requestId = _requestId;

    emit(state.copyWith(isLoadingMore: true, clearError: true));

    try {
      final articles = await _fetchNews(loadMore: true);

      if (isClosed || requestId != _requestId) return;

      final updatedNews = _removeDuplicates([...state.news, ...articles]);

      emit(
        state.copyWith(
          status: NewsStatus.success,
          news: updatedNews,
          hasMore: _newsApi.hasMore,
          isLoadingMore: false,
          clearError: true,
        ),
      );

      if (updatedNews.isNotEmpty) {
        try {
          await _localNewsService.saveNews(updatedNews);

          final savedTime = _localNewsService.getLastSavedTime();

          if (!isClosed && requestId == _requestId) {
            emit(state.copyWith(lastSavedTime: savedTime));
          }
        } catch (error) {
          debugPrint('Failed to save cached news: $error');
        }
      }
    } catch (error) {
      if (isClosed || requestId != _requestId) return;

      emit(state.copyWith(isLoadingMore: false, error: error));

      debugPrint('Loading more news error: $error');
    }
  }

  // =========================
  // Change Category
  // =========================

  void changeCategory(String category) {
    if (category == state.selectedCategory && !state.isSearching) {
      return;
    }

    emit(
      state.copyWith(
        selectedCategory: category,
        searchQuery: '',
        isSearching: false,
        clearError: true,
      ),
    );

    loadNews();
  }

  // =========================
  // Search News
  // =========================

  void searchNews(String query) {
    final trimmedQuery = query.trim();

    if (trimmedQuery.isEmpty) {
      clearSearch();
      return;
    }

    emit(
      state.copyWith(
        searchQuery: trimmedQuery,
        isSearching: true,
        clearError: true,
      ),
    );

    loadNews();
  }

  // =========================
  // Clear Search
  // =========================

  void clearSearch() {
    emit(
      state.copyWith(
        searchQuery: '',
        isSearching: false,
        selectedCategory: 'general',
        clearError: true,
      ),
    );

    loadNews();
  }

  // =========================
  // Refresh News
  // =========================

  Future<void> refreshNews() async {
    await loadNews();
  }

  // =========================
  // Retry
  // =========================

  Future<void> retry() async {
    await loadNews();
  }

  // =========================
  // Remove Duplicates
  // =========================

  List<NewsModel> _removeDuplicates(List<NewsModel> articles) {
    final seen = <String>{};
    final uniqueArticles = <NewsModel>[];

    for (final article in articles) {
      final key = article.url.trim().isNotEmpty
          ? article.url.trim()
          : article.title.trim();

      if (key.isNotEmpty && seen.add(key)) {
        uniqueArticles.add(article);
      }
    }

    return uniqueArticles;
  }
}
