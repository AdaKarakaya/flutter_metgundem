import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/providers/theme_provider.dart';

class SettingsPage extends ConsumerWidget {
  final String userName;
  final String? photoUrl;

  const SettingsPage({
    required this.userName,
    this.photoUrl,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final user = FirebaseAuth.instance.currentUser;
    final isGoogleUser = user?.providerData.any((info) => info.providerId == 'google.com') ?? false;

    final _userNameController = TextEditingController(text: userName);
    final _passwordController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    void _saveChanges() async {
      // Değişiklikler aynı kalabilir
    }

    void _updatePassword() async {
      // Değişiklikler aynı kalabilir
    }

    void _deleteAccount() async {
      // Değişiklikler aynı kalabilir
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Ayarlar',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfileCard(context, userName, photoUrl, isDarkMode),
            const SizedBox(height: 32),
            _buildSectionHeader(context, 'Kullanıcı Bilgileri', isDarkMode),
            _buildUserInfoSection(context, _userNameController, isDarkMode, _saveChanges),
            const SizedBox(height: 24),
            if (!isGoogleUser) ...[
              _buildSectionHeader(context, 'Güvenlik', isDarkMode),
              _buildPasswordSection(context, _passwordController, _formKey, isDarkMode, _updatePassword),
              const SizedBox(height: 24),
            ],
            _buildSectionHeader(context, 'Uygulama Teması', isDarkMode),
            _buildThemeSection(context, ref, themeMode, isDarkMode),
            const SizedBox(height: 32),
            Center(
              child: TextButton.icon(
                onPressed: _deleteAccount,
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                label: const Text(
                  'Hesabı Sil',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, String userName, String? photoUrl, bool isDarkMode) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(isDarkMode ? 0.2 : 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
              child: photoUrl == null
                  ? Icon(Icons.person, size: 50, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              userName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Hoş geldin!',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoSection(BuildContext context, TextEditingController controller, bool isDarkMode, VoidCallback onSave) {
    return _buildSettingsCard(
      context,
      isDarkMode,
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextField(context, 'Kullanıcı Adı', controller, Icons.person_outline, isDarkMode),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: _buildActionButton('Kaydet', Icons.save, onSave, context),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordSection(BuildContext context, TextEditingController controller, GlobalKey<FormState> formKey, bool isDarkMode, VoidCallback onUpdate) {
    return _buildSettingsCard(
      context,
      isDarkMode,
      Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField(context, 'Yeni şifre', controller, Icons.lock_outline, isDarkMode, obscureText: true),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: _buildActionButton('Şifreyi Güncelle', Icons.lock_reset, onUpdate, context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSection(BuildContext context, WidgetRef ref, ThemeMode themeMode, bool isDarkMode) {
    return _buildSettingsCard(
      context,
      isDarkMode,
      Column(
        children: [
          _buildThemeOption(context, ref, 'Sistem Teması', ThemeMode.system, themeMode, Icons.smartphone, isDarkMode),
          _buildThemeOption(context, ref, 'Açık Tema', ThemeMode.light, themeMode, Icons.wb_sunny_outlined, isDarkMode),
          _buildThemeOption(context, ref, 'Koyu Tema', ThemeMode.dark, themeMode, Icons.mode_night_outlined, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, bool isDarkMode, Widget child) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(isDarkMode ? 0.2 : 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildTextField(BuildContext context, String labelText, TextEditingController controller, IconData icon, bool isDarkMode, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
        prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: isDarkMode ? Theme.of(context).cardColor.withOpacity(0.5) : Theme.of(context).colorScheme.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onPressed, BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildThemeOption(BuildContext context, WidgetRef ref, String title, ThemeMode value, ThemeMode groupValue, IconData icon, bool isDarkMode) {
    return RadioListTile<ThemeMode>(
      title: Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
      secondary: Icon(icon, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8)),
      value: value,
      groupValue: groupValue,
      onChanged: (newValue) {
        if (newValue != null) {
          ref.read(themeProvider.notifier).setThemeMode(newValue);
        }
      },
      activeColor: Theme.of(context).colorScheme.primary,
      tileColor: groupValue == value
          ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
          : Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    );
  }
}