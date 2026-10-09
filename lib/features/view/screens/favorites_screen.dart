import 'package:flutter/material.dart';
import 'package:news_app/features/data/models/news_model.dart';
import 'package:news_app/features/data/services/favorites_service.dart';
import 'package:news_app/features/view/widgit/news_card_widgit.dart';
import 'package:news_app/features/view/widgit/news_skeleton.dart';

import '../../../core/routes/routes_app.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class FavoritesScreen extends StatefulWidget {
const FavoritesScreen({super.key});

@override
State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
final FavoritesService favoritesService = FavoritesService();

late Future<List<NewsModel>> favorites;

@override
void initState() {
super.initState();
favorites = favoritesService.getFavorites();
}

// Reload favorites after adding or removing an article.
void refreshFavorites() {
if (!mounted) return;
setState(() {
  favorites = favoritesService.getFavorites();
});
}

// Refresh favorites when the user pulls down.
Future<void> refreshFavoritesList() async {
final newFuture = favoritesService.getFavorites();
setState(() {
  favorites = newFuture;
});

try {
  await newFuture;
} catch (_) {
  // FutureBuilder displays the error state.
}
}

@override
Widget build(BuildContext context) {
final localization = AppLocalizations.of(context)!;
final theme = Theme.of(context);
return Scaffold(
  backgroundColor: theme.scaffoldBackgroundColor,
  appBar: AppBar(
    title: Text(
      localization.favorites,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
    centerTitle: false,
  ),
  body: FutureBuilder<List<NewsModel>>(
    future: favorites,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const NewsSkeleton();
      }

      if (snapshot.hasError) {
        return buildErrorState();
      }

      final newsList = snapshot.data ?? [];

      if (newsList.isEmpty) {
        return buildEmptyState();
      }

      return RefreshIndicator(
        color: AppTheme.primaryColor,
        onRefresh: refreshFavoritesList,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
          itemCount: newsList.length,
          itemBuilder: (context, index) {
            final article = newsList[index];

            return NewsCard(
              news: article,
              onTap: () async {
                await Navigator.pushNamed(
                  context,
                  RoutesApp.details,
                  arguments: article,
                );

                refreshFavorites();
              },
              onFavoriteChanged: refreshFavorites,
            );
          },
        ),
      );
    },
  ),
);

}

// Empty favorites state.
Widget buildEmptyState() {
final localization = AppLocalizations.of(context)!;
final colors = Theme.of(context).colorScheme;

return RefreshIndicator(
  color: AppTheme.primaryColor,
  onRefresh: refreshFavoritesList,
  child: ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    children: [
      SizedBox(
        height: MediaQuery.of(context).size.height * 0.16,
      ),
      Center(
        child: Container(
          width: 125,
          height: 125,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.favorite_border_rounded,
            color: AppTheme.primaryColor,
            size: 70,
          ),
        ),
      ),
      const SizedBox(height: 26),
      Text(
        localization.noFavoritesYet,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: colors.onSurface,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 12),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 35),
        child: Text(
          localization.favoritesDescription,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colors.onSurfaceVariant,
            fontSize: 14,
            height: 1.8,
          ),
        ),
      ),
      const SizedBox(height: 28),
      Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.favorite_rounded,
                color: AppTheme.primaryColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                localization.tapHeartToSave,
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  ),
);
}

// Error state.
Widget buildErrorState() {
final localization = AppLocalizations.of(context)!;
final colors = Theme.of(context).colorScheme;

return Center(
  child: Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.error_outline_rounded,
            color: Colors.red,
            size: 55,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          localization.unableToLoadFavorites,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          localization.favoritesLoadError,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colors.onSurfaceVariant,
            fontSize: 14,
            height: 1.7,
          ),
        ),
        const SizedBox(height: 26),
        ElevatedButton.icon(
          onPressed: refreshFavorites,
          icon: const Icon(Icons.refresh_rounded),
          label: Text(localization.retry),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 13,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    ),
  ),
);

}
}
