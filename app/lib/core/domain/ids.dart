int _localIdCounter = 0;

String newLocalId(String prefix) {
  final now = DateTime.now().toUtc().microsecondsSinceEpoch;
  _localIdCounter = (_localIdCounter + 1) & 0x3fffffff;
  return '$prefix-$now-$_localIdCounter';
}
