import 'package:sqflite/sqflite.dart';

import '../../../core/utils/logger_service.dart';

/// Executes schema migrations with existence checks for repeatable startup.
class DatabaseMigrationRunner {
  const DatabaseMigrationRunner();

  /// Runs one migration version and skips schema statements already applied.
  Future<void> runMigrationBatch(
    DatabaseExecutor executor, {
    required int version,
    required List<String> statements,
  }) async {
    for (final statement in statements) {
      await runStatement(executor, version: version, statement: statement);
    }
  }

  /// Runs one SQL statement after checking whether it is already reflected.
  Future<void> runStatement(
    DatabaseExecutor executor, {
    required int version,
    required String statement,
  }) async {
    final normalized = _normalizeSql(statement);

    // Tables and indexes can be safely skipped when sqlite_master has them.
    final createTable = _parseCreateObject(normalized, type: 'TABLE');
    if (createTable != null &&
        await _schemaObjectExists(executor, 'table', createTable)) {
      _logSkip(version, 'table', createTable);
      return;
    }

    final createIndex = _parseCreateObject(normalized, type: 'INDEX');
    if (createIndex != null &&
        await _schemaObjectExists(executor, 'index', createIndex)) {
      _logSkip(version, 'index', createIndex);
      return;
    }

    // SQLite cannot add an existing column, so check PRAGMA table_info first.
    final addedColumn = _parseAddColumn(normalized);
    if (addedColumn != null &&
        await _columnExists(
          executor,
          tableName: addedColumn.tableName,
          columnName: addedColumn.columnName,
        )) {
      _logSkip(
        version,
        'column',
        '${addedColumn.tableName}.${addedColumn.columnName}',
      );
      return;
    }

    await executor.execute(statement);
  }

  String _normalizeSql(String statement) {
    return statement.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String? _parseCreateObject(String sql, {required String type}) {
    final pattern = RegExp(
      '^CREATE\\s+(?:UNIQUE\\s+)?$type\\s+(?:IF\\s+NOT\\s+EXISTS\\s+)?'
      r'["`\[]?([A-Za-z_][A-Za-z0-9_]*)["`\]]?',
      caseSensitive: false,
    );
    return pattern.firstMatch(sql)?.group(1);
  }

  _AddedColumn? _parseAddColumn(String sql) {
    final pattern = RegExp(
      r'^ALTER\s+TABLE\s+["`\[]?([A-Za-z_][A-Za-z0-9_]*)["`\]]?'
      r'\s+ADD\s+COLUMN\s+["`\[]?([A-Za-z_][A-Za-z0-9_]*)["`\]]?',
      caseSensitive: false,
    );
    final match = pattern.firstMatch(sql);
    if (match == null) return null;
    return _AddedColumn(match.group(1)!, match.group(2)!);
  }

  Future<bool> _schemaObjectExists(
    DatabaseExecutor executor,
    String type,
    String name,
  ) async {
    final rows = await executor.rawQuery(
      'SELECT 1 FROM sqlite_master WHERE type = ? AND name = ? LIMIT 1',
      [type, name],
    );
    return rows.isNotEmpty;
  }

  Future<bool> _columnExists(
    DatabaseExecutor executor, {
    required String tableName,
    required String columnName,
  }) async {
    final rows = await executor.rawQuery('PRAGMA table_info($tableName)');
    return rows.any((row) => row['name'] == columnName);
  }

  void _logSkip(int version, String objectType, String objectName) {
    AppLogger.debug(
      '[DatabaseMigrationRunner] Skip existing v$version $objectType: '
      '$objectName',
    );
  }
}

/// Parsed ALTER TABLE ADD COLUMN target.
class _AddedColumn {
  const _AddedColumn(this.tableName, this.columnName);

  final String tableName;
  final String columnName;
}
