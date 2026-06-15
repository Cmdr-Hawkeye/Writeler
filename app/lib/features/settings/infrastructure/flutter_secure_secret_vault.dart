import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/secret_vault.dart';

final class FlutterSecureSecretVault implements SecretVault {
  const FlutterSecureSecretVault({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  }) : _storage = storage;

  final FlutterSecureStorage _storage;

  @override
  Future<void> write({
    required String ref,
    required String secret,
  }) {
    return _storage.write(key: ref, value: secret);
  }

  @override
  Future<String?> read(String ref) {
    return _storage.read(key: ref);
  }

  @override
  Future<void> delete(String ref) {
    return _storage.delete(key: ref);
  }
}
