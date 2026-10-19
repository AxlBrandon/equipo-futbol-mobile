import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class TeamSuggestion {
  final String name;
  final String badgeUrl;

  TeamSuggestion({required this.name, required this.badgeUrl});

  factory TeamSuggestion.fromJson(Map<String, dynamic> json) {
    // strBadge tiene el escudo del equipo en TheSportsDB v1 key=123
    final badge = (json['strBadge'] as String?) ??
        (json['strTeamBadge'] as String?) ??
        '';
    return TeamSuggestion(
      name: json['strTeam'] ?? '',
      badgeUrl: badge,
    );
  }
}

class TeamSearchService {
  // API pública de TheSportsDB — key 123 (test key gratuita)
  static Future<List<TeamSuggestion>> searchTeams(String query) async {
    if (query.trim().length < 2) return [];

    // Reemplazamos espacios por underscore ya que la API los prefiere así
    final encoded = Uri.encodeComponent(query.trim());
    final url = Uri.parse(
      'https://www.thesportsdb.com/api/v1/json/123/searchteams.php?t=$encoded',
    );

    try {
      final response =
          await http.get(url).timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['teams'] != null) {
          final List<dynamic> teamsJson = data['teams'] as List<dynamic>;
          // Filtramos solo los que tienen escudo y son de fútbol
          return teamsJson
              .map((j) => TeamSuggestion.fromJson(j as Map<String, dynamic>))
              .where((t) => t.name.isNotEmpty && t.badgeUrl.isNotEmpty)
              .toList();
        }
      }
    } catch (e) {
      debugPrint('TeamSearchService error: $e');
    }
    return [];
  }
}
