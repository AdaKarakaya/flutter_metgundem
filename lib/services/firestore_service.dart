import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createUserDocument() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docRef = _db.collection('users').doc(user.uid);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        await docRef.set({
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'photoURL': user.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
          'stats': {
            'readCount': 0,
            'likedCount': 0,
            'favoriteCategory': 'Belirsiz',
            'mostActiveDay': 'Belirsiz',
          },
          'badges': {
            'firstLogin': FieldValue.serverTimestamp(),
          }
        });
        print('Yeni kullanıcı dokümanı oluşturuldu.');
      } else {
        final data = docSnapshot.data() as Map<String, dynamic>;
        final Map<String, dynamic> updateData = {};
        
        if (!data.containsKey('stats')) {
          updateData['stats'] = {
            'readCount': 0,
            'likedCount': 0,
            'favoriteCategory': 'Belirsiz',
            'mostActiveDay': 'Belirsiz',
          };
        }
        
        if (!data.containsKey('badges')) {
          updateData['badges'] = {
            'firstLogin': FieldValue.serverTimestamp(),
          };
        }
        
        if (updateData.isNotEmpty) {
          await docRef.update(updateData);
          print('Mevcut kullanıcı dokümanına eksik alanlar eklendi.');
        }
      }
    }
  }

  // Yeni fonksiyon: Okuma istatistiklerini günceller
  Future<void> updateReadStats(String category) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        print('Firestore: updateReadStats fonksiyonu çağrıldı.');
        final userRef = _db.collection('users').doc(user.uid);
        
        // Haftanın gününü belirle (Pazartesi, Salı vb.)
        final now = DateTime.now();
        final daysOfWeek = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];
        final currentDay = daysOfWeek[now.weekday - 1];

        // Veritabanı güncelleme işlemi
        await userRef.update({
          'stats.readCount': FieldValue.increment(1),
          'stats.categoryCounts.$category': FieldValue.increment(1),
          'stats.dayCounts.$currentDay': FieldValue.increment(1),
        });

        print('Firestore: İstatistikler başarıyla güncellendi.');
      } catch (e) {
        print('Firestore: İstatistikler güncellenirken bir hata oluştu: $e');
      }
    } else {
      print('Firestore: Kullanıcı oturum açmamış.');
    }
  }
}