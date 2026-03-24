import 'package:flutter/foundation.dart';
import '../../../data/repositories/notification_repository.dart';
import '../data/models/notification.dart';
import '../data/models/notification_settings.dart';

// ═══════════════════════════════════════════════════════════════════════════════
/// 通知核心服务
/// 负责处理通知相关的业务逻辑，包括通知管理、便捷创建方法、设置管理等
// ═══════════════════════════════════════════════════════════════════════════════
class NotificationService {
  // ────────────────────────────────────────────────────────────────────────────
  // 依赖注入
  // ────────────────────────────────────────────────────────────────────────────

  /// 通知仓库接口
  final NotificationRepository _repository;

  NotificationService({
    required NotificationRepository repository,
  }) : _repository = repository;

  // ────────────────────────────────────────────────────────────────────────────
  // 通知管理方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 获取单条通知
  /// [id] 通知ID
  /// 返回通知对象，不存在则返回null
  Future<Notification?> getNotification(String id) async {
    try {
      return await _repository.getNotification(id);
    } catch (e) {
      debugPrint('获取通知失败: $e');
      rethrow;
    }
  }

  /// 获取通知列表
  /// [userId] 用户ID
  /// [type] 通知类型，可选，不传则获取所有类型
  /// [isRead] 已读状态，可选，不传则获取所有状态
  /// 返回通知列表
  Future<List<Notification>> getNotifications(
    String userId, {
    NotificationType? type,
    bool? isRead,
  }) async {
    try {
      return await _repository.getNotifications(
        userId,
        type: type,
        isRead: isRead,
      );
    } catch (e) {
      debugPrint('获取通知列表失败: $e');
      rethrow;
    }
  }

  /// 创建通知
  /// [notification] 通知对象
  Future<void> createNotification(Notification notification) async {
    try {
      await _repository.createNotification(notification);
      debugPrint('通知创建成功: ${notification.id}');
    } catch (e) {
      debugPrint('创建通知失败: $e');
      rethrow;
    }
  }

  /// 标记通知为已读
  /// [id] 通知ID
  Future<void> markAsRead(String id) async {
    try {
      await _repository.markAsRead(id);
      debugPrint('通知已标记为已读: $id');
    } catch (e) {
      debugPrint('标记通知已读失败: $e');
      rethrow;
    }
  }

  /// 标记用户所有通知为已读
  /// [userId] 用户ID
  Future<void> markAllAsRead(String userId) async {
    try {
      await _repository.markAllAsRead(userId);
      debugPrint('用户所有通知已标记为已读: $userId');
    } catch (e) {
      debugPrint('标记所有通知已读失败: $e');
      rethrow;
    }
  }

  /// 获取用户未读通知数量
  /// [userId] 用户ID
  /// 返回未读数量
  Future<int> getUnreadCount(String userId) async {
    try {
      return await _repository.getUnreadCount(userId);
    } catch (e) {
      debugPrint('获取未读数量失败: $e');
      return 0;
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 通知创建便捷方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 创建面试提醒通知
  /// [userId] 用户ID
  /// [title] 通知标题
  /// [content] 通知内容
  /// [interviewTime] 面试时间
  /// [extraData] 额外数据，可选
  Future<void> createInterviewReminder(
    String userId,
    String title,
    String content,
    DateTime interviewTime, {
    Map<String, dynamic>? extraData,
  }) async {
    try {
      final notification = Notification(
        id: _generateNotificationId(),
        userId: userId,
        type: NotificationType.interview,
        title: title,
        content: content,
        extraData: {
          'interviewTime': interviewTime.toIso8601String(),
          ...?extraData,
        },
        scheduledTime: interviewTime,
        createdAt: DateTime.now(),
      );

      await createNotification(notification);
      debugPrint('面试提醒创建成功: $title');
    } catch (e) {
      debugPrint('创建面试提醒失败: $e');
      rethrow;
    }
  }

  /// 创建投递状态通知
  /// [userId] 用户ID
  /// [companyName] 公司名称
  /// [position] 职位名称
  /// [status] 投递状态
  Future<void> createJobStatusNotification(
    String userId,
    String companyName,
    String position,
    String status,
  ) async {
    try {
      final notification = Notification(
        id: _generateNotificationId(),
        userId: userId,
        type: NotificationType.jobStatus,
        title: '投递状态更新',
        content: '$companyName - $position 的投递状态已更新为: $status',
        extraData: {
          'companyName': companyName,
          'position': position,
          'status': status,
        },
        createdAt: DateTime.now(),
      );

      await createNotification(notification);
      debugPrint('投递状态通知创建成功: $companyName - $position');
    } catch (e) {
      debugPrint('创建投递状态通知失败: $e');
      rethrow;
    }
  }

  /// 创建专栏更新通知
  /// [userId] 用户ID
  /// [columnTitle] 专栏标题
  Future<void> createColumnUpdateNotification(
    String userId,
    String columnTitle,
  ) async {
    try {
      final notification = Notification(
        id: _generateNotificationId(),
        userId: userId,
        type: NotificationType.columnUpdate,
        title: '专栏更新',
        content: '您关注的专栏「$columnTitle」有新内容更新',
        extraData: {
          'columnTitle': columnTitle,
        },
        createdAt: DateTime.now(),
      );

      await createNotification(notification);
      debugPrint('专栏更新通知创建成功: $columnTitle');
    } catch (e) {
      debugPrint('创建专栏更新通知失败: $e');
      rethrow;
    }
  }

  /// 创建VIP到期通知
  /// [userId] 用户ID
  /// [expireDate] 到期日期
  Future<void> createVipExpireNotification(
    String userId,
    DateTime expireDate,
  ) async {
    try {
      final daysLeft = expireDate.difference(DateTime.now()).inDays;
      final content = daysLeft > 0
          ? '您的VIP会员将在${daysLeft}天后到期，请及时续费'
          : '您的VIP会员已到期，续费可继续享受会员权益';

      final notification = Notification(
        id: _generateNotificationId(),
        userId: userId,
        type: NotificationType.vipExpire,
        title: 'VIP会员到期提醒',
        content: content,
        extraData: {
          'expireDate': expireDate.toIso8601String(),
          'daysLeft': daysLeft,
        },
        createdAt: DateTime.now(),
      );

      await createNotification(notification);
      debugPrint('VIP到期通知创建成功: 用户$userId');
    } catch (e) {
      debugPrint('创建VIP到期通知失败: $e');
      rethrow;
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 通知设置方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 获取用户通知设置
  /// [userId] 用户ID
  /// 返回通知设置，不存在则创建默认设置
  Future<NotificationSettings> getSettings(String userId) async {
    try {
      // 尝试获取现有设置
      final settings = await _repository.getSettings(userId);

      if (settings != null) {
        return settings;
      }

      // 不存在则创建默认设置
      final defaultSettings = NotificationSettings.createDefault(
        _generateSettingsId(),
        userId,
      );

      await _repository.updateSettings(defaultSettings);
      debugPrint('创建默认通知设置: $userId');

      return defaultSettings;
    } catch (e) {
      debugPrint('获取通知设置失败: $e');
      rethrow;
    }
  }

  /// 更新用户通知设置
  /// [userId] 用户ID
  /// [settings] 通知设置对象
  Future<void> updateSettings(
    String userId,
    NotificationSettings settings,
  ) async {
    try {
      // settings 已经包含 userId，直接调用 repository
      await _repository.updateSettings(settings);
      debugPrint('通知设置更新成功: $userId');
    } catch (e) {
      debugPrint('更新通知设置失败: $e');
      rethrow;
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 辅助方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 生成通知ID
  /// 使用时间戳和随机数确保唯一性
  String _generateNotificationId() {
    return 'notification_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }

  /// 生成设置ID
  /// 使用时间戳确保唯一性
  String _generateSettingsId() {
    return 'settings_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// 检查通知类型是否启用
  /// [settings] 通知设置
  /// [type] 通知类型
  /// 返回是否启用
  bool isNotificationTypeEnabled(
    NotificationSettings settings,
    NotificationType type,
  ) {
    // 如果推送总开关关闭，则所有通知都不启用
    if (!settings.pushEnabled) {
      return false;
    }

    // 根据类型检查对应的开关
    switch (type) {
      case NotificationType.interview:
        return settings.interviewEnabled;
      case NotificationType.jobStatus:
        return settings.jobStatusEnabled;
      case NotificationType.columnUpdate:
        return settings.columnUpdateEnabled;
      case NotificationType.vipExpire:
        return settings.vipExpireEnabled;
      case NotificationType.activity:
        return settings.activityEnabled;
      case NotificationType.system:
        return settings.systemEnabled;
    }
  }

  /// 检查当前时间是否在免打扰时段
  /// [settings] 通知设置
  /// 返回是否在免打扰时段
  bool isInQuietHours(NotificationSettings settings) {
    // 如果没有设置免打扰时段，则不在免打扰时段
    if (settings.quietHoursStart == null || settings.quietHoursEnd == null) {
      return false;
    }

    try {
      final now = DateTime.now();
      final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      // 解析免打扰时间段
      final start = settings.quietHoursStart!;
      final end = settings.quietHoursEnd!;

      // 判断当前时间是否在免打扰时段
      if (start.compareTo(end) < 0) {
        // 不跨天的情况，例如 22:00 - 08:00
        return currentTime.compareTo(start) >= 0 && currentTime.compareTo(end) <= 0;
      } else {
        // 跨天的情况，例如 22:00 - 08:00
        return currentTime.compareTo(start) >= 0 || currentTime.compareTo(end) <= 0;
      }
    } catch (e) {
      debugPrint('检查免打扰时段失败: $e');
      return false;
    }
  }
}
