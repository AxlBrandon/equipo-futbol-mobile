import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/player.dart';

class ApiService {
  // URL de tu backend en Java desplegado en Render
  static const String baseUrl = 'https://equipo-app.onrender.com';

  static Future<List<Player>> getPlayers() async {
    final response = await http.get(Uri.parse('$baseUrl/api/players'));
    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((model) => Player.fromJson(model)).toList();
    } else {
      throw Exception('Fallo al cargar los jugadores');
    }
  }
}
