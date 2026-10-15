import 'package:news_app/features/data/models/news_model.dart';

enum FavoritesStatus {
  initial,
  loading,
  success,
  failure,
}

class FavoritesState {
  final FavoritesStatus status;
  final List<NewsModel> favorites;
  final Object? error;

  const FavoritesState({
    this.status = FavoritesStatus.initial,
    this.favorites = const [],
    this.error,
  });

  bool get isLoading => status == FavoritesStatus.loading;

  bool get hasError => status == FavoritesStatus.failure;

  bool get isEmpty => favorites.isEmpty;

  FavoritesState copyWith({
    FavoritesStatus? status,
    List<NewsModel>? favorites,
    Object? error,
    bool clearError = false,
  }) {
    return FavoritesState(
      status: status ?? this.status,
      favorites: favorites ?? this.favorites,
      error: clearError ? null : error ?? this.error,
    );
  }
}