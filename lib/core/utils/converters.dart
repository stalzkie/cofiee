double toDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0.0;
}

int toInt(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}

bool toBool(dynamic v) {
  if (v is bool) return v;
  if (v == null) return false;
  final s = v.toString().toLowerCase();
  return s == 'true' || s == '1';
}
