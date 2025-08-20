import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/pages/news_page.dart';
import 'package:flutter_application_1/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

import 'package:flutter_application_1/utils/http_override.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/providers/theme_provider.dart';
import 'package:flutter_application_1/services/firestore_service.dart';

// envied paketinden oluşturulan Env sınıfını import edin
import 'package:flutter_application_1/env/env.dart'; 

import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

  // Platforma göre doğru FirebaseOptions'ı seç
  FirebaseOptions? options;

  if (kIsWeb) {
    options = FirebaseOptions(
      apiKey: Env.webApiKey,
      appId: Env.webAppId,
      messagingSenderId: Env.webMessagingSenderId,
      projectId: Env.webProjectId,
      authDomain: Env.webAuthDomain,
      storageBucket: Env.webStorageBucket,
      measurementId: Env.webMeasurementId,
    );
  } else if (defaultTargetPlatform == TargetPlatform.android) {
    options = FirebaseOptions(
      apiKey: Env.androidApiKey,
      appId: Env.androidAppId,
      messagingSenderId: Env.androidMessagingSenderId,
      projectId: Env.androidProjectId,
      storageBucket: Env.androidStorageBucket,
    );
  } else if (defaultTargetPlatform == TargetPlatform.iOS) {
    options = FirebaseOptions(
      apiKey: Env.iosApiKey,
      appId: Env.iosAppId,
      messagingSenderId: Env.iosMessagingSenderId,
      projectId: Env.iosProjectId,
      storageBucket: Env.iosStorageBucket,
      iosBundleId: Env.iosBundleId,
    );
  } else if (defaultTargetPlatform == TargetPlatform.macOS) {
    options = FirebaseOptions(
      apiKey: Env.macosApiKey,
      appId: Env.macosAppId,
      messagingSenderId: Env.macosMessagingSenderId,
      projectId: Env.macosProjectId,
      storageBucket: Env.macosStorageBucket,
      androidClientId: Env.macosAndroidClientId,
      iosBundleId: Env.macosBundleId,
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
            // Firestore dokümanını kontrol et ve gerekirse oluştur
            return FutureBuilder(
              future: FirestoreService().createUserDocument(),
              builder: (context, futureSnapshot) {
                if (futureSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (futureSnapshot.hasError) {
                  // Hata oluşursa, yine de uygulamayı göster
                  print("Firestore dokümanı oluşturulurken hata oluştu: ${futureSnapshot.error}");
                  return const NewsPage();
                }
                return const NewsPage();
              },
            );
          }
          return const LoginPage();
        },
      ),
    );
  }
}