// lib/pages/football_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/team_detail_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/providers/football_provider.dart';

class FootballPage extends ConsumerWidget {
  const FootballPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Süper Lig'),
          backgroundColor: Theme.of(context).primaryColor,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Takımlar'),
              Tab(text: 'Sonraki Maçlar'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTeamsTab(ref),
            _buildUpcomingMatchesTab(ref),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamsTab(WidgetRef ref) {
    final teamsAsyncValue = ref.watch(teamsProvider);

    return teamsAsyncValue.when(
      data: (teams) {
        if (teams.isEmpty) {
          return const Center(child: Text('Takım verisi bulunamadı.'));
        }
        return ListView.builder(
          itemCount: teams.length,
          itemBuilder: (context, index) {
            final team = teams[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                // Logo kısmı tamamen kaldırıldı.
                title: Text(
                  team['strTeam'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(team['strStadium']),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TeamDetailPage(team: team),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Hata: $error')),
    );
  }

  Widget _buildUpcomingMatchesTab(WidgetRef ref) {
    final matchesAsyncValue = ref.watch(upcomingMatchesProvider);

    return matchesAsyncValue.when(
      data: (matches) {
        if (matches.isEmpty) {
          return const Center(child: Text('Sonraki maçlar verisi bulunamadı.'));
        }
        return ListView.builder(
          itemCount: matches.length,
          itemBuilder: (context, index) {
            final match = matches[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      '${match['dateEvent']} ${match['strTime']}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildTeamInfo(match['strHomeTeam'], match['strHomeTeamBadge']),
                        const Text(
                          'vs',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        _buildTeamInfo(match['strAwayTeam'], match['strAwayTeamBadge']),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Hata: $error')),
    );
  }
}

Widget _buildTeamInfo(String teamName, String? teamBadgeUrl) {
  return Column(
    children: [
      if (teamBadgeUrl != null && teamBadgeUrl.isNotEmpty)
        Image.network(
          teamBadgeUrl,
          width: 60,
          height: 60,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const CircularProgressIndicator();
          },
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.shield_outlined, size: 60, color: Colors.grey);
          },
        )
      else
        const Icon(Icons.shield_outlined, size: 60, color: Colors.grey),
      const SizedBox(height: 8),
      SizedBox(
        width: 100,
        child: Text(
          teamName,
          style: const TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}