import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../../models/interaction.dart';
import 'database_helper.dart';

/// 交互记录本地数据源接口
/// 定义交互记录数据的本地存储操作
abstract class InteractionLocalDatasource {
  /// 获取指定用户的交互记录列表
  Future<List<Interaction>> getInteractions(String userId);
  
  /// 保存交互记录
  Future<void> saveInteraction(Interaction interaction);
  
  /// 删除交互记录
  Future<void> deleteInteraction(String id, String userId);
  
  /// 根据ID删除交互记录（无需userId）
  Future<void> deleteInteractionById(String id);
  
  /// 获取最近交互记录
  Future<List<Interaction>> getRecentInteractions(String userId, int limit);
  
  /// 获取交互记录数量
  Future<int> getInteractionCount(String userId);
  
  /// 根据ID获取单条交互记录
  Future<Interaction?> getInteractionById(String id);
}

/// Mock数据源实现（使用SharedPreferences）
/// 用于测试或作为备用数据源
class MockInteractionLocalDatasource implements InteractionLocalDatasource {
  static const String _keyInteractions = 'interactions';

  @override
  Future<List<Interaction>> getInteractions(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('${_keyInteractions}_$userId');
    if (jsonStr == null) return [];
    final List<dynamic> jsonList = jsonDecode(jsonStr) as List<dynamic>;
    return jsonList
        .map((json) => Interaction.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveInteraction(Interaction interaction) async {
    final interactions = await getInteractions(interaction.userId);
    final existingIndex = interactions.indexWhere((i) => i.id == interaction.id);
    if (existingIndex >= 0) {
      interactions[existingIndex] = interaction;
    } else {
      interactions.add(interaction);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '${_keyInteractions}_${interaction.userId}',
      jsonEncode(interactions.map((i) => i.toJson()).toList()),
    );
  }

  @override
  Future<void> deleteInteraction(String id, String userId) async {
    final interactions = await getInteractions(userId);
    interactions.removeWhere((i) => i.id == id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '${_keyInteractions}_$userId',
      jsonEncode(interactions.map((i) => i.toJson()).toList()),
    );
  }

  @override
  Future<void> deleteInteractionById(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_keyInteractions));
    
    for (final key in keys) {
      final jsonStr = prefs.getString(key);
      if (jsonStr != null) {
        final List<dynamic> jsonList = jsonDecode(jsonStr) as List<dynamic>;
        final originalLength = jsonList.length;
        jsonList.removeWhere((json) {
          final interaction = Interaction.fromJson(json as Map<String, dynamic>);
          return interaction.id == id;
        });
        
        // 如果找到了并删除了记录，更新存储
        if (jsonList.length < originalLength) {
          await prefs.setString(
            key,
            jsonEncode(jsonList),
          );
          return; // 找到并删除后直接返回
        }
      }
    }
  }

  @override
  Future<List<Interaction>> getRecentInteractions(String userId, int limit) async {
    final interactions = await getInteractions(userId);
    interactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return interactions.take(limit).toList();
  }

  @override
  Future<int> getInteractionCount(String userId) async {
    final interactions = await getInteractions(userId);
    return interactions.length;
  }

  @override
  Future<Interaction?> getInteractionById(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_keyInteractions));
    
    for (final key in keys) {
      final jsonStr = prefs.getString(key);
      if (jsonStr != null) {
        final List<dynamic> jsonList = jsonDecode(jsonStr) as List<dynamic>;
        for (final json in jsonList) {
          final interaction = Interaction.fromJson(json as Map<String, dynamic>);
          if (interaction.id == id) {
            return interaction;
          }
        }
      }
    }
    return null;
  }
}

/// SQLite数据源实现
/// 使用SQLite数据库存储交互记录数据
/// 包含从SharedPreferences到SQLite的数据迁移功能
class SqliteInteractionLocalDatasource implements InteractionLocalDatasource {
  final DatabaseHelper _databaseHelper;
  
  /// 迁移标记键名
  static const String _keyMigrationCompleted = 'interaction_data_migration_completed';
  
  /// SharedPreferences中交互记录数据的键前缀
  static const String _keyInteractionsPrefix = 'interactions';

  SqliteInteractionLocalDatasource({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper();

  /// 获取数据库实例
  Future<Database> get _database async => _databaseHelper.database;

  /// 初始化数据源
  /// 检查并执行数据迁移
  Future<void> initialize() async {
    await _migrateFromSharedPreferences();
  }

  /// 从SharedPreferences迁移数据到SQLite
  /// 迁移完成后会清理SharedPreferences中的旧数据
  /// 注意：只有全部迁移成功才会清理旧数据，确保数据安全
  Future<void> _migrateFromSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 检查是否已完成迁移
      final migrationCompleted = prefs.getBool(_keyMigrationCompleted) ?? false;
      if (migrationCompleted) {
        print('[SqliteInteractionLocalDatasource] 数据迁移已完成，跳过');
        return;
      }

      print('[SqliteInteractionLocalDatasource] 开始数据迁移...');

      // 获取所有交互记录数据的键
      final keys = prefs
          .getKeys()
          .where((k) => k.startsWith(_keyInteractionsPrefix))
          .toList();

      if (keys.isEmpty) {
        print('[SqliteInteractionLocalDatasource] 没有需要迁移的数据');
        await prefs.setBool(_keyMigrationCompleted, true);
        return;
      }

      // 迁移每条交互记录数据
      int migratedCount = 0;
      int failedCount = 0;
      final List<String> failedKeys = [];
      
      for (final key in keys) {
        final jsonStr = prefs.getString(key);
        if (jsonStr != null) {
          try {
            final List<dynamic> jsonList = jsonDecode(jsonStr) as List<dynamic>;
            for (final json in jsonList) {
              final interaction = Interaction.fromJson(json as Map<String, dynamic>);
              await _insertInteractionToDatabase(interaction);
              migratedCount++;
            }
          } catch (e) {
            print('[SqliteInteractionLocalDatasource] 迁移交互记录失败: $key, 错误: $e');
            failedCount++;
            failedKeys.add(key);
          }
        }
      }

      // 只有全部迁移成功才清理SharedPreferences中的旧数据
      if (failedCount == 0) {
        for (final key in keys) {
          await prefs.remove(key);
        }
        // 标记迁移完成
        await prefs.setBool(_keyMigrationCompleted, true);
        print('[SqliteInteractionLocalDatasource] 数据迁移成功完成，共迁移 $migratedCount 条记录');
      } else {
        // 迁移失败，保留旧数据以便后续重试
        print('[SqliteInteractionLocalDatasource] 数据迁移部分失败，成功 $migratedCount 条，失败 $failedCount 条');
        print('[SqliteInteractionLocalDatasource] 失败的键: $failedKeys');
        print('[SqliteInteractionLocalDatasource] 旧数据已保留，将在下次启动时重试');
      }
    } catch (e, stackTrace) {
      print('[SqliteInteractionLocalDatasource] 数据迁移失败: $e');
      print('[SqliteInteractionLocalDatasource] 堆栈跟踪: $stackTrace');
      // 迁移失败不影响后续操作，旧数据保留
    }
  }

  /// 将交互记录插入数据库
  /// 使用INSERT OR REPLACE确保数据唯一性
  Future<void> _insertInteractionToDatabase(Interaction interaction) async {
    final db = await _database;
    
    await db.insert(
      DatabaseHelper.tableInteractions,
      interaction.toDatabaseMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<Interaction>> getInteractions(String userId) async {
    try {
      final db = await _database;
      final results = await db.query(
        DatabaseHelper.tableInteractions,
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
      );
      return results.map((map) => Interaction.fromDatabase(map)).toList();
    } catch (e, stackTrace) {
      print('[SqliteInteractionLocalDatasource] 获取交互记录失败: $e');
      print('[SqliteInteractionLocalDatasource] 堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> saveInteraction(Interaction interaction) async {
    try {
      await _insertInteractionToDatabase(interaction);
    } catch (e, stackTrace) {
      print('[SqliteInteractionLocalDatasource] 保存交互记录失败: $e');
      print('[SqliteInteractionLocalDatasource] 堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> deleteInteraction(String id, String userId) async {
    try {
      final db = await _database;
      await db.delete(
        DatabaseHelper.tableInteractions,
        where: 'id = ? AND user_id = ?',
        whereArgs: [id, userId],
      );
    } catch (e, stackTrace) {
      print('[SqliteInteractionLocalDatasource] 删除交互记录失败: $e');
      print('[SqliteInteractionLocalDatasource] 堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> deleteInteractionById(String id) async {
    try {
      final db = await _database;
      await db.delete(
        DatabaseHelper.tableInteractions,
        where: '${DatabaseHelper.columnId} = ?',
        whereArgs: [id],
      );
    } catch (e, stackTrace) {
      print('[SqliteInteractionLocalDatasource] 根据ID删除交互记录失败: $e');
      print('[SqliteInteractionLocalDatasource] 堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<List<Interaction>> getRecentInteractions(String userId, int limit) async {
    try {
      final db = await _database;
      final results = await db.query(
        DatabaseHelper.tableInteractions,
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
        limit: limit,
      );
      return results.map((map) => Interaction.fromDatabase(map)).toList();
    } catch (e, stackTrace) {
      print('[SqliteInteractionLocalDatasource] 获取最近交互记录失败: $e');
      print('[SqliteInteractionLocalDatasource] 堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<int> getInteractionCount(String userId) async {
    try {
      final db = await _database;
      final results = await db.rawQuery(
        'SELECT COUNT(*) as count FROM ${DatabaseHelper.tableInteractions} WHERE user_id = ?',
        [userId],
      );
      return Sqflite.firstIntValue(results) ?? 0;
    } catch (e, stackTrace) {
      print('[SqliteInteractionLocalDatasource] 获取交互记录数量失败: $e');
      print('[SqliteInteractionLocalDatasource] 堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<Interaction?> getInteractionById(String id) async {
    try {
      final db = await _database;
      final results = await db.query(
        DatabaseHelper.tableInteractions,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (results.isEmpty) return null;
      return Interaction.fromDatabase(results.first);
    } catch (e, stackTrace) {
      print('[SqliteInteractionLocalDatasource] 根据ID获取交互记录失败: $e');
      print('[SqliteInteractionLocalDatasource] 堆栈跟踪: $stackTrace');
      rethrow;
    }
  }
}
