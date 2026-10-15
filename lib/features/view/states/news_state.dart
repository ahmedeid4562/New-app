import 'package:news_app/features/data/models/news_model.dart';

enum NewsStatus { initial, loading, success, failure }

class NewsState {
  final NewsStatus status;
  final List<NewsModel> news;
  final String selectedCategory;
  final String searchQuery;
  final bool isSearching;
  final bool isLoadingMore;
  final bool hasMore;
  final bool isOffline;
  final Object? error;
  final DateTime? lastSavedTime;

  const NewsState({
    this.status = NewsStatus.initial,
    this.news = const [],
    this.selectedCategory = 'general',
    this.searchQuery = '',
    this.isSearching = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.isOffline = false,
    this.error,
    this.lastSavedTime,
  });

  bool get isLoading => status == NewsStatus.loading;

  bool get hasError => status == NewsStatus.failure;

  NewsState copyWith({
    NewsStatus? status,
    List<NewsModel>? news,
    String? selectedCategory,
    String? searchQuery,
    bool? isSearching,
    bool? isLoadingMore,
    bool? hasMore,
    bool? isOffline,
    Object? error,
    bool clearError = false,
    DateTime? lastSavedTime,
  }) {
    return NewsState(
      status: status ?? this.status,
      news: news ?? this.news,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      isSearching: isSearching ?? this.isSearching,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      isOffline: isOffline ?? this.isOffline,
      error: clearError ? null : error ?? this.error,
      lastSavedTime: lastSavedTime ?? this.lastSavedTime,
    );
  }
}
