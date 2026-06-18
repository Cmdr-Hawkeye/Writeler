import '../../../core/infrastructure/database/app_database.dart';
import '../domain/app_preference_repository.dart';

final class DriftAppPreferenceRepository implements AppPreferenceRepository {
  const DriftAppPreferenceRepository(this.database);

  final AppDatabase database;

  @override
  Future<String?> read(String key) async {
    final row = await (database.select(database.appPreferences)
          ..where((table) => table.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  @override
  Future<void> write(String key, String value) async {
    await database.into(database.appPreferences).insertOnConflictUpdate(
          AppPreferencesCompanion.insert(
            key: key,
            value: value,
            updatedAt: DateTime.now().toUtc(),
          ),
        );
  }
}
