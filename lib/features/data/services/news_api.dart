import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/news_model.dart';

class NewsApi {
static const String apiKey = 'pub_95368d2aab9f485f9e04ca7136e6b1ea';

static const String baseUrl = 'https://newsdata.io/api/1/latest';

String _language = 'en';
String? _nextPage;
bool _hasMore = true;

String get language => _language;
bool get hasMore => _hasMore;

void setLanguage(String languageCode) {
final newLanguage = languageCode == 'ar' ? 'ar' : 'en';
if (_language != newLanguage) {
  _language = newLanguage;
  resetPagination();
}
}

void resetPagination() {
_nextPage = null;
_hasMore = true;
}

Future<List<NewsModel>> getTopHeadlines({
bool loadMore = false,
}) async {
if (!loadMore) {
resetPagination();
}

return _getNews({
  'country': 'eg',
  'language': _language,
}, loadMore: loadMore);

}

Future<List<NewsModel>> getCategoryNews(
String category, {
bool loadMore = false,
}) async {
if (!loadMore) {
resetPagination();
}
final parameters = <String, String>{
  'country': 'eg',
  'language': _language,
};

final apiCategory = _mapCategory(category);

if (apiCategory != null) {
  parameters['category'] = apiCategory;
}

return _getNews(parameters, loadMore: loadMore);

}

Future<List<NewsModel>> searchNews(
String query, {
bool loadMore = false,
}) async {
final trimmedQuery = query.trim();
if (trimmedQuery.isEmpty) {
  return getTopHeadlines(loadMore: loadMore);
}

if (!loadMore) {
  resetPagination();
}

return _getNews({
  'q': trimmedQuery,
  'language': _language,
}, loadMore: loadMore);
}

String? _mapCategory(String category) {
switch (category.toLowerCase()) {
case 'general':
return null;
case 'business':
return 'business';
case 'technology':
return 'technology';
case 'sports':
return 'sports';
case 'health':
return 'health';
case 'science':
return 'science';
case 'entertainment':
return 'entertainment';
default:
return null;
}
}

Future<List<NewsModel>> _getNews(
Map<String, String> parameters, {
required bool loadMore,
}) async {
if (loadMore && (!_hasMore || _nextPage == null)) {
return [];
}

try {
  final queryParameters = <String, String>{
    'apikey': apiKey,
    ...parameters,
    'image': '1',
    'size': '10',
  };

  if (loadMore) {
    queryParameters['page'] = _nextPage!;
  }

  final uri = Uri.parse(baseUrl).replace(
    queryParameters: queryParameters,
  );

  final response = await http
      .get(
        uri,
        headers: const {
          'Accept': 'application/json',
        },
      )
      .timeout(const Duration(seconds: 25));

  if (kDebugMode) {
    debugPrint('========== NEWSDATA API ==========');
    debugPrint('Language: $_language');
    debugPrint('Status Code: ${response.statusCode}');
  }

  final dynamic decodedData = jsonDecode(response.body);

  if (decodedData is! Map) {
    throw Exception('استجابة غير صحيحة من خدمة الأخبار.');
  }

  final data = Map<String, dynamic>.from(decodedData);

  if (response.statusCode != 200 ||
      data['status'] != 'success') {
    final message = _extractErrorMessage(data);

    debugPrint('NewsData API Error: $message');

    throw Exception('فشل تحميل الأخبار: $message');
  }

  final results = data['results'];

  if (results is! List) {
    _nextPage = null;
    _hasMore = false;
    return [];
  }

  final List<NewsModel> news = [];
  int articlesWithImageUrls = 0;
  int rejectedImageUrls = 0;

  for (final article in results) {
    if (article is! Map) continue;

    try {
      final articleData = Map<String, dynamic>.from(article);

      final title = articleData['title']?.toString().trim() ?? '';

      if (title.isEmpty || title == '[Removed]') {
        continue;
      }

      final rawImageUrl =
          articleData['image_url']?.toString().trim() ?? '';

      if (!isUsableImageUrl(rawImageUrl)) {
        articleData['image_url'] = '';
        rejectedImageUrls++;
      } else {
        articlesWithImageUrls++;
      }

      news.add(NewsModel.fromJson(articleData));
    } catch (error) {
      debugPrint('Article parsing error: $error');
    }
  }

  final nextPage = data['nextPage']?.toString();

  _nextPage = nextPage == null || nextPage.isEmpty
      ? null
      : nextPage;

  _hasMore = _nextPage != null;

  if (kDebugMode) {
    debugPrint('Articles loaded: ${news.length}');
    debugPrint('Articles with image URLs: $articlesWithImageUrls');
    debugPrint('Rejected image URLs: $rejectedImageUrls');
    debugPrint('Has more pages: $_hasMore');
    debugPrint('==================================');
  }

  return news;
} on TimeoutException {
  throw Exception('انتهت مهلة الاتصال. حاول مرة أخرى.');
} on http.ClientException catch (error) {
  debugPrint('Network error: $error');
  throw Exception('تعذر الاتصال بالإنترنت.');
} on FormatException catch (error) {
  debugPrint('Invalid JSON response: $error');
  throw Exception('حدث خطأ في قراءة بيانات الأخبار.');
}
}

bool isUsableImageUrl(String imageUrl) {
if (imageUrl.trim().isEmpty) {
return false;
}

final uri = Uri.tryParse(imageUrl.trim());

if (uri == null ||
    (uri.scheme != 'https' && uri.scheme != 'http') ||
    uri.host.isEmpty) {
  return false;
}

final host = uri.host.toLowerCase();
final path = uri.path.toLowerCase();

// تجاهل شعار MENAFN العام، وليس صور الأخبار.
if (host == 'menafn.com' &&
    path == '/images/menafn_smalllogo.jpg') {
  return false;
}

// روابط الصور التي ظهرت في السجلات ورجعت 404.
if (host == 'menafn.com' &&
    path.startsWith('/rss/') &&
    path.endsWith('image_story.jpg')) {
  return false;
}

return true;
}

String _extractErrorMessage(Map<String, dynamic> data) {
final results = data['results'];

if (results is Map) {
  final message = results['message'];

  if (message != null) {
    return message.toString();
  }
}

final message = data['message'];

if (message != null) {
  return message.toString();
}

return 'حدث خطأ أثناء تحميل الأخبار.';

}
}
