import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/firebase_options.dart';
import 'package:flutter_application_1/pages/news_page.dart';
import 'package:flutter_application_1/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

import 'package:flutter_application_1/utils/http_override.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _onThemeModeChanged(ThemeMode newThemeMode) {
    setState(() {
      _themeMode = newThemeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Haber Uygulaması',
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
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            
           

            return NewsPage(
              currentThemeMode: _themeMode,
              onThemeModeChanged: _onThemeModeChanged,
              
            );
          }
          return const LoginPage();
        },
      ),
    );
  }
}