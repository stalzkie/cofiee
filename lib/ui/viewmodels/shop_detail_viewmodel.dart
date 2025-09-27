import 'package:flutter/foundation.dart';

import '../../data/sources/remote/shops_api.dart';
import '../../data/models/coffee_shop.dart';
import '../../core/error/failure.dart';

class ShopDetailViewModel extends ChangeNotifier {
  final ShopsAPI _api;

  ShopDetailViewModel({ShopsAPI? api}) : _api = api ?? ShopsAPI();

  CoffeeShop? shop;
  bool isLoading = false;
  String? error;

  /// Fetch a shop by ID
  Future<void> loadShop(String id) async {
    _setLoading(true);
    try {
      final result = await _api.fetchShopById(id);
      shop = result;
      error = null;
    } on Failure catch (f) {
      error = f.message;
    } catch (e) {
      error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Save (insert/update) shop
  Future<void> saveShop(CoffeeShop updated) async {
    _setLoading(true);
    try {
      final saved = await _api.saveShop(updated);
      shop = saved;
      error = null;
    } on Failure catch (f) {
      error = f.message;
    } catch (e) {
      error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Delete shop
  Future<void> deleteShop() async {
    if (shop == null) return;
    _setLoading(true);
    try {
      await _api.deleteShop(shop!.id);
      shop = null;
      error = null;
    } on Failure catch (f) {
      error = f.message;
    } catch (e) {
      error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}
