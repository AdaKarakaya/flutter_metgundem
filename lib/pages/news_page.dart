import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/saved_news_page.dart';
import 'package:flutter_application_1/widgets/custom_app_bar.dart';
import 'package:flutter_application_1/widgets/featured_news_pager.dart';
import 'package:flutter_application_1/widgets/news_card.dart';
import 'package:flutter_application_1/pages/settings_page.dart';
import 'package:flutter_application_1/pages/about_page.dart';
import 'package:shimmer/shimmer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/pages/news_detail_page.dart';
import 'package:marquee/marquee.dart';
import 'package:flutter_application_1/pages/daily_summary_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/providers/news_provider.dart';
import 'package:flutter_application_1/providers/auth_provider.dart';
import 'package:flutter_application_1/providers/time_provider.dart';

// _isSearching durumu için bir StateProvider tanımlayalım
final isSearchingProvider = StateProvider<bool>((ref) => false);
// _selectedCategory durumu için bir StateProvider tanımlayalım
final selectedCategoryProvider = StateProvider<String>((ref) => 'Gündem');

// Kategori listesini global olarak tanımlıyoruz
const List<String> newsCategories = [
  'Gündem',
  'Teknoloji',
  'Spor',
  'Ekonomi',
  'Sağlık'
];

class NewsPage extends ConsumerStatefulWidget {
  const NewsPage({super.key});

  @override
  ConsumerState<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends ConsumerState<NewsPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openSettingsPage() {
    final user = FirebaseAuth.instance.currentUser;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsPage(
          userName: user?.displayName ?? 'Misafir',
          photoUrl: user?.photoURL,
        ),
      ),
    );
  }

  void _openAboutPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AboutPage()),
    );
  }

  void _toggleSearch() {
    ref.read(isSearchingProvider.notifier).state = !ref.read(isSearchingProvider);
    if (!ref.read(isSearchingProvider)) {
      _searchController.clear();
      ref.read(newsProvider.notifier).filterNewsByCategory(ref.read(selectedCategoryProvider));
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

  Widget _buildDrawer(WidgetRef ref) {
    final userName = ref.watch(userNameProvider);
    final authService = ref.read(authServiceProvider);
    return Drawer(
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
                  'Merhaba, $userName',
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
            onTap: () async {
              Navigator.pop(context);
              await authService.signOut();
            },
          ),
        ],
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

  @override
  Widget build(BuildContext context) {
    final asyncNewsData = ref.watch(newsProvider);
    final asyncFeaturedNewsData = ref.watch(featuredNewsProvider);
    final isSearching = ref.watch(isSearchingProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    
    final userName = ref.watch(userNameProvider);
    final currentTime = ref.watch(currentTimeProvider);
    
    final displayTime = currentTime.when(
      data: (time) => time,
      loading: () => '...',
      error: (_, __) => '...',
    );

    String _dailySummaryText = 'Günün özeti yükleniyor...';

    return asyncNewsData.when(
      loading: () => Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: CustomAppBar(
          onCategorySelected: (category) {},
          userName: userName,
          currentTime: displayTime,
          categories: newsCategories,
          selectedCategory: selectedCategory,
        ),
        body: _buildShimmerEffect(),
      ),
      error: (error, stackTrace) => Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: CustomAppBar(
          onCategorySelected: (category) {},
          userName: userName,
          currentTime: displayTime,
          categories: newsCategories,
          selectedCategory: selectedCategory,
        ),
        body: Center(child: Text('Hata oluştu: $error')),
      ),
      data: (newsItems) {
        final featuredNewsItems = asyncFeaturedNewsData.asData?.value ?? [];
        
        final summaries = <String>[];
        for (var i = 0; i < newsItems.length && i < 10; i++) {
          final description = newsItems[i]['description'];
          if (description != null && description.isNotEmpty) {
            summaries.add(description);
          }
        }
        if (summaries.isEmpty) {
          _dailySummaryText = 'Günün özeti bulunamadı.';
        } else {
          // Boşlukları temizlenmiş 'join' metodu
          String fullSummary = summaries.join(' • ');
          const int maxLength = 1000;
          if (fullSummary.length > maxLength) {
            fullSummary = '${fullSummary.substring(0, maxLength)}... (Devamı yok)';
          }
          _dailySummaryText = fullSummary;
        }

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: CustomAppBar(
            onCategorySelected: (category) {
              ref.read(selectedCategoryProvider.notifier).state = category;
              ref.read(newsProvider.notifier).filterNewsByCategory(category);
            },
            userName: userName,
            currentTime: displayTime,
            categories: newsCategories,
            selectedCategory: selectedCategory,
          ),
          drawer: _buildDrawer(ref),
          body: RefreshIndicator(
            onRefresh: () {
              return ref.read(newsProvider.notifier).refreshNews();
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      if (isSearching)
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
                                  onSubmitted: (query) => ref.read(newsProvider.notifier).filterNewsByQuery(query),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: _toggleSearch,
                              ),
                            ],
                          ),
                        ),
                      if (featuredNewsItems.isNotEmpty)
                        FeaturedNewsPager(newsItems: featuredNewsItems),
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
                if (newsItems.isEmpty)
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
                        final item = newsItems[index];
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
                      childCount: newsItems.length,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}