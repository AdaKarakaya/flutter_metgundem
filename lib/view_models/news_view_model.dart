// lib/view_models/news_view_model.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NewsViewModel extends ChangeNotifier {
  // Arama durumunu yöneten değişken
  bool _isSearching = false;
  bool get isSearching => _isSearching;

  // Arama kontrolcüsü
  final TextEditingController _searchController = TextEditingController();
  TextEditingController get searchController => _searchController;

  void toggleSearch() {
    _isSearching = !_isSearching;
    if (!_isSearching) {
      _searchController.clear();
      // Buraya kategoriye göre filtreleme mantığı gelebilir
    }
    notifyListeners(); // Durum değişikliğini dinleyicilere bildir
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

// NewsViewModel'ı sağlayan provider
final newsViewModelProvider = ChangeNotifierProvider<NewsViewModel>((ref) {
  return NewsViewModel();
});