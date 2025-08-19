import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/providers/version_provider.dart';

class AboutPage extends ConsumerWidget {
  const AboutPage({super.key});

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final versionAsyncValue = ref.watch(appVersionProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Hakkımızda',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(
          color: theme.colorScheme.onSurface,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Uygulama Logosu ve Sürüm
            Center(
              child: Image.asset('assets/images/logo.png', height: 120),
            ),
            const SizedBox(height: 16),
            Text(
              'Haber Uygulaması',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            versionAsyncValue.when(
              data: (version) => Text(
                'Versiyon $version',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              loading: () => Text(
                'Versiyon Yükleniyor...',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              error: (error, stackTrace) => Text(
                'Versiyon Bilgisi Alınamadı',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const Divider(height: 32),

            // Uygulama Hakkında Kartı
            Card(
              color: theme.cardColor,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Uygulama Hakkında',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Haber Uygulaması, güncel ve son dakika haberlerini kolayca takip etmeniz için tasarlanmış bir mobil platformdur. Kullanıcı dostu arayüzü sayesinde gündem, teknoloji, spor, ekonomi ve sağlık gibi çeşitli kategorilerdeki haberlere anında ulaşabilirsiniz.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Geliştirici Bilgileri Kartı
            Card(
              color: theme.cardColor,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Geliştirici',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                        child: Icon(
                          Icons.person_outline,
                          size: 36,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      title: Text(
                        'Metgün Grup',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        'Mobil Geliştirme Ekibi',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      onTap: () => _launchUrl('https://www.metgun.com.tr'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Bizi Takip Edin Kartı
            Card(
              color: theme.cardColor,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bizi Takip Edin',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: Icon(Icons.email, size: 36, color: theme.colorScheme.primary),
                          onPressed: () => _launchUrl('mailto:destek@metgun.com.tr'),
                        ),
                        IconButton(
                          icon: Icon(Icons.web, size: 36, color: theme.colorScheme.primary),
                          onPressed: () => _launchUrl('https://www.metgun.com.tr'),
                        ),
                        IconButton(
                          icon: Icon(Icons.code, size: 36, color: theme.colorScheme.primary),
                          onPressed: () => _launchUrl('https://github.com/AdaKarakaya'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Kullanılan Teknolojiler Kartı
            Card(
              color: theme.cardColor,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kullanılan Teknolojiler',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: [
                        _buildTechChip('Flutter', theme),
                        _buildTechChip('Dart', theme),
                        _buildTechChip('Firebase Auth', theme),
                        _buildTechChip('NewsAPI.org', theme),
                        _buildTechChip('Riverpod', theme),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Alt Kısım Bağlantıları
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const LicensePage(applicationName: 'Haber Uygulaması'),
                  ));
                },
                child: const Text('Açık Kaynak Lisansları'),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () => _launchUrl('https://www.metgun.com.tr/gizlilik-politikasi'),
                child: const Text('Gizlilik Politikası'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechChip(String label, ThemeData theme) {
    return Chip(
      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
      label: Text(
        label,
        style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.3)),
      ),
    );
  }
}