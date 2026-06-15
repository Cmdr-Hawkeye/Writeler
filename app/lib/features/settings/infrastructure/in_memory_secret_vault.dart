import '../domain/secret_vault.dart';

final class InMemorySecretVault implements SecretVault {
  final Map<String, String> _secrets = {};

  @override
  Future<void> write({
    required String ref,
    required String secret,
  }) async {
    _secrets[ref] = secret;
  }

  @override
  Future<String?> read(String ref) async => _secrets[ref];

  @override
  Future<void> delete(String ref) async {
    _secrets.remove(ref);
  }
}
