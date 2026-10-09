import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:news_app/features/data/models/news_model.dart';
import 'package:news_app/features/data/services/favorites_service.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class NewsCard extends StatefulWidget {
  const NewsCard({
    super.key,
    required this.news,
    required this.onTap,
    this.onFavoriteChanged,
  });

  final NewsModel news;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteChanged;

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> {
  final FavoritesService favoritesService = FavoritesService();

  bool isFavorite = false;
  bool isLoadingFavorite = false;

  @override
  void initState() {
    super.initState();
    checkFavorite();
  }

  Future<void> checkFavorite() async {
    try {
      final result = await favoritesService.isFavorite(
        widget.news.url,
      );

      if (!mounted) return;

      setState(() {
        isFavorite = result;
      });
    } catch (error) {
      debugPrint('Failed to check favorite: $error');
    }
  }

  Future<void> toggleFavorite() async {
    if (isLoadingFavorite) return;

    setState(() {
      isLoadingFavorite = true;
    });

    try {
      if (isFavorite) {
        await favoritesService.removeFavorite(
          widget.news.url,
        );
      } else {
        await favoritesService.addFavorite(
          widget.news,
        );
      }

      if (!mounted) return;

      setState(() {
        isFavorite = !isFavorite;
        isLoadingFavorite = false;
      });

      widget.onFavoriteChanged?.call();

      final localizations = AppLocalizations.of(context)!;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFavorite
                ? localizations.addedToFavorites
                : localizations.removedFromFavorites,
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (error) {
      debugPrint('Failed to update favorite: $error');

      if (!mounted) return;

      setState(() {
        isLoadingFavorite = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.somethingWentWrong,
          ),
        ),
      );
    }
  }

  String formatDate(String date) {
    try {
      final parsedDate = DateTime.parse(date).toLocal();

      final locale = Localizations.localeOf(context).toString();

      return DateFormat(
        'd MMM yyyy • h:mm a',
        locale,
      ).format(parsedDate);
    } catch (_) {
      return date;
    }
  }

  Widget buildPlaceholder() {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final localizations = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      height: 200,
      color: isDark
          ? const Color(0xFF252936)
          : const Color(0xFFECEFF4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.newspaper_rounded,
            color: isDark
                ? Colors.white38
                : Colors.blueGrey.shade300,
            size: 55,
          ),
          const SizedBox(height: 10),
          Text(
            localizations.imageUnavailable,
            style: TextStyle(
              color: isDark
                  ? Colors.white60
                  : Colors.blueGrey.shade500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNewsImage() {
    final imageUrl = widget.news.imageUrl.trim();

    final uri = Uri.tryParse(imageUrl);

    if (imageUrl.isEmpty ||
        uri == null ||
        !uri.hasAuthority ||
        uri.host.isEmpty ||
        (uri.scheme != 'https' && uri.scheme != 'http')) {
      return buildPlaceholder();
    }

    return Image.network(
      imageUrl,
      width: double.infinity,
      height: 200,
      fit: BoxFit.cover,
      gaplessPlayback: true,

      loadingBuilder: (
        context,
        child,
        loadingProgress,
      ) {
        if (loadingProgress == null) {
          return child;
        }

        return Container(
          width: double.infinity,
          height: 200,
          color: Theme.of(context).cardColor,
          alignment: Alignment.center,
          child: const CircularProgressIndicator(
            color: AppTheme.primaryColor,
            strokeWidth: 2,
          ),
        );
      },

      errorBuilder: (
        context,
        error,
        stackTrace,
      ) {
        debugPrint(
          'Failed to load news image: $imageUrl',
        );

        debugPrint('Image error: $error');

        return buildPlaceholder();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    final Color textColor =
        Theme.of(context).colorScheme.onSurface;

    final Color secondaryTextColor =
        isDark
            ? Colors.grey.shade400
            : Colors.grey.shade700;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: isDark ? 0.20 : 0.08,
              ),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: buildNewsImage(),
                ),

                Positioned(
                  top: 12,
                  right: 12,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: toggleFavorite,
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(
                            alpha: 0.65,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: isLoadingFavorite
                            ? const Padding(
                                padding: EdgeInsets.all(13),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isFavorite
                                    ? Colors.red
                                    : Colors.white,
                                size: 25,
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.public,
                        color: AppTheme.primaryColor,
                        size: 16,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          widget.news.sourceName.isNotEmpty
                              ? widget.news.sourceName
                              : localizations.unknownSource,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    widget.news.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),

                  if (widget.news.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.news.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      if (widget.news.author.isNotEmpty) ...[
                        Icon(
                          Icons.person_outline,
                          color: secondaryTextColor,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.news.author,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],

                      if (widget.news.publishedAt.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.access_time,
                          color: secondaryTextColor,
                          size: 15,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            formatDate(
                              widget.news.publishedAt,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
