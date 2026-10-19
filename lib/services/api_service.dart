import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/player.dart';

class ApiService {
  // Puedes cambiar a 'http://10.0.2.2:8080' (emulador Android) o 'http://localhost:8080' (web/desktop)
  // o tu URL en Render: 'https://equipo-app.onrender.com'
  static String baseUrl = 'https://equipo-app.onrender.com';

  // Obtener jugadores de manera segura sin romper la app ante un 404
  static Future<List<Player>> getPlayers() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/players'))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        Iterable list = json.decode(response.body);
        return list.map((model) => Player.fromJson(model)).toList();
      }
    } catch (_) {
      // Manejo silencioso: si el backend está offline o da 404,
      // la app utiliza los datos precargados localmente
    }
    return [];
  }

  // Registrar nuevo jugador con foto
  static Future<Player?> createPlayer(Player player) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/players'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(player.toJson()),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Player.fromJson(json.decode(response.body));
      }
    } catch (_) {}
    return null;
  }

  // Actualizar jugador existente
  static Future<bool> updatePlayer(Player player) async {
    if (player.id == null) return false;
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/api/players/${player.id}'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(player.toJson()),
          )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // Guardar asistencia
  static Future<bool> saveAttendance(int matchId, int playerId, bool rsvp, bool went, bool isCaptain) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/attendance'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'matchId': matchId,
              'playerId': playerId,
              'rsvpGoing': rsvp,
              'actuallyWent': went,
              'isCaptain': isCaptain,
            }),
          )
          .timeout(const Duration(seconds: 4));

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  // Registrar pago
  static Future<bool> recordPayment(int playerId, String concept, double amount, String status) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/payments'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'playerId': playerId,
              'concept': concept,
              'amount': amount,
              'status': status,
              'paymentDate': DateTime.now().toIso8601String().substring(0, 10),
            }),
          )
          .timeout(const Duration(seconds: 4));

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }
}
