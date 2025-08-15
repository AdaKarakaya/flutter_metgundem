// lib/pages/saved_news_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/news_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedNewsPage extends StatefulWidget {
  const SavedNewsPage({super.key});

  @override
  State<SavedNewsPage> createState() => _SavedNewsPageState();
}

class _SavedNewsPageState extends State<SavedNewsPage> {
  List<dynamic> _savedNews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedNews();
  }

  Future<void> _loadSavedNews() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedNewsJson = prefs.getString('saved_news');
    if (savedNewsJson != null) {
      setState(() {
        _savedNews = json.decode(savedNewsJson);
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kaydedilen Haberler'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _savedNews.isEmpty
              ? const Center(
                  child: Text(
                    'Henüz kaydedilmiş haber yok.',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: _savedNews.length,
                  itemBuilder: (context, index) {
                    final newsItem = _savedNews[index];
                    return NewsCard(
                      title: newsItem['title'] ?? 'Başlık Yok',
                      description: newsItem['description'],
                      imageUrl: newsItem['imageUrl'],
                      content: newsItem['content'] ?? 'İçerik Yok',
                      sourceUrl: newsItem['sourceUrl'],
                      sourceName: newsItem['sourceName'],
                      publishedAt: newsItem['publishedAt'],
                      onTap: () {
                        // Burada navigasyon detay sayfasına gidebilir
                      },
                    );
                  },
                ),
    );
  }
}