import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/coffee_shop.dart';

class MapViewModel extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  GoogleMapController? _controller;
  bool locationPermissionGranted = false;

  CameraPosition cameraPosition = const CameraPosition(
    target: LatLng(10.6765, 122.9511), // Bacolod default
    zoom: 14,
  );

  List<CoffeeShop> shops = []; // 👈 store shops instead of markers
  bool isLoading = false;
  String? errorMessage;

  MapViewModel() {
    _init();
  }

  Future<void> _init() async {
    await _ensureLocationPermissions();
    await loadShops();
    if (locationPermissionGranted) {
      await centerOnUser(animate: false);
    }
  }

  void onMapCreated(GoogleMapController controller) {
    _controller = controller;
  }

  Future<void> _ensureLocationPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }
    locationPermissionGranted = (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse);
    notifyListeners();
  }

  Future<void> centerOnUser({bool animate = true}) async {
    try {
      if (!locationPermissionGranted) return;
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      final target = LatLng(pos.latitude, pos.longitude);

      cameraPosition = CameraPosition(target: target, zoom: 15);
      if (animate) {
        await _controller?.animateCamera(
          CameraUpdate.newCameraPosition(cameraPosition),
        );
      } else {
        await _controller?.moveCamera(
          CameraUpdate.newCameraPosition(cameraPosition),
        );
      }
      notifyListeners();
    } catch (_) {
      // Ignore location errors silently here
    }
  }

  /// Load coffee shops from Supabase
  Future<void> loadShops() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await supabase.from('coffee_shops').select('''
        id,
        owner_id,
        name,
        description,
        address,
        location,
        wifi_available,
        opening_time,
        seat_capacity,
        seats_available,
        is_verified,
        average_rating,
        ratings_count,
        created_at
      ''');

      final List<dynamic> rows = response as List<dynamic>;
      final List<CoffeeShop> loaded = [];

      for (final raw in rows) {
        final map = raw as Map<String, dynamic>;

        // Handle GeoJSON "location"
        if (map['location'] != null) {
          dynamic loc = map['location'];
          if (loc is String) {
            try {
              loc = jsonDecode(loc);
            } catch (_) {}
          }
          if (loc is Map &&
              loc['type'] == 'Point' &&
              loc['coordinates'] is List) {
            final coords = (loc['coordinates'] as List);
            if (coords.length == 2) {
              map['lng'] = coords[0];
              map['lat'] = coords[1];
            }
          }
        }

        loaded.add(CoffeeShop.fromMap(map));
      }

      shops = loaded;
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage =
          'Failed to load coffee shops. ${kDebugMode ? e.toString() : ''}';
      notifyListeners();
    }
  }
}
