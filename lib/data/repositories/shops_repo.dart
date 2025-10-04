import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/error/failure.dart';
import '../models/coffee_shop.dart';

class ShopsRepository {
  final SupabaseClient _client;

  ShopsRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  static const _baseSelect = '''
    id, owner_id, name, description, address,
    wifi_available, opening_time, seat_capacity, seats_available,
    is_verified, average_rating, ratings_count, created_at,
    location
  ''';

  /// Fetch all coffee shops
  Future<List<CoffeeShop>> getAll() async {
    try {
      final response = await _client
          .from('coffee_shops')
          .select(_baseSelect)
          .order('created_at', ascending: false);

      final rows = response as List<dynamic>;
      return rows
          .map((e) => CoffeeShop.fromMap(e as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw Failure('Failed to load coffee shops: ${e.message}');
    } catch (e) {
      throw Failure('Failed to load coffee shops: $e');
    }
  }

  /// Fetch by ID
  Future<CoffeeShop?> getById(String id) async {
    try {
      final response = await _client
          .from('coffee_shops')
          .select(_baseSelect)
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return CoffeeShop.fromMap(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      throw Failure('Failed to load coffee shop $id: ${e.message}');
    } catch (e) {
      throw Failure('Failed to load coffee shop $id: $e');
    }
  }

  /// Save a coffee shop:
  /// - UPDATE first (RLS should enforce owner-only updates).
  /// - If nothing updated, INSERT a new row with owner_id.
  /// NOTE: This only updates scalar fields. Use [setLocation] to change geometry.
  Future<CoffeeShop> upsert(CoffeeShop shop) async {
    try {
      final uid = _client.auth.currentUser?.id;
      if (uid == null) throw Failure('Not authenticated');

      // Scalar-only payload (no lat/lng here; geometry is separate)
      final data = shop.toMapForUpsert(
        includeIsVerified: false, // change to true only if RLS allows it
      );

      // --- UPDATE (filter by id; RLS will further restrict by owner_id) ---
      final updated = await _client
          .from('coffee_shops')
          .update(data)
          .eq('id', shop.id)
          .select(_baseSelect)
          .maybeSingle();

      if (updated != null) {
        return CoffeeShop.fromMap(updated as Map<String, dynamic>);
      }

      // --- INSERT (new shop) ---
      final inserted = await _client
          .from('coffee_shops')
          .insert({
            'id': shop.id,
            'owner_id': uid,
            ...data,
          })
          .select(_baseSelect)
          .single();

      return CoffeeShop.fromMap(inserted as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      throw Failure('Failed to save coffee shop: ${e.message}');
    } catch (e) {
      throw Failure('Failed to save coffee shop: $e');
    }
  }

  /// Update geometry (Point, 4326) via RPC.
  /// Create this SQL in Supabase first:
  /// ```
  /// create or replace function public.set_shop_location(
  ///   p_shop_id uuid, p_lat double precision, p_lng double precision
  /// ) returns void language sql security definer as $$
  ///   update public.coffee_shops
  ///   set location = ST_SetSRID(ST_MakePoint(p_lng, p_lat), 4326)
  ///   where id = p_shop_id;
  /// $$;
  /// ```
  Future<void> setLocation({
    required String shopId,
    required double lat,
    required double lng,
  }) async {
    try {
      await _client.rpc('set_shop_location', params: {
        'p_shop_id': shopId,
        'p_lat': lat,
        'p_lng': lng,
      });
    } on PostgrestException catch (e) {
      throw Failure('Failed to set location: ${e.message}');
    } catch (e) {
      throw Failure('Failed to set location: $e');
    }
  }

  /// Delete by ID (owner-only via RLS)
  Future<void> delete(String id) async {
    try {
      final uid = _client.auth.currentUser?.id;
      if (uid == null) throw Failure('Not authenticated');

      await _client.from('coffee_shops').delete().eq('id', id);
      // RLS should prevent deleting others' rows.
    } on PostgrestException catch (e) {
      throw Failure('Failed to delete coffee shop $id: ${e.message}');
    } catch (e) {
      throw Failure('Failed to delete coffee shop $id: $e');
    }
  }
}
