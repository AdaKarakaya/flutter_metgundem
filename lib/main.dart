import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/pages/news_page.dart';
import 'package:flutter_application_1/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

import 'package:flutter_application_1/utils/http_override.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/providers/theme_provider.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart'; // flutter_dotenv paketini ekle
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform; // Platform tespiti için gerekli

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

  // .env dosyasını yükle
  await dotenv.load(fileName: ".env");

  // Platforma göre doğru FirebaseOptions'ı seç
  FirebaseOptions? options;

  if (kIsWeb) {
    options = FirebaseOptions(
      apiKey: dotenv.env['WEB_API_KEY']!,
      appId: dotenv.env['WEB_APP_ID']!,
      messagingSenderId: dotenv.env['WEB_MESSAGING_SENDER_ID']!,
      projectId: dotenv.env['WEB_PROJECT_ID']!,
      authDomain: dotenv.env['WEB_AUTH_DOMAIN'],
      storageBucket: dotenv.env['WEB_STORAGE_BUCKET'],
      measurementId: dotenv.env['WEB_MEASUREMENT_ID'],
    );
  } else if (defaultTargetPlatform == TargetPlatform.android) {
    options = FirebaseOptions(
      apiKey: dotenv.env['ANDROID_API_KEY']!,
      appId: dotenv.env['ANDROID_APP_ID']!,
      messagingSenderId: dotenv.env['ANDROID_MESSAGING_SENDER_ID']!,
      projectId: dotenv.env['ANDROID_PROJECT_ID']!,
      storageBucket: dotenv.env['ANDROID_STORAGE_BUCKET'],
    );
  } else if (defaultTargetPlatform == TargetPlatform.iOS) {
    options = FirebaseOptions(
      apiKey: dotenv.env['IOS_API_KEY']!,
      appId: dotenv.env['IOS_APP_ID']!,
      messagingSenderId: dotenv.env['IOS_MESSAGING_SENDER_ID']!,
      projectId: dotenv.env['IOS_PROJECT_ID']!,
      storageBucket: dotenv.env['IOS_STORAGE_BUCKET'],
      iosBundleId: dotenv.env['IOS_BUNDLE_ID'],
      // Android client id sadece iOS için gerekli olabilir.
    );
  } else if (defaultTargetPlatform == TargetPlatform.macOS) {
    options = FirebaseOptions(
      apiKey: dotenv.env['MACOS_API_KEY']!,
      appId: dotenv.env['MACOS_APP_ID']!,
      messagingSenderId: dotenv.env['MACOS_MESSAGING_SENDER_ID']!,
      projectId: dotenv.env['MACOS_PROJECT_ID']!,
      storageBucket: dotenv.env['MACOS_STORAGE_BUCKET'],
      androidClientId: dotenv.env['MACOS_ANDROID_CLIENT_ID'],
      iosBundleId: dotenv.env['MACOS_BUNDLE_ID'],
    );
  }

  // Yalnızca geçerli bir platform için seçenekler varsa Firebase'i başlat
  if (options != null) {
    await Firebase.initializeApp(
      options: options,
    );
  }

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
            return const NewsPage();
          }
          return const LoginPage();
        },
      ),
    );
  }
}