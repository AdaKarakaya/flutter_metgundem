// lib/widgets/news_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  String _formatPublishedAt(String? dateString) {
    if (dateString == null) {
      return 'Tarih Yok';
    }
    try {
      final dateTimeUtc = DateTime.parse(dateString);
      final localDateTime = dateTimeUtc.toLocal();
      return DateFormat('dd MMMM yyyy, HH:mm', 'tr_TR').format(localDateTime);
    } catch (e) {
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
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Resim bölümü
            if (imageUrl != null && imageUrl!.isNotEmpty && imageUrl != '[Removed]' && !imageUrl!.contains('null'))
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  topRight: Radius.circular(12.0),
                ),
                child: Image.network(
                  imageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/placeholder.png',
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              )
            else
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  topRight: Radius.circular(12.0),
                ),
                child: Image.asset(
                  'assets/images/placeholder.png',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

            // İçerik bölümü
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Haber Başlığı
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Kaynak ve Tarih Bilgisi
                  if (sourceName != null || publishedAt != null)
                    Text(
                      '${sourceName ?? 'Kaynak Yok'} • ${_formatPublishedAt(publishedAt)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        // ignore: deprecated_member_use
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),

                  const SizedBox(height: 12),
                  
                  // Açıklama
                  if (description != null && description!.isNotEmpty)
                    Text(
                      description!,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}