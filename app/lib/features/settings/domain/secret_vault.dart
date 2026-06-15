abstract interface class SecretVault {
  Future<void> write({
    required String ref,
    required String secret,
  });

  Future<String?> read(String ref);

  Future<void> delete(String ref);
}
