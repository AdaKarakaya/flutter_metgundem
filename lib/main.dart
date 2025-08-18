import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/firebase_options.dart';
import 'package:flutter_application_1/pages/news_page.dart';
import 'package:flutter_application_1/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

import 'package:flutter_application_1/utils/http_override.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod'u import et
import 'package:flutter_application_1/providers/theme_provider.dart'; // Tema sağlayıcınızı import edin

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Uygulamayı ProviderScope ile sarın
  runApp(const ProviderScope(child: MyApp()));
}

// StatefulWidget yerine ConsumerWidget kullanın
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // themeProvider'ı dinleyerek tema modunu alın
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Haber Uygulaması',
      themeMode: themeMode, // Riverpod'dan gelen temayı kullan
      debugShowCheckedModeBanner: false,
      // Açık tema için özelleştirmeler
      theme: ThemeData.light().copyWith(
        primaryColor: const Color(0xFF4A148C), // Koyu mor
        scaffoldBackgroundColor: Colors.white,
        cardColor: Colors.grey[200], // Açık temada kart rengi
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black87),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4A148C),
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        drawerTheme: const DrawerThemeData(
          backgroundColor: Colors.white,
        ),
        // ColorScheme ayarları
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.deepPurple,
        ).copyWith(
          secondary: const Color(0xFFF06292), // Pembe vurgu rengi
        ),
      ),
      // Koyu tema için özelleştirmeler
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFFF06292), // Koyu temada pembe tonu
        scaffoldBackgroundColor: const Color(0xFF121212), // Koyu siyah
        cardColor: const Color(0xFF1F1B24), // Koyu temada kart rengi
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F1B24),
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        drawerTheme: const DrawerThemeData(
          backgroundColor: Color(0xFF1F1B24),
        ),
        // ColorScheme ayarları
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.deepPurple,
          brightness: Brightness.dark,
        ).copyWith(
          secondary: const Color(0xFFF06292), // Pembe vurgu rengi
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            // NewsPage artık tema parametrelerini almıyor
            return const NewsPage();
          }
          return const LoginPage();
        },
      ),
    );
  }
}