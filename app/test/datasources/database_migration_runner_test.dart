import 'package:flutter_test/flutter_test.dart';
import 'package:jobpet/data/datasources/local/database_migration.dart';
import 'package:jobpet/data/datasources/local/database_migration_runner.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Database database;
  const runner = DatabaseMigrationRunner();

  setUpAll(() {
    // Tests use the FFI database factory so no device or emulator is required.
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    database = await openDatabase(inMemoryDatabasePath);
  });

  tearDown(() async {
    await database.close();
  });

  group('DatabaseMigrationRunner', () {
    test('skips existing tables and indexes when migration reruns', () async {
      final statements = DatabaseMigration.getMigration(1)!;

      await runner.runMigrationBatch(
        database,
        version: 1,
        statements: statements,
      );
      await runner.runMigrationBatch(
        database,
        version: 1,
        statements: statements,
      );

      final userTables = await database.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'users'",
      );
      final userIndex = await database.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'index' "
        "AND name = 'idx_interactions_user_id'",
      );

      expect(userTables, hasLength(1));
      expect(userIndex, hasLength(1));
    });

    test('skips existing columns when alter-table migration reruns', () async {
      final v1Statements = DatabaseMigration.getMigration(1)!;
      final v5Statements = DatabaseMigration.getMigration(5)!;

      await runner.runMigrationBatch(
        database,
        version: 1,
        statements: v1Statements,
      );
      await runner.runMigrationBatch(
        database,
        version: 5,
        statements: v5Statements,
      );
      await runner.runMigrationBatch(
        database,
        version: 5,
        statements: v5Statements,
      );

      final columns = await database.rawQuery('PRAGMA table_info(users)');
      final columnNames = columns.map((row) => row['name']).toList();

      expect(columnNames, containsAll(['account', 'password', 'is_logged_in']));
    });

    test('adds missing columns to partially migrated tables', () async {
      await database.execute('''
        CREATE TABLE users (
          user_id TEXT PRIMARY KEY,
          user_name TEXT NOT NULL
        )
      ''');
      await database.execute('ALTER TABLE users ADD COLUMN account TEXT');

      final statements = DatabaseMigration.getMigration(5)!;

      await runner.runMigrationBatch(
        database,
        version: 5,
        statements: statements,
      );

      final columns = await database.rawQuery('PRAGMA table_info(users)');
      final columnNames = columns.map((row) => row['name']).toList();

      expect(columnNames, containsAll(['account', 'password', 'is_logged_in']));
    });
  });
}
