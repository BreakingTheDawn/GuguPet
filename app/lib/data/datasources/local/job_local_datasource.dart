import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../../models/job_event.dart';
import 'database_helper.dart';

/// 求职事件本地数据源接口
/// 定义求职事件数据的本地存储操作
abstract class JobLocalDatasource {
  /// 获取指定用户的求职事件列表
  Future<List<JobEvent>> getJobEvents(String userId);
  
  /// 保存求职事件
  Future<void> saveJobEvent(JobEvent event);
  
  /// 删除求职事件
  Future<void> deleteJobEvent(String id, String userId);
  
  /// 根据ID删除求职事件（无需userId）
  Future<void> deleteJobEventById(String id);
  
  /// 获取周统计数据
  Future<Map<String, int>> getWeeklyStats(String userId);
  
  /// 获取总投递数
  Future<int> getTotalSubmissions(String userId);
  
  /// 根据ID获取单条求职事件
  Future<JobEvent?> getJobEventById(String id);
}

/// Mock数据源实现（使用SharedPreferences）
/// 用于测试或作为备用数据源
class MockJobLocalDatasource implements JobLocalDatasource {
  static const String _keyJobEvents = 'job_events';

  @override
  Future<List<JobEvent>> getJobEvents(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('${_keyJobEvents}_$userId');
    if (jsonStr == null) return [];
    final List<dynamic> jsonList = jsonDecode(jsonStr) as List<dynamic>;
    return jsonList
        .map((json) => JobEvent.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveJobEvent(JobEvent event) async {
    final events = await getJobEvents(event.userId);
    final existingIndex = events.indexWhere((e) => e.id == event.id);
    if (existingIndex >= 0) {
      events[existingIndex] = event;
    } else {
      events.add(event);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '${_keyJobEvents}_${event.userId}',
      jsonEncode(events.map((e) => e.toJson()).toList()),
    );
  }

  @override
  Future<void> deleteJobEvent(String id, String userId) async {
    final events = await getJobEvents(userId);
    events.removeWhere((e) => e.id == id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '${_keyJobEvents}_$userId',
      jsonEncode(events.map((e) => e.toJson()).toList()),
    );
  }

  @override
  Future<void> deleteJobEventById(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_keyJobEvents));
    
    for (final key in keys) {
      final jsonStr = prefs.getString(key);
      if (jsonStr != null) {
        final List<dynamic> jsonList = jsonDecode(jsonStr) as List<dynamic>;
        final originalLength = jsonList.length;
        jsonList.removeWhere((json) {
          final event = JobEvent.fromJson(json as Map<String, dynamic>);
          return event.id == id;
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
  Future<Map<String, int>> getWeeklyStats(String userId) async {
    final events = await getJobEvents(userId);
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final weekEvents = events.where((e) => e.eventTime.isAfter(weekAgo));
    return {
      'submissions': weekEvents.where((e) => e.eventType == '投递').length,
      'interviews': weekEvents.where((e) => e.eventType == '面试').length,
      'rejections': weekEvents.where((e) => e.eventType == '拒信').length,
      'offers': weekEvents.where((e) => e.eventType == 'Offer').length,
    };
  }

  @override
  Future<int> getTotalSubmissions(String userId) async {
    final events = await getJobEvents(userId);
    return events.where((e) => e.eventType == '投递').length;
  }

  @override
  Future<JobEvent?> getJobEventById(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_keyJobEvents));
    
    for (final key in keys) {
      final jsonStr = prefs.getString(key);
      if (jsonStr != null) {
        final List<dynamic> jsonList = jsonDecode(jsonStr) as List<dynamic>;
        for (final json in jsonList) {
          final event = JobEvent.fromJson(json as Map<String, dynamic>);
          if (event.id == id) {
            return event;
          }
        }
      }
    }
    return null;
  }
}

/// SQLite数据源实现
/// 使用SQLite数据库存储求职事件数据
/// 包含从SharedPreferences到SQLite的数据迁移功能
class SqliteJobEventLocalDatasource implements JobLocalDatasource {
  final DatabaseHelper _databaseHelper;
  
  /// 迁移标记键名
  static const String _keyMigrationCompleted = 'job_event_data_migration_completed';
  
  /// SharedPreferences中求职事件数据的键前缀
  static const String _keyJobEventsPrefix = 'job_events';

  SqliteJobEventLocalDatasource({DatabaseHelper? databaseHelper})
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
        print('[SqliteJobEventLocalDatasource] 数据迁移已完成，跳过');
        return;
      }

      print('[SqliteJobEventLocalDatasource] 开始数据迁移...');

      // 获取所有求职事件数据的键
      final keys = prefs
          .getKeys()
          .where((k) => k.startsWith(_keyJobEventsPrefix))
          .toList();

      if (keys.isEmpty) {
        print('[SqliteJobEventLocalDatasource] 没有需要迁移的数据');
        await prefs.setBool(_keyMigrationCompleted, true);
        return;
      }

      // 迁移每条求职事件数据
      int migratedCount = 0;
      int failedCount = 0;
      final List<String> failedKeys = [];
      
      for (final key in keys) {
        final jsonStr = prefs.getString(key);
        if (jsonStr != null) {
          try {
            final List<dynamic> jsonList = jsonDecode(jsonStr) as List<dynamic>;
            for (final json in jsonList) {
              final event = JobEvent.fromJson(json as Map<String, dynamic>);
              await _insertJobEventToDatabase(event);
              migratedCount++;
            }
          } catch (e) {
            print('[SqliteJobEventLocalDatasource] 迁移求职事件失败: $key, 错误: $e');
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
        print('[SqliteJobEventLocalDatasource] 数据迁移成功完成，共迁移 $migratedCount 条记录');
      } else {
        // 迁移失败，保留旧数据以便后续重试
        print('[SqliteJobEventLocalDatasource] 数据迁移部分失败，成功 $migratedCount 条，失败 $failedCount 条');
        print('[SqliteJobEventLocalDatasource] 失败的键: $failedKeys');
        print('[SqliteJobEventLocalDatasource] 旧数据已保留，将在下次启动时重试');
      }
    } catch (e, stackTrace) {
      print('[SqliteJobEventLocalDatasource] 数据迁移失败: $e');
      print('[SqliteJobEventLocalDatasource] 堆栈跟踪: $stackTrace');
      // 迁移失败不影响后续操作，旧数据保留
    }
  }

  /// 将求职事件插入数据库
  /// 使用INSERT OR REPLACE确保数据唯一性
  Future<void> _insertJobEventToDatabase(JobEvent event) async {
    final db = await _database;
    
    await db.insert(
      DatabaseHelper.tableJobEvents,
      event.toDatabaseMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<JobEvent>> getJobEvents(String userId) async {
    try {
      final db = await _database;
      final results = await db.query(
        DatabaseHelper.tableJobEvents,
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'event_time DESC',
      );
      return results.map((map) => JobEvent.fromDatabase(map)).toList();
    } catch (e, stackTrace) {
      print('[SqliteJobEventLocalDatasource] 获取求职事件失败: $e');
      print('[SqliteJobEventLocalDatasource] 堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> saveJobEvent(JobEvent event) async {
    try {
      await _insertJobEventToDatabase(event);
    } catch (e, stackTrace) {
      print('[SqliteJobEventLocalDatasource] 保存求职事件失败: $e');
      print('[SqliteJobEventLocalDatasource] 堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> deleteJobEvent(String id, String userId) async {
    try {
      final db = await _database;
      await db.delete(
        DatabaseHelper.tableJobEvents,
        where: 'id = ? AND user_id = ?',
        whereArgs: [id, userId],
      );
    } catch (e, stackTrace) {
      print('[SqliteJobEventLocalDatasource] 删除求职事件失败: $e');
      print('[SqliteJobEventLocalDatasource] 堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> deleteJobEventById(String id) async {
    try {
      final db = await _database;
      await db.delete(
        DatabaseHelper.tableJobEvents,
        where: '${DatabaseHelper.columnId} = ?',
        whereArgs: [id],
      );
    } catch (e, stackTrace) {
      print('[SqliteJobEventLocalDatasource] 根据ID删除求职事件失败: $e');
      print('[SqliteJobEventLocalDatasource] 堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<Map<String, int>> getWeeklyStats(String userId) async {
    try {
      final db = await _database;
      
      // 计算一周前的日期
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      final weekAgoStr = weekAgo.toIso8601String();
      
      // 查询一周内的事件统计
      final results = await db.rawQuery(
        '''
        SELECT event_type, COUNT(*) as count 
        FROM ${DatabaseHelper.tableJobEvents} 
        WHERE user_id = ? AND event_time >= ?
        GROUP BY event_type
        ''',
        [userId, weekAgoStr],
      );
      
      // 构建统计结果
      final stats = <String, int>{
        'submissions': 0,
        'interviews': 0,
        'rejections': 0,
        'offers': 0,
      };
      
      for (final row in results) {
        final eventType = row['event_type'] as String;
        final count = row['count'] as int;
        
        switch (eventType) {
          case '投递':
            stats['submissions'] = count;
            break;
          case '面试':
            stats['interviews'] = count;
            break;
          case '拒信':
            stats['rejections'] = count;
            break;
          case 'Offer':
            stats['offers'] = count;
            break;
        }
      }
      
      return stats;
    } catch (e, stackTrace) {
      print('[SqliteJobEventLocalDatasource] 获取周统计失败: $e');
      print('[SqliteJobEventLocalDatasource] 堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<int> getTotalSubmissions(String userId) async {
    try {
      final db = await _database;
      final results = await db.rawQuery(
        'SELECT COUNT(*) as count FROM ${DatabaseHelper.tableJobEvents} WHERE user_id = ? AND event_type = ?',
        [userId, '投递'],
      );
      return Sqflite.firstIntValue(results) ?? 0;
    } catch (e, stackTrace) {
      print('[SqliteJobEventLocalDatasource] 获取总投递数失败: $e');
      print('[SqliteJobEventLocalDatasource] 堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<JobEvent?> getJobEventById(String id) async {
    try {
      final db = await _database;
      final results = await db.query(
        DatabaseHelper.tableJobEvents,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (results.isEmpty) return null;
      return JobEvent.fromDatabase(results.first);
    } catch (e, stackTrace) {
      print('[SqliteJobEventLocalDatasource] 根据ID获取求职事件失败: $e');
      print('[SqliteJobEventLocalDatasource] 堆栈跟踪: $stackTrace');
      rethrow;
    }
  }
}
