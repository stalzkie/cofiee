import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/coffee_shop.dart';

class ShopsAPI {
  ShopsAPI();

  SupabaseClient get _sb {
    try {
      return Supabase.instance.client;
    } catch (_) {
      throw StateError(
        'Supabase is not initialized. Call Supabase.initialize(...) before using ShopsAPI.',
      );
    }
  }

  Future<List<CoffeeShop>> fetchAllShops() async {
    final rows = await _sb
        .from('coffee_shops')
        .select('''
          id, owner_id, name, description, address,
          wifi_available, opening_time, seat_capacity, seats_available,
          is_verified, average_rating, ratings_count, created_at,
          location
        ''');

    return (rows as List)
        .map((m) => CoffeeShop.fromMap(m as Map<String, dynamic>))
        .toList();
  }

  Future<CoffeeShop> fetchShopById(String id) async {
    final row = await _sb
        .from('coffee_shops')
        .select('''
          id, owner_id, name, description, address,
          wifi_available, opening_time, seat_capacity, seats_available,
          is_verified, average_rating, ratings_count, created_at,
          location
        ''')
        .eq('id', id)
        .single();

    return CoffeeShop.fromMap(row as Map<String, dynamic>);
  }

  /// Update scalar fields (geometry handled separately via RPC if needed)
  Future<CoffeeShop> saveShop(CoffeeShop shop) async {
    final payload = <String, dynamic>{
      'name': shop.name,
      if (shop.description != null) 'description': shop.description,
      if (shop.address != null) 'address': shop.address,
      'wifi_available': shop.wifiAvailable,
      if (shop.openingTime != null) 'opening_time': shop.openingTime, // "HH:mm:ss"
      'seat_capacity': shop.seatCapacity,
      'seats_available': shop.seatsAvailable,
      // avoid is_verified unless policy allows it
    };

    final updated = await _sb
        .from('coffee_shops')
        .update(payload)
        .eq('id', shop.id)
        .select()
        .single();

    return CoffeeShop.fromMap(updated as Map<String, dynamic>);
  }

  /// Optional: update geometry with an RPC (see earlier SQL)
  Future<void> setShopLocation({
    required String shopId,
    required double lat,
    required double lng,
  }) async {
    await _sb.rpc('set_shop_location', params: {
      'p_shop_id': shopId,
      'p_lat': lat,
      'p_lng': lng,
    });
  }

  Future<void> deleteShop(String id) async {
    await _sb.from('coffee_shops').delete().eq('id', id);
  }
}
