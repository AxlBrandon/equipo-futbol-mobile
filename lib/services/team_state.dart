import 'package:flutter/material.dart';
import '../models/match_model.dart';
import '../models/player.dart';
import 'api_service.dart';

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

  // Partido actual (con sede oficial predeterminada)
  MatchModel currentMatch = MatchModel(
    id: 1,
    opponent: 'Bayern Munich',
    opponentLogo:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1b/FC_Bayern_M%C3%BCnchen_logo_%282017%29.svg/200px-FC_Bayern_M%C3%BCnchen_logo_%282017%29.svg.png',
    matchDate: 'Viernes 23/10/2026',
    matchLocation: mainVenue,
  );

  // Lista de Jugadores (Activos e Inactivos / Dados de baja)
  List<Player> players = [];

  // ID del Jugador que es Capitán en este partido (exclusivo)
  int? captainPlayerId = 1; // Por defecto: Abraham #3

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
    // 14 Jugadores de tu tabla real + jugadores de baja de ejemplo
    players = [
      Player(
        id: 1,
        name: 'Abraham Castillo',
        jerseyName: 'ABRAHAM',
        jerseyNumber: 3,
        phoneNumber: '55 1298 3401',
        photoUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80',
        isCaptain: true,
      ),
      Player(
        id: 2,
        name: 'Alejandro Morales',
        jerseyName: 'ALEJANDRO',
        jerseyNumber: 30,
        phoneNumber: '55 8734 1122',
      ),
      Player(
        id: 3,
        name: 'Angel Ruiz',
        jerseyName: 'ANGEL',
        jerseyNumber: 14,
        phoneNumber: '55 9012 3456',
      ),
      Player(
        id: 4,
        name: 'Antonio Gallardo',
        jerseyName: 'GALLARDO',
        jerseyNumber: 59,
        phoneNumber: '55 6745 2389',
      ),
      Player(
        id: 5,
        name: 'Armando Perez',
        jerseyName: 'ARMANDO',
        jerseyNumber: 13,
        phoneNumber: '55 4321 9876',
      ),
      Player(
        id: 6,
        name: 'Brandon Montiel',
        jerseyName: 'BRANDON',
        jerseyNumber: 10,
        phoneNumber: '55 3344 5566',
        photoUrl: 'https://images.unsplash.com/photo-1580489944761-15a19d654956?auto=format&fit=crop&w=150&q=80',
      ),
      Player(
        id: 7,
        name: 'Cesar Lopez',
        jerseyName: 'CESAR',
        jerseyNumber: 6,
        phoneNumber: '55 7890 1234',
      ),
      Player(
        id: 8,
        name: 'Cristian Sanchez',
        jerseyName: 'CRISTIAN',
        jerseyNumber: 100,
        phoneNumber: '55 2211 4433',
      ),
      Player(
        id: 9,
        name: 'Cristian Jr',
        jerseyName: 'GAEL',
        jerseyNumber: 10,
        phoneNumber: '55 6677 8899',
      ),
      Player(
        id: 10,
        name: 'Daniel Ortiz',
        jerseyName: 'DANIEL',
        jerseyNumber: 31,
        phoneNumber: '55 9988 7766',
      ),
      Player(
        id: 11,
        name: 'Emiliano Salcido',
        jerseyName: 'SALCIDO',
        jerseyNumber: 7,
        phoneNumber: '55 4455 6677',
      ),
      Player(
        id: 12,
        name: 'Joshua Gutierrez',
        jerseyName: 'JOSH',
        jerseyNumber: 1,
        phoneNumber: '55 5566 7788',
        photoUrl: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?auto=format&fit=crop&w=150&q=80',
      ),
      Player(
        id: 13,
        name: 'Alberto Ramos',
        jerseyName: 'ALBERTO',
        jerseyNumber: 0,
        phoneNumber: '55 1122 3344',
      ),
      Player(
        id: 14,
        name: 'Ray Reglin',
        jerseyName: 'REGLIN',
        jerseyNumber: 17,
        phoneNumber: '55 9876 5432',
      ),
      // Jugadores dados de baja (para visualizar en el módulo de perfil)
      Player(
        id: 15,
        name: 'Santiago Morales',
        jerseyName: 'SANTI',
        jerseyNumber: 22,
        phoneNumber: '55 8899 0011',
        status: 'INACTIVO',
        lastMatchInfo: '10/09/2026 (Dado de baja)',
      ),
      Player(
        id: 16,
        name: 'Rodrigo Nava',
        jerseyName: 'RODRIGO',
        jerseyNumber: 8,
        phoneNumber: '55 7766 5544',
        status: 'INACTIVO',
        lastMatchInfo: '03/09/2026 (Dado de baja)',
      ),
    ];

    // Por requerimiento del usuario:
    // Inscripción ($100), Horario ($100) y Uniforme ($300) inician 100% CUBIERTOS (VERDE)
    for (var p in players) {
      final pid = p.id!;
      paidInscripcion[pid] = feeInscripcion; // $100 -> Verde
      paidHorario[pid] = feeHorario;         // $100 -> Verde
      paidUniforme[pid] = feeUniforme;       // $300 -> 100% CUBIERTO (VERDE)
    }

    // Confirmaciones RSVP iniciales
    rsvpMap[1] = true;
    rsvpMap[6] = true;
    rsvpMap[8] = true;
    rsvpMap[10] = true;
    rsvpMap[12] = true;

    // Asistencias iniciales en cancha
    attendedMap[1] = true;
    paidArbitraje[1] = 50.0; // Abraham asistió y pagó arbitraje completo -> Verde

    attendedMap[12] = true;
    paidArbitraje[12] = 25.0; // Joshua asistió y dio abono de $25 -> Naranja

    attendedMap[6] = true;
    paidArbitraje[6] = 0.0; // Brandon asistió y no ha pagado arbitraje -> Rojo
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
    paidInscripcion[newId] = feeInscripcion;
    paidHorario[newId] = feeHorario;
    paidUniforme[newId] = feeUniforme; // Uniforme cubierto también para nuevos ingresos

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

  void updateMatch(MatchModel newMatch) {
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
