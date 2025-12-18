import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_article.dart';

class NewsService {
  static const String _apiKey = "442323531d2e441a9a80a7fc9fe440d9";
  static const String _baseUrl = "https://newsapi.org/v2/everything";

  Future<List<NewsArticle>> fetchHealthNews() async {
    // Kita filter berita kesehatan bayi dan anak di Indonesia
    final String query = Uri.encodeComponent("kesehatan bayi OR nutrisi anak OR MPASI");
    final String url = "$_baseUrl?q=$query&language=id&sortBy=publishedAt&apiKey=$_apiKey";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> articlesJson = data['articles'];

        return articlesJson.map((json) => NewsArticle.fromJson(json)).toList();
      } else {
        throw Exception("Gagal mengambil berita: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Terjadi kesalahan: $e");
    }
  }
}
