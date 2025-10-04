import '../../core/utils/enums.dart';


class Profile {
  final String id;                 // auth.users.id (uuid)
  final UserRole role;             // 'user' | 'owner' | 'admin'
  final String? displayName;
  final String? photoUrl;
  final DateTime? createdAt;

  const Profile({
    required this.id,
    required this.role,
    this.displayName,
    this.photoUrl,
    this.createdAt,
  });

  factory Profile.fromMap(Map<String, dynamic> m) {
    return Profile(
      id: m['id'],
      role: roleFromText(m['role']?.toString()),
      displayName: m['display_name'],
      photoUrl: m['photo_url'],
      createdAt: m['created_at'] != null ? DateTime.tryParse(m['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'role': roleToText(role),
        'display_name': displayName,
        'photo_url': photoUrl,
      };

  Profile copyWith({
    UserRole? role,
    String? displayName,
    String? photoUrl,
  }) =>
      Profile(
        id: id,
        role: role ?? this.role,
        displayName: displayName ?? this.displayName,
        photoUrl: photoUrl ?? this.photoUrl,
        createdAt: createdAt,
      );
}
