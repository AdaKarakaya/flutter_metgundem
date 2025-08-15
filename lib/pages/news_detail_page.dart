// lib/pages/news_detail_page.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_tts/flutter_tts.dart';

class NewsDetailPage extends StatefulWidget {
  final String title;
  final String? description;
  final String? imageUrl;
  final String? content;
  final String? sourceUrl;
  final String? sourceName;
  final String? publishedAt;

  const NewsDetailPage({
    required this.title,
    this.description,
    this.imageUrl,
    this.content,
    this.sourceUrl,
    this.sourceName,
    this.publishedAt,
    super.key,
  });

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  bool isSaved = false;

  late FlutterTts flutterTts;
  TtsState ttsState = TtsState.stopped;
  bool _isTtsInitialized = false; // Yeni eklenen değişken

  @override
  void initState() {
    super.initState();
    _checkSavedStatus();
    _initTts();
  }

  void _initTts() async {
    flutterTts = FlutterTts();
    await flutterTts.setLanguage("tr-TR");
    flutterTts.setCompletionHandler(() {
      setState(() {
        ttsState = TtsState.stopped;
      });
    });
    setState(() {
      _isTtsInitialized = true;
    });
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  Future<void> _checkSavedStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedNewsJson = prefs.getString('saved_news');
    if (savedNewsJson != null) {
      List<dynamic> savedNews = json.decode(savedNewsJson);
      isSaved = savedNews.any((item) => item['sourceUrl'] == widget.sourceUrl);
      setState(() {});
    }
  }

  void _toggleSave() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedNewsJson = prefs.getString('saved_news');
    List<dynamic> savedNews = [];
    if (savedNewsJson != null) {
      savedNews = json.decode(savedNewsJson);
    }

    if (isSaved) {
      savedNews.removeWhere((item) => item['sourceUrl'] == widget.sourceUrl);
      await prefs.setString('saved_news', json.encode(savedNews));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Haber kaldırıldı.')),
      );
    } else {
      savedNews.add({
        'title': widget.title,
        'description': widget.description,
        'imageUrl': widget.imageUrl,
        'content': widget.content,
        'sourceUrl': widget.sourceUrl,
        'sourceName': widget.sourceName,
        'publishedAt': widget.publishedAt,
      });
      await prefs.setString('saved_news', json.encode(savedNews));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Haber kaydedildi.')),
      );
    }

    setState(() {
      isSaved = !isSaved;
    });
  }

  void _shareNews() {
    if (widget.sourceUrl != null && widget.sourceUrl!.isNotEmpty) {
      Share.share('${widget.title}\n\n${widget.sourceUrl}');
    } else {
      Share.share(widget.title);
    }
  }

  Future _speak() async {
    // Ses motorunun hazır olup olmadığını kontrol et
    if (!_isTtsInitialized) return;

    if (ttsState == TtsState.stopped || ttsState == TtsState.paused) {
      String textToSpeak = widget.title + ". " + (widget.description ?? "") + ". " + (widget.content ?? "");
      String cleanedText = textToSpeak.replaceAll(RegExp(r'\s*\[\+\d+ chars\]\s*$'), '');
      var result = await flutterTts.speak(cleanedText);
      if (result == 1) setState(() => ttsState = TtsState.playing);
    } else if (ttsState == TtsState.playing) {
      var result = await flutterTts.pause();
      if (result == 1) setState(() => ttsState = TtsState.paused);
    }
  }

  Future _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  Future<void> _launchUrl() async {
    if (widget.sourceUrl != null && widget.sourceUrl!.isNotEmpty) {
      if (!await launchUrl(Uri.parse(widget.sourceUrl!), mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch ${widget.sourceUrl}');
      }
    }
  }

  String _formatPublishedDate(String? dateString) {
    if (dateString == null) return 'Tarih Yok';
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
    String combinedText = '';
    if (widget.description != null && widget.description!.isNotEmpty) {
      combinedText += widget.description!;
    }
    if (widget.content != null && widget.content!.isNotEmpty) {
      String cleanedContent = widget.content!.replaceAll(RegExp(r'\s*\[\+\d+ chars\]\s*$'), '');
      if (combinedText.isNotEmpty) {
        combinedText += '\n\n';
      }
      combinedText += cleanedContent;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Haber Detayı'),
        actions: [
          IconButton(
            icon: Icon(
              isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: isSaved ? Colors.yellow.shade800 : null,
            ),
            onPressed: _toggleSave,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareNews,
          ),
          IconButton(
  icon: Icon(
    ttsState == TtsState.playing ? Icons.pause : Icons.volume_up,
  ),
  onPressed: _isTtsInitialized
      ? () {
          if (ttsState == TtsState.playing) {
            _stop(); // Eğer ses çalıyorsa, durdur
          } else {
            _speak(); // Ses çalmıyorsa, başlat
          }
        }
      : null,
),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(
                  widget.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Icon(Icons.broken_image, size: 50, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5)),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            Text(
              widget.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Theme.of(context).textTheme.headlineMedium?.color,
              ),
            ),
            const SizedBox(height: 12),
            if (widget.sourceName != null || widget.publishedAt != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.sourceName != null)
                    Text(
                      'Kaynak: ${widget.sourceName}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  if (widget.publishedAt != null)
                    Text(
                      'Yayın Tarihi: ${_formatPublishedDate(widget.publishedAt)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                          ),
                    ),
                ],
              ),
            const SizedBox(height: 20),
            if (combinedText.isNotEmpty)
              Text(
                combinedText,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            
            const SizedBox(height: 20),
            
            if (widget.sourceUrl != null && widget.sourceUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: ElevatedButton.icon(
                  onPressed: _launchUrl,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Habere Git'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

enum TtsState { playing, stopped, paused }