// lib/providers/football_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/services/football_service.dart';

final footballServiceProvider = Provider((ref) => FootballService());

// Takımlar için yeni provider
final teamsProvider = FutureProvider<List<dynamic>>((ref) async {
  return ref.read(footballServiceProvider).getTeams();
});

final upcomingMatchesProvider = FutureProvider<List<dynamic>>((ref) async {
  return ref.read(footballServiceProvider).getUpcomingMatches();
});