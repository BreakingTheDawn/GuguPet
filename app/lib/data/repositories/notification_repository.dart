import '../../features/notifications/data/models/notification.dart';
import '../../features/notifications/data/models/notification_settings.dart';

// ═══════════════════════════════════════════════════════════════════════════════
/// 通知仓库接口
/// 定义通知消息和通知设置的业务操作
// ═══════════════════════════════════════════════════════════════════════════════
abstract class NotificationRepository {
  // ────────────────────────────────────────────────────────────────────────────
  // 通知消息操作
  // ────────────────────────────────────────────────────────────────────────────

  /// 获取单条通知消息
  /// [id] 通知ID
  /// 返回通知消息，不存在则返回null
  Future<Notification?> getNotification(String id);

  /// 获取通知消息列表
  /// [userId] 用户ID
  /// [type] 可选的通知类型过滤
  /// [isRead] 可选的已读状态过滤
  /// 返回通知消息列表
  Future<List<Notification>> getNotifications(
    String userId, {
    NotificationType? type,
    bool? isRead,
  });

  /// 创建通知消息
  /// [notification] 通知消息数据
  Future<void> createNotification(Notification notification);

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

  // ────────────────────────────────────────────────────────────────────────────
  // 通知设置操作
  // ────────────────────────────────────────────────────────────────────────────

  /// 获取用户通知设置
  /// [userId] 用户ID
  /// 返回通知设置，不存在则返回null
  Future<NotificationSettings?> getSettings(String userId);

  /// 更新通知设置
  /// [settings] 通知设置数据
  Future<void> updateSettings(NotificationSettings settings);
}
