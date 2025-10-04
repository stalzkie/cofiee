// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:cofiee/core/utils/converters.dart';

class CoffeeShop {
  final String id;
  // ignore: non_constant_identifier_names
  final String? owner_id;
  final String name;
  final String? description;

  /// Normalized coordinates (derived from PostGIS geometry or flat columns if present)
  final double lat;
  final double lng;

  final String? address;
  final bool wifiAvailable;

  /// "HH:mm:ss" (simple daily opening time)
  final String? openingTime;

  final int seatCapacity;
  final int seatsAvailable;
  final bool isVerified;
  final double averageRating; // 0..5
  final int ratingsCount;
  final DateTime? createdAt;

  const CoffeeShop({
    required this.id,
    this.owner_id,
    required this.name,
    this.description,
    required this.lat,
    required this.lng,
    this.address,
    required this.wifiAvailable,
    this.openingTime,
    required this.seatCapacity,
    required this.seatsAvailable,
    required this.isVerified,
    required this.averageRating,
    required this.ratingsCount,
    this.createdAt,
  });

  factory CoffeeShop.fromMap(Map<String, dynamic> m) {
    // --- Helpers to derive lat/lng from various shapes ---
    double _lat() {
      if (m['lat'] != null) return toDouble(m['lat']);
      final loc = m['location'];

      // GeoJSON object: { type:"Point", coordinates:[lng, lat] }
      if (loc is Map && loc['coordinates'] is List && (loc['coordinates'] as List).length >= 2) {
        final coords = loc['coordinates'] as List;
        return toDouble(coords[1]); // lat is second
      }

      // Location as stringified JSON
      if (loc is String) {
        try {
          final decoded = jsonDecode(loc);
          if (decoded is Map && decoded['coordinates'] is List && (decoded['coordinates'] as List).length >= 2) {
            final coords = decoded['coordinates'] as List;
            return toDouble(coords[1]);
          }
        } catch (_) {}
      }

      // Fallback: some backends send { location: { lat, lng } }
      if (loc is Map && loc['lat'] != null) return toDouble(loc['lat']);

      return 0.0;
    }

    double _lng() {
      if (m['lng'] != null) return toDouble(m['lng']);
      final loc = m['location'];

      // GeoJSON object
      if (loc is Map && loc['coordinates'] is List && (loc['coordinates'] as List).length >= 2) {
        final coords = loc['coordinates'] as List;
        return toDouble(coords[0]); // lng is first
      }

      // Stringified JSON
      if (loc is String) {
        try {
          final decoded = jsonDecode(loc);
          if (decoded is Map && decoded['coordinates'] is List && (decoded['coordinates'] as List).length >= 2) {
            final coords = decoded['coordinates'] as List;
            return toDouble(coords[0]);
          }
        } catch (_) {}
      }

      // Fallback nested object
      if (loc is Map && loc['lng'] != null) return toDouble(loc['lng']);

      return 0.0;
    }

    return CoffeeShop(
      id: m['id'],
      owner_id: m['owner_id'],
      name: m['name'] ?? '',
      description: m['description'],
      lat: _lat(),
      lng: _lng(),
      address: m['address'],
      wifiAvailable: toBool(m['wifi_available']),
      openingTime: m['opening_time']?.toString(),
      seatCapacity: toInt(m['seat_capacity']),
      seatsAvailable: toInt(m['seats_available']),
      isVerified: toBool(m['is_verified']),
      averageRating: toDouble(m['average_rating']),
      ratingsCount: toInt(m['ratings_count']),
      createdAt: m['created_at'] != null
          ? DateTime.tryParse(m['created_at'].toString())
          : null,
    );
  }

  /// For inserts/updates of scalar fields only.
  /// Your DB stores location as PostGIS geometry, so we do NOT send lat/lng here.
  Map<String, dynamic> toMapForUpsert({
    bool includeIsVerified = false, // set true only if RLS allows client to edit this
  }) {
    final map = <String, dynamic>{
      if (owner_id != null) 'owner_id': owner_id,
      'name': name,
      if (description != null) 'description': description,
      'address': address,
      'wifi_available': wifiAvailable,
      if (openingTime != null) 'opening_time': openingTime,
      'seat_capacity': seatCapacity,
      'seats_available': seatsAvailable,
    };

    if (includeIsVerified) {
      map['is_verified'] = isVerified;
    }

    return map;
  }

  CoffeeShop copyWith({
    String? owner_id,
    String? name,
    String? description,
    double? lat,
    double? lng,
    String? address,
    bool? wifiAvailable,
    String? openingTime,
    int? seatCapacity,
    int? seatsAvailable,
    bool? isVerified,
    double? averageRating,
    int? ratingsCount,
  }) {
    return CoffeeShop(
      id: id,
      owner_id: owner_id ?? this.owner_id,
      name: name ?? this.name,
      description: description ?? this.description,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      address: address ?? this.address,
      wifiAvailable: wifiAvailable ?? this.wifiAvailable,
      openingTime: openingTime ?? this.openingTime,
      seatCapacity: seatCapacity ?? this.seatCapacity,
      seatsAvailable: seatsAvailable ?? this.seatsAvailable,
      isVerified: isVerified ?? this.isVerified,
      averageRating: averageRating ?? this.averageRating,
      ratingsCount: ratingsCount ?? this.ratingsCount,
      createdAt: createdAt,
    );
  }
}
