import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/error/failure.dart';
import '../models/coffee_shop.dart';

class ShopsRepository {
  final SupabaseClient _client;

  ShopsRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  /// Fetch all coffee shops
  Future<List<CoffeeShop>> getAll() async {
    try {
      final response = await _client
          .from('coffee_shops')
          .select('*')
          .order('created_at', ascending: false);

      final rows = response as List<dynamic>;
      return rows.map((e) => CoffeeShop.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Failure('Failed to load coffee shops: $e');
    }
  }

  /// Fetch by ID
  Future<CoffeeShop?> getById(String id) async {
    try {
      final response =
          await _client.from('coffee_shops').select().eq('id', id).maybeSingle();

      if (response == null) return null;
      return CoffeeShop.fromMap(response as Map<String, dynamic>);
    } catch (e) {
      throw Failure('Failed to load coffee shop $id: $e');
    }
  }

  /// Insert or update a coffee shop
  Future<CoffeeShop> upsert(CoffeeShop shop) async {
    try {
      final data = shop.toMapForUpsert(lat: shop.lat, lng: shop.lng);

      final response = await _client
          .from('coffee_shops')
          .upsert({
            'id': shop.id,
            ...data,
            'lat': shop.lat,
            'lng': shop.lng,
          })
          .select()
          .single();

      return CoffeeShop.fromMap(response as Map<String, dynamic>);
    } catch (e) {
      throw Failure('Failed to save coffee shop: $e');
    }
  }

  /// Delete by ID
  Future<void> delete(String id) async {
    try {
      await _client.from('coffee_shops').delete().eq('id', id);
    } catch (e) {
      throw Failure('Failed to delete coffee shop $id: $e');
    }
  }
}
