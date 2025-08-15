import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsPage extends StatefulWidget {
  final ThemeMode currentThemeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final String userName;
  final String? photoUrl;

  const SettingsPage({
    required this.currentThemeMode,
    required this.onThemeModeChanged,
    required this.userName,
    this.photoUrl,
    super.key,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _userNameController = TextEditingController();
  final _passwordController = TextEditingController();
  late ThemeMode _internalThemeMode;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _userNameController.text = widget.userName;
    _internalThemeMode = widget.currentThemeMode;
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _saveChanges() async {
    final user = FirebaseAuth.instance.currentUser;
    final newUserName = _userNameController.text.trim();

    if (user != null && newUserName.isNotEmpty && newUserName != user.displayName) {
      try {
        await user.updateDisplayName(newUserName);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kullanıcı adı başarıyla güncellendi.')),
          );
          Navigator.pop(context, newUserName); // Yeni ismi geri döndür
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hata: Kullanıcı adı güncellenemedi. $e')),
          );
        }
      }
    } else {
      Navigator.pop(context, user?.displayName); // Değişiklik yoksa mevcut ismi geri döndür
    }
  }

  void _updatePassword() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      try {
        await user?.updatePassword(_passwordController.text);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Şifre başarıyla güncellendi.')),
          );
          _passwordController.clear();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hata: Şifre güncellenemedi. $e')),
          );
        }
      }
    }
  }

  void _deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hesabı Sil'),
        content: const Text('Hesabınızı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await user?.delete();
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Hesabınız başarıyla silindi.')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Hata: Hesap silinemedi. $e')),
                  );
                }
              }
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isGoogleUser = user?.providerData.any((info) => info.providerId == 'google.com') ?? false;

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
                backgroundImage: widget.photoUrl != null ? NetworkImage(widget.photoUrl!) : null,
                child: widget.photoUrl == null
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
                groupValue: _internalThemeMode,
                onChanged: (ThemeMode? value) {
                  if (value != null) {
                    setState(() => _internalThemeMode = value);
                    widget.onThemeModeChanged(value);
                  }
                },
                activeColor: Theme.of(context).colorScheme.primary,
              ),
            ),
            ListTile(
              title: const Text('Açık Tema'),
              leading: Radio<ThemeMode>(
                value: ThemeMode.light,
                groupValue: _internalThemeMode,
                onChanged: (ThemeMode? value) {
                  if (value != null) {
                    setState(() => _internalThemeMode = value);
                    widget.onThemeModeChanged(value);
                  }
                },
                activeColor: Theme.of(context).colorScheme.primary,
              ),
            ),
            ListTile(
              title: const Text('Koyu Tema'),
              leading: Radio<ThemeMode>(
                value: ThemeMode.dark,
                groupValue: _internalThemeMode,
                onChanged: (ThemeMode? value) {
                  if (value != null) {
                    setState(() => _internalThemeMode = value);
                    widget.onThemeModeChanged(value);
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