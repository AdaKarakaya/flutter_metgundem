import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String _version = 'Yükleniyor...';

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _version = info.version;
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hakkımızda'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset('assets/images/logo.png', height: 100),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Haber Uygulaması',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Versiyon $_version', // Dinamik sürüm
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const Divider(height: 40),
            Text(
              'Uygulama Hakkında',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Haber Uygulaması, güncel ve son dakika haberlerini kolayca takip etmeniz için tasarlanmış bir mobil platformdur. Kullanıcı dostu arayüzü sayesinde gündem, teknoloji, spor, ekonomi ve sağlık gibi çeşitli kategorilerdeki haberlere anında ulaşabilirsiniz.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Text(
              'Geliştirici',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const ListTile(
              leading: Icon(Icons.person, size: 36),
              title: Text('Metgün Grup'),
              subtitle: Text('mobil geliştirme ekibi'),
            ),
            const SizedBox(height: 24),
            Text(
              'Bizi Takip Edin',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.email, size: 36),
                  onPressed: () => _launchUrl('mailto:destek@metgungrup.com'),
                ),
                IconButton(
                  icon: const Icon(Icons.web, size: 36),
                  onPressed: () => _launchUrl('https://www.metgungrup.com'),
                ),
                // Buraya diğer sosyal medya ikonları eklenebilir
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Kullanılan Teknolojiler',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: const [
                Chip(label: Text('Flutter')),
                Chip(label: Text('Dart')),
                Chip(label: Text('Firebase Auth')),
                Chip(label: Text('newsapi.org')),
              ],
            ),
            const Divider(height: 40),
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
                onPressed: () => _launchUrl('https://www.metgungrup.com/gizlilik-politikasi'),
                child: const Text('Gizlilik Politikası'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}