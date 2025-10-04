import '../../core/utils/enums.dart';
import '../../core/utils/converters.dart';

class MenuItem {
  final String id;
  final String shopId;
  final MenuCategory category;
  final String name;
  final String? description;
  final double price;
  final bool isAvailable;
  final DateTime? createdAt;

  const MenuItem({
    required this.id,
    required this.shopId,
    required this.category,
    required this.name,
    this.description,
    required this.price,
    required this.isAvailable,
    this.createdAt,
  });

  factory MenuItem.fromMap(Map<String, dynamic> m) => MenuItem(
        id: m['id'],
        shopId: m['shop_id'],
        category: categoryFromText(m['category']?.toString()),
        name: m['name'] ?? '',
        description: m['description'],
        price: toDouble(m['price']),
        isAvailable: toBool(m['is_available']),
        createdAt: m['created_at'] != null ? DateTime.tryParse(m['created_at'].toString()) : null,
      );

  Map<String, dynamic> toMapForInsert() => {
        'shop_id': shopId,
        'category': categoryToText(category),
        'name': name,
        if (description != null) 'description': description,
        'price': price,
        'is_available': isAvailable,
      };

  Map<String, dynamic> toMapForUpdate() => {
        'category': categoryToText(category),
        if (name.isNotEmpty) 'name': name,
        'description': description,
        'price': price,
        'is_available': isAvailable,
      };
}
