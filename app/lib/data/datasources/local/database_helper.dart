import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../../../core/utils/logger_service.dart';
import 'database_migration.dart';

/// SQLite数据库帮助类
/// 采用单例模式管理数据库实例
/// 负责数据库的创建、版本管理和迁移
class DatabaseHelper {
  // 单例实例
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  // 数据库实例
  static Database? _database;
  
  // 用于保证数据库初始化只执行一次的 Completer
  // 解决并发访问时的竞态条件问题
  static Completer<Database>? _completer;

  // 数据库配置常量
  static const String _databaseName = 'gugupet.db';
  static const int _databaseVersion = 5;

  /// 获取数据库实例
  /// 使用 Completer 确保并发安全，避免竞态条件
  /// 当多个地方同时首次调用时，只会初始化一次
  Future<Database> get database async {
    // 如果数据库已初始化，直接返回
    if (_database != null) return _database!;
    
    // 如果正在初始化，等待完成
    if (_completer != null) return _completer!.future;
    
    // 开始初始化
    _completer = Completer<Database>();
    
    try {
      _database = await _initDatabase();
      _completer!.complete(_database!);
      return _database!;
    } catch (e) {
      // 初始化失败，重置 Completer 以便下次重试
      _completer = null;
      rethrow;
    }
  }

  /// 初始化数据库
  /// 获取数据库路径并打开数据库
  /// 包含错误处理和日志记录
  Future<Database> _initDatabase() async {
    try {
      // 获取应用文档目录
      final Directory documentsDirectory = await getApplicationDocumentsDirectory();
      
      // 拼接数据库完整路径
      final String path = join(documentsDirectory.path, _databaseName);
      
      AppLogger.debug('[DatabaseHelper] 初始化数据库: $path');
      
      // 打开数据库，如果不存在则创建
      final db = await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onConfigure: _onConfigure,
      );
      
      AppLogger.info('[DatabaseHelper] 数据库初始化成功，版本: $_databaseVersion');
      return db;
    } catch (e, stackTrace) {
      AppLogger.error('[DatabaseHelper] 数据库初始化失败: $e');
      AppLogger.error('[DatabaseHelper] 堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  /// 数据库配置回调
  /// 启用外键约束
  Future<void> _onConfigure(Database db) async {
    try {
      await db.execute('PRAGMA foreign_keys = ON');
      AppLogger.info('[DatabaseHelper] 外键约束已启用');
    } catch (e) {
      AppLogger.error('[DatabaseHelper] 启用外键约束失败: $e');
      rethrow;
    }
  }

  /// 数据库创建回调
  /// 执行所有版本的迁移脚本
  /// 使用事务确保迁移的原子性
  Future<void> _onCreate(Database db, int version) async {
    AppLogger.debug('[DatabaseHelper] 创建数据库，目标版本: $version');
    
    try {
      // 使用事务包装所有迁移脚本，确保原子性
      await db.transaction((txn) async {
        // 从版本1到当前版本，依次执行迁移
        for (int i = 1; i <= version; i++) {
          final migration = DatabaseMigration.getMigration(i);
          if (migration != null) {
            AppLogger.debug('[DatabaseHelper] 执行迁移脚本 v$i，共 ${migration.length} 条SQL');
            for (final sql in migration) {
              await txn.execute(sql);
            }
          }
        }
      });
      
      AppLogger.info('[DatabaseHelper] 数据库创建成功');
    } catch (e, stackTrace) {
      AppLogger.error('[DatabaseHelper] 数据库创建失败: $e');
      AppLogger.error('[DatabaseHelper] 堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  /// 数据库升级回调
  /// 执行从旧版本到新版本的迁移
  /// 使用事务确保迁移的原子性
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    AppLogger.debug('[DatabaseHelper] 升级数据库: v$oldVersion -> v$newVersion');
    
    try {
      // 使用事务包装所有迁移脚本，确保原子性
      await db.transaction((txn) async {
        // 从旧版本+1到新版本，依次执行迁移
        for (int i = oldVersion + 1; i <= newVersion; i++) {
          final migration = DatabaseMigration.getMigration(i);
          if (migration != null) {
            AppLogger.debug('[DatabaseHelper] 执行迁移脚本 v$i，共 ${migration.length} 条SQL');
            for (final sql in migration) {
              await txn.execute(sql);
            }
          }
        }
      });
      
      AppLogger.info('[DatabaseHelper] 数据库升级成功');
    } catch (e, stackTrace) {
      AppLogger.error('[DatabaseHelper] 数据库升级失败: $e');
      AppLogger.error('[DatabaseHelper] 堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  /// 关闭数据库连接
  Future<void> close() async {
    if (_database != null) {
      try {
        await _database!.close();
        _database = null;
        _completer = null; // 重置 Completer
        AppLogger.info('[DatabaseHelper] 数据库连接已关闭');
      } catch (e) {
        AppLogger.error('[DatabaseHelper] 关闭数据库连接失败: $e');
        rethrow;
      }
    }
  }

  /// 重置数据库（用于测试或重置）
  /// 注意：此方法会删除所有数据，请谨慎使用
  Future<void> resetDatabase() async {
    try {
      final Directory documentsDirectory = await getApplicationDocumentsDirectory();
      final String path = join(documentsDirectory.path, _databaseName);
      
      AppLogger.debug('[DatabaseHelper] 开始重置数据库: $path');
      
      // 先关闭连接
      await close();
      
      // 删除数据库文件
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        AppLogger.info('[DatabaseHelper] 数据库文件已删除');
      }
      
      AppLogger.info('[DatabaseHelper] 数据库重置成功');
    } catch (e, stackTrace) {
      AppLogger.error('[DatabaseHelper] 重置数据库失败: $e');
      AppLogger.error('[DatabaseHelper] 堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  // ==================== 表名常量 ====================
  
  /// 用户表名
  static const String tableUsers = 'users';
  
  /// 交互记录表名
  static const String tableInteractions = 'interactions';
  
  /// 求职事件表名
  static const String tableJobEvents = 'job_events';
  
  /// 收藏职位表名
  static const String tableFavoriteJobs = 'favorite_jobs';
  
  /// 专栏购买记录表名
  static const String tablePurchasedColumns = 'purchased_columns';
  
  /// 专栏收藏记录表名
  static const String tableFavoriteColumns = 'favorite_columns';
  
  /// 通知消息表名
  static const String tableNotifications = 'notifications';
  
  /// 通知设置表名
  static const String tableNotificationSettings = 'notification_settings';

  // ==================== 用户表字段常量 ====================
  
  static const String columnUserId = 'user_id';
  static const String columnUserName = 'user_name';
  static const String columnJobIntention = 'job_intention';
  static const String columnCity = 'city';
  static const String columnSalaryExpect = 'salary_expect';
  static const String columnPetMemory = 'pet_memory';
  static const String columnVipStatus = 'vip_status';
  static const String columnVipExpireTime = 'vip_expire_time';
  static const String columnIsOnboarded = 'is_onboarded';
  static const String columnIndustryTag = 'industry_tag';
  static const String columnOnboardingReport = 'onboarding_report';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';

  // ==================== 交互记录表字段常量 ====================
  
  static const String columnId = 'id';
  static const String columnContent = 'content';
  static const String columnActionType = 'action_type';
  static const String columnEmotionType = 'emotion_type';
  static const String columnPetAction = 'pet_action';
  static const String columnPetBubble = 'pet_bubble';

  // ==================== 求职事件表字段常量 ====================
  
  static const String columnEventType = 'event_type';
  static const String columnEventContent = 'event_content';
  static const String columnCompanyName = 'company_name';
  static const String columnPositionName = 'position_name';
  static const String columnEventTime = 'event_time';

  // ==================== 收藏职位表字段常量 ====================
  
  static const String columnJobId = 'job_id';
  static const String columnJobTitle = 'job_title';
  static const String columnSalaryRange = 'salary_range';
  static const String columnJobLocation = 'job_location';
  static const String columnJobTags = 'job_tags';

  // ==================== 专栏购买记录表字段常量 ====================
  
  static const String columnColumnId = 'column_id';
  static const String columnPurchaseType = 'purchase_type';
  static const String columnPurchasePrice = 'purchase_price';
  static const String columnPurchasedAt = 'purchased_at';

  // ==================== 通知消息表字段常量 ====================
  
  static const String columnType = 'type';
  static const String columnTitle = 'title';
  static const String columnExtraData = 'extra_data';
  static const String columnIsRead = 'is_read';
  static const String columnIsActioned = 'is_actioned';
  static const String columnScheduledTime = 'scheduled_time';
  static const String columnSentAt = 'sent_at';

  // ==================== 通知设置表字段常量 ====================
  
  static const String columnInterviewEnabled = 'interview_enabled';
  static const String columnJobStatusEnabled = 'job_status_enabled';
  static const String columnColumnUpdateEnabled = 'column_update_enabled';
  static const String columnVipExpireEnabled = 'vip_expire_enabled';
  static const String columnActivityEnabled = 'activity_enabled';
  static const String columnSystemEnabled = 'system_enabled';
  static const String columnPushEnabled = 'push_enabled';
  static const String columnQuietHoursStart = 'quiet_hours_start';
  static const String columnQuietHoursEnd = 'quiet_hours_end';

  // ==================== 用户认证字段常量 ====================

  static const String columnAccount = 'account';
  static const String columnPassword = 'password';
  static const String columnIsLoggedIn = 'is_logged_in';
}
