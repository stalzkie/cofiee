import '../../core/utils/converters.dart';

class Rating {
  final String id;
  final String shopId;
  final String userId;
  final int rating;       // 1..5
  final String? review;
  final DateTime? createdAt;

  const Rating({
    required this.id,
    required this.shopId,
    required this.userId,
    required this.rating,
    this.review,
    this.createdAt,
  });

  factory Rating.fromMap(Map<String, dynamic> m) => Rating(
        id: m['id'],
        shopId: m['shop_id'],
        userId: m['user_id'],
        rating: toInt(m['rating']),
        review: m['review'],
        createdAt: m['created_at'] != null ? DateTime.tryParse(m['created_at'].toString()) : null,
      );

  /// Insert (unique per (shop_id, user_id))
  Map<String, dynamic> toMapForInsert() => {
        'shop_id': shopId,
        'user_id': userId,
        'rating': rating,
        if (review != null) 'review': review,
      };

  /// Update your own rating
  Map<String, dynamic> toMapForUpdate() => {
        'rating': rating,
        'review': review,
      };
}
