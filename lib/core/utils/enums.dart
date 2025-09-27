enum UserRole { user, owner, admin }
UserRole roleFromText(String? v) =>
  switch (v) { 'owner' => UserRole.owner, 'admin' => UserRole.admin, _ => UserRole.user };
String roleToText(UserRole r) => switch (r) { UserRole.owner => 'owner', UserRole.admin => 'admin', _ => 'user' };

enum MenuCategory { food, beverage, pastry, other }
MenuCategory categoryFromText(String? v) => switch (v) {
  'food' => MenuCategory.food,
  'beverage' => MenuCategory.beverage,
  'pastry' => MenuCategory.pastry,
  _ => MenuCategory.other
};
String categoryToText(MenuCategory c) => switch (c) {
  MenuCategory.food => 'food',
  MenuCategory.beverage => 'beverage',
  MenuCategory.pastry => 'pastry',
  MenuCategory.other => 'other',
};
