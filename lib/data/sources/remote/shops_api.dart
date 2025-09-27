import '../../models/coffee_shop.dart';
import '../../repositories/shops_repo.dart';

/// ShopsAPI is a higher-level wrapper around [ShopsRepository].
/// It provides methods for your app logic to call, returning [CoffeeShop] objects.
class ShopsAPI {
  final ShopsRepository _repo;

  ShopsAPI({ShopsRepository? repo}) : _repo = repo ?? ShopsRepository();

  /// Get all coffee shops
  Future<List<CoffeeShop>> fetchAllShops() async {
    return await _repo.getAll();
  }

  /// Get single coffee shop by ID
  Future<CoffeeShop?> fetchShopById(String id) async {
    return await _repo.getById(id);
  }

  /// Add or update a coffee shop
  Future<CoffeeShop> saveShop(CoffeeShop shop) async {
    return await _repo.upsert(shop);
  }

  /// Delete a coffee shop by ID
  Future<void> deleteShop(String id) async {
    return await _repo.delete(id);
  }
}
