import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../models/news_article.dart';
import '../services/news_service.dart';

class EdukasiScreen extends StatefulWidget {
  const EdukasiScreen({super.key});

  @override
  State<EdukasiScreen> createState() => _EdukasiScreenState();
}

class _EdukasiScreenState extends State<EdukasiScreen> {
  final NewsService _newsService = NewsService();
  late Future<List<NewsArticle>> _newsFuture;

  @override
  void initState() {
    super.initState();
    _newsFuture = _newsService.fetchHealthNews();
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tidak bisa membuka link: $urlString')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: FutureBuilder<List<NewsArticle>>(
              future: _newsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 60, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            'Gagal memuat berita.',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            snapshot.error.toString().split(':').last.trim(),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => setState(() {
                              _newsFuture = _newsService.fetchHealthNews();
                            }),
                            child: const Text('Coba Lagi'),
                          )
                        ],
                      ),
                    ),
                  );
                }

                final articles = snapshot.data ?? [];

                if (articles.isEmpty) {
                  return const Center(child: Text("Tidak ada berita ditemukan."));
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: articles.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final article = articles[index];

                    return _buildNewsCard(article);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 45, 20, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3E5CF7), Color(0xFF254EDB)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Berita Kesehatan Terbaru',
            style: TextStyle(
              fontSize: 24, 
              fontWeight: FontWeight.bold, 
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Informasi terpercaya',
            style: TextStyle(
              fontSize: 14, 
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCard(NewsArticle article) {
    String dateStr = "";
    if (article.publishedAt != null) {
      final date = DateTime.parse(article.publishedAt!);
      dateStr = DateFormat('dd MMM yyyy').format(date);
    }

    return GestureDetector(
      onTap: () => _launchURL(article.url),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF254EDB).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      article.sourceName ?? "Berita",
                      style: const TextStyle(
                        fontSize: 10, 
                        fontWeight: FontWeight.bold, 
                        color: Color(0xFF254EDB),
                      ),
                    ),
                  ),
                  Text(
                    dateStr,
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                article.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold, 
                  height: 1.3,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Text(
                    "Baca selengkapnya",
                    style: TextStyle(
                      fontSize: 13, 
                      fontWeight: FontWeight.bold, 
                      color: Color(0xFF254EDB),
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward_rounded, size: 16, color: Color(0xFF254EDB)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
