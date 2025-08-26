// lib/pages/team_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/football_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final footballServiceProvider = Provider((ref) => FootballService());

final teamNextMatchProvider = FutureProvider.family<dynamic, String>((ref, teamId) async {
  return ref.read(footballServiceProvider).getUpcomingTeamMatch(teamId);
});

class TeamDetailPage extends ConsumerWidget {
  final Map<String, dynamic> team;

  const TeamDetailPage({super.key, required this.team});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String teamId = team['idTeam'] ?? '';
    final nextMatchAsyncValue = ref.watch(teamNextMatchProvider(teamId));
    final colorScheme = Theme.of(context).colorScheme;

    final String? teamLogoFromMatch = nextMatchAsyncValue.when(
      data: (match) {
        if (match != null) {
          if (match['idHomeTeam'] == teamId) {
            return match['strHomeTeamBadge'];
          } else if (match['idAwayTeam'] == teamId) {
            return match['strAwayTeamBadge'];
          }
        }
        return null;
      },
      loading: () => null,
      error: (error, stack) => null,
    );

    final String? finalLogoUrl = (team['strTeamBadge'] != null && team['strTeamBadge'].isNotEmpty)
        ? team['strTeamBadge']
        : teamLogoFromMatch;

    final double appBarHeight = kToolbarHeight + MediaQuery.of(context).padding.top;

        return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Temaya duyarlı zemin rengi
      appBar: AppBar(
        title: Text(team['strTeam']),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor, // Temaya duyarlı AppBar rengi
        elevation: 0,
        iconTheme: Theme.of(context).iconTheme, // Tema için ikon rengi
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: appBarHeight),
            Container(
              height: 250,
decoration: const BoxDecoration(
  gradient: LinearGradient(
    colors: [Color(0xFF5D3FD3), Color(0xFFC71585)], // Daha yumuşak mor ve macenta tonları
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  ),
),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.transparent,
                    child: (finalLogoUrl != null && finalLogoUrl.isNotEmpty)
                        ? Image.network(
                            finalLogoUrl,
                            width: 120,
                            height: 120,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const CircularProgressIndicator(
                                color: Colors.white,
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.shield_outlined, size: 60, color: colorScheme.onBackground); // Temaya duyarlı ikon rengi
                            },
                          )
                        : Icon(Icons.shield_outlined, size: 60, color: colorScheme.onBackground), // Temaya duyarlı ikon rengi
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      team['strTeam'],
                      style: TextStyle(
                        color: colorScheme.onPrimary, // Temaya duyarlı metin rengi
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: Theme.of(context).cardColor, // Temaya duyarlı kart rengi
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Column(
                    children: [
                      Text(
                        'Stadyum',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant, // Temaya duyarlı metin rengi
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        team['strStadium'] ?? 'Bilinmiyor',
                        style: TextStyle(
                          color: colorScheme.onSurface, // Temaya duyarlı metin rengi
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Sonraki Maç',
                style: TextStyle(
                  color: colorScheme.onSurface, // Temaya duyarlı metin rengi
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: nextMatchAsyncValue.when(
                data: (match) {
                  if (match == null) {
                    return Text(
                      'Sonraki maç bulunamadı.',
                      style: TextStyle(fontStyle: FontStyle.italic, color: colorScheme.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    );
                  }
                  return Card(
                    color: Theme.of(context).cardColor, // Temaya duyarlı kart rengi
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Text(
                            '${match['strHomeTeam']} vs ${match['strAwayTeam']}',
                            style: TextStyle(
                              color: colorScheme.onSurface, // Temaya duyarlı metin rengi
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tarih: ${match['dateEvent'] ?? 'Bilinmiyor'}',
                            style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)), // Temaya duyarlı metin rengi
                          ),
                          Text(
                            'Saat: ${match['strTime'] ?? 'Bilinmiyor'}',
                            style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)), // Temaya duyarlı metin rengi
                          ),
                        ],
                      ),
                    ),
                  );
                },
                loading: () => Center(child: CircularProgressIndicator(color: colorScheme.onBackground)),
                error: (error, stack) => Center(
                  child: Text(
                    'Maç verisi yüklenirken hata oluştu: $error',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}