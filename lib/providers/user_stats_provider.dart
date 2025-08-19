import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Yardımcı fonksiyon: Bir haritadaki en büyük değere sahip anahtarı bulur
String _findMaxKey(Map<String, dynamic> counts) {
  if (counts.isEmpty) {
    return 'Belirsiz';
  }

  String maxKey = 'Belirsiz';
  int maxValue = -1;

  counts.forEach((key, value) {
    if (value is int) {
      if (value > maxValue) {
        maxValue = value;
        maxKey = key;
      }
    }
  });

  return maxKey;
}

// Firestore'dan kullanıcı istatistiklerini dinleyen ve hesaplamaları yapan provider
final userStatsProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    // Kullanıcı oturum açmamışsa varsayılan boş veri gönder
    return Stream.value({
      'readCount': 0,
      'favoriteCategory': 'Belirsiz',
      'mostActiveDay': 'Belirsiz',
      'displayName': 'Misafir',
      'email': 'misafir@mail.com',
      'photoURL': null,
      'badges': {},
      'categoryCounts': {},
    });
  }

  // Kullanıcının belgesini dinle
  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((snapshot) {
    // Belge verisini al, eğer yoksa boş bir Map döndür
    final data = snapshot.data();
    if (data == null || !snapshot.exists) {
      // Eğer belge yoksa veya boşsa, varsayılan değerleri döndür
      return {
        'readCount': 0,
        'favoriteCategory': 'Belirsiz',
        'mostActiveDay': 'Belirsiz',
        'displayName': user.displayName ?? 'Kullanıcı Adı',
        'email': user.email ?? 'E-posta',
        'photoURL': user.photoURL,
        'badges': {},
        'categoryCounts': {},
      };
    }

    final stats = data['stats'] as Map<String, dynamic>? ?? {};
    final readCount = stats['readCount'] as int? ?? 0;
    
    // En çok okunan kategoriyi bulma
    final categoryCounts = stats['categoryCounts'] as Map<String, dynamic>? ?? {};
    final favoriteCategory = _findMaxKey(categoryCounts);

    // En aktif günü bulma
    final dayCounts = stats['dayCounts'] as Map<String, dynamic>? ?? {};
    final mostActiveDay = _findMaxKey(dayCounts);

    return {
      'readCount': readCount,
      'favoriteCategory': favoriteCategory,
      'mostActiveDay': mostActiveDay,
      'displayName': data['displayName'] ?? 'Kullanıcı Adı',
      'email': data['email'] ?? 'E-posta',
      'photoURL': data['photoURL'],
      'badges': data['badges'] as Map<String, dynamic>? ?? {},
      'categoryCounts': categoryCounts, // Debug için ekledik
    };
  });
});