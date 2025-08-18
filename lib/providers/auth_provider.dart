import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. AuthService sınıfı: Firebase Authentication işlemlerini yönetir
class AuthService {
  final FirebaseAuth _auth;

  AuthService(this._auth);

  // Kullanıcı durumunda bir değişiklik olduğunda bir stream yayınlayan provider
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Çıkış yapma metodu
  Future<void> signOut() async {
    await _auth.signOut();
  }
}

// 2. AuthService'i bir provider ile uygulamanın geri kalanına açın
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(FirebaseAuth.instance);
});

// 3. Kullanıcının giriş durumunu dinleyen stream provider
// Bu provider, AuthService'in authStateChanges stream'ini izler
final authStateChangesProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// 4. Kullanıcı adını sağlayan bir provider
// Bu, UI'da kullanıcı adını kolayca göstermek için kullanılır
final userNameProvider = Provider<String>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  return authState.when(
    data: (user) => user?.displayName ?? 'Misafir',
    loading: () => 'Yükleniyor...',
    error: (_, __) => 'Hata',
  );
});