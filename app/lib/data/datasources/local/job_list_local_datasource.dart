import 'dart:io';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/job.dart';

/// 职位数据本地数据源接口
/// 定义职位数据的本地存储操作
abstract class JobListLocalDatasource {
  /// 获取所有职位列表
  Future<List<Job>> getAllJobs();
  
  /// 根据类别获取职位列表
  Future<List<Job>> getJobsByCategory(String category);
  
  /// 搜索职位
  Future<List<Job>> searchJobs(String query);
  
  /// 获取职位总数
  Future<int> getJobCount();
  
  /// 获取各类别职位数量统计
  Future<Map<String, int>> getCategoryStats();
  
  /// 刷新数据（重新从assets加载）
  Future<void> refresh();
}

/// SQLite数据源实现
/// 从assets中的jobs.db数据库读取职位数据，并缓存到本地
class SqliteJobListLocalDatasource implements JobListLocalDatasource {
  Database? _database;
  List<Job>? _cachedJobs;
  
  /// 数据库文件名
  static const String _databaseName = 'jobs.db';
  
  /// 获取数据库实例
  Future<Database> get _db async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  /// 初始化数据库
  /// 策略：优先使用本地缓存的数据库，不存在才从assets复制
  Future<Database> _initDatabase() async {
    try {
      // 获取数据库路径
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, _databaseName);
      
      print('[SqliteJobListLocalDatasource] 数据库路径: $path');
      
      // 检查本地数据库是否存在
      final file = File(path);
      final exists = await file.exists();
      
      if (exists) {
        // 本地已缓存，直接打开
        print('[SqliteJobListLocalDatasource] 使用本地缓存的数据库');
        final db = await openDatabase(path, readOnly: false);
        
        // 检查数据库是否有数据
        final count = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) as count FROM jobs')
        ) ?? 0;
        print('[SqliteJobListLocalDatasource] 本地数据库有 $count 条职位');
        
        // 如果有数据，直接返回
        if (count > 0) {
          return db;
        }
        
        // 如果没有数据，关闭并从assets重新加载
        await db.close();
        await file.delete();
        print('[SqliteJobListLocalDatasource] 本地数据库为空，重新从assets加载');
      }
      
      // 从assets复制数据库
      await _copyDatabaseFromAssets(path);
      
      // 打开数据库
      final db = await openDatabase(path, readOnly: false);
      print('[SqliteJobListLocalDatasource] 数据库初始化成功');
      return db;
    } catch (e, stackTrace) {
      print('[SqliteJobListLocalDatasource] 数据库初始化失败: $e');
      print('[SqliteJobListLocalDatasource] 堆栈跟踪: $stackTrace');
      rethrow;
    }
  }
  
  /// 从assets复制数据库文件
  Future<void> _copyDatabaseFromAssets(String path) async {
    try {
      // 确保目录存在
      final dbPath = await getDatabasesPath();
      final dir = Directory(dbPath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      
      // 从assets读取数据库文件
      final data = await rootBundle.load('assets/data/$_databaseName');
      final bytes = data.buffer.asUint8List();
      
      // 写入到应用目录
      await File(path).writeAsBytes(bytes, flush: true);
      
      print('[SqliteJobListLocalDatasource] 数据库从assets复制成功，大小: ${bytes.length} bytes');
    } catch (e, stackTrace) {
      print('[SqliteJobListLocalDatasource] 复制数据库失败: $e');
      print('[SqliteJobListLocalDatasource] 堆栈跟踪: $stackTrace');
      rethrow;
    }
  }
  
  @override
  Future<List<Job>> getAllJobs() async {
    // 优先使用内存缓存
    if (_cachedJobs != null && _cachedJobs!.isNotEmpty) {
      print('[SqliteJobListLocalDatasource] 使用内存缓存: ${_cachedJobs!.length} 个职位');
      return _cachedJobs!;
    }
    
    try {
      final db = await _db;
      // 使用 synced_at 作为排序字段（created_at 可能不存在）
      final results = await db.query(
        'jobs',
        orderBy: 'synced_at DESC',
      );
      _cachedJobs = results.map((map) => Job.fromDatabase(map)).toList();
      print('[SqliteJobListLocalDatasource] 从数据库加载了 ${_cachedJobs!.length} 个职位');
      return _cachedJobs!;
    } catch (e, stackTrace) {
      print('[SqliteJobListLocalDatasource] 获取职位列表失败: $e');
      print('[SqliteJobListLocalDatasource] 堆栈跟踪: $stackTrace');
      return [];
    }
  }
  
  @override
  Future<List<Job>> getJobsByCategory(String category) async {
    try {
      final db = await _db;
      final results = await db.query(
        'jobs',
        where: 'category = ?',
        whereArgs: [category],
        orderBy: 'synced_at DESC',
      );
      return results.map((map) => Job.fromDatabase(map)).toList();
    } catch (e, stackTrace) {
      print('[SqliteJobListLocalDatasource] 获取类别职位失败: $e');
      print('[SqliteJobListLocalDatasource] 堆栈跟踪: $stackTrace');
      return [];
    }
  }
  
  @override
  Future<List<Job>> searchJobs(String query) async {
    try {
      final db = await _db;
      final results = await db.query(
        'jobs',
        where: 'title LIKE ? OR company LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'synced_at DESC',
      );
      return results.map((map) => Job.fromDatabase(map)).toList();
    } catch (e, stackTrace) {
      print('[SqliteJobListLocalDatasource] 搜索职位失败: $e');
      print('[SqliteJobListLocalDatasource] 堆栈跟踪: $stackTrace');
      return [];
    }
  }
  
  @override
  Future<int> getJobCount() async {
    try {
      final db = await _db;
      final results = await db.rawQuery('SELECT COUNT(*) as count FROM jobs');
      return Sqflite.firstIntValue(results) ?? 0;
    } catch (e, stackTrace) {
      print('[SqliteJobListLocalDatasource] 获取职位数量失败: $e');
      print('[SqliteJobListLocalDatasource] 堆栈跟踪: $stackTrace');
      return 0;
    }
  }
  
  @override
  Future<Map<String, int>> getCategoryStats() async {
    try {
      final db = await _db;
      final results = await db.rawQuery(
        'SELECT category, COUNT(*) as count FROM jobs GROUP BY category'
      );
      return Map.fromEntries(
        results.map((row) => MapEntry(
          row['category'] as String? ?? '其他',
          row['count'] as int,
        )),
      );
    } catch (e, stackTrace) {
      print('[SqliteJobListLocalDatasource] 获取类别统计失败: $e');
      print('[SqliteJobListLocalDatasource] 堆栈跟踪: $stackTrace');
      return {};
    }
  }
  
  @override
  Future<void> refresh() async {
    // 清除缓存
    _cachedJobs = null;
    
    // 关闭并删除本地数据库
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
    
    // 删除本地数据库文件
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
    
    print('[SqliteJobListLocalDatasource] 数据已刷新，下次加载将从assets重新读取');
  }
  
  /// 关闭数据库连接
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      print('[SqliteJobListLocalDatasource] 数据库连接已关闭');
    }
  }
}
