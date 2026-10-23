import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/match_model.dart';
import '../models/player.dart';

class PastMatch {
  final String opponent;
  final String opponentLogo;
  final String matchDate;
  final String matchLocation;
  int homeScore;
  int awayScore;
  final List<int> confirmedPlayerIds;   // Quienes confirmaron RSVP
  final List<int> presentPlayerIds;     // Quienes asistieron en cancha
  final DateTime? matchDateTime;        // Momento en que se programó el partido

  PastMatch({
    required this.opponent,
    required this.opponentLogo,
    required this.matchDate,
    required this.matchLocation,
    this.homeScore = 0,
    this.awayScore = 0,
    this.confirmedPlayerIds = const [],
    this.presentPlayerIds = const [],
    this.matchDateTime,
  });

  Map<String, dynamic> toJson() => {
    'opponent': opponent,
    'opponentLogo': opponentLogo,
    'matchDate': matchDate,
    'matchLocation': matchLocation,
    'homeScore': homeScore,
    'awayScore': awayScore,
    'confirmedPlayerIds': confirmedPlayerIds,
    'presentPlayerIds': presentPlayerIds,
    'matchDateTime': matchDateTime?.toIso8601String(),
  };

  factory PastMatch.fromJson(Map<String, dynamic> json) => PastMatch(
    opponent: json['opponent'] ?? '',
    opponentLogo: json['opponentLogo'] ?? '',
    matchDate: json['matchDate'] ?? '',
    matchLocation: json['matchLocation'] ?? '',
    homeScore: json['homeScore'] ?? 0,
    awayScore: json['awayScore'] ?? 0,
    confirmedPlayerIds: (json['confirmedPlayerIds'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? [],
    presentPlayerIds: (json['presentPlayerIds'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? [],
    matchDateTime: json['matchDateTime'] != null ? DateTime.tryParse(json['matchDateTime']) : null,
  );
}

class TeamState extends ChangeNotifier {
  static final TeamState _instance = TeamState._internal();
  factory TeamState() => _instance;

  TeamState._internal() {
    _loadFromLocalStorage();
  }

  // Sede oficial principal requerida por el usuario
  static const String mainVenue = 'Deportivo Centenario Unidad C.T.M.';

  // Lista de canchas disponibles para agendar partidos
  List<String> availableVenues = [
    'Deportivo Centenario Unidad C.T.M.',
    'Cancha 2 - Deportivo Centenario',
    'Polideportivo Revolución',
    'Campo San Antonio',
    'Cancha Los Álamos',
  ];

  // Partido actual (inicialmente vacío para que el usuario registre el real)
  MatchModel currentMatch = MatchModel(
    id: 1,
    opponent: '',
    opponentLogo: '',
    matchDate: 'Sin partido programado',
    matchLocation: mainVenue,
  );

  // Historial de partidos anteriores
  List<PastMatch> pastMatches = [];

  // Lista de Jugadores (inicia vacía para meter datos reales)
  List<Player> players = [];

  // ID del Jugador que es Capitán en este partido (exclusivo)
  int? captainPlayerId;

  // Control de RSVP (Confirmación previa)
  final Map<int, bool> rsvpMap = {};

  // Control de Asistencia Real en cancha
  final Map<int, bool> attendedMap = {};

  // Cuotas objetivo
  final double feeArbitraje = 50.0;
  final double feeInscripcion = 100.0;
  final double feeHorario = 100.0;
  final double feeUniforme = 300.0;

  // Montos abonados por cada jugador
  final Map<int, double> paidArbitraje = {};
  final Map<int, double> paidInscripcion = {};
  final Map<int, double> paidHorario = {};
  final Map<int, double> paidUniforme = {};

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  // Carga instantánea de memoria local (< 5 ms)
  Future<void> _loadFromLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Cargar Jugadores
      final playersJson = prefs.getString('team_players');
      if (playersJson != null && playersJson.isNotEmpty) {
        final List<dynamic> list = json.decode(playersJson);
        players = list.map((item) => Player.fromJson(item)).toList();
      }

      // 2. Cargar Partido Actual
      final matchJson = prefs.getString('current_match');
      if (matchJson != null && matchJson.isNotEmpty) {
        currentMatch = MatchModel.fromJson(json.decode(matchJson));
      }

      // 3. Cargar Partidos Anteriores
      final pastJson = prefs.getString('past_matches');
      if (pastJson != null && pastJson.isNotEmpty) {
        final List<dynamic> list = json.decode(pastJson);
        pastMatches = list.map((item) => PastMatch.fromJson(item)).toList();
      }

      // 4. Cargar Pagos
      _loadMap(prefs.getString('paid_arbitraje'), paidArbitraje);
      _loadMap(prefs.getString('paid_inscripcion'), paidInscripcion);
      _loadMap(prefs.getString('paid_horario'), paidHorario);
      _loadMap(prefs.getString('paid_uniforme'), paidUniforme);

      // 5. Cargar Asistencia y RSVP
      _loadBoolMap(prefs.getString('rsvp_map'), rsvpMap);
      _loadBoolMap(prefs.getString('attended_map'), attendedMap);

      captainPlayerId = prefs.getInt('captain_id');

      // 6. Canchas personalizadas
      final venuesList = prefs.getStringList('available_venues');
      if (venuesList != null && venuesList.isNotEmpty) {
        availableVenues = venuesList;
      }
    } catch (e) {
      debugPrint('Error cargando almacenamiento local: $e');
    } finally {
      _isLoaded = true;
      notifyListeners();
    }
  }

  void _loadMap(String? raw, Map<int, double> target) {
    if (raw == null || raw.isEmpty) return;
    try {
      final Map<String, dynamic> decoded = json.decode(raw);
      target.clear();
      decoded.forEach((key, val) {
        final id = int.tryParse(key);
        if (id != null) {
          target[id] = (val as num).toDouble();
        }
      });
    } catch (_) {}
  }

  void _loadBoolMap(String? raw, Map<int, bool> target) {
    if (raw == null || raw.isEmpty) return;
    try {
      final Map<String, dynamic> decoded = json.decode(raw);
      target.clear();
      decoded.forEach((key, val) {
        final id = int.tryParse(key);
        if (id != null) {
          target[id] = val == true;
        }
      });
    } catch (_) {}
  }

  // Guardado asíncrono ultra rápido en segundo plano
  Future<void> _saveToLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Guardar jugadores
      final playersJson = json.encode(players.map((p) => p.toJson()).toList());
      await prefs.setString('team_players', playersJson);

      // Guardar partido actual
      await prefs.setString('current_match', json.encode(currentMatch.toJson()));

      // Guardar partidos anteriores
      final pastJson = json.encode(pastMatches.map((m) => m.toJson()).toList());
      await prefs.setString('past_matches', pastJson);

      // Guardar pagos
      await prefs.setString('paid_arbitraje', json.encode(paidArbitraje.map((k, v) => MapEntry(k.toString(), v))));
      await prefs.setString('paid_inscripcion', json.encode(paidInscripcion.map((k, v) => MapEntry(k.toString(), v))));
      await prefs.setString('paid_horario', json.encode(paidHorario.map((k, v) => MapEntry(k.toString(), v))));
      await prefs.setString('paid_uniforme', json.encode(paidUniforme.map((k, v) => MapEntry(k.toString(), v))));

      // Guardar RSVP y Asistencia
      await prefs.setString('rsvp_map', json.encode(rsvpMap.map((k, v) => MapEntry(k.toString(), v))));
      await prefs.setString('attended_map', json.encode(attendedMap.map((k, v) => MapEntry(k.toString(), v))));

      if (captainPlayerId != null) {
        await prefs.setInt('captain_id', captainPlayerId!);
      } else {
        await prefs.remove('captain_id');
      }

      await prefs.setStringList('available_venues', availableVenues);
    } catch (e) {
      debugPrint('Error guardando en almacenamiento local: $e');
    }
  }

  // ==================== LÓGICA DE CAPITÁN ====================
  bool isCaptain(int playerId) => captainPlayerId == playerId;

  void toggleCaptain(int playerId) {
    if (captainPlayerId == playerId) {
      captainPlayerId = null;
    } else {
      captainPlayerId ??= playerId;
    }
    for (var p in players) {
      p.isCaptain = (p.id == captainPlayerId);
    }
    notifyListeners();
    _saveToLocalStorage();
  }

  // ==================== ASISTENCIA Y RSVP ====================
  void updateRsvp(int playerId, bool isGoing) {
    rsvpMap[playerId] = isGoing;
    notifyListeners();
    _saveToLocalStorage();
  }

  void setActuallyWent(int playerId, bool went) {
    attendedMap[playerId] = went;
    if (went) {
      paidArbitraje[playerId] ??= 0.0;
    }
    if (!went && captainPlayerId == playerId) {
      captainPlayerId = null;
    }
    notifyListeners();
    _saveToLocalStorage();
  }

  void addUnconfirmedAttendance(int playerId) {
    rsvpMap[playerId] = false;
    attendedMap[playerId] = true;
    paidArbitraje[playerId] ??= 0.0;
    notifyListeners();
    _saveToLocalStorage();
  }

  // ==================== CONTROL FINANCIERO ====================
  void recordPayment(int playerId, String concept, double amount) {
    switch (concept) {
      case 'Arbitraje':
        paidArbitraje[playerId] = (paidArbitraje[playerId] ?? 0.0) + amount;
        break;
      case 'Inscripción':
        paidInscripcion[playerId] = (paidInscripcion[playerId] ?? 0.0) + amount;
        break;
      case 'Horario':
        paidHorario[playerId] = (paidHorario[playerId] ?? 0.0) + amount;
        break;
      case 'Uniforme':
        paidUniforme[playerId] = (paidUniforme[playerId] ?? 0.0) + amount;
        break;
    }

    notifyListeners();
    _saveToLocalStorage();
  }

  Color getPaymentColor(int playerId, String concept) {
    double paid = 0.0;
    double target = 0.0;

    switch (concept) {
      case 'Arbitraje':
        final attended = attendedMap[playerId] ?? false;
        if (!attended) return const Color(0xFF94A3B8); // Gris: no asistió
        paid = paidArbitraje[playerId] ?? 0.0;
        target = feeArbitraje;
        break;
      case 'Inscripción':
        paid = paidInscripcion[playerId] ?? 0.0;
        target = feeInscripcion;
        break;
      case 'Horario':
        paid = paidHorario[playerId] ?? 0.0;
        target = feeHorario;
        break;
      case 'Uniforme':
        paid = paidUniforme[playerId] ?? 0.0;
        target = feeUniforme;
        break;
    }

    if (paid >= target && target > 0) {
      return const Color(0xFF10B981); // Verde: Completo
    } else if (paid > 0 && paid < target) {
      return const Color(0xFFF59E0B); // Naranja: Abono parcial
    } else {
      return const Color(0xFFEF4444); // Rojo: Sin pagar
    }
  }

  // ==================== GESTIÓN DE JUGADORES Y ESTADOS ====================
  void addPlayer(Player player) {
    final newId = players.isEmpty ? 1 : (players.map((p) => p.id ?? 0).reduce((a, b) => a > b ? a : b) + 1);
    final newP = Player(
      id: newId,
      name: player.name,
      jerseyName: player.jerseyName.isNotEmpty ? player.jerseyName : player.name.split(' ').first.toUpperCase(),
      jerseyNumber: player.jerseyNumber,
      phoneNumber: player.phoneNumber.isNotEmpty ? player.phoneNumber : '55 1234 5678',
      status: player.status,
      photoUrl: player.photoUrl,
      photoBase64: player.photoBase64,
    );
    players.add(newP);
    // Nuevos jugadores inician con montos en 0 para cubrir según corresponda
    paidInscripcion[newId] = 0.0;
    paidHorario[newId] = 0.0;
    paidUniforme[newId] = 0.0;
    paidArbitraje[newId] = 0.0;

    notifyListeners();
    _saveToLocalStorage();
  }

  void updatePlayer(Player updated) {
    final idx = players.indexWhere((p) => p.id == updated.id);
    if (idx != -1) {
      players[idx] = updated;
      notifyListeners();
      _saveToLocalStorage();
    }
  }

  // Cambiar estado activo / dado de baja
  void togglePlayerStatus(int playerId) {
    final idx = players.indexWhere((p) => p.id == playerId);
    if (idx != -1) {
      final current = players[idx];
      final isNowActive = current.status == 'ACTIVO';
      current.status = isNowActive ? 'INACTIVO' : 'ACTIVO';
      if (!isNowActive && captainPlayerId == playerId) {
        captainPlayerId = null;
      }
      notifyListeners();
      _saveToLocalStorage();
    }
  }

  // Archivar partido actual al historial
  void archiveCurrentMatchAsPast({DateTime? matchDateTime}) {
    if (currentMatch.opponent.trim().isNotEmpty) {
      final confirmedIds = rsvpMap.entries.where((e) => e.value).map((e) => e.key).toList();
      final presentIds = attendedMap.entries.where((e) => e.value).map((e) => e.key).toList();
      pastMatches.insert(
        0,
        PastMatch(
          opponent: currentMatch.opponent,
          opponentLogo: currentMatch.opponentLogo,
          matchDate: currentMatch.matchDate,
          matchLocation: currentMatch.matchLocation,
          homeScore: 0,
          awayScore: 0,
          confirmedPlayerIds: confirmedIds,
          presentPlayerIds: presentIds,
          matchDateTime: matchDateTime,
        ),
      );
      rsvpMap.clear();
      attendedMap.clear();
      captainPlayerId = null;
      notifyListeners();
      _saveToLocalStorage();
    }
  }

  void updatePastMatchScore(int index, int homeScore, int awayScore) {
    if (index >= 0 && index < pastMatches.length) {
      pastMatches[index].homeScore = homeScore;
      pastMatches[index].awayScore = awayScore;
      notifyListeners();
      _saveToLocalStorage();
    }
  }

  void updateMatch(MatchModel newMatch, {DateTime? previousMatchDateTime}) {
    if (currentMatch.opponent.trim().isNotEmpty && currentMatch.opponent != newMatch.opponent) {
      archiveCurrentMatchAsPast(matchDateTime: previousMatchDateTime);
    }
    currentMatch = newMatch;
    notifyListeners();
    _saveToLocalStorage();
  }

  void addVenue(String newVenue) {
    if (newVenue.isNotEmpty && !availableVenues.contains(newVenue)) {
      availableVenues.add(newVenue);
      notifyListeners();
      _saveToLocalStorage();
    }
  }
}
