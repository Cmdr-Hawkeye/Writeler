String newLocalId(String prefix) {
  final now = DateTime.now().toUtc().microsecondsSinceEpoch;
  return '$prefix-$now';
}
