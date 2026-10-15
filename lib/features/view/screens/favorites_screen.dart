import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:news_app/features/view/cubit/favorites_cubit.dart';
import 'package:news_app/features/view/states/favorites_state.dart';
import 'package:news_app/features/view/widgit/news_card_widgit.dart';
import 'package:news_app/features/view/widgit/news_skeleton.dart';

import '../../../core/routes/routes_app.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class FavoritesScreen extends StatelessWidget {
const FavoritesScreen({super.key});

@override
Widget build(BuildContext context) {
final localization = AppLocalizations.of(context)!;
final theme = Theme.of(context);

return Scaffold(
  backgroundColor: theme.scaffoldBackgroundColor,
  appBar: AppBar(
    title: Text(
      localization.favorites,
      style: const TextStyle(fontWeight: FontWeight.bold),
    ),
    centerTitle: false,
  ),
  body: BlocBuilder<FavoritesCubit, FavoritesState>(
    builder: (context, state) {
      if (state.status == FavoritesStatus.initial ||
          state.status == FavoritesStatus.loading) {
        return const NewsSkeleton();
      }

      if (state.hasError) {
        return _buildErrorState(context);
      }

      final newsList = state.favorites;

      if (newsList.isEmpty) {
        return _buildEmptyState(context);
      }

      return RefreshIndicator(
        color: AppTheme.primaryColor,
        onRefresh: () {
          return context.read<FavoritesCubit>().refreshFavorites();
        },
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
          itemCount: newsList.length,
          itemBuilder: (context, index) {
            final article = newsList[index];

            return NewsCard(
              key: ValueKey(article.url),
              news: article,
              onTap: () async {
                await Navigator.pushNamed(
                  context,
                  RoutesApp.details,
                  arguments: article,
                );

                if (!context.mounted) return;

                await context.read<FavoritesCubit>().loadFavorites();
              },
              onFavoriteChanged: () {
                context.read<FavoritesCubit>().loadFavorites();
              },
            );
          },
        ),
      );
    },
  ),
);

}

// Empty favorites state.
Widget _buildEmptyState(BuildContext context) {
final localization = AppLocalizations.of(context)!;
final colors = Theme.of(context).colorScheme;

return RefreshIndicator(
  color: AppTheme.primaryColor,
  onRefresh: () {
    return context.read<FavoritesCubit>().refreshFavorites();
  },
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
Widget _buildErrorState(BuildContext context) {
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
          onPressed: () {
            context.read<FavoritesCubit>().loadFavorites();
          },
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
