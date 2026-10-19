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
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: const Color(0xFFD31027),
          unselectedItemColor: const Color(0xFF94A3B8),
          backgroundColor: Colors.white,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.groups_outlined),
              activeIcon: Icon(Icons.groups),
              label: 'Asistencia',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.payments_outlined),
              activeIcon: Icon(Icons.payments),
              label: 'Pagos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings_outlined),
              activeIcon: Icon(Icons.admin_panel_settings),
              label: 'Perfil Club',
            ),
          ],
        ),
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
    final palette = [
      const Color(0xFF00C9A7), // Turquesa
      const Color(0xFFF59E0B), // Dorado / Ámbar
      const Color(0xFFA855F7), // Púrpura
      const Color(0xFF3B82F6), // Azul
    ];

    // En Inicio mostramos los jugadores activos
    final activePlayers = _state.players
        .where((p) => p.status == 'ACTIVO')
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. ENCABEZADO CON LOGO OFICIAL LIVERPOOL Y AURA NEÓN
            _buildTopHeader(),

            // 2. CONTENIDO PRINCIPAL CURVADO
            Transform.translate(
              offset: const Offset(0, -18),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF6F8FB),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    // TARJETA DE PRÓXIMO PARTIDO (AL TOCAR ABRE CONFIRMACIÓN DE ASISTENCIA)
                    _buildNextMatchCard(),

                    const SizedBox(height: 12),

                    // PUNTOS INDICADORES DEL CARRUSEL
                    _buildCarouselIndicators(),

                    const SizedBox(height: 22),

                    // TÍTULO "Mi Plantilla" + BOTÓN "+ Agregar Jugadores"
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Mi Plantilla',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              '${activePlayers.length} Jugadores Activos en Cancha',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        _buildAddPlayerButton(),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // LISTA DE TARJETAS DE JUGADORES ACTIVOS
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: activePlayers.length,
                      itemBuilder: (context, index) {
                        final player = activePlayers[index];
                        final accentColor = palette[index % palette.length];
                        return _buildPlayerCard(player, accentColor, index);
                      },
                    ),

                    const SizedBox(height: 20),
                    const Center(
                      child: Text(
                        'by AXLORRA',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Encabezado con Logo oficial de Liverpool
  Widget _buildTopHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 48, 20, 36),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFE50914), // Rojo Liverpool vibrante
            Color(0xFFC8102E),
            Color(0xFF8B0000), // Rojo profundo
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Liverpool',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  height: 1.05,
                ),
              ),
              Text(
                'F.C.',
                style: TextStyle(
                  color: Color(0xFF00E5FF),
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  height: 1.1,
                ),
              ),
            ],
          ),

          // Escudo oficial con aura neón
          _buildOfficialLiverpoolLogo(),
        ],
      ),
    );
  }

  Widget _buildOfficialLiverpoolLogo() {
    return Container(
      width: 78,
      height: 78,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
            blurRadius: 18,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: const Color(0xFFFF2A6D).withValues(alpha: 0.4),
            blurRadius: 22,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Halo de luz neón
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.8),
                width: 1.5,
              ),
              gradient: SweepGradient(
                colors: [
                  const Color(0xFF00E5FF),
                  const Color(0xFFFF2A6D).withValues(alpha: 0.7),
                  Colors.transparent,
                  const Color(0xFF00E5FF),
                ],
              ),
            ),
          ),
          // Logo oficial cargado desde los assets
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Image.asset(
              'assets/images/liverpool_logo.png',
              width: 58,
              height: 58,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) =>
                  const Icon(Icons.shield, color: Colors.white, size: 40),
            ),
          ),
        ],
      ),
    );
  }

  // Tarjeta "Próximo Partido" interactiva — estilo de la plantilla
  Widget _buildNextMatchCard() {
    final match = _state.currentMatch;
    final confirmedCount = _state.rsvpMap.values.where((v) => v).length;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _showRsvpModal(context),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD31027).withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // ── Fondo: gradiente rojo/naranja como la plantilla ──
              Container(
                height: 170,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFB91C1C),
                      Color(0xFFEF4444),
                      Color(0xFFFF6B35),
                      Color(0xFFEF4444),
                      Color(0xFFB91C1C),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                  ),
                ),
              ),
              // ── Rayas diagonales blancas estilo plantilla ──
              Positioned.fill(
                child: CustomPaint(
                  painter: _DiagonalStripesPainter(),
                ),
              ),
              // ── Botón editar esquina superior derecha ──
              Positioned(
                top: 4,
                right: 4,
                child: IconButton(
                  icon: const Icon(
                    Icons.edit_calendar,
                    color: Colors.white70,
                    size: 18,
                  ),
                  tooltip: 'Cambiar o Agendar Partido',
                  onPressed: () => _showNewMatchDialog(context),
                ),
              ),
              // ── Contenido centrado ──
              SizedBox(
                height: 170,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Badge "Próximo Partido"
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Próximo Partido',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    // Fecha con hora
                    Text(
                      match.matchDate,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Logos y nombres de equipos
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Liverpool
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(4),
                              child: Image.asset(
                                'assets/images/liverpool_logo.png',
                                fit: BoxFit.contain,
                                errorBuilder: (_, _, _) => const Icon(
                                  Icons.shield,
                                  color: Color(0xFFD31027),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Liverpool',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        // VS badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'VS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        // Rival
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Image.network(
                                    match.opponentLogo,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, _, _) => const Icon(
                                      Icons.sports_soccer,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              match.opponent,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Toca para confirmar asistencia ($confirmedCount confirmados)',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 10,
                      ),
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

  Widget _buildCarouselIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 14,
          height: 5,
          decoration: BoxDecoration(
            color: const Color(0xFFD31027),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        for (int i = 0; i < 4; i++) ...[
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: Color(0xFFCBD5E1),
              shape: BoxShape.circle,
            ),
          ),
          if (i < 3) const SizedBox(width: 5),
        ],
      ],
    );
  }

  Widget _buildAddPlayerButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF5252), Color(0xFFFF7A00)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF5252).withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => _showAddPlayerDialog(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add, color: Colors.white, size: 20),
                const SizedBox(width: 4),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Agregar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      'Jugadores',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Tarjeta de Jugador con navegación al perfil e insignia de Capitán
  Widget _buildPlayerCard(Player player, Color accentColor, int index) {
    final parts = player.name.trim().split(' ');
    final firstName = parts.first;
    final lastName = parts.length > 1
        ? parts.sublist(1).join(' ')
        : (player.jerseyName.isNotEmpty ? player.jerseyName : '');
    final isCaptain = _state.isCaptain(player.id!);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _showPlayerProfileModal(context, player),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isCaptain ? const Color(0xFFF59E0B) : accentColor,
            width: isCaptain ? 2.5 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isCaptain
                  ? const Color(0xFFF59E0B).withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              // Rayas diagonales estilizadas en esquina inferior derecha
              Positioned(
                right: -12,
                bottom: -18,
                child: Transform.rotate(
                  angle: -0.65,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5,
                        height: 70,
                        color: accentColor.withValues(alpha: 0.35),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 9,
                        height: 70,
                        color: accentColor.withValues(alpha: 0.8),
                      ),
                    ],
                  ),
                ),
              ),

              // Contenido
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    // Avatar con anillo de color temático y soporte para fotos de cámara/galería
                    Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCaptain
                              ? const Color(0xFFF59E0B)
                              : accentColor,
                          width: 2.2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 26,
                        backgroundColor: const Color(0xFFF1F5F9),
                        backgroundImage: player.avatarImage,
                        child: player.avatarImage == null
                            ? const Icon(
                                Icons.person,
                                color: Color(0xFF94A3B8),
                                size: 30,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Nombres
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
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF1E293B),
                                  letterSpacing: 0.2,
                                ),
                              ),
                              if (isCaptain) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 1.5,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFF59E0B),
                                        Color(0xFFD97706),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    '👑 CAP',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 9.5,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            lastName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                              height: 1.1,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Estatus ACTIVO y Número unificado
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2.5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F8F0),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            player.status.toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF10B981),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        _buildUnifiedJerseyBadge(player.jerseyNumber, styleIndex: index),
                      ],
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 3 estilos rotativos de dorsal según índice
  Widget _buildUnifiedJerseyBadge(int number, {int styleIndex = 0}) {
    switch (styleIndex % 3) {
      // Estilo 0: Rojo rubí hexagonal con borde cyan
      case 0:
        return Container(
          width: 46,
          height: 50,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFD31027), Color(0xFF8B0000)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
              bottomLeft: Radius.circular(22),
              bottomRight: Radius.circular(22),
            ),
            border: Border.all(color: const Color(0xFF00E5FF), width: 1.8),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD31027).withValues(alpha: 0.45),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '$number',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 21,
                letterSpacing: 0.5,
              ),
            ),
          ),
        );

      // Estilo 1: Escudo medieval azul marino con borde dorado
      case 1:
        return SizedBox(
          width: 46,
          height: 52,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(46, 52),
                painter: _ShieldPainter(
                  fillColor: const Color(0xFF0A2342),
                  borderColor: const Color(0xFFD4AF37),
                ),
              ),
              Text(
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 19,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        );

      // Estilo 2: Círculo púrpura con doble anillo
      default:
        return Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [Color(0xFF7C3AED), Color(0xFF4C1D95)],
              center: Alignment(-0.3, -0.3),
              radius: 1.2,
            ),
            border: Border.all(color: const Color(0xFFDDD6FE), width: 2.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C3AED).withValues(alpha: 0.4),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  '$number',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 19,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        );
    }
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
// Pintor del escudo medieval (azul marino con borde dorado)
// ============================================================
class _ShieldPainter extends CustomPainter {
  final Color fillColor;
  final Color borderColor;

  _ShieldPainter({required this.fillColor, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path()
      ..moveTo(w * 0.5, h)
      ..lineTo(0, h * 0.6)
      ..lineTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h * 0.6)
      ..close();

    // Relleno
    canvas.drawPath(path, Paint()..color = fillColor);

    // Borde dorado
    canvas.drawPath(
      path,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );
  }

  @override
  bool shouldRepaint(_ShieldPainter old) =>
      fillColor != old.fillColor || borderColor != old.borderColor;
}

// ============================================================
// Pintor de rayas diagonales semi-transparentes (tarjeta de partido)
// ============================================================
class _DiagonalStripesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..strokeWidth = 22
      ..style = PaintingStyle.stroke;

    // 6 rayas diagonales espaciadas
    for (int i = -2; i < 8; i++) {
      final x = i * 36.0;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DiagonalStripesPainter old) => false;
}
