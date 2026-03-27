import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// 测试数据库帮助类
/// 用于创建内存数据库，测试完成后自动清理
class TestDatabaseHelper {
  static Database? _testDatabase;
  static final int _databaseVersion = 5;

  /// 获取测试数据库实例
  /// 使用内存数据库，每次测试都是全新的
  static Future<Database> get database async {
    if (_testDatabase != null) return _testDatabase!;
    
    // 初始化 sqflite_ffi
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    
    // 创建内存数据库
    _testDatabase = await openDatabase(
      inMemoryDatabasePath,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
    
    return _testDatabase!;
  }

  /// 创建数据库表
  static Future<void> _onCreate(Database db, int version) async {
    // 用户表
    await db.execute('''
      CREATE TABLE users (
        user_id TEXT PRIMARY KEY,
        account TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        user_name TEXT NOT NULL,
        is_logged_in INTEGER DEFAULT 0,
        job_intention TEXT,
        city TEXT,
        salary_expect TEXT,
        pet_memory TEXT DEFAULT '[]',
        vip_status INTEGER DEFAULT 0,
        vip_expire_time TEXT,
        is_onboarded INTEGER DEFAULT 0,
        industry_tag TEXT,
        onboarding_report TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // 交互记录表
    await db.execute('''
      CREATE TABLE interactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        content TEXT,
        action_type TEXT,
        emotion_type TEXT,
        pet_action TEXT,
        pet_bubble TEXT,
        created_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users(user_id)
      )
    ''');

    // 求职事件表
    await db.execute('''
      CREATE TABLE job_events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        event_type TEXT NOT NULL,
        event_content TEXT,
        company_name TEXT,
        position_name TEXT,
        event_time TEXT,
        created_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users(user_id)
      )
    ''');

    // 收藏职位表
    await db.execute('''
      CREATE TABLE favorite_jobs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        job_id TEXT NOT NULL,
        job_title TEXT,
        company TEXT,
        salary_range TEXT,
        job_location TEXT,
        job_tags TEXT,
        created_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users(user_id),
        UNIQUE(user_id, job_id)
      )
    ''');

    // 通知消息表
    await db.execute('''
      CREATE TABLE notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        type TEXT NOT NULL,
        title TEXT NOT NULL,
        content TEXT,
        extra_data TEXT,
        is_read INTEGER DEFAULT 0,
        is_actioned INTEGER DEFAULT 0,
        scheduled_time TEXT,
        sent_at TEXT,
        created_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users(user_id)
      )
    ''');
  }

  /// 关闭并清理测试数据库
  static Future<void> cleanup() async {
    if (_testDatabase != null) {
      await _testDatabase!.close();
      _testDatabase = null;
    }
  }

  /// 清空所有表数据（保留表结构）
  static Future<void> clearAllTables() async {
    final db = await database;
    await db.delete('notifications');
    await db.delete('favorite_jobs');
    await db.delete('job_events');
    await db.delete('interactions');
    await db.delete('users');
  }

  /// 插入测试用户
  static Future<void> insertTestUser({
    required String userId,
    required String account,
    required String password,
    required String userName,
    bool isLoggedIn = false,
    bool isVip = false,
  }) async {
    final db = await database;
    await db.insert('users', {
      'user_id': userId,
      'account': account,
      'password': password,
      'user_name': userName,
      'is_logged_in': isLoggedIn ? 1 : 0,
      'vip_status': isVip ? 1 : 0,
      'pet_memory': '[]',
      'is_onboarded': 0,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}

/// 测试数据库初始化
/// 在测试组开始前调用
Future<void> setUpTestDatabase() async {
  await TestDatabaseHelper.database;
}

/// 测试数据库清理
/// 在测试组结束后调用
Future<void> tearDownTestDatabase() async {
  await TestDatabaseHelper.cleanup();
}
