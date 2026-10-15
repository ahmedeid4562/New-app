import 'dart:async';

import 'package:flutter/material.dart';
import 'package:news_app/features/data/models/news_model.dart';
import 'package:news_app/features/data/services/news_api.dart';
import 'package:news_app/features/data/services/local_news_service.dart';
import 'package:news_app/features/view/widgit/news_card_widgit.dart';
import 'package:news_app/features/view/widgit/news_skeleton.dart';

import '../../../core/routes/routes_app.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NewsApi newsApi = NewsApi();
  final LocalNewsService localNewsService = LocalNewsService();

  final TextEditingController searchController =
      TextEditingController();

  final ScrollController scrollController = ScrollController();

  List<NewsModel> newsList = [];

  String selectedCategory = 'general';
  String? _currentLanguageCode;

  bool isSearching = false;
  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasError = false;
  bool hasMore = true;
  bool isOffline = false;

  DateTime? lastSavedTime;

  Object? loadingError;

  int _requestId = 0;

  Timer? _searchDebounce;

  final List<String> categoryValues = [
    'general',
    'business',
    'technology',
    'sports',
    'health',
    'science',
    'entertainment',
  ];

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final languageCode =
        Localizations.localeOf(context).languageCode;

    if (_currentLanguageCode != languageCode) {
      _currentLanguageCode = languageCode;
      newsApi.setLanguage(languageCode);
      _loadInitialNews();
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    searchController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;

    final position = scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 400) {
      _loadMoreNews();
    }
  }

  Future<List<NewsModel>> _fetchNews({
    required bool loadMore,
  }) {
    if (isSearching &&
        searchController.text.trim().isNotEmpty) {
      return newsApi.searchNews(
        searchController.text.trim(),
        loadMore: loadMore,
      );
    }

    if (selectedCategory == 'general') {
      return newsApi.getTopHeadlines(
        loadMore: loadMore,
      );
    }

    return newsApi.getCategoryNews(
      selectedCategory,
      loadMore: loadMore,
    );
  }

  Future<void> _loadInitialNews() async {
    final requestId = ++_requestId;

    setState(() {
      isLoading = true;
      isLoadingMore = false;
      hasError = false;
      loadingError = null;
      hasMore = true;
      isOffline = false;
    });

    try {
      final articles = await _fetchNews(loadMore: false);

      if (!mounted || requestId != _requestId) return;

      final uniqueArticles = _removeDuplicates(articles);

      setState(() {
        newsList = uniqueArticles;
        hasMore = newsApi.hasMore;
        isLoading = false;
        hasError = false;
        isOffline = false;
      });

      if (uniqueArticles.isNotEmpty) {
        await localNewsService.saveNews(uniqueArticles);

        lastSavedTime = localNewsService.getLastSavedTime();
      }

      if (!mounted || requestId != _requestId) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _onScroll();
        }
      });
    } catch (error) {
      if (!mounted || requestId != _requestId) return;

      debugPrint('News loading error: $error');

      List<NewsModel> cachedArticles = [];

      try {
        cachedArticles = localNewsService.getCachedNews();
        lastSavedTime = localNewsService.getLastSavedTime();
      } catch (cacheError) {
        debugPrint('Local cache error: $cacheError');
      }

      if (!mounted || requestId != _requestId) return;

      setState(() {
        loadingError = error;
        isLoading = false;
        isOffline = cachedArticles.isNotEmpty;

        if (cachedArticles.isNotEmpty) {
          newsList = _removeDuplicates(cachedArticles);
          hasError = false;
          hasMore = false;
        } else {
          newsList = [];
          hasError = true;
          hasMore = false;
        }
      });
    }
  }

  Future<void> _loadMoreNews() async {
    if (isLoading ||
        isLoadingMore ||
        hasError ||
        isOffline ||
        !hasMore ||
        !newsApi.hasMore ||
        newsList.isEmpty) {
      return;
    }

    setState(() {
      isLoadingMore = true;
    });

    final requestId = _requestId;

    try {
      final articles = await _fetchNews(loadMore: true);

      if (!mounted || requestId != _requestId) return;

      final updatedNews = _removeDuplicates([
        ...newsList,
        ...articles,
      ]);

      setState(() {
        newsList = updatedNews;
        hasMore = newsApi.hasMore;
        isLoadingMore = false;
      });

      if (updatedNews.isNotEmpty) {
        await localNewsService.saveNews(updatedNews);

        lastSavedTime = localNewsService.getLastSavedTime();
      }
    } catch (error) {
      if (!mounted || requestId != _requestId) return;

      setState(() {
        loadingError = error;
        isLoadingMore = false;
      });

      debugPrint('Loading more news error: $error');
    }
  }

  List<NewsModel> _removeDuplicates(
    List<NewsModel> articles,
  ) {
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

  void changeCategory(String category) {
    FocusScope.of(context).unfocus();
    _searchDebounce?.cancel();

    setState(() {
      selectedCategory = category;
      isSearching = false;
      searchController.clear();
    });

    _loadInitialNews();
  }

  void searchNews() {
    final query = searchController.text.trim();

    _searchDebounce?.cancel();

    if (query.isEmpty) {
      clearSearch();
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      isSearching = true;
    });

    _loadInitialNews();
  }

  void _onSearchChanged(String query) {
    setState(() {});

    _searchDebounce?.cancel();

    if (query.trim().isEmpty) {
      return;
    }

    _searchDebounce = Timer(
      const Duration(milliseconds: 600),
      () {
        if (!mounted) return;

        setState(() {
          isSearching = true;
        });

        _loadInitialNews();
      },
    );
  }

  void clearSearch() {
    _searchDebounce?.cancel();
    FocusScope.of(context).unfocus();
    searchController.clear();

    setState(() {
      isSearching = false;
      selectedCategory = 'general';
    });

    _loadInitialNews();
  }

  void retry() {
    _loadInitialNews();
  }

  Future<void> refreshNews() async {
    await _loadInitialNews();
  }

  String getErrorMessage(
    Object? error,
    AppLocalizations localizations,
  ) {
    if (error != null) {
      debugPrint('News loading error: $error');
    }

    return localizations.unexpectedError;
  }

  String getCategoryName(
    AppLocalizations localizations,
    String category,
  ) {
    switch (category) {
      case 'general':
        return localizations.general;
      case 'business':
        return localizations.business;
      case 'technology':
        return localizations.technology;
      case 'sports':
        return localizations.sports;
      case 'health':
        return localizations.health;
      case 'science':
        return localizations.science;
      case 'entertainment':
        return localizations.entertainment;
      default:
        return category;
    }
  }

  Widget _buildErrorState(
    AppLocalizations localizations,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            const SizedBox(height: 15),
            Text(
              localizations.unableToLoadNews,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              getErrorMessage(loadingError, localizations),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: secondaryTextColor,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: retry,
              icon: const Icon(Icons.refresh),
              label: Text(localizations.tryAgain),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    AppLocalizations localizations,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              color: Colors.grey,
              size: 65,
            ),
            const SizedBox(height: 15),
            Text(
              localizations.noNewsFound,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isSearching) ...[
              const SizedBox(height: 8),
              Text(
                localizations.trySearchingElse,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineBanner(
    BuildContext context,
    Color textColor,
    Color secondaryTextColor,
    AppLocalizations localizations,
  ) {
    final materialLocalizations =
        MaterialLocalizations.of(context);

    String updatedText = 'Showing saved news';

    if (lastSavedTime != null) {
      final formattedDate =
          materialLocalizations.formatShortDate(lastSavedTime!);

      final formattedTime =
          materialLocalizations.formatTimeOfDay(
        TimeOfDay.fromDateTime(lastSavedTime!),
      );

      updatedText =
          'Showing saved news • Last updated: $formattedDate $formattedTime';
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.wifi_off,
            color: Colors.orange,
            size: 24,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Offline Mode',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  updatedText,
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: retry,
            icon: const Icon(
              Icons.refresh,
              color: Colors.orange,
            ),
            tooltip: localizations.tryAgain,
          ),
        ],
      ),
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
        isDark ? Colors.grey.shade400 : Colors.grey.shade700;

    final Color cardColor = Theme.of(context).cardColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(localizations.appTitle),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    style: TextStyle(color: textColor),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => searchNews(),
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: localizations.searchNews,
                      hintStyle: TextStyle(
                        color: secondaryTextColor,
                      ),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              onPressed: clearSearch,
                              icon: const Icon(Icons.clear),
                              tooltip: localizations.clear,
                            )
                          : null,
                      filled: true,
                      fillColor: cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: isDark
                              ? Colors.white12
                              : Colors.black12,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: AppTheme.primaryColor,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 50,
                  width: 50,
                  child: ElevatedButton(
                    onPressed: searchNews,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Icon(
                      Icons.search,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!isSearching)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      localizations.categories,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    itemCount: categoryValues.length,
                    itemBuilder: (context, index) {
                      final value = categoryValues[index];

                      final name = getCategoryName(
                        localizations,
                        value,
                      );

                      final bool isSelected =
                          selectedCategory == value;

                      return GestureDetector(
                        onTap: () => changeCategory(value),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsetsDirectional.only(
                            end: 8,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primaryColor
                                : cardColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : (isDark
                                      ? Colors.white12
                                      : Colors.black12),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              name,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : secondaryTextColor,
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          if (isSearching)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      localizations.searchResultsFor(
                        searchController.text.trim(),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: clearSearch,
                    child: Text(localizations.clear),
                  ),
                ],
              ),
            ),
          if (isOffline && newsList.isNotEmpty)
            _buildOfflineBanner(
              context,
              textColor,
              secondaryTextColor,
              localizations,
            ),
          Expanded(
            child: isLoading
                ? const NewsSkeleton()
                : hasError
                    ? _buildErrorState(
                        localizations,
                        textColor,
                        secondaryTextColor,
                      )
                    : newsList.isEmpty
                        ? _buildEmptyState(
                            localizations,
                            textColor,
                            secondaryTextColor,
                          )
                        : RefreshIndicator(
                            color: AppTheme.primaryColor,
                            onRefresh: refreshNews,
                            child: ListView.builder(
                              controller: scrollController,
                              physics:
                                  const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              itemCount: newsList.length +
                                  (isLoadingMore || hasMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == newsList.length) {
                                  if (isLoadingMore) {
                                    return const Padding(
                                      padding: EdgeInsets.all(20),
                                      child: Center(
                                        child:
                                            CircularProgressIndicator(),
                                      ),
                                    );
                                  }

                                  if (hasMore && !isOffline) {
                                    return Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Center(
                                        child: TextButton.icon(
                                          onPressed: _loadMoreNews,
                                          icon: const Icon(
                                            Icons.expand_more,
                                          ),
                                          label: const Text(
                                            'Load more news',
                                          ),
                                        ),
                                      ),
                                    );
                                  }

                                  return const SizedBox.shrink();
                                }

                                final article = newsList[index];

                                return NewsCard(
                                  news: article,
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      RoutesApp.details,
                                      arguments: article,
                                    );
                                  },
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
