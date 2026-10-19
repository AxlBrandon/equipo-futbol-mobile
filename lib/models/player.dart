import 'dart:convert';
import 'package:flutter/widgets.dart';

class Player {
  final int? id;
  String name;
  String jerseyName;
  int jerseyNumber;
  String phoneNumber; // Número de teléfono del jugador
  String status; // 'ACTIVO' o 'INACTIVO' (Dado de baja)
  String? photoUrl;
  String? photoBase64;
  String? lastMatchInfo;
  bool isCaptain;

  Player({
    this.id,
    required this.name,
    this.jerseyName = '',
    required this.jerseyNumber,
    this.phoneNumber = '55 1234 5678',
    this.status = 'ACTIVO',
    this.photoUrl,
    this.photoBase64,
    this.lastMatchInfo = '23/10/2026 vs Bayern Munich',
    this.isCaptain = false,
  }) {
    if (jerseyName.isEmpty) {
      final parts = name.trim().split(' ');
      jerseyName = parts.isNotEmpty ? parts.first.toUpperCase() : '';
    }
  }

  ImageProvider? get avatarImage {
    if (photoBase64 != null && photoBase64!.isNotEmpty) {
      try {
        return MemoryImage(base64Decode(photoBase64!));
      } catch (_) {}
    }
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return NetworkImage(photoUrl!);
    }
    return null;
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      name: json['name'] ?? '',
      jerseyName: json['jerseyName'] ?? '',
      jerseyNumber: json['jerseyNumber'] ?? 0,
      phoneNumber: json['phoneNumber'] ?? json['phone_number'] ?? '55 1234 5678',
      status: json['status'] ?? 'ACTIVO',
      photoUrl: json['photoUrl'],
      photoBase64: json['photoBase64'] ?? json['photoData'],
      lastMatchInfo: json['lastMatchInfo'] ?? '23/10/2026 vs Bayern Munich',
      isCaptain: json['isCaptain'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'jerseyName': jerseyName,
      'jerseyNumber': jerseyNumber,
      'phoneNumber': phoneNumber,
      'status': status,
      'photoUrl': photoUrl,
      'photoBase64': photoBase64,
      'lastMatchInfo': lastMatchInfo,
      'isCaptain': isCaptain,
    };
  }
}
