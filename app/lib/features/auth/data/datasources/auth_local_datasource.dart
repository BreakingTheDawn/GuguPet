import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../../../data/datasources/local/database_helper.dart';
import '../models/auth_user.dart';

/// 认证本地数据源
/// 负责用户认证相关的数据库操作
class AuthLocalDatasource {
  final DatabaseHelper _databaseHelper;
  
  AuthLocalDatasource({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper();
  
  /// 获取数据库实例
  Future<Database> get _database async => _databaseHelper.database;
  
  /// 密码加密（SHA256）
  /// 使用SHA256算法对密码进行哈希处理
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }
  
  /// 注册新用户
  /// 返回注册结果：成功返回AuthUser，失败返回null
  Future<AuthUser?> register({
    required String account,
    required String password,
    required String userName,
  }) async {
    try {
      final db = await _database;
      
      // 检查账号是否已存在
      final existing = await db.query(
        DatabaseHelper.tableUsers,
        where: 'account = ?',
        whereArgs: [account],
        limit: 1,
      );
      
      if (existing.isNotEmpty) {
        return null; // 账号已存在
      }
      
      // 生成用户ID
      final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      final now = DateTime.now().toIso8601String();
      
      // 插入新用户（包含完整的用户档案字段，但都是空白状态）
      await db.insert(
        DatabaseHelper.tableUsers,
        {
          'user_id': userId,
          'account': account,
          'password': _hashPassword(password),
          'user_name': userName,
          'is_logged_in': 1,
          // 用户档案字段 - 新用户为空白状态
          'job_intention': null,
          'city': null,
          'salary_expect': null,
          'pet_memory': '[]',
          'vip_status': 0,
          'vip_expire_time': null,
          'is_onboarded': 0,
          'industry_tag': null,
          'onboarding_report': null,
          'created_at': now,
          'updated_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      return AuthUser(
        userId: userId,
        account: account,
        userName: userName,
        isLoggedIn: true,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      print('[AuthLocalDatasource] 注册失败: $e');
      return null;
    }
  }
  
  /// 用户登录
  /// 验证账号密码，成功返回AuthUser，失败返回null
  Future<AuthUser?> login({
    required String account,
    required String password,
  }) async {
    try {
      final db = await _database;
      
      // 查询用户
      final results = await db.query(
        DatabaseHelper.tableUsers,
        where: 'account = ? AND password = ?',
        whereArgs: [account, _hashPassword(password)],
        limit: 1,
      );
      
      if (results.isEmpty) {
        return null; // 账号或密码错误
      }
      
      // 更新登录状态
      await db.update(
        DatabaseHelper.tableUsers,
        {'is_logged_in': 1, 'updated_at': DateTime.now().toIso8601String()},
        where: 'user_id = ?',
        whereArgs: [results.first['user_id']],
      );
      
      return AuthUser.fromDatabase(results.first).copyWith(isLoggedIn: true);
    } catch (e) {
      print('[AuthLocalDatasource] 登录失败: $e');
      return null;
    }
  }
  
  /// 用户登出
  Future<void> logout(String userId) async {
    try {
      final db = await _database;
      await db.update(
        DatabaseHelper.tableUsers,
        {'is_logged_in': 0, 'updated_at': DateTime.now().toIso8601String()},
        where: 'user_id = ?',
        whereArgs: [userId],
      );
    } catch (e) {
      print('[AuthLocalDatasource] 登出失败: $e');
    }
  }
  
  /// 获取当前登录用户
  Future<AuthUser?> getCurrentUser() async {
    try {
      final db = await _database;
      final results = await db.query(
        DatabaseHelper.tableUsers,
        where: 'is_logged_in = 1',
        limit: 1,
      );
      
      if (results.isEmpty) {
        return null;
      }
      
      return AuthUser.fromDatabase(results.first);
    } catch (e) {
      print('[AuthLocalDatasource] 获取当前用户失败: $e');
      return null;
    }
  }
  
  /// 检查账号是否存在
  Future<bool> isAccountExists(String account) async {
    try {
      final db = await _database;
      final results = await db.query(
        DatabaseHelper.tableUsers,
        where: 'account = ?',
        whereArgs: [account],
        limit: 1,
      );
      return results.isNotEmpty;
    } catch (e) {
      print('[AuthLocalDatasource] 检查账号失败: $e');
      return false;
    }
  }
}
