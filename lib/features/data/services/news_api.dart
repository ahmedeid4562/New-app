import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/news_model.dart';

class NewsApi {
  static const String apiKey = '125e000912dd4eb2819b49f1714562d9';

  static const String baseUrl = 'https://newsapi.org/v2';

  Future<List<NewsModel>> getTopHeadlines() async {
    final url = Uri.parse(
      '$baseUrl/top-headlines?country=us&apiKey=$apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List articles = data['articles'];

      return articles
          .map((article) => NewsModel.fromJson(article))
          .toList();
    } else {
      throw Exception(
        'Error: ${response.statusCode}\n${response.body}',
      );
    }
  }
}
