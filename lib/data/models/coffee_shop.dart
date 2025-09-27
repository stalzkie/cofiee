import 'package:cofiee/core/utils/converters.dart';

class CoffeeShop {
  final String id;
  final String? ownerId;
  final String name;
  final String? description;
  // location normalized to lat/lng (either from ST_Y/ST_X or nested JSON)
  final double lat;
  final double lng;
  final String? address;
  final bool wifiAvailable;
  /// "HH:mm:ss" (simple daily opening time)
  final String? openingTime;
  final int seatCapacity;
  final int seatsAvailable;
  final bool isVerified;
  final double averageRating;    // 0..5
  final int ratingsCount;
  final DateTime? createdAt;

  const CoffeeShop({
    required this.id,
    this.ownerId,
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
    // Support either flat lat/lng or PostGIS JSON like { location: { lat, lng } }
    double lat() {
      if (m['lat'] != null) return toDouble(m['lat']);
      if (m['lat_out'] != null) return toDouble(m['lat_out']);
      final loc = m['location'];
      if (loc is Map && loc['lat'] != null) return toDouble(loc['lat']);
      return 0.0;
    }

    double lng() {
      if (m['lng'] != null) return toDouble(m['lng']);
      if (m['lng_out'] != null) return toDouble(m['lng_out']);
      final loc = m['location'];
      if (loc is Map && loc['lng'] != null) return toDouble(loc['lng']);
      return 0.0;
    }

    return CoffeeShop(
      id: m['id'],
      ownerId: m['owner_id'],
      name: m['name'] ?? '',
      description: m['description'],
      lat: lat(),
      lng: lng(),
      address: m['address'],
      wifiAvailable: toBool(m['wifi_available']),
      openingTime: m['opening_time']?.toString(),
      seatCapacity: toInt(m['seat_capacity']),
      seatsAvailable: toInt(m['seats_available']),
      isVerified: toBool(m['is_verified']),
      averageRating: toDouble(m['average_rating']),
      ratingsCount: toInt(m['ratings_count']),
      createdAt: m['created_at'] != null ? DateTime.tryParse(m['created_at'].toString()) : null,
    );
  }

  /// For inserts/updates (server will compute averages)
  Map<String, dynamic> toMapForUpsert({
    required double lat,
    required double lng,
  }) =>
      {
        if (ownerId != null) 'owner_id': ownerId,
        'name': name,
        if (description != null) 'description': description,
        // Supply geometry via RPC or via raw SQL if using PostGIS on server side.
        // If you store lat/lng separately, adjust accordingly.
        'address': address,
        'wifi_available': wifiAvailable,
        if (openingTime != null) 'opening_time': openingTime,
        'seat_capacity': seatCapacity,
        'seats_available': seatsAvailable,
        'is_verified': isVerified,
      };

  CoffeeShop copyWith({
    String? ownerId,
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
  }) =>
      CoffeeShop(
        id: id,
        ownerId: ownerId ?? this.ownerId,
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
