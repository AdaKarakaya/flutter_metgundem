// lib/pages/daily_summary_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart'; 

class DailySummaryPage extends StatefulWidget {
  final String title;
  final String summaryText;

  const DailySummaryPage({
    required this.title,
    required this.summaryText,
    super.key,
  });

  @override
  State<DailySummaryPage> createState() => _DailySummaryPageState();
}

class _DailySummaryPageState extends State<DailySummaryPage> {
  final FlutterTts flutterTts = FlutterTts();
  bool _isSpeaking = false;
  bool _isTtsInitialized = false; 

  @override
  void initState() {
    super.initState();
    _initializeTts();
  }

  Future<void> _initializeTts() async {
    await flutterTts.setLanguage("tr-TR");
    
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);

    flutterTts.setStartHandler(() {
      if (mounted) {
        setState(() {
          _isSpeaking = true;
        });
      }
    });

    flutterTts.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
        });
      }
    });

    flutterTts.setErrorHandler((msg) {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
        });
      }
    });

    if (mounted) {
      setState(() {
        _isTtsInitialized = true;
      });
    }
  }

  Future<void> _speak() async {
    // Okuma işleminden önce mevcut tüm komutları durdur
    await flutterTts.stop();
    await Future.delayed(const Duration(milliseconds: 100)); // Kısa bir bekleme ekle

    if (_isTtsInitialized && widget.summaryText.isNotEmpty) {
      await flutterTts.speak(widget.summaryText);
    }
  }

  Future<void> _stop() async {
    await flutterTts.stop();
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            expandedHeight: 200,
            floating: false,
            pinned: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF4A148C), 
                    Color(0xFFF06292), 
                    Color(0xFFF4511E), 
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.flash_on, color: Colors.white, size: 80),
                    const SizedBox(height: 8),
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Günlük Özet Metni',
                        style: Theme.of(context).textTheme.titleLarge ?? const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Divider(height: 24),
                      Text(
                        widget.summaryText,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5) ?? const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: IconButton(
                          onPressed: _isTtsInitialized ? (_isSpeaking ? _stop : () {
                            setState(() {
                              _isSpeaking = true;
                            });
                            _speak();
                          }) : null,
                          icon: Icon(
                            _isSpeaking ? Icons.pause_circle_filled : Icons.play_circle_fill,
                            size: 60,
                            color: _isTtsInitialized ? Theme.of(context).colorScheme.primary : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}