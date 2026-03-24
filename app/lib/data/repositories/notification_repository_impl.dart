import '../datasources/local/notification_local_datasource.dart';
import '../../features/notifications/data/models/notification.dart';
import '../../features/notifications/data/models/notification_settings.dart';
import 'notification_repository.dart';

// ═══════════════════════════════════════════════════════════════════════════════
/// 通知仓库实现
/// 封装数据源操作，提供统一的业务逻辑接口
// ═══════════════════════════════════════════════════════════════════════════════
class NotificationRepositoryImpl implements NotificationRepository {
  // ═══════════════════════════════════════════════════════════════════════════════
  // 依赖注入
  // ═══════════════════════════════════════════════════════════════════════════════

  /// 本地数据源实例
  final NotificationLocalDatasource _localDatasource;

  /// 构造函数
  /// [localDatasource] 本地数据源，默认使用SQLite实现
  NotificationRepositoryImpl({NotificationLocalDatasource? localDatasource})
      : _localDatasource =
            localDatasource ?? SqliteNotificationLocalDatasource();

  // ═══════════════════════════════════════════════════════════════════════════════
  // 通知消息相关操作实现
  // ═══════════════════════════════════════════════════════════════════════════════

  @override
  Future<Notification?> getNotification(String id) async {
    try {
      return await _localDatasource.getNotification(id);
    } catch (e) {
      print('[NotificationRepositoryImpl] 获取通知消息失败: $e');
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
      return await _localDatasource.getNotifications(
        userId,
        type: type,
        isRead: isRead,
      );
    } catch (e) {
      print('[NotificationRepositoryImpl] 获取通知列表失败: $e');
      rethrow;
    }
  }

  @override
  Future<void> createNotification(Notification notification) async {
    try {
      await _localDatasource.saveNotification(notification);
    } catch (e) {
      print('[NotificationRepositoryImpl] 创建通知消息失败: $e');
      rethrow;
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    try {
      await _localDatasource.markAsRead(id);
    } catch (e) {
      print('[NotificationRepositoryImpl] 标记通知已读失败: $e');
      rethrow;
    }
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    try {
      await _localDatasource.markAllAsRead(userId);
    } catch (e) {
      print('[NotificationRepositoryImpl] 标记所有通知已读失败: $e');
      rethrow;
    }
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    try {
      return await _localDatasource.getUnreadCount(userId);
    } catch (e) {
      print('[NotificationRepositoryImpl] 获取未读数量失败: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteNotification(String id) async {
    try {
      await _localDatasource.deleteNotification(id);
    } catch (e) {
      print('[NotificationRepositoryImpl] 删除通知消息失败: $e');
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  // 通知设置相关操作实现
  // ═══════════════════════════════════════════════════════════════════════════════

  @override
  Future<NotificationSettings?> getSettings(String userId) async {
    try {
      // 使用getOrCreateSettings确保总是返回设置
      // 如果不存在则创建默认设置
      return await _localDatasource.getOrCreateSettings(userId);
    } catch (e) {
      print('[NotificationRepositoryImpl] 获取通知设置失败: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateSettings(NotificationSettings settings) async {
    try {
      // 更新设置时，同时更新updatedAt时间戳
      final updatedSettings = settings.copyWith(
        updatedAt: DateTime.now(),
      );

      await _localDatasource.saveSettings(updatedSettings);
    } catch (e) {
      print('[NotificationRepositoryImpl] 更新通知设置失败: $e');
      rethrow;
    }
  }
}
