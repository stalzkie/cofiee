import 'package:flutter/foundation.dart';

import '../../data/sources/remote/shops_api.dart';
import '../../data/models/coffee_shop.dart';
import '../../core/error/failure.dart';

/// ViewModel for handling single shop details, updates, and deletion.
class ShopDetailViewModel extends ChangeNotifier {
  final ShopsAPI _api;

  ShopDetailViewModel({ShopsAPI? api}) : _api = api ?? ShopsAPI();

  CoffeeShop? shop;
  bool isLoading = false;
  String? error;

  /// Fetch a shop by its ID from Supabase
  Future<void> loadShop(String id) async {
    _setLoading(true);
    error = null;
    try {
      final result = await _api.fetchShopById(id);
      shop = result;
      if (kDebugMode) {
        print('[ShopDetailViewModel] Loaded shop: ${shop?.name}');
      }
    } on Failure catch (f) {
      error = f.message;
      if (kDebugMode) print('[ShopDetailViewModel] Failure: ${f.message}');
    } catch (e, st) {
      error = e.toString();
      if (kDebugMode) {
        print('[ShopDetailViewModel] Unexpected error: $e');
        print(st);
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Save (update) a shop in Supabase.
  /// Returns the updated [CoffeeShop] on success.
  Future<CoffeeShop?> saveShop(CoffeeShop updated) async {
    _setLoading(true);
    error = null;

    try {
      // Attempt save through API
      final saved = await _api.saveShop(updated);

      // Re-fetch the full row from DB for consistency
      if (saved.id.isNotEmpty) {
        final refreshed = await _api.fetchShopById(saved.id);
        shop = refreshed;
        if (kDebugMode) {
          print('[ShopDetailViewModel] Shop successfully updated: ${refreshed?.name}');
        }
        return refreshed;
      } else {
        shop = saved;
        if (kDebugMode) {
          print('[ShopDetailViewModel] Shop saved (no ID refresh).');
        }
        return saved;
      }
    } on Failure catch (f) {
      error = f.message;
      if (kDebugMode) print('[ShopDetailViewModel] Failure on save: ${f.message}');
      rethrow;
    } catch (e, st) {
      error = e.toString();
      if (kDebugMode) {
        print('[ShopDetailViewModel] Unexpected error on save: $e');
        print(st);
      }
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete the current shop from Supabase
  Future<void> deleteShop() async {
    if (shop == null) return;
    _setLoading(true);
    error = null;

    try {
      await _api.deleteShop(shop!.id);
      if (kDebugMode) print('[ShopDetailViewModel] Deleted shop ${shop!.id}');
      shop = null;
    } on Failure catch (f) {
      error = f.message;
      if (kDebugMode) print('[ShopDetailViewModel] Failure on delete: ${f.message}');
    } catch (e, st) {
      error = e.toString();
      if (kDebugMode) {
        print('[ShopDetailViewModel] Unexpected error on delete: $e');
        print(st);
      }
    } finally {
      _setLoading(false);
    }
  }

  // ---- Private Helper ----
  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}
