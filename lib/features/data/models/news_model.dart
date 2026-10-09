class NewsModel {
  final String title;
  final String description;
  final String imageUrl;
  final String author;
  final String publishedAt;
  final String content;
  final String url;
  final String sourceName;

  const NewsModel({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.author,
    required this.publishedAt,
    required this.content,
    required this.url,
    required this.sourceName,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    String getString(dynamic value) {
      if (value == null) return '';

      if (value is String) {
        return value.trim();
      }

      return value.toString().trim();
    }

    String getFirstString(List<dynamic> values) {
      for (final value in values) {
        final result = getString(value);

        if (result.isNotEmpty &&
            result.toLowerCase() != 'null') {
          return result;
        }
      }

      return '';
    }

    String getAuthor(dynamic value) {
      if (value is List) {
        return value
            .where((item) => item != null)
            .map((item) => getString(item))
            .where((item) => item.isNotEmpty)
            .join(', ');
      }

      return getString(value);
    }

    String getSourceName() {
      final source = json['source'];

      if (source is Map) {
        final name = getString(source['name']);

        if (name.isNotEmpty) {
          return name;
        }
      }

      return getFirstString([
        json['source_name'],
        json['source_id'],
      ]);
    }

    return NewsModel(
      title: getString(json['title']),
      description: getString(json['description']),
      imageUrl: getFirstString([
        json['image_url'],
        json['urlToImage'],
        json['imageUrl'],
      ]),
      author: getAuthor(
        json['creator'] ?? json['author'],
      ),
      publishedAt: getFirstString([
        json['pubDate'],
        json['publishedAt'],
      ]),
      content: getFirstString([
        json['content'],
        json['full_content'],
      ]),
      url: getFirstString([
        json['link'],
        json['url'],
      ]),
      sourceName: getSourceName(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'author': author,
      'publishedAt': publishedAt,
      'content': content,
      'url': url,
      'sourceName': sourceName,
    };
  }

  factory NewsModel.fromSavedJson(
    Map<String, dynamic> json,
  ) {
    String getString(dynamic value) {
      if (value == null) return '';

      final result = value.toString().trim();

      return result.toLowerCase() == 'null'
          ? ''
          : result;
    }

    return NewsModel(
      title: getString(json['title']),
      description: getString(json['description']),
      imageUrl: getString(json['imageUrl']),
      author: getString(json['author']),
      publishedAt: getString(json['publishedAt']),
      content: getString(json['content']),
      url: getString(json['url']),
      sourceName: getString(json['sourceName']),
    );
  }
}
