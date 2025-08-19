import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/providers/user_stats_provider.dart';

// UserProfilePage'i bir ConsumerWidget olarak güncelliyoruz
class UserProfilePage extends ConsumerWidget {
  const UserProfilePage({super.key});

  Widget _buildProfileBadge(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);
    return Chip(
      avatar: Icon(icon, color: theme.colorScheme.primary),
      label: Text(label, style: TextStyle(color: theme.colorScheme.onSurface)),
      backgroundColor: theme.colorScheme.surfaceVariant,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  Widget _buildStatisticItem(BuildContext context, String title, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface)),
          Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Yeni provider'ı dinlemeye başlıyoruz
    final userStatsAsyncValue = ref.watch(userStatsProvider);
    
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final List<Color> appBarGradientColors = isDarkMode
        ? [theme.colorScheme.primary, theme.colorScheme.secondary]
        : [
            Colors.purple.shade200.withOpacity(0.7),
            Colors.pink.shade100.withOpacity(0.7)
          ];
    
    final Color? backgroundColor = isDarkMode ? null : Colors.grey.shade50;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Profilim', style: TextStyle(color: theme.colorScheme.onSurface)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: appBarGradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: userStatsAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Hata: $err')),
        data: (userStats) {
          final readCount = userStats['readCount'] ?? 0;
          final favoriteCategory = userStats['favoriteCategory'] ?? 'Belirsiz';
          final mostActiveDay = userStats['mostActiveDay'] ?? 'Belirsiz';
          final name = userStats['displayName'] ?? 'Kullanıcı Adı';
          final email = userStats['email'] ?? 'E-posta';
          final photoURL = userStats['photoURL'];
          final badges = userStats['badges'] as Map<String, dynamic>? ?? {};

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profil Üst Bilgisi
                Card(
                  color: theme.cardColor,
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: photoURL != null ? NetworkImage(photoURL) : null,
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                          child: photoURL == null ? Icon(Icons.person, size: 50, color: theme.colorScheme.primary) : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          name,
                          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          email,
                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSecondaryContainer),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Rozetler
                Card(
                  color: theme.cardColor,
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Rozetler', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: [
                            if (badges.containsKey('firstLogin'))
                              _buildProfileBadge(context, Icons.star_border, 'İlk Giriş'),
                            // Diğer rozetler için de buraya benzer kontrol eklenecek.
                            // Örneğin: if (readCount >= 10) _buildProfileBadge(...)
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // İstatistikler
                Card(
                  color: theme.cardColor,
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('İstatistikler', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                        const SizedBox(height: 12),
                        _buildStatisticItem(context, 'Okunan Haberler', readCount.toString()),
                        _buildStatisticItem(context, 'Favori Kategori', favoriteCategory),
                        _buildStatisticItem(context, 'En Aktif Gün', mostActiveDay),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                    foregroundColor: theme.colorScheme.onError,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: const Text('Çıkış Yap'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}