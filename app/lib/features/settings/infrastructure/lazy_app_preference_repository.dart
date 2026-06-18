import '../domain/app_preference_repository.dart';

final class LazyAppPreferenceRepository implements AppPreferenceRepository {
  LazyAppPreferenceRepository(this._create);

  final AppPreferenceRepository Function() _create;
  AppPreferenceRepository? _inner;

  AppPreferenceRepository get _repository => _inner ??= _create();

  @override
  Future<String?> read(String key) => _repository.read(key);

  @override
  Future<void> write(String key, String value) => _repository.write(key, value);
}
