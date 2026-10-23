import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/match_model.dart';

class TeamSuggestion {
  final String name;
  final String badgeUrl;

  TeamSuggestion({required this.name, required this.badgeUrl});

  factory TeamSuggestion.fromJson(Map<String, dynamic> json) {
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
  // Caché en memoria para respuestas instantáneas de 0 ms
  static final Map<String, List<TeamSuggestion>> _memoryCache = {};

  static Future<List<TeamSuggestion>> searchTeams(String query) async {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.length < 2) return [];

    // 1. Revisar caché en memoria
    if (_memoryCache.containsKey(cleanQuery)) {
      return _memoryCache[cleanQuery]!;
    }

    // 2. Coincidencia inmediata con clubes populares locales (0 ms de espera)
    final localMatches = popularClubs
        .where((club) => club.name.toLowerCase().contains(cleanQuery))
        .map((club) => TeamSuggestion(name: club.name, badgeUrl: club.logoUrl))
        .toList();

    // 3. Consulta de respaldo en TheSportsDB
    final encoded = Uri.encodeComponent(cleanQuery);
    final url = Uri.parse(
      'https://www.thesportsdb.com/api/v1/json/123/searchteams.php?t=$encoded',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['teams'] != null) {
          final List<dynamic> teamsJson = data['teams'] as List<dynamic>;
          final remoteResults = teamsJson
              .map((j) => TeamSuggestion.fromJson(j as Map<String, dynamic>))
              .where((t) => t.name.isNotEmpty && t.badgeUrl.isNotEmpty)
              .toList();

          // Combinar resultados locales + remotos sin duplicar nombres
          final seen = <String>{};
          final combined = <TeamSuggestion>[];
          for (var item in [...localMatches, ...remoteResults]) {
            if (seen.add(item.name.toLowerCase())) {
              combined.add(item);
            }
          }

          _memoryCache[cleanQuery] = combined;
          return combined;
        }
      }
    } catch (e) {
      debugPrint('TeamSearchService error: $e');
    }

    if (localMatches.isNotEmpty) {
      _memoryCache[cleanQuery] = localMatches;
      return localMatches;
    }

    return [];
  }
}
