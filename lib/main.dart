import 'package:flutter/material.dart';
import 'package:tugas_article_mobile6/api_service.dart';
import 'package:tugas_article_mobile6/article_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Berita',
      debugShowCheckedModeBanner: false,
      home: NewsScreen(),
    );
  }
}

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  late Future<List<Article>> articles;
  late ScrollController _scrollController;
  bool _showBackToTopButton = false;

  @override
  void initState() {
    super.initState();
    articles = ApiService().fetchArticles();

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset >= 300) {
        if (!_showBackToTopButton) {
          setState(() {
            _showBackToTopButton = true;
          });
        }
      } else {
        if (_showBackToTopButton) {
          setState(() {
            _showBackToTopButton = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    setState(() {
      articles = ApiService().fetchArticles();
    });
    await articles;
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.newspaper),
        title: const Text('Berita Terkini Wadidaw'),
        backgroundColor: Colors.red,
      ),
      body: FutureBuilder<List<Article>>(
        future: articles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final data = snapshot.data ?? [];

          if (data.isEmpty) {
            return const Center(
              child: Text('Tidak ada berita.'),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshData,
            child: ListView.builder(
              controller: _scrollController,
              itemCount: data.length,
              itemBuilder: (context, index) {
                final article = data[index];

                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: article.urlToImage != null
                        ? Image.network(
                            article.urlToImage!,
                            width: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.broken_image),
                          )
                        : const Icon(Icons.newspaper),
                    title: Text(article.judul),
                    subtitle: Text(
                      article.deskripsi ?? 'Tidak ada deskripsi',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: _showBackToTopButton
          ? FloatingActionButton(
              onPressed: _scrollToTop,
              backgroundColor: Colors.red,
              child: const Icon(Icons.arrow_upward, color: Colors.white),
            )
          : null,
    );
  }
}