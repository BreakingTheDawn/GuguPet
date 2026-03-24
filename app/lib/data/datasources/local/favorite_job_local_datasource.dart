import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../../models/favorite_job.dart';
import 'database_helper.dart';

/// 收藏职位本地数据源接口
/// 定义收藏职位数据的本地存储操作
abstract class FavoriteJobLocalDatasource {
  /// 获取指定用户的收藏职位列表
  Future<List<FavoriteJob>> getFavoriteJobs(String userId);
  
  /// 添加收藏职位
  Future<void> addFavoriteJob(FavoriteJob job);
  
  /// 取消收藏职位
  Future<void> removeFavoriteJob(String userId, String jobId);
  
  /// 检查职位是否已收藏
  Future<bool> isFavorited(String userId, String jobId);
  
  /// 根据ID获取收藏记录
  Future<FavoriteJob?> getFavoriteJobById(String id);
  
  /// 获取收藏数量
  Future<int> getFavoriteCount(String userId);
}

/// Mock数据源实现（使用SharedPreferences）
/// 用于测试或作为备用数据源
class MockFavoriteJobLocalDatasource implements FavoriteJobLocalDatasource {
  static const String _keyFavoriteJobs = 'favorite_jobs';

  @override
  Future<List<FavoriteJob>> getFavoriteJobs(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('${_keyFavoriteJobs}_$userId');
    if (jsonStr == null) return [];
    final List<dynamic> jsonList = jsonDecode(jsonStr) as List<dynamic>;
    return jsonList
        .map((json) => FavoriteJob.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> addFavoriteJob(FavoriteJob job) async {
    final jobs = await getFavoriteJobs(job.userId);
    // 检查是否已存在
    final existingIndex = jobs.indexWhere((j) => j.jobId == job.jobId);
    if (existingIndex < 0) {
      jobs.add(job);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '${_keyFavoriteJobs}_${job.userId}',
      jsonEncode(jobs.map((j) => j.toJson()).toList()),
    );
  }

  @override
  Future<void> removeFavoriteJob(String userId, String jobId) async {
    final jobs = await getFavoriteJobs(userId);
    jobs.removeWhere((j) => j.jobId == jobId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '${_keyFavoriteJobs}_$userId',
      jsonEncode(jobs.map((j) => j.toJson()).toList()),
    );
  }

  @override
  Future<bool> isFavorited(String userId, String jobId) async {
    final jobs = await getFavoriteJobs(userId);
    return jobs.any((j) => j.jobId == jobId);
  }

  @override
  Future<FavoriteJob?> getFavoriteJobById(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_keyFavoriteJobs));
    
    for (final key in keys) {
      final jsonStr = prefs.getString(key);
      if (jsonStr != null) {
        final List<dynamic> jsonList = jsonDecode(jsonStr) as List<dynamic>;
        for (final json in jsonList) {
          final job = FavoriteJob.fromJson(json as Map<String, dynamic>);
          if (job.id == id) {
            return job;
          }
        }
      }
    }
    return null;
  }

  @override
  Future<int> getFavoriteCount(String userId) async {
    final jobs = await getFavoriteJobs(userId);
    return jobs.length;
  }
}

/// SQLite数据源实现
/// 使用SQLite数据库存储收藏职位数据
class SqliteFavoriteJobLocalDatasource implements FavoriteJobLocalDatasource {
  final DatabaseHelper _databaseHelper;

  SqliteFavoriteJobLocalDatasource({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper();

  /// 获取数据库实例
  Future<Database> get _database async => _databaseHelper.database;

  @override
  Future<List<FavoriteJob>> getFavoriteJobs(String userId) async {
    try {
      final db = await _database;
      final results = await db.query(
        DatabaseHelper.tableFavoriteJobs,
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
      );
      return results.map((map) => FavoriteJob.fromDatabase(map)).toList();
    } catch (e, stackTrace) {
      print('[SqliteFavoriteJobLocalDatasource] 获取收藏职位失败: $e');
      print('[SqliteFavoriteJobLocalDatasource] 堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> addFavoriteJob(FavoriteJob job) async {
    try {
      final db = await _database;
      
      // 使用数据库Map格式
      final data = job.toDatabaseMap();
      // 确保created_at有值
      if (data['created_at'] == null) {
        data['created_at'] = DateTime.now().toIso8601String();
      }
      
      await db.insert(
        DatabaseHelper.tableFavoriteJobs,
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e, stackTrace) {
      print('[SqliteFavoriteJobLocalDatasource] 添加收藏职位失败: $e');
      print('[SqliteFavoriteJobLocalDatasource] 堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> removeFavoriteJob(String userId, String jobId) async {
    try {
      final db = await _database;
      await db.delete(
        DatabaseHelper.tableFavoriteJobs,
        where: 'user_id = ? AND job_id = ?',
        whereArgs: [userId, jobId],
      );
    } catch (e, stackTrace) {
      print('[SqliteFavoriteJobLocalDatasource] 取消收藏职位失败: $e');
      print('[SqliteFavoriteJobLocalDatasource] 堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<bool> isFavorited(String userId, String jobId) async {
    try {
      final db = await _database;
      final results = await db.query(
        DatabaseHelper.tableFavoriteJobs,
        where: 'user_id = ? AND job_id = ?',
        whereArgs: [userId, jobId],
        limit: 1,
      );
      return results.isNotEmpty;
    } catch (e, stackTrace) {
      print('[SqliteFavoriteJobLocalDatasource] 检查收藏状态失败: $e');
      print('[SqliteFavoriteJobLocalDatasource] 堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<FavoriteJob?> getFavoriteJobById(String id) async {
    try {
      final db = await _database;
      final results = await db.query(
        DatabaseHelper.tableFavoriteJobs,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (results.isEmpty) return null;
      return FavoriteJob.fromDatabase(results.first);
    } catch (e, stackTrace) {
      print('[SqliteFavoriteJobLocalDatasource] 根据ID获取收藏职位失败: $e');
      print('[SqliteFavoriteJobLocalDatasource] 堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<int> getFavoriteCount(String userId) async {
    try {
      final db = await _database;
      final results = await db.rawQuery(
        'SELECT COUNT(*) as count FROM ${DatabaseHelper.tableFavoriteJobs} WHERE user_id = ?',
        [userId],
      );
      return Sqflite.firstIntValue(results) ?? 0;
    } catch (e, stackTrace) {
      print('[SqliteFavoriteJobLocalDatasource] 获取收藏数量失败: $e');
      print('[SqliteFavoriteJobLocalDatasource] 堆栈跟踪: $stackTrace');
      rethrow;
    }
  }
}
