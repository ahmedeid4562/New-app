import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

import 'package:news_app/features/data/models/news_model.dart';
import 'package:news_app/features/data/services/favorites_service.dart';
import 'package:news_app/features/data/services/reading_history_service.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({
    super.key,
    required this.news,
  });

  final NewsModel news;

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final FavoritesService favoritesService = FavoritesService();
  final ReadingHistoryService readingHistoryService =
      ReadingHistoryService();

  bool isFavorite = false;
  bool isLoadingFavorite = false;

  @override
  void initState() {
    super.initState();
    checkFavorite();
    saveToReadingHistory();
  }

  // Save news to reading history.
  Future<void> saveToReadingHistory() async {
    try {
      debugPrint('Starting to save news to history...');
      debugPrint('News URL: ${widget.news.url}');

      await readingHistoryService.addToHistory(widget.news);

      debugPrint('SUCCESS: News saved to reading history');
    } catch (e, stackTrace) {
      debugPrint('ERROR saving reading history: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  // Check if news is in favorites.
  Future<void> checkFavorite() async {
    try {
      final result = await favoritesService.isFavorite(
        widget.news.url,
      );

      if (!mounted) return;

      setState(() {
        isFavorite = result;
      });
    } catch (e) {
      debugPrint('Check favorite error: $e');
    }
  }

  // Add or remove favorite.
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
    } catch (e) {
      debugPrint('Toggle favorite error: $e');

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

  // Share news.
  Future<void> shareNews() async {
    final localizations = AppLocalizations.of(context)!;

    final String title = widget.news.title.trim();
    final String url = widget.news.url.trim();

    if (title.isEmpty && url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.noNewsInfoToShare),
        ),
      );
      return;
    }

    final String shareText = url.isEmpty ? title : '$title\n$url';

    try {
      await SharePlus.instance.share(
        ShareParams(
          text: shareText,
          subject: title.isEmpty ? localizations.newsDetails : title,
        ),
      );
    } catch (e) {
      debugPrint('Share error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localizations.sharingFailed,
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  // Format published date according to the current language.
  String formatDate(String date) {
    try {
      final parsedDate = DateTime.parse(date).toLocal();

      final locale = Localizations.localeOf(context).toString();

      return DateFormat('d MMM yyyy • h:mm a', locale)
          .format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  // Open the original article.
  Future<void> openArticle() async {
    final localizations = AppLocalizations.of(context)!;
    final String articleUrl = widget.news.url.trim();

    if (articleUrl.isEmpty) return;

    final Uri? url = Uri.tryParse(articleUrl);

    if (url == null ||
        (url.scheme != 'https' && url.scheme != 'http') ||
        url.host.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.invalidArticleLink),
        ),
      );

      return;
    }

    try {
      final launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.couldNotOpenArticle),
          ),
        );
      }
    } catch (e) {
      debugPrint('Open article error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.couldNotOpenArticle),
        ),
      );
    }
  }

  // Placeholder when the image is unavailable.
  Widget buildPlaceholder() {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      height: 230,
      color: Theme.of(context).cardColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            color: Colors.grey.shade500,
            size: 60,
          ),
          const SizedBox(height: 8),
          Text(
            localizations.noImage,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // News image.
  Widget buildNewsImage() {
    if (widget.news.imageUrl.isEmpty) {
      return buildPlaceholder();
    }

    return Image.network(
      widget.news.imageUrl,
      width: double.infinity,
      height: 230,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return buildPlaceholder();
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;

        return Container(
          width: double.infinity,
          height: 230,
          color: Theme.of(context).cardColor,
          child: const Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryColor,
              strokeWidth: 2,
            ),
          ),
        );
      },
    );
  }

  // Author and date information.
  Widget buildInfoRow({
    required IconData icon,
    required String text,
  }) {
    final secondaryTextColor =
        Theme.of(context).brightness == Brightness.dark
            ? Colors.grey.shade400
            : Colors.grey.shade700;

    return Row(
      children: [
        Icon(
          icon,
          color: secondaryTextColor,
          size: 17,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: secondaryTextColor,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  // News content section.
  Widget buildSection({
    required String title,
    required String content,
  }) {
    if (content.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    final Color textColor = Theme.of(context).colorScheme.onSurface;

    final Color secondaryTextColor =
        isDark ? Colors.grey.shade300 : Colors.grey.shade800;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          content,
          style: TextStyle(
            color: secondaryTextColor,
            fontSize: 15,
            height: 1.7,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    final Color textColor = Theme.of(context).colorScheme.onSurface;

    final bool hasAuthor = widget.news.author.isNotEmpty;
    final bool hasDate = widget.news.publishedAt.isNotEmpty;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(localizations.newsDetails),
        actions: [
          IconButton(
            onPressed: shareNews,
            tooltip: localizations.shareNews,
            icon: const Icon(Icons.share_outlined),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: IconButton(
              onPressed: isLoadingFavorite ? null : toggleFavorite,
              tooltip: isFavorite
                  ? localizations.removeFromFavorites
                  : localizations.addToFavorites,
              icon: isLoadingFavorite
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: isFavorite ? Colors.red : textColor,
                    ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
              child: buildNewsImage(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.news.sourceName.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(
                          alpha: 0.12,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.public,
                            color: AppTheme.primaryColor,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              widget.news.sourceName,
                              style: const TextStyle(
                                color: AppTheme.primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  Text(
                    widget.news.title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),

                  if (hasAuthor || hasDate) ...[
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        if (hasAuthor)
                          Expanded(
                            child: buildInfoRow(
                              icon: Icons.person_outline,
                              text: widget.news.author,
                            ),
                          ),
                        if (hasAuthor && hasDate)
                          const SizedBox(width: 15),
                        if (hasDate)
                          Expanded(
                            child: buildInfoRow(
                              icon: Icons.access_time,
                              text: formatDate(
                                widget.news.publishedAt,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 28),

                  if (widget.news.description.trim().isNotEmpty) ...[
                    buildSection(
                      title: localizations.description,
                      content: widget.news.description,
                    ),
                    const SizedBox(height: 26),
                  ],

                  if (widget.news.content.trim().isNotEmpty)
                    buildSection(
                      title: localizations.content,
                      content: widget.news.content,
                    ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: widget.news.url.trim().isEmpty
                          ? null
                          : openArticle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.open_in_new),
                      label: Text(
                        localizations.openFullArticle,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}