import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';

class Player {
  final int? id;
  String name;
  String jerseyName;
  int jerseyNumber;
  String phoneNumber; // Número de teléfono del jugador
  String status; // 'ACTIVO' o 'INACTIVO' (Dado de baja)
  String? photoUrl;
  String? _photoBase64;
  String? lastMatchInfo;
  bool isCaptain;

  // Caché de imagen en memoria para renderizado ultra rápido a 60-120fps sin recodificar en cada build
  Uint8List? _cachedBytes;
  ImageProvider? _cachedAvatar;

  Player({
    this.id,
    required this.name,
    this.jerseyName = '',
    required this.jerseyNumber,
    this.phoneNumber = '55 1234 5678',
    this.status = 'ACTIVO',
    this.photoUrl,
    String? photoBase64,
    this.lastMatchInfo = 'Sin partido registrado',
    this.isCaptain = false,
  }) {
    _photoBase64 = photoBase64;
    if (jerseyName.isEmpty) {
      final parts = name.trim().split(' ');
      jerseyName = parts.isNotEmpty ? parts.first.toUpperCase() : '';
    }
  }

  String? get photoBase64 => _photoBase64;
  set photoBase64(String? val) {
    if (_photoBase64 != val) {
      _photoBase64 = val;
      _cachedBytes = null;
      _cachedAvatar = null;
    }
  }

  ImageProvider? get avatarImage {
    if (_cachedAvatar != null) return _cachedAvatar;

    if (_photoBase64 != null && _photoBase64!.isNotEmpty) {
      try {
        _cachedBytes ??= base64Decode(_photoBase64!);
        _cachedAvatar = MemoryImage(_cachedBytes!);
        return _cachedAvatar;
      } catch (_) {}
    }
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      _cachedAvatar = NetworkImage(photoUrl!);
      return _cachedAvatar;
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
      lastMatchInfo: json['lastMatchInfo'] ?? 'Sin partido registrado',
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
      'photoBase64': _photoBase64,
      'lastMatchInfo': lastMatchInfo,
      'isCaptain': isCaptain,
    };
  }
}
