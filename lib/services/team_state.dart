import 'package:flutter/material.dart';
import '../models/match_model.dart';
import '../models/player.dart';
import 'api_service.dart';

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
}

class TeamState extends ChangeNotifier {
  static final TeamState _instance = TeamState._internal();
  factory TeamState() => _instance;

  TeamState._internal() {
    _initializeDefaultData();
    _fetchFromBackend();
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

  void _initializeDefaultData() {
    // Todos los datos de prueba han sido removidos.
    // La app inicia limpia para registrar plantilla y partidos reales.
    players = [];
    rsvpMap.clear();
    attendedMap.clear();
    paidArbitraje.clear();
    paidInscripcion.clear();
    paidHorario.clear();
    paidUniforme.clear();
    captainPlayerId = null;
  }

  // Sincronización segura con el backend
  Future<void> _fetchFromBackend() async {
    final remotePlayers = await ApiService.getPlayers();
    if (remotePlayers.isNotEmpty) {
      for (var rp in remotePlayers) {
        final existingIdx = players.indexWhere((p) => p.name.toLowerCase() == rp.name.toLowerCase() || p.jerseyNumber == rp.jerseyNumber);
        if (existingIdx != -1) {
          players[existingIdx] = rp;
        } else {
          players.add(rp);
        }
      }
      notifyListeners();
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
  }

  // ==================== ASISTENCIA Y RSVP ====================
  void updateRsvp(int playerId, bool isGoing) {
    rsvpMap[playerId] = isGoing;
    notifyListeners();
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
  }

  void addUnconfirmedAttendance(int playerId) {
    rsvpMap[playerId] = false;
    attendedMap[playerId] = true;
    paidArbitraje[playerId] ??= 0.0;
    notifyListeners();
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

    final color = getPaymentColor(playerId, concept);
    final status = (color == const Color(0xFF10B981)) ? 'PAID' : 'PENDING';
    ApiService.recordPayment(playerId, concept, amount, status);

    notifyListeners();
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

    ApiService.createPlayer(newP);
    notifyListeners();
  }

  void updatePlayer(Player updated) {
    final idx = players.indexWhere((p) => p.id == updated.id);
    if (idx != -1) {
      players[idx] = updated;
      ApiService.updatePlayer(updated);
      notifyListeners();
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
      ApiService.updatePlayer(current);
      notifyListeners();
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
    }
  }

  void updatePastMatchScore(int index, int homeScore, int awayScore) {
    if (index >= 0 && index < pastMatches.length) {
      pastMatches[index].homeScore = homeScore;
      pastMatches[index].awayScore = awayScore;
      notifyListeners();
    }
  }

  void updateMatch(MatchModel newMatch, {DateTime? previousMatchDateTime}) {
    if (currentMatch.opponent.trim().isNotEmpty && currentMatch.opponent != newMatch.opponent) {
      archiveCurrentMatchAsPast(matchDateTime: previousMatchDateTime);
    }
    currentMatch = newMatch;
    notifyListeners();
  }

  void addVenue(String newVenue) {
    if (newVenue.isNotEmpty && !availableVenues.contains(newVenue)) {
      availableVenues.add(newVenue);
      notifyListeners();
    }
  }
}
