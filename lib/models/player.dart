class Player {
  final int? id;
  final String name;
  final int jerseyNumber;
  final String status;

  Player({
    this.id,
    required this.name,
    required this.jerseyNumber,
    required this.status,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      name: json['name'],
      jerseyNumber: json['jerseyNumber'],
      status: json['status'] ?? 'ACTIVE',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'jerseyNumber': jerseyNumber, 'status': status};
  }
}
