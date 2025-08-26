// lib/services/football_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class FootballService {
  final String apiKey = '123';
  final String baseUrl = 'https://www.thesportsdb.com/api/v1/json';

  // TheSportsDB'de Süper Lig'in ID'si
  final String superLigId = '4339';
  // Lig adını da kullanabiliriz.
  final String superLigName = 'Turkish_Super_Lig';

  // Takım listesini çeken metot
  Future<List<dynamic>> getTeams() async {
    final url = Uri.parse('$baseUrl/$apiKey/search_all_teams.php?l=$superLigName');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> teams = data['teams'] ?? [];

      // Her takım için detaylı bilgi ve logo çekme işlemi
      final List<Future<dynamic>> logoFutures = teams.map((team) {
        return getTeamDetails(team['idTeam']);
      }).toList();

      final List<dynamic> detailedTeams = await Future.wait(logoFutures);

      return detailedTeams;
    } else {
      throw Exception('Takımlar yüklenemedi. Durum Kodu: ${response.statusCode}');
    }
  }

  // Takım detaylarını (logo dahil) çeken yeni metot
  Future<dynamic> getTeamDetails(String teamId) async {
    final url = Uri.parse('$baseUrl/$apiKey/lookupteam.php?id=$teamId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['teams'] != null && data['teams'].isNotEmpty) {
        return data['teams'][0];
      }
      return null;
    }
    return null;
  }

  // Sonraki maçları çeken metot
  Future<List<dynamic>> getUpcomingMatches() async {
    // eventsnextleague.php uç noktası kullanılıyor
    final url = Uri.parse('$baseUrl/$apiKey/eventsnextleague.php?id=$superLigId');

    try {
      final response = await http.get(url);

      // API yanıtının boş olup olmadığını kontrol et
      if (response.body.isEmpty) {
        return [];
      }

      final data = json.decode(response.body);

      // Gelen verinin yapısını kontrol et
      if (data['events'] == null) {
        return [];
      }

      return data['events'];
    } catch (e) {
      throw Exception('Maçlar yüklenemedi. Detay: $e');
    }
  }

  Future<dynamic> getUpcomingTeamMatch(String teamId) async {
    final url = Uri.parse('$baseUrl/$apiKey/eventsnext.php?id=$teamId');

    try {
      final response = await http.get(url);

      if (response.body.isEmpty) {
        return null;
      }

      final data = json.decode(response.body);

      if (data['events'] == null || data['events'].isEmpty) {
        return null;
      }

      return data['events'][0]; // Sadece ilk maçı döndürüyoruz
    } catch (e) {
      return null;
    }
  }
}