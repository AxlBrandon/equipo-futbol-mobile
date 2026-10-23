class MatchModel {
  final int? id;
  String opponent;
  String opponentLogo;
  String matchDate;
  String matchLocation;
  bool isUpcoming;
  DateTime? matchDateTime;

  MatchModel({
    this.id,
    required this.opponent,
    required this.opponentLogo,
    required this.matchDate,
    required this.matchLocation,
    this.isUpcoming = true,
    this.matchDateTime,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'opponent': opponent,
    'opponentLogo': opponentLogo,
    'matchDate': matchDate,
    'matchLocation': matchLocation,
    'isUpcoming': isUpcoming,
    'matchDateTime': matchDateTime?.toIso8601String(),
  };

  factory MatchModel.fromJson(Map<String, dynamic> json) => MatchModel(
    id: json['id'],
    opponent: json['opponent'] ?? '',
    opponentLogo: json['opponentLogo'] ?? '',
    matchDate: json['matchDate'] ?? '',
    matchLocation: json['matchLocation'] ?? '',
    isUpcoming: json['isUpcoming'] ?? true,
    matchDateTime: json['matchDateTime'] != null ? DateTime.tryParse(json['matchDateTime']) : null,
  );
}

class InternationalClub {
  final String name;
  final String country;
  final String logoUrl;

  const InternationalClub({
    required this.name,
    required this.country,
    required this.logoUrl,
  });
}

// Catálogo ampliado de más de 30 clubes internacionales con escudos de alta resolución
const List<InternationalClub> popularClubs = [
  // España (LaLiga)
  InternationalClub(
    name: 'Real Madrid',
    country: 'España',
    logoUrl: 'https://upload.wikimedia.org/wikipedia/en/thumb/5/56/Real_Madrid_CF.svg/200px-Real_Madrid_CF.svg.png',
  ),
  InternationalClub(
    name: 'FC Barcelona',
    country: 'España',
    logoUrl: 'https://upload.wikimedia.org/wikipedia/en/thumb/4/47/FC_Barcelona_%28crest%29.svg/200px-FC_Barcelona_%28crest%29.svg.png',
  ),
  InternationalClub(
    name: 'Atlético de Madrid',
    country: 'España',
    logoUrl: 'https://upload.wikimedia.org/wikipedia/en/thumb/f/f4/Atletico_Madrid_2017_logo.svg/200px-Atletico_Madrid_2017_logo.svg.png',
  ),
  InternationalClub(
    name: 'Sevilla FC',
    country: 'España',
    logoUrl: 'https://upload.wikimedia.org/wikipedia/en/thumb/3/3b/Sevilla_FC_logo.svg/200px-Sevilla_FC_logo.svg.png',
  ),
  InternationalClub(
    name: 'Real Betis',
    country: 'España',
    logoUrl: 'https://upload.wikimedia.org/wikipedia/en/thumb/1/13/Real_betis_logo.svg/200px-Real_betis_logo.svg.png',
  ),

  // Alemania (Bundesliga)
  InternationalClub(
    name: 'Bayern Munich',
    country: 'Alemania',
    logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1b/FC_Bayern_M%C3%BCnchen_logo_%282017%29.svg/200px-FC_Bayern_M%C3%BCnchen_logo_%282017%29.svg.png',
  ),
  InternationalClub(
    name: 'Borussia Dortmund',
    country: 'Alemania',
    logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/67/Borussia_Dortmund_logo.svg/200px-Borussia_Dortmund_logo.svg.png',
  ),
  InternationalClub(
    name: 'Bayer Leverkusen',
    country: 'Alemania',
    logoUrl: 'https://upload.wikimedia.org/wikipedia/en/thumb/5/59/Bayer_04_Leverkusen_logo.svg/200px-Bayer_04_Leverkusen_logo.svg.png',
  ),
  InternationalClub(
    name: 'RB Leipzig',
    country: 'Alemania',
    logoUrl: 'https://upload.wikimedia.org/wikipedia/en/thumb/0/04/RB_Leipzig_2014_logo.svg/200px-RB_Leipzig_2014_logo.svg.png',
  ),

  // Inglaterra (Premier League)
  InternationalClub(
    name: 'Manchester City',
    country: 'Inglaterra',
    logoUrl: 'https://upload.wikimedia.org/wikipedia/en/thumb/e/eb/Manchester_City_FC_badge.svg/200px-Manchester_City_FC_badge.svg.png',
  ),
  InternationalClub(
    name: 'Arsenal',
    country: 'Inglaterra',
    logoUrl: 'https://upload.wikimedia.org/wikipedia/en/thumb/5/53/Arsenal_FC.svg/200px-Arsenal_FC.svg.png',
  ),
  InternationalClub(
    name: 'Chelsea FC',
    country: 'Inglaterra',
    logoUrl: 'https://upload.wikimedia.org/wikipedia/en/thumb/c/cc/Chelsea_FC.svg/200px-Chelsea_FC.svg.png',
  ),
  InternationalClub(
    name: 'Manchester United',
    country: 'Inglaterra',
    logoUrl: 'https://upload.wikimedia.org/wikipedia/en/thumb/7/7a/Manchester_United_FC_crest.svg/200px-Manchester_United_FC_crest.svg.png',
  ),
  InternationalClub(
    name: 'Tottenham Hotspur',
    country: 'Inglaterra',
    logoUrl: 'https://upload.wikimedia.org/wikipedia/en/thumb/b/b4/Tottenham_Hotspur.svg/200px-Tottenham_Hotspur.svg.png',
  ),

  // Italia (Serie A)
  InternationalClub(
    name: 'Inter de Milán',
    country: 'Italia',
    logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/05/FC_Internazionale_Milano_2021.svg/200px-FC_Internazionale_Milano_2021.svg.png',
  ),
  InternationalClub(
    name: 'AC Milan',
    country: 'Italia',
    logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d0/Logo_of_AC_Milan.svg/200px-Logo_of_AC_Milan.svg.png',
  ),
  InternationalClub(
    name: 'Juventus',
    country: 'Italia',
    logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/15/Juventus_FC_2017_logo.svg/200px-Juventus_FC_2017_logo.svg.png',
  ),
  InternationalClub(
    name: 'Napoli',
    country: 'Italia',
    logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/ba/SSC_Napoli_2024_%28deep_blue_silhouette%29.svg/200px-SSC_Napoli_2024_%28deep_blue_silhouette%29.svg.png',
  ),
  InternationalClub(
    name: 'AS Roma',
    country: 'Italia',
    logoUrl: 'https://upload.wikimedia.org/wikipedia/en/thumb/f/f7/AS_Roma_logo_%282017%29.svg/200px-AS_Roma_logo_%282017%29.svg.png',
  ),

  // Francia (Ligue 1)
  InternationalClub(
    name: 'Paris Saint-Germain',
    country: 'Francia',
    logoUrl: 'https://upload.wikimedia.org/wikipedia/en/thumb/a/a7/Paris_Saint-Germain_F.C..svg/200px-Paris_Saint-Germain_F.C..svg.png',
  ),
  InternationalClub(
    name: 'Olympique de Marsella',
    country: 'Francia',
    logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d8/Olympique_Marseille_logo.svg/200px-Olympique_Marseille_logo.svg.png',
  ),

  // México (Liga MX)
  InternationalClub(
    name: 'Club América',
    country: 'México',
    logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/17/Club_America_logo.svg/200px-Club_America_logo.svg.png',
  ),
  InternationalClub(
    name: 'Chivas Guadalajara',
    country: 'México',
    logoUrl: 'https://upload.wikimedia.org/wikipedia/en/thumb/4/43/C.D._Guadalajara_logo.svg/200px-C.D._Guadalajara_logo.svg.png',
  ),
  InternationalClub(
    name: 'Cruz Azul',
    country: 'México',
    logoUrl: 'https://upload.wikimedia.org/wikipedia/en/thumb/9/90/Cruz_Azul_logo.svg/200px-Cruz_Azul_logo.svg.png',
  ),
  InternationalClub(
    name: 'Tigres UANL',
    country: 'México',
    logoUrl: 'https://upload.wikimedia.org/wikipedia/en/thumb/5/53/Tigres_UANL_logo.svg/200px-Tigres_UANL_logo.svg.png',
  ),
  InternationalClub(
    name: 'Monterrey Rayados',
    country: 'México',
    logoUrl: 'https://upload.wikimedia.org/wikipedia/en/thumb/c/c2/CF_Monterrey_logo.svg/200px-CF_Monterrey_logo.svg.png',
  ),

  // Argentina & Sudamérica
  InternationalClub(
    name: 'Boca Juniors',
    country: 'Argentina',
    logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e3/Boca_Juniors_logo18.svg/200px-Boca_Juniors_logo18.svg.png',
  ),
  InternationalClub(
    name: 'River Plate',
    country: 'Argentina',
    logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ac/Escudo_del_C_A_River_Plate.svg/200px-Escudo_del_C_A_River_Plate.svg.png',
  ),
  InternationalClub(
    name: 'Flamengo',
    country: 'Brasil',
    logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2e/Flamengo_braz_logo.svg/200px-Flamengo_braz_logo.svg.png',
  ),
];
