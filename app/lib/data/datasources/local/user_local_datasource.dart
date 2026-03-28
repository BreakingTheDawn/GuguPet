import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../../models/user_profile.dart';
import '../../../core/services/vip_protection_service.dart';
import 'database_helper.dart';

/// 用户本地数据源接口
/// 定义用户数据的本地存储操作
abstract class UserLocalDatasource {
  /// 获取指定用户
  Future<UserProfile?> getUser(String userId);
  
  /// 保存用户
  Future<void> saveUser(UserProfile user);
  
  /// 更新用户
  Future<void> updateUser(UserProfile user);
  
  /// 删除用户
  Future<void> deleteUser(String userId);
  
  /// 获取所有用户
  Future<List<UserProfile>> getAllUsers();
}

/// Mock数据源实现（使用SharedPreferences）
/// 用于测试或作为备用数据源
class MockUserLocalDatasource implements UserLocalDatasource {
  static const String _keyUserProfile = 'user_profile';

  @override
  Future<UserProfile?> getUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('${_keyUserProfile}_$userId');
    if (jsonStr == null) return null;
    return UserProfile.fromJson(
      Map<String, dynamic>.from(jsonDecode(jsonStr) as Map),
    );
  }

  @override
  Future<void> saveUser(UserProfile user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '${_keyUserProfile}_${user.userId}',
      jsonEncode(user.toJson()),
    );
  }

  @override
  Future<void> updateUser(UserProfile user) async {
    await saveUser(user);
  }

  @override
  Future<void> deleteUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${_keyUserProfile}_$userId');
  }

  @override
  Future<List<UserProfile>> getAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_keyUserProfile));
    final users = <UserProfile>[];
    for (final key in keys) {
      final jsonStr = prefs.getString(key);
      if (jsonStr != null) {
        users.add(
          UserProfile.fromJson(
            Map<String, dynamic>.from(jsonDecode(jsonStr) as Map),
          ),
        );
      }
    }
    return users;
  }
}

/// SQLite数据源实现
/// 使用SQLite数据库存储用户数据
/// 包含从SharedPreferences到SQLite的数据迁移功能
class SqliteUserLocalDatasource implements UserLocalDatasource {
  final DatabaseHelper _databaseHelper;
  final VipProtectionService _vipProtectionService = VipProtectionService();
  
  /// 迁移标记键名
  static const String _keyMigrationCompleted = 'user_data_migration_completed';
  
  /// SharedPreferences中用户数据的键前缀
  static const String _keyUserProfilePrefix = 'user_profile';

  SqliteUserLocalDatasource({DatabaseHelper? databaseHelper})
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
  Future<void> _migrateFromSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 检查是否已完成迁移
      final migrationCompleted = prefs.getBool(_keyMigrationCompleted) ?? false;
      if (migrationCompleted) {
        print('[SqliteUserLocalDatasource] 数据迁移已完成，跳过');
        return;
      }

      print('[SqliteUserLocalDatasource] 开始数据迁移...');

      // 获取所有用户数据的键
      final keys = prefs
          .getKeys()
          .where((k) => k.startsWith(_keyUserProfilePrefix))
          .toList();

      if (keys.isEmpty) {
        print('[SqliteUserLocalDatasource] 没有需要迁移的数据');
        await prefs.setBool(_keyMigrationCompleted, true);
        return;
      }

      // 迁移每个用户数据
      int migratedCount = 0;
      for (final key in keys) {
        final jsonStr = prefs.getString(key);
        if (jsonStr != null) {
          try {
            final user = UserProfile.fromJson(
              Map<String, dynamic>.from(jsonDecode(jsonStr) as Map),
            );
            await _insertUserToDatabase(user);
            migratedCount++;
          } catch (e) {
            print('[SqliteUserLocalDatasource] 迁移用户数据失败: $key, 错误: $e');
          }
        }
      }

      // 清理SharedPreferences中的旧数据
      for (final key in keys) {
        await prefs.remove(key);
      }

      // 标记迁移完成
      await prefs.setBool(_keyMigrationCompleted, true);

      print('[SqliteUserLocalDatasource] 数据迁移完成，共迁移 $migratedCount 条记录');
    } catch (e, stackTrace) {
      print('[SqliteUserLocalDatasource] 数据迁移失败: $e');
      print('[SqliteUserLocalDatasource] 堆栈跟踪: $stackTrace');
      // 迁移失败不影响后续操作
    }
  }

  /// 将用户数据插入数据库
  /// 使用INSERT OR REPLACE确保数据唯一性
  Future<void> _insertUserToDatabase(UserProfile user) async {
    final db = await _database;
    final now = DateTime.now().toIso8601String();
    
    await db.insert(
      DatabaseHelper.tableUsers,
      _userToMap(user, now, now),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 将UserProfile转换为数据库Map
  Map<String, dynamic> _userToMap(
    UserProfile user,
    String createdAt,
    String updatedAt,
  ) {
    return {
      DatabaseHelper.columnUserId: user.userId,
      DatabaseHelper.columnUserName: user.userName,
      DatabaseHelper.columnJobIntention: user.jobIntention,
      DatabaseHelper.columnCity: user.city,
      DatabaseHelper.columnSalaryExpect: user.salaryExpect,
      DatabaseHelper.columnPetMemory: jsonEncode(
        user.petMemory.map((m) => m.toJson()).toList(),
      ),
      DatabaseHelper.columnVipStatus: user.vipStatus ? 1 : 0,
      DatabaseHelper.columnVipExpireTime: user.vipExpireTime?.toIso8601String(),
      DatabaseHelper.columnIsOnboarded: user.isOnboarded ? 1 : 0,
      DatabaseHelper.columnIndustryTag: user.industryTag,
      DatabaseHelper.columnOnboardingReport: user.onboardingReport,
      'is_park_unlocked': user.isParkUnlocked ? 1 : 0,
      'park_unlocked_at': user.parkUnlockedAt?.toIso8601String(),
      'park_unlock_source': user.parkUnlockSource,
      DatabaseHelper.columnCreatedAt: createdAt,
      DatabaseHelper.columnUpdatedAt: updatedAt,
    };
  }

  /// 将数据库Map转换为UserProfile
  UserProfile _mapToUser(Map<String, dynamic> map) {
    // 解析petMemory JSON
    List<PetMemory> petMemory = [];
    final petMemoryStr = map[DatabaseHelper.columnPetMemory] as String?;
    if (petMemoryStr != null && petMemoryStr.isNotEmpty) {
      try {
        final petMemoryList = jsonDecode(petMemoryStr) as List<dynamic>;
        petMemory = petMemoryList
            .map((m) => PetMemory.fromJson(m as Map<String, dynamic>))
            .toList();
      } catch (e) {
        print('[SqliteUserLocalDatasource] 解析petMemory失败: $e');
      }
    }

    return UserProfile(
      userId: map[DatabaseHelper.columnUserId] as String,
      userName: map[DatabaseHelper.columnUserName] as String,
      jobIntention: map[DatabaseHelper.columnJobIntention] as String?,
      city: map[DatabaseHelper.columnCity] as String?,
      salaryExpect: map[DatabaseHelper.columnSalaryExpect] as String?,
      petMemory: petMemory,
      vipStatus: (map[DatabaseHelper.columnVipStatus] as int?) == 1,
      vipExpireTime: map[DatabaseHelper.columnVipExpireTime] != null
          ? DateTime.parse(map[DatabaseHelper.columnVipExpireTime] as String)
          : null,
      isOnboarded: (map[DatabaseHelper.columnIsOnboarded] as int?) == 1,
      industryTag: map[DatabaseHelper.columnIndustryTag] as String?,
      onboardingReport: map[DatabaseHelper.columnOnboardingReport] as String?,
      isParkUnlocked: (map['is_park_unlocked'] as int?) == 1,
      parkUnlockedAt: map['park_unlocked_at'] != null
          ? DateTime.parse(map['park_unlocked_at'] as String)
          : null,
      parkUnlockSource: map['park_unlock_source'] as String?,
    );
  }

  @override
  Future<UserProfile?> getUser(String userId) async {
    try {
      final db = await _database;
      final results = await db.query(
        DatabaseHelper.tableUsers,
        where: '${DatabaseHelper.columnUserId} = ?',
        whereArgs: [userId],
        limit: 1,
      );

      if (results.isEmpty) return null;
      final user = _mapToUser(results.first);
      
      // 验证VIP状态是否可信
      final isTrusted = await _vipProtectionService.isVipStatusTrusted(
        userId,
        user.vipStatus,
        user.vipExpireTime,
      );

      if (!isTrusted && user.vipStatus) {
        // VIP状态不可信，返回非VIP状态的用户
        print('[SqliteUserLocalDatasource] 检测到VIP状态异常，用户ID: $userId');
        return user.copyWith(
          vipStatus: false,
          vipExpireTime: null,
        );
      }

      return user;
    } catch (e, stackTrace) {
      print('[SqliteUserLocalDatasource] 获取用户失败: $e');
      print('[SqliteUserLocalDatasource] 堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> saveUser(UserProfile user) async {
    try {
      await _insertUserToDatabase(user);
    } catch (e, stackTrace) {
      print('[SqliteUserLocalDatasource] 保存用户失败: $e');
      print('[SqliteUserLocalDatasource] 堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> updateUser(UserProfile user) async {
    try {
      final db = await _database;
      final now = DateTime.now().toIso8601String();
      
      // 获取原记录的创建时间
      final existingUser = await getUser(user.userId);
      final createdAt = existingUser != null
          ? (await db.query(
              DatabaseHelper.tableUsers,
              columns: [DatabaseHelper.columnCreatedAt],
              where: '${DatabaseHelper.columnUserId} = ?',
              whereArgs: [user.userId],
              limit: 1,
            )).first[DatabaseHelper.columnCreatedAt] as String
          : now;

      await db.update(
        DatabaseHelper.tableUsers,
        _userToMap(user, createdAt, now),
        where: '${DatabaseHelper.columnUserId} = ?',
        whereArgs: [user.userId],
      );
    } catch (e, stackTrace) {
      print('[SqliteUserLocalDatasource] 更新用户失败: $e');
      print('[SqliteUserLocalDatasource] 堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      final db = await _database;
      await db.delete(
        DatabaseHelper.tableUsers,
        where: '${DatabaseHelper.columnUserId} = ?',
        whereArgs: [userId],
      );
    } catch (e, stackTrace) {
      print('[SqliteUserLocalDatasource] 删除用户失败: $e');
      print('[SqliteUserLocalDatasource] 堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<List<UserProfile>> getAllUsers() async {
    try {
      final db = await _database;
      final results = await db.query(
        DatabaseHelper.tableUsers,
        orderBy: '${DatabaseHelper.columnCreatedAt} DESC',
      );
      return results.map(_mapToUser).toList();
    } catch (e, stackTrace) {
      print('[SqliteUserLocalDatasource] 获取所有用户失败: $e');
      print('[SqliteUserLocalDatasource] 堆栈跟踪: $stackTrace');
      rethrow;
    }
  }
}
