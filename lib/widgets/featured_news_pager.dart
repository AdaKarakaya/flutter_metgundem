import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter_application_1/pages/news_detail_page.dart';

class FeaturedNewsPager extends StatefulWidget {
  final List<dynamic> newsItems;

  const FeaturedNewsPager({required this.newsItems, super.key});

  @override
  State<FeaturedNewsPager> createState() => _FeaturedNewsPagerState();
}

class _FeaturedNewsPagerState extends State<FeaturedNewsPager> {
  final SwiperController _swiperController = SwiperController();

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.newsItems.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final bool autoplay = widget.newsItems.length > 1;

    return SizedBox(
      height: 250,
      child: Swiper(
        controller: _swiperController,
        autoplay: autoplay,
        autoplayDelay: 5000,
        itemCount: widget.newsItems.length,
        itemBuilder: (BuildContext context, int index) {
          final item = widget.newsItems[index];
          final imageUrl = item['urlToImage'];

          // URL'nin geçerli olup olmadığını kontrol eden fonksiyon
          bool isImageUrlValid(String? url) {
            return url != null &&
                   url.isNotEmpty &&
                   url != '[Removed]' &&
                   !url.contains('null');
          }

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewsDetailPage(
                    title: item['title'] ?? 'Başlık Yok',
                    description: item['description'] ?? 'Açıklama Yok',
                    imageUrl: imageUrl,
                    content: item['content'] ?? 'İçerik Yok',
                    sourceUrl: item['url'],
                    sourceName: item['source']['name'],
                    publishedAt: item['publishedAt'],
                  ),
                ),
              );
            },
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect( // Resim kenarlarını yuvarlatmak için eklendi
                    borderRadius: BorderRadius.circular(16.0),
                    child: isImageUrlValid(imageUrl)
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/images/placeholder.png',
                                fit: BoxFit.cover,
                              );
                            },
                          )
                        : Image.asset(
                            'assets/images/placeholder.png',
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.1),
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 40.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'] ?? 'Başlık Yok',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item['description'] ?? '',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        pagination: const SwiperPagination(
          margin: EdgeInsets.only(bottom: 10.0, right: 10.0),
          alignment: Alignment.bottomRight,
          builder: FractionPaginationBuilder(
            color: Colors.white,
            activeColor: Colors.white,
            fontSize: 14.0,
            activeFontSize: 16.0,
          ),
        ),
      ),
    );
  }
}