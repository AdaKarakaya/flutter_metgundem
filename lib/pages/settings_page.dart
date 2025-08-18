import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod'u import et
import 'package:flutter_application_1/providers/theme_provider.dart'; // Tema sağlayıcınızı import edin

class SettingsPage extends ConsumerWidget { // StatefulWidget yerine ConsumerWidget kullan
  final String userName;
  final String? photoUrl;

  const SettingsPage({
    required this.userName,
    this.photoUrl,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Riverpod'dan tema modunu dinleyin
    final themeMode = ref.watch(themeProvider);

    final user = FirebaseAuth.instance.currentUser;
    final isGoogleUser = user?.providerData.any((info) => info.providerId == 'google.com') ?? false;

    // _userNameController ve _passwordController gibi durumları yönetmek için Riverpod kullanabilirsin
    // Ancak şimdilik mevcut yapıyı koruyalım
    final _userNameController = TextEditingController(text: userName);
    final _passwordController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    // Bu metotları doğrudan burada tanımlayabiliriz
    void _saveChanges() async {
      // Değişiklikler aynı kalabilir
      // ...
    }

    void _updatePassword() async {
      // Değişiklikler aynı kalabilir
      // ...
    }

    void _deleteAccount() async {
      // Değişiklikler aynı kalabilir
      // ...
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
                child: photoUrl == null
                    ? Icon(Icons.person, size: 50, color: Theme.of(context).colorScheme.primary)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Kullanıcı Adı',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _userNameController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'Adınızı girin',
                labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7)),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _saveChanges,
                icon: const Icon(Icons.save),
                label: const Text('Değişiklikleri Kaydet'),
              ),
            ),
            const SizedBox(height: 20),
            if (!isGoogleUser) ...[
              Text(
                'Şifreyi Güncelle',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Yeni şifre',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 6) {
                      return 'Şifre en az 6 karakter olmalıdır.';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: _updatePassword,
                  icon: const Icon(Icons.lock),
                  label: const Text('Şifreyi Değiştir'),
                ),
              ),
              const SizedBox(height: 20),
            ],
            Text(
              'Uygulama Teması',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListTile(
              title: const Text('Sistem Teması'),
              leading: Radio<ThemeMode>(
                value: ThemeMode.system,
                groupValue: themeMode,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(themeProvider.notifier).setThemeMode(value);
                  }
                },
                activeColor: Theme.of(context).colorScheme.primary,
              ),
            ),
            ListTile(
              title: const Text('Açık Tema'),
              leading: Radio<ThemeMode>(
                value: ThemeMode.light,
                groupValue: themeMode,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(themeProvider.notifier).setThemeMode(value);
                  }
                },
                activeColor: Theme.of(context).colorScheme.primary,
              ),
            ),
            ListTile(
              title: const Text('Koyu Tema'),
              leading: Radio<ThemeMode>(
                value: ThemeMode.dark,
                groupValue: themeMode,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(themeProvider.notifier).setThemeMode(value);
                  }
                },
                activeColor: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Divider(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5)),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: TextButton.icon(
                onPressed: _deleteAccount,
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                label: const Text('Hesabı Sil', style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}