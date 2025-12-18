class NewsArticle {
  final String title;
  final String? description;
  final String url;
  final String? urlToImage;
  final String? publishedAt;
  final String? sourceName;

  NewsArticle({
    required this.title,
    this.description,
    required this.url,
    this.urlToImage,
    this.publishedAt,
    this.sourceName,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? 'No Title',
      description: json['description'],
      url: json['url'] ?? '',
      urlToImage: json['urlToImage'],
      publishedAt: json['publishedAt'],
      sourceName: json['source'] != null ? json['source']['name'] : null,
    );
  }
}
