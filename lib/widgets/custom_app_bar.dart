// lib/widgets/custom_app_bar.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ValueChanged<String> onCategorySelected;
  final String userName;
  final List<String> categories;
  final String selectedCategory;
  final String currentTime;

  CustomAppBar({
    required this.onCategorySelected,
    required this.userName,
    required this.categories,
    required this.selectedCategory,
    required this.currentTime,
    super.key,
  }) : formattedDate = DateFormat('dd MMMM yyyy, HH:mm').format(DateTime.now());

  final String formattedDate;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 64);

  @override
  Widget build(BuildContext context) {
    // isDarkMode değişkenini tekrar ekliyoruz
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF4A148C), // Morun koyu tonu
            Color(0xFFF06292), // Pembe tonu
            Color(0xFFF4511E), // Turuncu tonu
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AppBar(
            title: Row(
              children: [
                Image.asset('assets/images/logo.png', height: 30),
                const SizedBox(width: 8),
                const Text(
                  'Haberler',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    Text(formattedDate, style: const TextStyle(fontSize: 12, color: Colors.white70)),
                  ],
                ),
              ),
            ],
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              children: categories.map((category) {
                final isSelected = category == selectedCategory;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: FilterChip(
                    label: Text(
                      category,
                      style: TextStyle(
                        color: isSelected
                            ? (isDarkMode ? Colors.white : Colors.black) // Seçili çipin yazı rengini temaya göre ayarladık
                            : (isDarkMode ? Colors.white : Colors.black), // Seçili olmayan çipin yazı rengini temaya göre ayarladık
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      if (selected) {
                        onCategorySelected(category);
                      }
                    },
                    backgroundColor: isSelected
                        ? (isDarkMode ? Colors.white.withOpacity(0.4) : Colors.black.withOpacity(0.4)) // Seçili çipin arka planını temaya göre ayarladık
                        : (isDarkMode ? Colors.black.withOpacity(0.3) : Colors.white.withOpacity(0.8)), // Seçili olmayan çipin arka planını temaya göre ayarladık
                    selectedColor: isDarkMode
                        ? Colors.white.withOpacity(0.4)
                        : Colors.black.withOpacity(0.4), // Seçili çipin arka plan rengini temaya göre belirledik
                    checkmarkColor: isDarkMode ? Colors.white : Colors.black, // Onay işareti rengini temaya göre ayarladık
                    side: BorderSide(
                      color: isDarkMode ? Colors.white : Colors.black, // Kenarlık rengini temaya göre ayarladık
                      width: 1,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}