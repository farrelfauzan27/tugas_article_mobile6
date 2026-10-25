import 'package:http/http.dart' as http;

import 'dart:convert';

import 'package:tugas_article_mobile6/article_model.dart';

class ApiService {
  static const baseUrl =
      'https://newsapi.org/v2/top-headlines?country=us&category=business&apiKey=a0fa2a6c6bf34652a0d5557bb954ceda';

  Future<List<Article>> fetchArticles() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil berita.');
    }

    final data = jsonDecode(response.body);

    return (data['articles'] as List)
        .map((item) => Article.fromJson(item))
        .toList();
  }
}