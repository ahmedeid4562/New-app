import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/news_model.dart';
import '../../data/services/favorites_service.dart';
import '../states/favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
FavoritesCubit({
FavoritesService? favoritesService,
})  : _favoritesService = favoritesService ?? FavoritesService(),
super(const FavoritesState());

final FavoritesService _favoritesService;

int _requestId = 0;

Future<void> loadFavorites() async {
final requestId = ++_requestId;

emit(
  state.copyWith(
    status: FavoritesStatus.loading,
    clearError: true,
  ),
);

try {
  final favorites = await _favoritesService.getFavorites();

  if (isClosed || requestId != _requestId) return;

  emit(
    state.copyWith(
      status: FavoritesStatus.success,
      favorites: favorites,
      clearError: true,
    ),
  );
} catch (error, stackTrace) {
  if (isClosed || requestId != _requestId) return;

  debugPrint('Failed to load favorites: $error');
  debugPrintStack(stackTrace: stackTrace);

  emit(
    state.copyWith(
      status: FavoritesStatus.failure,
      error: error,
    ),
  );
}

}

Future<void> refreshFavorites() async {
await loadFavorites();
}

Future<void> addFavorite(NewsModel news) async {
try {
await _favoritesService.addFavorite(news);

  if (isClosed) return;

  await loadFavorites();
} catch (error, stackTrace) {
  if (isClosed) return;

  debugPrint('Failed to add favorite: $error');
  debugPrintStack(stackTrace: stackTrace);

  emit(
    state.copyWith(
      status: FavoritesStatus.failure,
      error: error,
    ),
  );

  rethrow;
}

}

Future<void> removeFavorite(String url) async {
try {
await _favoritesService.removeFavorite(url);

  if (isClosed) return;

  await loadFavorites();
} catch (error, stackTrace) {
  if (isClosed) return;

  debugPrint('Failed to remove favorite: $error');
  debugPrintStack(stackTrace: stackTrace);

  emit(
    state.copyWith(
      status: FavoritesStatus.failure,
      error: error,
    ),
  );

  rethrow;
}

}

Future<bool> isFavorite(String url) {
return _favoritesService.isFavorite(url);
}
}
