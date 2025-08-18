import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Mevcut kullanıcı adını sağlayan provider
// Kullanıcı adı değiştiğinde dinleyen widget'lar otomatik güncellenir.
final userNameProvider = Provider<String>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  return user?.displayName ?? 'Misafir';
});