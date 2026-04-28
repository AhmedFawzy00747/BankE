T? safeFirst<T>(List<T>? list) {
  if (list == null || list.isEmpty) return null;
  return list.first;
}

T? safeSingle<T>(List<T>? list) {
  if (list == null || list.length != 1) return null;
  return list.single;
}
