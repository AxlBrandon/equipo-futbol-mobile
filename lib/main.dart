import 'dart:convert';

import 'package:equipo_futbol_mobile/services/team_search_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:image_picker/image_picker.dart';

import 'models/match_model.dart';
import 'models/player.dart';
import 'services/team_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LiverpoolApp());
}

class LiverpoolApp extends StatelessWidget {
  const LiverpoolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Liverpool F.C.',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'MX'),
        Locale('en', 'US'),
      ],
      locale: const Locale('es', 'MX'),
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF6F8FB),
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD31027),
          primary: const Color(0xFFD31027),
        ),
        useMaterial3: true,
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final TeamState _state = TeamState();

  @override
  void initState() {
    super.initState();
    _state.addListener(() {
      if (mounted) setState(() {});
    });
  }

  final List<Widget> _screens = const [
    HomeScreen(),
    AttendanceScreen(),
    PaymentsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
          border: const Border(
            top: BorderSide(color: Color(0xFFF1F5F9), width: 1),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_outlined, Icons.home, 'Inicio'),
              _buildNavItem(1, Icons.calendar_today_outlined, Icons.calendar_today, 'Partidos'),
              _buildNavItem(2, Icons.people_outline, Icons.people, 'Plantilla'),
              _buildNavItem(3, Icons.shield_outlined, Icons.shield, 'Mi club'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFDE8E8) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? const Color(0xFFC8102E) : const Color(0xFF94A3B8),
              size: 22,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFFC8102E) : const Color(0xFF94A3B8),
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== 1. INICIO (PANTALLA PRINCIPAL) ====================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TeamState _state = TeamState();
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    // En Inicio mostramos los jugadores activos
    final activePlayers = _state.players
        .where((p) => p.status == 'ACTIVO')
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. ENCABEZADO CON GEOMETRÍA FIGMA LIVERPOOL F.C.
            _buildTopHeader(),

            // 2. CONTENIDO PRINCIPAL
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 14),

                  // TARJETA DE PRÓXIMO PARTIDO (FIGMA STYLE)
                  _buildNextMatchCard(),

                  const SizedBox(height: 20),

                  // TÍTULO "MI PLANTILLA" + BOTÓN "+ Agregar jugadores"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'MI PLANTILLA',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                          letterSpacing: 0.2,
                        ),
                      ),
                      _buildAddPlayerButton(),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // LISTA DE TARJETAS DE JUGADORES ACTIVOS
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: activePlayers.length,
                    itemBuilder: (context, index) {
                      final player = activePlayers[index];
                      return _buildPlayerCard(player, index);
                    },
                  ),

                  const SizedBox(height: 14),
                  const Center(
                    child: Text(
                      'Partido y plantilla de ejemplo',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Obtener iniciales para el avatar estilo Figma (ej: "AC", "JG", "BM")
  String _getPlayerInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return 'LFC';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  // Encabezado con geometría y escudo oficial de Liverpool estilo Figma
  Widget _buildTopHeader() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFC8102E), // Rojo oficial de Liverpool
      child: Stack(
        children: [
          // Geometría angular en el fondo derecho (cuña roja oscura y cuña teal)
          Positioned.fill(
            child: CustomPaint(
              painter: _HeaderGeometricPainter(),
            ),
          ),

          // Contenido principal
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 18, 22),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Textos a la izquierda
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'MI EQUIPO • MI PASIÓN',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'LIVERPOOL F.C.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Nunca caminarás solo.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Escudo oficial Liverpool a la derecha sobre el corte teal
                  Container(
                    width: 66,
                    height: 66,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/liverpool_logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.shield,
                        color: Colors.white,
                        size: 44,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tarjeta "PRÓXIMO PARTIDO" estilo Figma (verde/teal pizarra con corte angular)
  Widget _buildNextMatchCard() {
    final match = _state.currentMatch;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _showRsvpModal(context),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF0E2E2E), // Fondo verde/teal pizarra profundo
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Corte diagonal geométrico oscuro en el fondo
              Positioned.fill(
                child: CustomPaint(
                  painter: _MatchCardGeometricPainter(),
                ),
              ),

              // Botón sutil para agendar / cambiar partido
              Positioned(
                top: 8,
                right: 85,
                child: GestureDetector(
                  onTap: () => _showNewMatchDialog(context),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit_calendar,
                      color: Colors.white70,
                      size: 14,
                    ),
                  ),
                ),
              ),

              // Contenido de la tarjeta
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fila superior: "PRÓXIMO PARTIDO" y badge "POR JUGAR"
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'PRÓXIMO PARTIDO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 3.5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'POR JUGAR',
                            style: TextStyle(
                              color: Color(0xFF5EEAD4), // Menta suave
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Fila media: Liverpool vs Rival
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Liverpool
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 44,
                              height: 44,
                              child: Image.asset(
                                'assets/images/liverpool_logo.png',
                                fit: BoxFit.contain,
                                errorBuilder: (_, _, _) => const Icon(
                                  Icons.shield,
                                  color: Color(0xFFC8102E),
                                  size: 36,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Liverpool',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        // VS con pequeña barra teal
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'VS',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Container(
                              width: 18,
                              height: 2.2,
                              decoration: BoxDecoration(
                                color: const Color(0xFF00A398),
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                          ],
                        ),

                        // Rival
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              padding: const EdgeInsets.all(3),
                              child: ClipOval(
                                child: match.opponentLogo.isNotEmpty
                                    ? Image.network(
                                        match.opponentLogo,
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, _, _) => Container(
                                          color: const Color(0xFFC8102E),
                                          child: Center(
                                            child: Text(
                                              match.opponent.isNotEmpty
                                                  ? match.opponent.substring(0, 1).toUpperCase()
                                                  : 'R',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(
                                        color: const Color(0xFFC8102E),
                                        child: const Center(
                                          child: Text(
                                            'FCB',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              match.opponent,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Línea divisoria sutil
                    Container(
                      width: double.infinity,
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.10),
                    ),

                    const SizedBox(height: 10),

                    // Fila inferior: Calendario Fecha y Flecha oblicua
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 13.5,
                              color: Colors.white.withValues(alpha: 0.75),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              match.matchDate,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.north_east,
                          size: 15,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Botón "+ Agregar jugadores" estilo píldora roja Figma
  Widget _buildAddPlayerButton() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFC8102E), // Rojo oficial de Liverpool
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC8102E).withValues(alpha: 0.28),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => _showAddPlayerDialog(context),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text(
                  'Agregar jugadores',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Tarjeta de Jugador estilo Figma (franja teal, iniciales mint, número rojo y estado verde)
  Widget _buildPlayerCard(Player player, int index) {
    final parts = player.name.trim().split(RegExp(r'\s+'));
    final firstName = parts.first;
    final lastName = parts.length > 1
        ? parts.sublist(1).join(' ')
        : (player.jerseyName.isNotEmpty ? player.jerseyName : '');
    final isCaptain = _state.isCaptain(player.id!);
    final initials = _getPlayerInitials(player.name);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _showPlayerProfileModal(context, player),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFF1F5F9),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Franja vertical verde/teal a la izquierda como en Figma
                Container(
                  width: 3.8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00A398), // Teal oficial de Liverpool
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        // Círculo avatar con iniciales (estilo Figma) o foto del jugador
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFE6F4F1), // Menta/teal suave
                          ),
                          child: Center(
                            child: player.avatarImage != null
                                ? CircleAvatar(
                                    radius: 22,
                                    backgroundImage: player.avatarImage,
                                  )
                                : Text(
                                    initials,
                                    style: const TextStyle(
                                      color: Color(0xFF007A6E),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(width: 14),

                        // Nombres: Primer nombre arriba en gris, Apellido abajo en negro negrita
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    firstName,
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                  if (isCaptain) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 1.5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF59E0B),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        '👑 CAP',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 8.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 1),
                              Text(
                                lastName,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                  height: 1.15,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Lado derecho: Número dorsal en rojo y estado ACTIVO en verde
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${player.jerseyNumber}',
                              style: const TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFC8102E), // Rojo Liverpool
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              player.status.toUpperCase(),
                              style: const TextStyle(
                                color: Color(0xFF10B981), // Verde activo
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== MODALES Y DIÁLOGOS ====================

  // 1. Confirmación de Asistencia (RSVP) desde el Próximo Partido
  void _showRsvpModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final activePlayers = _state.players
                .where((p) => p.status == 'ACTIVO')
                .toList();
            final confirmedCount = _state.rsvpMap.values.where((v) => v).length;

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Confirmar Asistencia',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Partido: Liverpool vs ${_state.currentMatch.opponent} (${_state.currentMatch.matchDate})',
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F8F0),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Color(0xFF10B981),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$confirmedCount jugadores confirmaron que sí irán',
                                style: const TextStyle(
                                  color: Color(0xFF10B981),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.builder(
                      itemCount: activePlayers.length,
                      itemBuilder: (context, index) {
                        final p = activePlayers[index];
                        final isGoing = _state.rsvpMap[p.id] ?? false;

                        return SwitchListTile(
                          title: Row(
                            children: [
                              Text(
                                p.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              if (_state.isCaptain(p.id!)) ...[
                                const SizedBox(width: 6),
                                const Text(
                                  '👑 CAP',
                                  style: TextStyle(
                                    color: Color(0xFFF59E0B),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          subtitle: Text(
                            'Dorsal #${p.jerseyNumber} • ${p.jerseyName} • Tel: ${p.phoneNumber}',
                          ),
                          secondary: CircleAvatar(
                            backgroundColor: const Color(0xFFF1F5F9),
                            backgroundImage: p.avatarImage,
                            child: p.avatarImage == null
                                ? const Icon(Icons.person, color: Colors.grey)
                                : null,
                          ),
                          activeThumbColor: const Color(0xFF10B981),
                          value: isGoing,
                          onChanged: (val) {
                            setModalState(() {
                              _state.updateRsvp(p.id!, val);
                            });
                          },
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD31027),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Guardar y Ver en Asistencia',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 2. Diálogo para Agregar Nuevo Jugador con Cámara, Galería y Teléfono
  void _showAddPlayerDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final jerseyNameCtrl = TextEditingController();
    final numberCtrl = TextEditingController();
    final phoneCtrl = TextEditingController(text: '55 ');
    String? pickedBase64;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            top: 24,
            left: 24,
            right: 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Agregar Nuevo Jugador',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 14),

                // Selector de Foto (Cámara o Galería)
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: const Color(0xFFF1F5F9),
                        backgroundImage: pickedBase64 != null
                            ? MemoryImage(base64Decode(pickedBase64!))
                            : null,
                        child: pickedBase64 == null
                            ? const Icon(
                                Icons.person,
                                size: 45,
                                color: Colors.grey,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _pickPhotoSheet(context, (base64) {
                            setDialogState(() {
                              pickedBase64 = base64;
                            });
                          }),
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: const BoxDecoration(
                              color: Color(0xFFD31027),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Toca la cámara para tomar foto o elegir de galería',
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Nombre Completo',
                    hintText: 'Ej. Roberto Firmino',
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: jerseyNameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Nombre en la Playera',
                    hintText: 'Ej. BOBBY',
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: numberCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Dorsal',
                          hintText: 'Ej. 9',
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Teléfono',
                          hintText: '55 1234 5678',
                          prefixIcon: const Icon(Icons.phone, size: 18),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      final name = nameCtrl.text.trim();
                      final jName = jerseyNameCtrl.text.trim();
                      final num = int.tryParse(numberCtrl.text.trim()) ?? 0;
                      final phone = phoneCtrl.text.trim();

                      if (name.isNotEmpty && num >= 0) {
                        Navigator.pop(ctx);
                        final newPlayer = Player(
                          name: name,
                          jerseyName: jName.isNotEmpty
                              ? jName.toUpperCase()
                              : name.split(' ').first.toUpperCase(),
                          jerseyNumber: num,
                          phoneNumber: phone.isNotEmpty
                              ? phone
                              : '55 1234 5678',
                          photoBase64: pickedBase64,
                        );
                        _state.addPlayer(newPlayer);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD31027),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Registrar Jugador',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Selector para Cámara o Galería
  void _pickPhotoSheet(
    BuildContext context,
    Function(String base64) onPhotoSelected,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Seleccionar Foto del Jugador',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFFD31027)),
              title: const Text('Tomar Foto con la Cámara'),
              onTap: () async {
                Navigator.pop(ctx);
                final xfile = await _picker.pickImage(
                  source: ImageSource.camera,
                  maxWidth: 600,
                );
                if (xfile != null) {
                  final bytes = await xfile.readAsBytes();
                  onPhotoSelected(base64Encode(bytes));
                }
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: Color(0xFF00C9A7),
              ),
              title: const Text('Elegir de la Galería del Teléfono'),
              onTap: () async {
                Navigator.pop(ctx);
                final xfile = await _picker.pickImage(
                  source: ImageSource.gallery,
                  maxWidth: 600,
                );
                if (xfile != null) {
                  final bytes = await xfile.readAsBytes();
                  onPhotoSelected(base64Encode(bytes));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // 3. Modal de Perfil de Jugador con edición y pagos
  void _showPlayerProfileModal(BuildContext context, Player player) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final arbPaid = _state.paidArbitraje[player.id] ?? 0.0;
        final insPaid = _state.paidInscripcion[player.id] ?? 0.0;
        final horPaid = _state.paidHorario[player.id] ?? 0.0;
        final uniPaid = _state.paidUniforme[player.id] ?? 0.0;
        final isCap = _state.isCaptain(player.id!);
        final isBaja = player.status == 'INACTIVO';

        return Container(
          height: MediaQuery.of(context).size.height * 0.90,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Encabezado de perfil
              Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: const Color(0xFFF1F5F9),
                    backgroundImage: player.avatarImage,
                    child: player.avatarImage == null
                        ? const Icon(Icons.person, size: 40, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              player.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            if (isCap) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: const Color(0xFFF59E0B),
                                  ),
                                ),
                                child: const Text(
                                  '👑 CAPITÁN',
                                  style: TextStyle(
                                    color: Color(0xFFB45309),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          'Playera: ${player.jerseyName} • Dorsal #${player.jerseyNumber}',
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.phone,
                              size: 14,
                              color: Color(0xFF10B981),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              player.phoneNumber,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF10B981),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 1.5,
                              ),
                              decoration: BoxDecoration(
                                color: isBaja
                                    ? const Color(0xFFFEE2E2)
                                    : const Color(0xFFE8F8F0),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                player.status.toUpperCase(),
                                style: TextStyle(
                                  color: isBaja
                                      ? const Color(0xFFDC2626)
                                      : const Color(0xFF10B981),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Divider(),
              // Último Partido
              const Text(
                'Último Partido Jugado',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.sports_soccer,
                    color: Color(0xFFD31027),
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    player.lastMatchInfo ??
                        '23/10/2026 vs Bayern Munich (Asistió)',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Estatus de Pagos
              const Text(
                'Estatus Financiero y Cuotas',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 10),
              _buildPaymentProgressItem(
                'Arbitraje',
                arbPaid,
                _state.feeArbitraje,
                _state.getPaymentColor(player.id!, 'Arbitraje'),
              ),
              _buildPaymentProgressItem(
                'Inscripción',
                insPaid,
                _state.feeInscripcion,
                _state.getPaymentColor(player.id!, 'Inscripción'),
              ),
              _buildPaymentProgressItem(
                'Horario',
                horPaid,
                _state.feeHorario,
                _state.getPaymentColor(player.id!, 'Horario'),
              ),
              _buildPaymentProgressItem(
                'Uniforme',
                uniPaid,
                _state.feeUniforme,
                _state.getPaymentColor(player.id!, 'Uniforme'),
              ),
              const Spacer(),
              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Editar / Teléfono'),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showEditPlayerDialog(context, player);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(
                        Icons.attach_money,
                        size: 18,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Abonar Pago',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showRecordPaymentDialog(context, player);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentProgressItem(
    String title,
    double paid,
    double target,
    Color statusColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                ),
              ),
              Text(
                '\$${paid.toStringAsFixed(0)} / \$${target.toStringAsFixed(0)}',
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: target > 0 ? (paid / target).clamp(0.0, 1.0) : 0,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  // 4. Diálogo para Registrar / Cambiar Próximo Partido con Búsqueda en Vivo de Escudos
  void _showNewMatchDialog(BuildContext context) {
    final opponentCtrl = TextEditingController(
      text: _state.currentMatch.opponent,
    );
    final locationCtrl = TextEditingController(
      text: _state.currentMatch.matchLocation,
    );
    String selectedLogo = _state.currentMatch.opponentLogo;

    // Intentamos parsear la fecha actual guardada
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));
    TimeOfDay selectedTime = const TimeOfDay(hour: 20, minute: 0);

    List<TeamSuggestion> searchResults = [];
    bool isLoading = false;

    // Helper para formatear la fecha seleccionada al estilo "Viernes 30/10/2026 • 8:00 PM"
    String formatMatchDateTime(DateTime date, TimeOfDay time) {
      const dias = [
        'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'
      ];
      final diaNombre = dias[date.weekday - 1];
      final d = date.day.toString().padLeft(2, '0');
      final m = date.month.toString().padLeft(2, '0');
      final y = date.year;
      final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
      final min = time.minute.toString().padLeft(2, '0');
      final period = time.period == DayPeriod.am ? 'AM' : 'PM';
      return '$diaNombre $d/$m/$y • $hour:$min $period';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setMatchState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.90,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Registrar Próximo Partido',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Busca el nombre del equipo rival para obtener su escudo oficial:',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 10),

                    // Barra de búsqueda en tiempo real conectada al servicio web
                    TextField(
                      onChanged: (val) async {
                        if (val.length < 3) {
                          setMatchState(() {
                            searchResults = [];
                            isLoading = false;
                          });
                          return;
                        }

                        setMatchState(() {
                          isLoading = true;
                        });

                        final results = await TeamSearchService.searchTeams(
                          val,
                        );

                        setMatchState(() {
                          searchResults = results;
                          isLoading = false;
                        });
                      },
                      decoration: InputDecoration(
                        hintText:
                            'Escribe el rival (ej. Real Madrid, Arsenal...)',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFFD31027),
                        ),
                        suffixIcon: isLoading
                            ? const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.sports_soccer,
                                color: Colors.grey,
                              ),
                        filled: true,
                        fillColor: const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Cuadrícula de sugerencias encontradas en internet
                    if (searchResults.isNotEmpty) ...[
                      const Text(
                        'Selecciona una sugerencia:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 95,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: searchResults.length,
                          itemBuilder: (context, i) {
                            final club = searchResults[i];
                            final isSelected =
                                opponentCtrl.text.toLowerCase() ==
                                club.name.toLowerCase();

                            return GestureDetector(
                              onTap: () {
                                setMatchState(() {
                                  opponentCtrl.text = club.name;
                                  selectedLogo = club.badgeUrl;
                                });
                              },
                              child: Container(
                                width: 90,
                                margin: const EdgeInsets.only(right: 10),
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFFE8F8F0)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF10B981)
                                        : Colors.grey.shade300,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    club.badgeUrl.isNotEmpty
                                        ? Image.network(
                                            club.badgeUrl,
                                            width: 36,
                                            height: 36,
                                            fit: BoxFit.contain,
                                            errorBuilder: (_, _, _) =>
                                                const Icon(
                                                  Icons.shield,
                                                  color: Colors.blue,
                                                ),
                                          )
                                        : const Icon(
                                            Icons.shield,
                                            color: Colors.blue,
                                            size: 36,
                                          ),
                                    const SizedBox(height: 4),
                                    Text(
                                      club.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    TextField(
                      controller: opponentCtrl,
                      decoration: InputDecoration(
                        labelText: 'Nombre del Rival',
                        prefixIcon: const Icon(Icons.shield),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ── Selector Visual de Fecha y Hora ──
                    const Text(
                      'Fecha y Hora del Partido:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Botón Fecha
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.calendar_today, size: 18),
                            label: Text(
                              '${selectedDate.day.toString().padLeft(2, '0')}/'
                              '${selectedDate.month.toString().padLeft(2, '0')}/'
                              '${selectedDate.year}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFD31027),
                              side: const BorderSide(color: Color(0xFFD31027)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
                                locale: const Locale('es', 'MX'),
                              );
                              if (picked != null) {
                                setMatchState(() => selectedDate = picked);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Botón Hora
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.access_time, size: 18),
                            label: Text(
                              () {
                                final h = selectedTime.hourOfPeriod == 0
                                    ? 12
                                    : selectedTime.hourOfPeriod;
                                final min = selectedTime.minute
                                    .toString()
                                    .padLeft(2, '0');
                                final p = selectedTime.period == DayPeriod.am
                                    ? 'AM'
                                    : 'PM';
                                return '$h:$min $p';
                              }(),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF0077B6),
                              side: const BorderSide(color: Color(0xFF0077B6)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: selectedTime,
                              );
                              if (picked != null) {
                                setMatchState(() => selectedTime = picked);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Vista previa del formato final
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        formatMatchDateTime(selectedDate, selectedTime),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),


                    // Selector de Canchas
                    const Text(
                      'Sede / Cancha de Juego:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue:
                          _state.availableVenues.contains(locationCtrl.text)
                          ? locationCtrl.text
                          : TeamState.mainVenue,
                      items: _state.availableVenues.map((v) {
                        return DropdownMenuItem(
                          value: v,
                          child: Text(v, style: const TextStyle(fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setMatchState(() {
                            locationCtrl.text = val;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.location_on,
                          color: Color(0xFFD31027),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _state.updateMatch(
                            MatchModel(
                              opponent: opponentCtrl.text.trim().isNotEmpty
                                  ? opponentCtrl.text.trim()
                                  : 'Rival',
                              opponentLogo: selectedLogo.isNotEmpty
                                  ? selectedLogo
                                  : 'https://www.thesportsdb.com/images/media/team/badge/default.png',
                              matchDate: formatMatchDateTime(selectedDate, selectedTime),
                              matchLocation: locationCtrl.text.trim().isNotEmpty
                                  ? locationCtrl.text.trim()
                                  : TeamState.mainVenue,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD31027),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Guardar y Publicar Partido',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 5. Editar Jugador con Foto y Teléfono
  void _showEditPlayerDialog(BuildContext context, Player player) {
    final nameCtrl = TextEditingController(text: player.name);
    final jerseyNameCtrl = TextEditingController(text: player.jerseyName);
    final numberCtrl = TextEditingController(
      text: player.jerseyNumber.toString(),
    );
    final phoneCtrl = TextEditingController(text: player.phoneNumber);
    String? currentBase64 = player.photoBase64;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setEditState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            top: 24,
            left: 24,
            right: 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Editar Jugador',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 14),
                // Foto actual o nueva
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: const Color(0xFFF1F5F9),
                      backgroundImage: currentBase64 != null
                          ? MemoryImage(base64Decode(currentBase64!))
                          : player.avatarImage,
                      child:
                          (currentBase64 == null && player.avatarImage == null)
                          ? const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _pickPhotoSheet(context, (base64) {
                          setEditState(() {
                            currentBase64 = base64;
                          });
                        }),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFFD31027),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre Completo',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: jerseyNameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de Playera',
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: numberCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Dorsal'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Teléfono',
                          prefixIcon: Icon(Icons.phone, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      player.name = nameCtrl.text.trim();
                      player.jerseyName = jerseyNameCtrl.text
                          .trim()
                          .toUpperCase();
                      player.jerseyNumber =
                          int.tryParse(numberCtrl.text.trim()) ??
                          player.jerseyNumber;
                      player.phoneNumber = phoneCtrl.text.trim();
                      if (currentBase64 != null) {
                        player.photoBase64 = currentBase64;
                      }
                      _state.updatePlayer(player);
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD31027),
                    ),
                    child: const Text(
                      'Guardar Cambios',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 6. Registrar Abono / Pago rápido
  void _showRecordPaymentDialog(BuildContext context, Player player) {
    String concept = 'Arbitraje';
    final amountCtrl = TextEditingController(text: '50');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setPaymentState) => AlertDialog(
          title: Text('Abonar Cuota - ${player.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: concept,
                items: const [
                  DropdownMenuItem(
                    value: 'Arbitraje',
                    child: Text('Arbitraje (\$50 por partido)'),
                  ),
                  DropdownMenuItem(
                    value: 'Inscripción',
                    child: Text('Inscripción (\$100)'),
                  ),
                  DropdownMenuItem(
                    value: 'Horario',
                    child: Text('Horario (\$100)'),
                  ),
                  DropdownMenuItem(
                    value: 'Uniforme',
                    child: Text('Uniforme (\$300)'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setPaymentState(() {
                      concept = val;
                      amountCtrl.text = val == 'Arbitraje' ? '50' : '100';
                    });
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Rubro / Concepto',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Monto a Abonar (\$)',
                  prefixText: '\$ ',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
              ),
              onPressed: () {
                final amt = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
                if (amt > 0) {
                  _state.recordPayment(player.id!, concept, amt);
                  Navigator.pop(ctx);
                }
              },
              child: const Text(
                'Confirmar Pago',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== 2. ASISTENCIA ====================
class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final TeamState _state = TeamState();

  @override
  Widget build(BuildContext context) {
    final activePlayers = _state.players
        .where((p) => p.status == 'ACTIVO')
        .toList();
    final confirmedPlayers = activePlayers
        .where((p) => _state.rsvpMap[p.id] == true)
        .toList();
    final unconfirmedPlayers = activePlayers
        .where((p) => _state.rsvpMap[p.id] != true)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Control de Asistencia en Cancha',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFFC8102E),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
            tooltip: 'Agregar jugador no confirmado',
            onPressed: () =>
                _showAddUnconfirmedDialog(context, unconfirmedPlayers),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFD31027),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Asistió sin confirmar (+)',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () => _showAddUnconfirmedDialog(context, unconfirmedPlayers),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Partido: Liverpool vs ${_state.currentMatch.opponent}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Fecha: ${_state.currentMatch.matchDate}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  'Sede: ${_state.currentMatch.matchLocation}',
                  style: const TextStyle(
                    color: Color(0xFFD31027),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Confirmaron que sí irían (RSVP)',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          if (confirmedPlayers.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'Nadie ha confirmado todavía.\nToca la tarjeta de Próximo Partido en Inicio para confirmar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ...confirmedPlayers.map((player) {
            final went = _state.attendedMap[player.id] ?? false;
            final isCap = _state.isCaptain(player.id!);
            final hasAnyCaptain = _state.captainPlayerId != null;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFF1F5F9),
                  backgroundImage: player.avatarImage,
                  child: player.avatarImage == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Text(
                  player.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dorsal #${player.jerseyNumber} • Tel: ${player.phoneNumber} • ${went ? "SÍ ASISTIÓ" : "NO HA LLEGADO"}',
                    ),
                    if (went) ...[
                      const SizedBox(height: 4),
                      if (isCap)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _state.toggleCaptain(player.id!);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFF59E0B),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  '👑 CAPITÁN ',
                                  style: TextStyle(
                                    color: Color(0xFFB45309),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                                Text(
                                  '(Quitar Cap)',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else if (!hasAnyCaptain)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _state.toggleCaptain(player.id!);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFCBD5E1),
                              ),
                            ),
                            child: const Text(
                              '👑 Hacer Cap',
                              style: TextStyle(
                                color: Color(0xFF475569),
                                fontWeight: FontWeight.bold,
                                fontSize: 10.5,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
                trailing: Switch(
                  value: went,
                  activeThumbColor: const Color(0xFF10B981),
                  onChanged: (val) {
                    setState(() {
                      _state.setActuallyWent(player.id!, val);
                    });
                  },
                ),
              ),
            );
          }),
          const SizedBox(height: 20),
          const Text(
            'Jugadores agregados directamente en cancha (+)',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          ...activePlayers
              .where(
                (p) =>
                    _state.rsvpMap[p.id] != true &&
                    _state.attendedMap[p.id] == true,
              )
              .map((player) {
                final isCap = _state.isCaptain(player.id!);
                final hasAnyCaptain = _state.captainPlayerId != null;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  color: const Color(0xFFF0FDF4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.check_circle,
                      color: Color(0xFF10B981),
                    ),
                    title: Text(
                      player.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Presente en cancha (No confirmó) • Tel: ${player.phoneNumber}',
                        ),
                        const SizedBox(height: 4),
                        if (isCap)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _state.toggleCaptain(player.id!);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFF59E0B),
                                ),
                              ),
                              child: const Text(
                                '👑 CAPITÁN (Quitar Cap)',
                                style: TextStyle(
                                  color: Color(0xFFB45309),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          )
                        else if (!hasAnyCaptain)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _state.toggleCaptain(player.id!);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade400),
                              ),
                              child: const Text(
                                '👑 Hacer Cap',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _state.setActuallyWent(player.id!, false);
                        });
                      },
                    ),
                  ),
                );
              }),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  void _showAddUnconfirmedDialog(
    BuildContext context,
    List<Player> unconfirmed,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Agregar Jugador que Asistió sin Confirmar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: unconfirmed.length,
                itemBuilder: (context, i) {
                  final p = unconfirmed[i];
                  return ListTile(
                    leading: const Icon(
                      Icons.person_add,
                      color: Color(0xFFD31027),
                    ),
                    title: Text(
                      p.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Dorsal #${p.jerseyNumber} • Tel: ${p.phoneNumber}',
                    ),
                    onTap: () {
                      _state.addUnconfirmedAttendance(p.id!);
                      Navigator.pop(ctx);
                      setState(() {});
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== 3. PAGOS ====================
class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final TeamState _state = TeamState();

  @override
  Widget build(BuildContext context) {
    final activePlayers = _state.players
        .where((p) => p.status == 'ACTIVO')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Control Financiero y Pagos',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFFC8102E),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner informativo de cuotas cubiertas
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F8F0),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: const [
                Icon(Icons.verified, color: Color(0xFF10B981), size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Inscripción, Horario y Uniforme se encuentran 100% CUBIERTOS para todo el equipo.',
                    style: TextStyle(
                      color: Color(0xFF065F46),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Leyenda de colores
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem(const Color(0xFF10B981), 'Completo'),
                _buildLegendItem(const Color(0xFFF59E0B), 'Abono'),
                _buildLegendItem(const Color(0xFFEF4444), 'Pendiente'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ...activePlayers.map((player) {
            final arbColor = _state.getPaymentColor(player.id!, 'Arbitraje');
            final insColor = _state.getPaymentColor(player.id!, 'Inscripción');
            final horColor = _state.getPaymentColor(player.id!, 'Horario');
            final uniColor = _state.getPaymentColor(player.id!, 'Uniforme');

            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _showPaymentOptions(context, player),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFFF1F5F9),
                      backgroundImage: player.avatarImage,
                      child: player.avatarImage == null
                          ? const Icon(Icons.person, color: Colors.grey)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            player.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            'Playera: ${player.jerseyName} (#${player.jerseyNumber}) • Tel: ${player.phoneNumber}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 4 ICONOS CON SEMÁFORO DE COLOR
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildCategoryBadge(
                          Icons.sports_soccer,
                          'Arbitraje',
                          arbColor,
                        ),
                        const SizedBox(width: 6),
                        _buildCategoryBadge(
                          Icons.emoji_events,
                          'Inscripción',
                          insColor,
                        ),
                        const SizedBox(width: 6),
                        _buildCategoryBadge(
                          Icons.access_time,
                          'Horario',
                          horColor,
                        ),
                        const SizedBox(width: 6),
                        _buildCategoryBadge(
                          Icons.checkroom,
                          'Uniforme',
                          uniColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1.5),
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void _showPaymentOptions(BuildContext context, Player player) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pagos de ${player.name}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(
                Icons.sports_soccer,
                color: Color(0xFFD31027),
              ),
              title: const Text('Arbitraje (\$50 por partido)'),
              subtitle: Text(
                'Abonado: \$${_state.paidArbitraje[player.id] ?? 0.0}',
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  _state.recordPayment(player.id!, 'Arbitraje', 50.0);
                  Navigator.pop(ctx);
                  setState(() {});
                },
                child: const Text('Pagar \$50'),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.emoji_events, color: Color(0xFF10B981)),
              title: const Text('Inscripción al Torneo (\$100)'),
              subtitle: Text(
                'Abonado: \$${_state.paidInscripcion[player.id] ?? 0.0} (100% Cubierto)',
              ),
            ),
            ListTile(
              leading: const Icon(Icons.access_time, color: Color(0xFF10B981)),
              title: const Text('Horario (\$100)'),
              subtitle: Text(
                'Abonado: \$${_state.paidHorario[player.id] ?? 0.0} (100% Cubierto)',
              ),
            ),
            ListTile(
              leading: const Icon(Icons.checkroom, color: Color(0xFF10B981)),
              title: const Text('Uniforme Oficial (\$300)'),
              subtitle: Text(
                'Abonado: \$${_state.paidUniforme[player.id] ?? 0.0} (100% Cubierto)',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== 4. PERFIL DE EQUIPO Y PLANTILLA COMPLETA ====================
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TeamState _state = TeamState();
  String _selectedFilter = 'TODOS'; // 'TODOS', 'ACTIVOS', 'BAJAS'

  @override
  Widget build(BuildContext context) {
    final allPlayers = _state.players;
    final activeCount = allPlayers.where((p) => p.status == 'ACTIVO').length;
    final bajaCount = allPlayers.where((p) => p.status == 'INACTIVO').length;

    List<Player> displayedPlayers = allPlayers;
    if (_selectedFilter == 'ACTIVOS') {
      displayedPlayers = allPlayers.where((p) => p.status == 'ACTIVO').toList();
    } else if (_selectedFilter == 'BAJAS') {
      displayedPlayers = allPlayers
          .where((p) => p.status == 'INACTIVO')
          .toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Perfil y Administración del Club',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFFC8102E),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Tarjeta Cabecera del Club con Sede Oficial
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.all(6),
                    child: Image.asset(
                      'assets/images/liverpool_logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Liverpool F.C.',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
                const Text(
                  'Torneo Apertura 2026 • 1er Lugar General',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 14),
                // CANCHA PRINCIPAL FIJA REQUERIDA
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Color(0xFFD31027),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Sede Principal de Juego:',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF991B1B),
                              ),
                            ),
                            Text(
                              TeamState.mainVenue,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF7F1D1D),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.add_location_alt,
                          color: Color(0xFFD31027),
                          size: 20,
                        ),
                        tooltip: 'Agregar nueva cancha',
                        onPressed: () => _showAddVenueDialog(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Filtro de Pestañas (Todos, Activos, Dados de Baja)
          Row(
            children: [
              _buildFilterChip('TODOS', 'Todos (${allPlayers.length})'),
              const SizedBox(width: 8),
              _buildFilterChip('ACTIVOS', 'Activos ($activeCount)'),
              const SizedBox(width: 8),
              _buildFilterChip('BAJAS', 'Dados de Baja ($bajaCount)'),
            ],
          ),
          const SizedBox(height: 12),

          // 3. Lista de toda la plantilla con número de teléfono
          ...displayedPlayers.map((player) {
            final isBaja = player.status == 'INACTIVO';

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isBaja ? Colors.red.shade200 : Colors.grey.shade200,
                  width: isBaja ? 1.5 : 1,
                ),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFF1F5F9),
                  backgroundImage: player.avatarImage,
                  child: player.avatarImage == null
                      ? Icon(
                          Icons.person,
                          color: isBaja ? Colors.red : Colors.grey,
                        )
                      : null,
                ),
                title: Row(
                  children: [
                    Text(
                      player.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        decoration: isBaja ? TextDecoration.lineThrough : null,
                        color: isBaja
                            ? Colors.grey.shade700
                            : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: isBaja
                            ? const Color(0xFFFEE2E2)
                            : const Color(0xFFE8F8F0),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isBaja ? 'DADO DE BAJA' : 'ACTIVO',
                        style: TextStyle(
                          color: isBaja
                              ? const Color(0xFFDC2626)
                              : const Color(0xFF10B981),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Playera: ${player.jerseyName} • Dorsal #${player.jerseyNumber}',
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone,
                          size: 14,
                          color: Color(0xFF10B981),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          player.phoneNumber,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'toggle') {
                      _state.togglePlayerStatus(player.id!);
                      setState(() {});
                    } else if (value == 'edit') {
                      _showQuickEditDialog(context, player);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'toggle',
                      child: Row(
                        children: [
                          Icon(
                            isBaja ? Icons.check_circle : Icons.block,
                            color: isBaja ? Colors.green : Colors.red,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(isBaja ? 'Reactivar Jugador' : 'Dar de Baja'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: const [
                          Icon(Icons.edit, color: Colors.blue, size: 18),
                          SizedBox(width: 8),
                          Text('Editar Teléfono / Info'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filterKey, String label) {
    final isSelected = _selectedFilter == filterKey;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = filterKey;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFD31027) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              if (!isSelected)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF64748B),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 11.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddVenueDialog(BuildContext context) {
    final venueCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Agregar Otra Cancha'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Canchas registradas actualmente:',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 6),
            ..._state.availableVenues.map(
              (v) => Text('• $v', style: const TextStyle(fontSize: 12)),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: venueCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre de la nueva cancha',
                hintText: 'Ej. Cancha Los Olivos',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final newVenue = venueCtrl.text.trim();
              if (newVenue.isNotEmpty) {
                _state.addVenue(newVenue);
                Navigator.pop(ctx);
                setState(() {});
              }
            },
            child: const Text('Agregar Cancha'),
          ),
        ],
      ),
    );
  }

  void _showQuickEditDialog(BuildContext context, Player player) {
    final phoneCtrl = TextEditingController(text: player.phoneNumber);
    final nameCtrl = TextEditingController(text: player.name);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Editar a ${player.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Número de Teléfono',
                prefixIcon: Icon(Icons.phone),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              player.name = nameCtrl.text.trim();
              player.phoneNumber = phoneCtrl.text.trim();
              _state.updatePlayer(player);
              Navigator.pop(ctx);
              setState(() {});
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Pintor geométrico del encabezado estilo Figma Liverpool F.C.
// ============================================================
class _HeaderGeometricPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Cuña angular rojo oscuro / sombra
    final darkRedPaint = Paint()
      ..color = const Color(0xFF8B0014)
      ..style = PaintingStyle.fill;
    final pathDark = Path()
      ..moveTo(w * 0.58, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h)
      ..lineTo(w * 0.70, h)
      ..close();
    canvas.drawPath(pathDark, darkRedPaint);

    // Cuña angular verde esmeralda / teal característica de Liverpool
    final tealPaint = Paint()
      ..color = const Color(0xFF00A398)
      ..style = PaintingStyle.fill;
    final pathTeal = Path()
      ..moveTo(w * 0.72, h)
      ..lineTo(w, h * 0.36)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(pathTeal, tealPaint);
  }

  @override
  bool shouldRepaint(_HeaderGeometricPainter old) => false;
}

// ============================================================
// Pintor geométrico de la tarjeta de próximo partido estilo Figma
// ============================================================
class _MatchCardGeometricPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Sutil corte diagonal oscuro en la mitad inferior derecha
    final darkCutPaint = Paint()
      ..color = const Color(0xFF071F1F)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(w * 0.46, h)
      ..lineTo(w, h * 0.12)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(path, darkCutPaint);
  }

  @override
  bool shouldRepaint(_MatchCardGeometricPainter old) => false;
}
