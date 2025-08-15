// lib/widgets/news_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/pages/news_detail_page.dart';

class NewsCard extends StatelessWidget {
  final String title;
  final String? description;
  final String? imageUrl;
  final String content;
  final String? sourceUrl;
  final String? sourceName;
  final String? publishedAt;
  final VoidCallback onTap;

  const NewsCard({
    required this.title,
    this.description,
    this.imageUrl,
    required this.content,
    this.sourceUrl,
    this.sourceName,
    this.publishedAt,
    required this.onTap,
    super.key,
  });

  // Tarih ve saati güvenilir bir şekilde formatlayan fonksiyon
  String _formatPublishedAt(String? dateString) {
    if (dateString == null) {
      return 'Tarih Yok';
    }
    try {
      final dateTimeUtc = DateTime.parse(dateString);
      final localDateTime = dateTimeUtc.toLocal();
      return DateFormat('dd MMMM yyyy, HH:mm', 'tr_TR').format(localDateTime);
    } catch (e) {
      // Ayrıştırma başarısız olursa orijinal metni döndürürüz.
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 4.0,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewsDetailPage(
                title: title,
                description: description,
                imageUrl: imageUrl,
                content: content,
                sourceUrl: sourceUrl,
                sourceName: sourceName,
                publishedAt: publishedAt,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Resim URL'si geçerli olduğunda resim yükleniyor
              if (imageUrl != null && imageUrl!.isNotEmpty && imageUrl != '[Removed]' && !imageUrl!.contains('null'))
                ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      imageUrl!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      // Hatalı resim yerine placeholder kullanıldı
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/placeholder.png',
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                ]
              else
                // Resim URL'si yoksa veya geçersizse placeholder göster
                ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset(
                      'assets/images/placeholder.png',
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              if (sourceName != null || publishedAt != null)
                Text(
                  '${sourceName ?? ''}${sourceName != null && publishedAt != null ? ' - ' : ''}${_formatPublishedAt(publishedAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              const SizedBox(height: 8),
              if (description != null)
                Text(
                  description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }
}