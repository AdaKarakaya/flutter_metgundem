import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Tema durumunu yöneten StateNotifier sınıfı
class ThemeNotifier extends StateNotifier<ThemeMode> {
  // Başlangıç teması olarak sistem temasını ayarlarız
  ThemeNotifier() : super(ThemeMode.system);

  // Dışarıdan yeni tema modunu ayarlamak için bir metot
  void setThemeMode(ThemeMode mode) {
    state = mode;
  }

  // Tema değiştirme butonu için bu metot eklendi
  void toggleTheme() {
    if (state == ThemeMode.light) {
      state = ThemeMode.dark;
    } else if (state == ThemeMode.dark) {
      state = ThemeMode.system;
    } else {
      state = ThemeMode.light;
    }
  }
}

// Uygulamanızın her yerinden erişebileceğiniz ana sağlayıcı
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});