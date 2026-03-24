import 'package:sqflite/sqflite.dart';
import '../../../features/notifications/data/models/notification.dart';
import '../../../features/notifications/data/models/notification_settings.dart';
import 'database_helper.dart';

// ═══════════════════════════════════════════════════════════════════════════════
/// 通知本地数据源接口
/// 定义通知消息和通知设置的本地存储操作
// ═══════════════════════════════════════════════════════════════════════════════
abstract class NotificationLocalDatasource {
  // ────────────────────────────────────────────────────────────────────────────
  // 通知消息相关操作
  // ────────────────────────────────────────────────────────────────────────────

  /// 获取单条通知消息
  /// [id] 通知ID
  /// 返回通知消息，不存在则返回null
  Future<Notification?> getNotification(String id);

  /// 获取通知消息列表
  /// [userId] 用户ID
  /// [type] 可选的通知类型过滤
  /// [isRead] 可选的已读状态过滤
  /// 返回通知消息列表，按创建时间降序排列
  Future<List<Notification>> getNotifications(
    String userId, {
    NotificationType? type,
    bool? isRead,
  });

  /// 保存通知消息
  /// [notification] 通知消息数据
  Future<void> saveNotification(Notification notification);

  /// 标记通知为已读
  /// [id] 通知ID
  Future<void> markAsRead(String id);

  /// 标记用户所有通知为已读
  /// [userId] 用户ID
  Future<void> markAllAsRead(String userId);

  /// 获取用户未读通知数量
  /// [userId] 用户ID
  /// 返回未读通知数量
  Future<int> getUnreadCount(String userId);

  /// 删除单条通知消息
  /// [id] 通知ID
  Future<void> deleteNotification(String id);

  /// 删除用户所有通知消息
  /// [userId] 用户ID
  Future<void> deleteAllNotifications(String userId);

  // ────────────────────────────────────────────────────────────────────────────
  // 通知设置相关操作
  // ────────────────────────────────────────────────────────────────────────────

  /// 获取用户通知设置
  /// [userId] 用户ID
  /// 返回通知设置，不存在则返回null
  Future<NotificationSettings?> getSettings(String userId);

  /// 保存通知设置
  /// [settings] 通知设置数据
  Future<void> saveSettings(NotificationSettings settings);

  /// 获取或创建用户通知设置
  /// 如果设置不存在，则创建默认设置并保存
  /// [userId] 用户ID
  /// 返回通知设置
  Future<NotificationSettings> getOrCreateSettings(String userId);
}

// ═══════════════════════════════════════════════════════════════════════════════
/// SQLite数据源实现
/// 使用SQLite数据库存储通知消息和通知设置数据
// ═══════════════════════════════════════════════════════════════════════════════
class SqliteNotificationLocalDatasource implements NotificationLocalDatasource {
  /// 数据库帮助类实例
  final DatabaseHelper _databaseHelper;

  /// 构造函数
  /// [databaseHelper] 可选的数据库帮助类，默认使用单例
  SqliteNotificationLocalDatasource({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper();

  /// 获取数据库实例
  Future<Database> get _database async => _databaseHelper.database;

  // ═══════════════════════════════════════════════════════════════════════════════
  // 通知消息相关操作实现
  // ═══════════════════════════════════════════════════════════════════════════════

  @override
  Future<Notification?> getNotification(String id) async {
    try {
      final db = await _database;

      // 查询通知消息表
      final results = await db.query(
        DatabaseHelper.tableNotifications,
        where: '${DatabaseHelper.columnId} = ?',
        whereArgs: [id],
        limit: 1,
      );

      // 如果没有找到记录，返回null
      if (results.isEmpty) return null;

      // 将数据库Map转换为Notification模型
      return Notification.fromDatabase(results.first);
    } catch (e, stackTrace) {
      print('[SqliteNotificationLocalDatasource] 获取通知消息失败: $e');
      print('[SqliteNotificationLocalDatasource] 堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<List<Notification>> getNotifications(
    String userId, {
    NotificationType? type,
    bool? isRead,
  }) async {
    try {
      final db = await _database;

      // 构建查询条件
      final whereConditions = <String>[];
      final whereArgs = <dynamic>[];

      // 添加用户ID条件
      whereConditions.add('${DatabaseHelper.columnUserId} = ?');
      whereArgs.add(userId);

      // 添加类型过滤条件
      if (type != null) {
        whereConditions.add('${DatabaseHelper.columnType} = ?');
        whereArgs.add(type.name);
      }

      // 添加已读状态过滤条件
      if (isRead != null) {
        whereConditions.add('${DatabaseHelper.columnIsRead} = ?');
        whereArgs.add(isRead ? 1 : 0);
      }

      // 查询通知消息列表，按创建时间降序排列
      final results = await db.query(
        DatabaseHelper.tableNotifications,
        where: whereConditions.join(' AND '),
        whereArgs: whereArgs,
        orderBy: '${DatabaseHelper.columnCreatedAt} DESC',
      );

      // 将结果列表转换为Notification模型列表
      return results.map((map) => Notification.fromDatabase(map)).toList();
    } catch (e, stackTrace) {
      print('[SqliteNotificationLocalDatasource] 获取通知列表失败: $e');
      print('[SqliteNotificationLocalDatasource] 堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> saveNotification(Notification notification) async {
    try {
      final db = await _database;

      // 将Notification模型转换为数据库Map
      final data = notification.toDatabaseMap();

      // 使用INSERT OR REPLACE确保数据唯一性
      await db.insert(
        DatabaseHelper.tableNotifications,
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e, stackTrace) {
      print('[SqliteNotificationLocalDatasource] 保存通知消息失败: $e');
      print('[SqliteNotificationLocalDatasource] 堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    try {
      final db = await _database;

      // 更新通知的已读状态
      await db.update(
        DatabaseHelper.tableNotifications,
        {DatabaseHelper.columnIsRead: 1},
        where: '${DatabaseHelper.columnId} = ?',
        whereArgs: [id],
      );
    } catch (e, stackTrace) {
      print('[SqliteNotificationLocalDatasource] 标记通知已读失败: $e');
      print('[SqliteNotificationLocalDatasource] 堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    try {
      final db = await _database;

      // 更新用户所有通知的已读状态
      await db.update(
        DatabaseHelper.tableNotifications,
        {DatabaseHelper.columnIsRead: 1},
        where: '${DatabaseHelper.columnUserId} = ?',
        whereArgs: [userId],
      );
    } catch (e, stackTrace) {
      print('[SqliteNotificationLocalDatasource] 标记所有通知已读失败: $e');
      print('[SqliteNotificationLocalDatasource] 堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    try {
      final db = await _database;

      // 查询未读通知数量
      final results = await db.rawQuery(
        'SELECT COUNT(*) as count FROM ${DatabaseHelper.tableNotifications} '
        'WHERE ${DatabaseHelper.columnUserId} = ? AND ${DatabaseHelper.columnIsRead} = 0',
        [userId],
      );

      // 返回计数结果
      return Sqflite.firstIntValue(results) ?? 0;
    } catch (e, stackTrace) {
      print('[SqliteNotificationLocalDatasource] 获取未读数量失败: $e');
      print('[SqliteNotificationLocalDatasource] 堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> deleteNotification(String id) async {
    try {
      final db = await _database;

      // 删除指定的通知消息
      await db.delete(
        DatabaseHelper.tableNotifications,
        where: '${DatabaseHelper.columnId} = ?',
        whereArgs: [id],
      );
    } catch (e, stackTrace) {
      print('[SqliteNotificationLocalDatasource] 删除通知消息失败: $e');
      print('[SqliteNotificationLocalDatasource] 堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> deleteAllNotifications(String userId) async {
    try {
      final db = await _database;

      // 删除用户所有通知消息
      await db.delete(
        DatabaseHelper.tableNotifications,
        where: '${DatabaseHelper.columnUserId} = ?',
        whereArgs: [userId],
      );
    } catch (e, stackTrace) {
      print('[SqliteNotificationLocalDatasource] 删除所有通知消息失败: $e');
      print('[SqliteNotificationLocalDatasource] 堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  // 通知设置相关操作实现
  // ═══════════════════════════════════════════════════════════════════════════════

  @override
  Future<NotificationSettings?> getSettings(String userId) async {
    try {
      final db = await _database;

      // 查询通知设置表
      final results = await db.query(
        DatabaseHelper.tableNotificationSettings,
        where: '${DatabaseHelper.columnUserId} = ?',
        whereArgs: [userId],
        limit: 1,
      );

      // 如果没有找到记录，返回null
      if (results.isEmpty) return null;

      // 将数据库Map转换为NotificationSettings模型
      return NotificationSettings.fromDatabase(results.first);
    } catch (e, stackTrace) {
      print('[SqliteNotificationLocalDatasource] 获取通知设置失败: $e');
      print('[SqliteNotificationLocalDatasource] 堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> saveSettings(NotificationSettings settings) async {
    try {
      final db = await _database;

      // 将NotificationSettings模型转换为数据库Map
      final data = settings.toDatabaseMap();

      // 使用INSERT OR REPLACE确保数据唯一性
      await db.insert(
        DatabaseHelper.tableNotificationSettings,
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e, stackTrace) {
      print('[SqliteNotificationLocalDatasource] 保存通知设置失败: $e');
      print('[SqliteNotificationLocalDatasource] 堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<NotificationSettings> getOrCreateSettings(String userId) async {
    try {
      // 先尝试获取现有设置
      final existingSettings = await getSettings(userId);

      // 如果存在，直接返回
      if (existingSettings != null) {
        return existingSettings;
      }

      // 如果不存在，创建默认设置
      final defaultSettings = NotificationSettings.createDefault(
        _generateSettingsId(userId),
        userId,
      );

      // 保存默认设置
      await saveSettings(defaultSettings);

      return defaultSettings;
    } catch (e, stackTrace) {
      print('[SqliteNotificationLocalDatasource] 获取或创建通知设置失败: $e');
      print('[SqliteNotificationLocalDatasource] 堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  // 辅助方法
  // ═══════════════════════════════════════════════════════════════════════════════

  /// 生成通知设置ID
  /// 使用用户ID作为基础生成唯一ID
  String _generateSettingsId(String userId) {
    return 'settings_$userId';
  }
}
