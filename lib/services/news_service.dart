// lib/services/news_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsService {
  static const String _apiKey = 'acb5818185a142bc9b59da08f6cfd70d';
  static const int _pageSize = 20;

  Future<List<Map<String, dynamic>>> fetchNews({String? category}) async {
    // Kategoriye göre URL'yi oluşturuyoruz
    String url;
    if (category != null && category != 'Genel') {
      url = 'https://newsapi.org/v2/everything?q=$category&pageSize=$_pageSize&apiKey=$_apiKey';
    } else {
      url = 'https://newsapi.org/v2/everything?q=flutter&pageSize=$_pageSize&apiKey=$_apiKey';
    }
    
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['articles'] as List)
          .map((article) => article as Map<String, dynamic>)
          .toList();
    } else {
      throw Exception('Haberler yüklenemedi. Durum kodu: ${response.statusCode}');
    }
  }
}