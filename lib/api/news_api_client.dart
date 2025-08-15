import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsApiClient {
  static const String _apiKey = 'acb5818185a142bc9b59da08f6cfd70d';
  static const String _baseUrl = 'https://newsapi.org/v2';

  static const List<Map<String, dynamic>> _fallbackNews = [
    {
      'title': 'Flutter ile Uygulama Geliştirme Rehberi',
      'description': 'Flutter, Google tarafından geliştirilen açık kaynaklı bir UI yazılım geliştirme kitidir.',
      'urlToImage': 'https://i.picsum.photos/id/1/5616/3744.jpg?hmac=k78_YyZ-gE4mP1mR_yB_R31y8n_r0I4x9p0k8X9t-E',
      'content': 'Flutter ile mobil, web ve masaüstü uygulamaları kolayca geliştirebilirsiniz...',
      'source': {'name': 'Flutter Blog'},
      'category': 'Gündem',
    },
    {
      'title': 'Türkiye Ekonomisindeki Son Gelişmeler',
      'description': 'Uzmanlar, Türkiye ekonomisi üzerindeki son verileri değerlendiriyor.',
      'urlToImage': 'https://i.picsum.photos/id/1018/3914/2935.jpg?hmac=3N9j_LwVp60JpP1I3S_K6wD4q5j_M5z_j3q2E7z-Y4',
      'content': 'Ekonomi gündemini yakından takip edenler için son gelişmeler...',
      'source': {'name': 'Ekonomi Gazetesi'},
      'category': 'Ekonomi',
    },
  ];

  Future<List<dynamic>> fetchNews({String? category, String? query, int pageSize = 20}) async {
    String endpoint = '/everything';
    Map<String, String> params = {
      'apiKey': _apiKey,
      'language': 'tr',
      'sortBy': 'publishedAt',
      'pageSize': pageSize.toString(),
    };

    if (query != null && query.isNotEmpty) {
      params['q'] = query;
    } else if (category != null && category.isNotEmpty) {
      params['q'] = _translateCategoryToEnglish(category);
    } else {
      params['q'] = 'gündem';
    }
    
    final uri = Uri.parse('$_baseUrl$endpoint').replace(queryParameters: params);
    
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['articles'] != null && data['articles'].isNotEmpty) {
          return data['articles'];
        }
      }
    } catch (e) {
      print('API bağlantı hatası: $e');
    }
    return _fallbackNews;
  }

  Future<List<dynamic>> fetchFeaturedNews({int pageSize = 20}) async {
    final url = '$_baseUrl/everything?q=teknoloji&sortBy=publishedAt&language=tr&apiKey=$_apiKey&pageSize=$pageSize';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['articles'].isNotEmpty) {
          return data['articles'];
        }
      }
    } catch (e) {
      print('API bağlantı hatası: $e');
    }
    return _fallbackNews.take(2).toList();
  }

  String _translateCategoryToEnglish(String category) {
    switch (category) {
      case 'Gündem':
        return 'general';
      case 'Teknoloji':
        return 'technology';
      case 'Spor':
        return 'sports';
      case 'Ekonomi':
        return 'business';
      case 'Sağlık':
        return 'health';
      default:
        return 'general';
    }
  }
}