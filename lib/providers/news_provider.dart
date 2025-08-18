import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/api/news_api_client.dart';

// AsyncNotifier sınıfımızı tanımlıyoruz.
// Bu sınıf, haber verilerini AsyncValue<List<dynamic>> olarak yönetecek.
class NewsNotifier extends AsyncNotifier<List<dynamic>> {
  final _newsApiClient = NewsApiClient();

  // AsyncNotifier'ın zorunlu `build` metodu.
  // Bu metot, provider ilk kez çağrıldığında çalışır ve başlangıç durumunu belirler.
  @override
  Future<List<dynamic>> build() async {
    return _fetchNews();
  }

  // Haberleri API'den çeken ana metot.
  // Bu metot, durum güncellemelerini handle eder.
  Future<List<dynamic>> _fetchNews({String? category, String? query}) async {
    try {
      state = const AsyncValue.loading(); // Veri çekilirken loading durumuna geç
      
      final newsResponse = await _newsApiClient.fetchNews(
        category: category,
        query: query,
        pageSize: 20,
      );

      // Sadece resimli ve geçerli haberleri filtrele
      final filteredNews = newsResponse.where((item) {
        final urlToImage = item['urlToImage'] as String?;
        return urlToImage != null &&
            urlToImage.isNotEmpty &&
            urlToImage != '[Removed]' &&
            !urlToImage.contains('null');
      }).toList();

      state = AsyncValue.data(filteredNews); // Veriler başarıyla geldi, durumu güncelle
      return filteredNews;

    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace); // Hata durumuna geç
      return [];
    }
  }

  // Kategoriye göre haberleri filtrelemek için dışarıdan çağrılacak metot
  Future<void> filterNewsByCategory(String category) async {
    // state = AsyncValue.loading(); // Opsiyonel: Kategori değişiminde yükleme ekranı göster
    await _fetchNews(category: category);
  }

  // Arama sorgusuna göre haberleri filtrelemek için dışarıdan çağrılacak metot
  Future<void> filterNewsByQuery(String query) async {
    await _fetchNews(query: query);
  }

  // Veriyi manuel olarak yenilemek için
  Future<void> refreshNews() async {
    state = const AsyncValue.loading();
    await _fetchNews();
  }
}

// AsyncNotifierProvider'ımızı tanımlıyoruz.
// Bu provider'a uygulamanın her yerinden erişebiliriz.
final newsProvider = AsyncNotifierProvider<NewsNotifier, List<dynamic>>(() {
  return NewsNotifier();
});

// Sadece ana haberleri (featured) çeken ve yöneten farklı bir provider
final featuredNewsProvider = FutureProvider<List<dynamic>>((ref) async {
  final newsApiClient = NewsApiClient();
  final featuredResponse = await newsApiClient.fetchFeaturedNews(pageSize: 20);
  
  final filteredFeatured = featuredResponse.where((item) {
    final urlToImage = item['urlToImage'] as String?;
    return urlToImage != null &&
        urlToImage.isNotEmpty &&
        urlToImage != '[Removed]' &&
        !urlToImage.contains('null');
  }).take(7).toList();
  
  return filteredFeatured;
});