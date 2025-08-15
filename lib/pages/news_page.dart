import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/news_api_client.dart';
import 'package:flutter_application_1/pages/saved_news_page.dart';
import 'package:flutter_application_1/widgets/custom_app_bar.dart';
import 'package:flutter_application_1/widgets/featured_news_pager.dart';
import 'package:flutter_application_1/widgets/news_card.dart';
import 'package:flutter_application_1/pages/settings_page.dart';
import 'package:flutter_application_1/pages/about_page.dart';
import 'package:shimmer/shimmer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/pages/news_detail_page.dart';
import 'package:intl/intl.dart';
import 'package:marquee/marquee.dart';
import 'package:flutter_application_1/pages/daily_summary_page.dart';

class NewsPage extends StatefulWidget {
  final ThemeMode currentThemeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  const NewsPage({
    required this.currentThemeMode,
    required this.onThemeModeChanged,
    super.key,
  });

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final _searchController = TextEditingController();
  final _newsApiClient = NewsApiClient();
  final _categories = ['Gündem', 'Teknoloji', 'Spor', 'Ekonomi', 'Sağlık'];
  Timer? _timer;

  List<dynamic> _newsItems = [];
  List<dynamic> _featuredNewsItems = [];
  List<dynamic> _filteredNewsItems = [];

  String _selectedCategory = 'Gündem';
  bool _isLoading = true;
  bool _isSearching = false;
  
  late String _userName;
  String _currentTime = DateFormat('h:mm').format(DateTime.now());

  String _dailySummaryText = 'Günün özeti yükleniyor...';

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _userName = user?.displayName ?? 'Misafir';
    
    _updateTime();
    _startTimer();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchNews();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {
          _updateTime();
        });
      }
    });
  }
  
  void _updateTime() {
    _currentTime = DateFormat('h:mm').format(DateTime.now());
  }

  void _fetchNews() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final featuredResponse = await _newsApiClient.fetchFeaturedNews(pageSize: 20);
      final newsResponse = await _newsApiClient.fetchNews(category: 'Gündem', pageSize: 20);

      final filteredFeatured = featuredResponse
          .where((item) {
            final urlToImage = item['urlToImage'] as String?;
            return urlToImage != null && 
                   urlToImage.isNotEmpty &&
                   urlToImage != '[Removed]' &&
                   !urlToImage.contains('null');
          })
          .toList();

      final filteredNews = newsResponse
          .where((item) {
            final urlToImage = item['urlToImage'] as String?;
            return urlToImage != null && 
                   urlToImage.isNotEmpty &&
                   urlToImage != '[Removed]' &&
                   !urlToImage.contains('null');
          })
          .toList();


      if (mounted) {
        setState(() {
          _newsItems = filteredNews;
          _featuredNewsItems = filteredFeatured.take(7).toList();
          _filteredNewsItems = filteredNews;
          _isLoading = false;
          _createDailySummary();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      debugPrint('Haberler alınırken bir hata oluştu: $e');
    }
  }

  void _filterNewsByCategory(String category) async {
    if (!mounted) return;
    setState(() {
      _selectedCategory = category;
      _isLoading = true;
    });
    try {
      final news = await _newsApiClient.fetchNews(category: category, pageSize: 20);
      
      final filteredNews = news
          .where((item) {
            final urlToImage = item['urlToImage'] as String?;
            return urlToImage != null && 
                   urlToImage.isNotEmpty &&
                   urlToImage != '[Removed]' &&
                   !urlToImage.contains('null');
          })
          .toList();
      
      if (mounted) {
        setState(() {
          _newsItems = filteredNews;
          _filteredNewsItems = filteredNews;
          _isLoading = false;
          _createDailySummary();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      debugPrint('Kategori haberleri alınırken bir hata oluştu: $e');
    }
  }

void _createDailySummary() {
    if (_newsItems.isEmpty) {
      _dailySummaryText = 'Günün özeti bulunamadı.';
      return;
    }

    final summaries = <String>[];
    for (var i = 0; i < _newsItems.length && i < 10; i++) {
      final description = _newsItems[i]['description'];
      if (description != null && description.isNotEmpty) {
        summaries.add(description);
      }
    }

    if (summaries.isEmpty) {
      _dailySummaryText = 'Günün özeti bulunamadı.';
    } else {
      String fullSummary = summaries.join('    •    ');
      
      const int maxLength = 1000;
      if (fullSummary.length > maxLength) {
        fullSummary = '${fullSummary.substring(0, maxLength)}... (Devamı yok)';
      }
      _dailySummaryText = fullSummary;
    }
  }

  void _openSettingsPage() async {
    final user = FirebaseAuth.instance.currentUser;
    final newUserName = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsPage(
          currentThemeMode: widget.currentThemeMode,
          onThemeModeChanged: widget.onThemeModeChanged,
          userName: user?.displayName ?? 'Misafir',
          photoUrl: user?.photoURL,
        ),
      ),
    );

    if (newUserName != null && newUserName is String && newUserName != _userName) {
      if (mounted) {
        setState(() {
          _userName = newUserName;
        });
      }
    }
  }

  void _openAboutPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AboutPage()),
    );
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        // Arama kapatıldığında ana sayfa haberlerini tekrar yükle
        _filterNewsByCategory(_selectedCategory);
      }
    });
  }

  void _filterNews(String query) async {
    if (!mounted) return;
    if (query.isEmpty) {
      setState(() {
        _filteredNewsItems = _newsItems;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final news = await _newsApiClient.fetchNews(query: query, pageSize: 20);
      
      final filteredNews = news
          .where((item) {
            final urlToImage = item['urlToImage'] as String?;
            return urlToImage != null && 
                   urlToImage.isNotEmpty &&
                   urlToImage != '[Removed]' &&
                   !urlToImage.contains('null');
          })
          .toList();
      
      if (mounted) {
        setState(() {
          _filteredNewsItems = filteredNews;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      debugPrint('Arama yapılırken bir hata oluştu: $e');
    }
  }

  Widget _buildShimmerEffect() {
    final cardColor = Theme.of(context).cardColor;
    return Shimmer.fromColors(
      baseColor: cardColor,
      highlightColor: cardColor.withOpacity(0.5),
      child: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 18,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 14,
                    width: 250,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        onCategorySelected: _filterNewsByCategory,
        userName: _userName,
        currentTime: _currentTime,
        categories: _categories,
        selectedCategory: _selectedCategory,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF281E57),
                    Color(0xFFEE395F),
                    Color(0xFFF56A2D),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Image.asset('assets/images/logo.png', height: 60),
                  const SizedBox(height: 8),
                  Text(
                    'Merhaba, $_userName',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Theme.of(context).textTheme.bodyLarge?.color),
              title: Text('Ana Sayfa', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: Theme.of(context).textTheme.bodyLarge?.color),
              title: Text('Ayarlar', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
              onTap: () {
                Navigator.pop(context);
                _openSettingsPage();
              },
            ),
            ListTile(
              leading: Icon(Icons.info_outline, color: Theme.of(context).textTheme.bodyLarge?.color),
              title: Text('Hakkımızda', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
              onTap: () {
                Navigator.pop(context);
                _openAboutPage();
              },
            ),
            ListTile(
              leading: Icon(Icons.bookmark, color: Theme.of(context).textTheme.bodyLarge?.color),
              title: Text('Kaydedilen Haberler', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SavedNewsPage()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Theme.of(context).textTheme.bodyLarge?.color),
              title: Text('Çıkış Yap', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
              onTap: () {
                Navigator.pop(context);
                _logout();
              },
            ),
          ],
        ),
      ),
      body: _isLoading
          ? _buildShimmerEffect()
          : RefreshIndicator(
                onRefresh: () async {
                  _fetchNews();
                },
                child: CustomScrollView(
                          slivers: [
                            SliverToBoxAdapter(
                              child: Column(
                                children: [
                                  if (_isSearching)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              controller: _searchController,
                                              decoration: InputDecoration(
                                                hintText: 'Haberlerde Ara...',
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                  borderSide: BorderSide.none,
                                                ),
                                                filled: true,
                                                fillColor: Theme.of(context).cardColor,
                                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                                hintStyle: TextStyle(
                                                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                                                ),
                                              ),
                                              style: Theme.of(context).textTheme.bodyMedium,
                                              onSubmitted: (query) => _filterNews(query), // Arama Enter'a basınca başlar
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.close),
                                            onPressed: _toggleSearch,
                                          ),
                                        ],
                                      ),
                                    ),
                                  
                                  if (_featuredNewsItems.isNotEmpty)
                                    FeaturedNewsPager(newsItems: _featuredNewsItems),
                                    
                                  const SizedBox(height: 16),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => DailySummaryPage(
                                                    title: 'Günün Özeti',
                                                    summaryText: _dailySummaryText,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Card(
                                              elevation: 2,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(24.0),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                                child: SizedBox(
                                                  height: 20,
                                                  child: Marquee(
                                                    text: _dailySummaryText,
                                                    style: Theme.of(context).textTheme.bodyMedium,
                                                    scrollAxis: Axis.horizontal,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    blankSpace: 20.0,
                                                    velocity: 50.0,
                                                    pauseAfterRound: const Duration(seconds: 1),
                                                    startPadding: 10.0,
                                                    showFadingOnlyWhenScrolling: true,
                                                    fadingEdgeStartFraction: 0.1,
                                                    fadingEdgeEndFraction: 0.1,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: const Icon(Icons.search),
                                          onPressed: _toggleSearch,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                            if (_filteredNewsItems.isEmpty && !_isLoading)
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Center(
                                    child: Text(
                                      'Haber bulunamadı.',
                                      style: Theme.of(context).textTheme.headlineSmall,
                                    ),
                                  ),
                                ),
                              )
                            else
                              SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (BuildContext context, int index) {
                                    final item = _filteredNewsItems[index];
                                    return NewsCard(
                                      title: item['title'] ?? 'Başlık Yok',
                                      description: item['description'],
                                      imageUrl: item['urlToImage'],
                                      content: item['content'] ?? 'İçerik Yok',
                                      sourceUrl: item['url'],
                                      sourceName: item['source']['name'],
                                      publishedAt: item['publishedAt'],
                                      onTap: () => _openNewsDetailPage(item),
                                    );
                                  },
                                  childCount: _filteredNewsItems.length,
                                ),
                              ),
                          ],
                        ),
              ),
    );
  }

  void _openNewsDetailPage(dynamic newsItem) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewsDetailPage(
          title: newsItem['title'] ?? 'Başlık Yok',
          description: newsItem['description'] ?? 'Açıklama Yok',
          imageUrl: newsItem['urlToImage'],
          content: newsItem['content'] ?? 'İçerik Yok',
          sourceUrl: newsItem['url'],
          sourceName: newsItem['source']['name'],
          publishedAt: newsItem['publishedAt'],
        ),
      ),
    );
  }
}