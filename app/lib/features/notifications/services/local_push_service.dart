import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../data/models/notification.dart';

// ═══════════════════════════════════════════════════════════════════════════════
/// 本地推送通知服务
/// 负责管理本地通知的发送、定时、取消等功能
/// 支持 Android 和 iOS 双平台
// ═══════════════════════════════════════════════════════════════════════════════
class LocalPushService {
  // ────────────────────────────────────────────────────────────────────────────
  // 单例模式
  // ────────────────────────────────────────────────────────────────────────────

  static final LocalPushService _instance = LocalPushService._internal();
  factory LocalPushService() => _instance;
  LocalPushService._internal();

  // ────────────────────────────────────────────────────────────────────────────
  // 依赖注入
  // ────────────────────────────────────────────────────────────────────────────

  /// Flutter 本地通知插件实例
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// 是否已初始化
  bool _isInitialized = false;

  // ────────────────────────────────────────────────────────────────────────────
  // 初始化方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 初始化推送服务
  /// 
  /// 配置 Android 和 iOS 平台的通知设置
  /// 初始化时区数据库（用于定时通知）
  /// 请求通知权限
  /// 
  /// 返回是否初始化成功
  Future<bool> initialize() async {
    try {
      if (_isInitialized) {
        debugPrint('本地推送服务已经初始化');
        return true;
      }

      // 初始化时区数据库
      tz_data.initializeTimeZones();
      debugPrint('时区数据库初始化成功');

      // 配置 Android 通知设置
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      // 配置 iOS 通知设置
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false, // 稍后手动请求权限
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      // 合并平台设置
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // 初始化插件
      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      _isInitialized = true;
      debugPrint('本地推送服务初始化成功');

      // 请求权限
      await requestPermission();

      return true;
    } catch (e) {
      debugPrint('本地推送服务初始化失败: $e');
      return false;
    }
  }

  /// 通知点击回调
  /// 
  /// 当用户点击通知时触发
  /// [response] 通知响应数据，包含 payload 等信息
  void _onNotificationTapped(NotificationResponse response) {
    try {
      final payload = response.payload;
      debugPrint('通知被点击: payload = $payload');

      // TODO: 根据payload跳转到对应页面
      // 例如：面试提醒 -> 跳转到面试详情页
      // 例如：投递状态更新 -> 跳转到投递记录页
      // 这里可以通过事件总线或导航服务处理跳转逻辑
    } catch (e) {
      debugPrint('处理通知点击失败: $e');
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 权限请求方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 请求通知权限
  /// 
  /// Android 13+ 需要请求通知权限
  /// iOS 需要请求通知权限、徽章、声音等权限
  /// 
  /// 返回是否授权成功
  Future<bool> requestPermission() async {
    try {
      bool granted = false;

      if (Platform.isAndroid) {
        // Android 请求权限
        final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

        if (androidPlugin != null) {
          granted = await androidPlugin.requestNotificationsPermission() ?? false;
        }
      } else if (Platform.isIOS) {
        // iOS 请求权限
        final iosPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

        if (iosPlugin != null) {
          granted = await iosPlugin.requestPermissions(
            alert: true,  // 通知提醒
            badge: true,  // 应用图标徽章
            sound: true,  // 通知声音
          ) ?? false;
        }
      }

      debugPrint('通知权限请求结果: ${granted ? "已授权" : "未授权"}');
      return granted;
    } catch (e) {
      debugPrint('请求通知权限失败: $e');
      return false;
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 立即通知方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 立即发送通知
  /// 
  /// [id] 通知唯一标识ID，用于后续取消或更新通知
  /// [title] 通知标题
  /// [body] 通知内容
  /// [payload] 通知携带的数据，点击通知时可以获取
  /// [type] 通知类型，用于配置不同的通知样式
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    NotificationType? type,
  }) async {
    try {
      // 获取通知详情配置
      final details = await _getNotificationDetails(type);

      // 显示通知
      await _notificationsPlugin.show(
        id,
        title,
        body,
        details,
        payload: payload,
      );

      debugPrint('立即通知发送成功: id=$id, title=$title');
    } catch (e) {
      debugPrint('发送立即通知失败: $e');
      rethrow;
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 定时通知方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 定时发送通知
  /// 
  /// [id] 通知唯一标识ID
  /// [title] 通知标题
  /// [body] 通知内容
  /// [scheduledTime] 定时发送时间
  /// [payload] 通知携带的数据
  /// [type] 通知类型
  /// 
  /// 注意：iOS 需要配置后台模式才能在应用未运行时触发定时通知
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
    NotificationType? type,
  }) async {
    try {
      // 获取通知详情配置
      final details = await _getNotificationDetails(type);

      // 转换为本地时区时间
      final scheduledDate = tz.TZDateTime.from(
        scheduledTime,
        tz.local,
      );

      // 定时通知
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        // Android 使用精确时间，允许在低电量模式下触发
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        // iOS 使用绝对时间
        payload: payload,
      );

      debugPrint('定时通知创建成功: id=$id, time=$scheduledTime');
    } catch (e) {
      debugPrint('创建定时通知失败: $e');
      rethrow;
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 取消通知方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 取消指定通知
  /// 
  /// [id] 通知ID
  Future<void> cancelNotification(int id) async {
    try {
      await _notificationsPlugin.cancel(id);
      debugPrint('通知已取消: id=$id');
    } catch (e) {
      debugPrint('取消通知失败: $e');
      rethrow;
    }
  }

  /// 取消所有通知
  /// 
  /// 包括立即通知和定时通知
  Future<void> cancelAllNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
      debugPrint('所有通知已取消');
    } catch (e) {
      debugPrint('取消所有通知失败: $e');
      rethrow;
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 查询方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 获取待发送的通知列表
  /// 
  /// 返回所有已定时但尚未发送的通知
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      final pendingNotifications =
          await _notificationsPlugin.pendingNotificationRequests();
      debugPrint('待发送通知数量: ${pendingNotifications.length}');
      return pendingNotifications;
    } catch (e) {
      debugPrint('获取待发送通知列表失败: $e');
      return [];
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 辅助方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 获取通知详情配置
  /// 
  /// 根据通知类型返回不同的通知样式配置
  /// [type] 通知类型
  /// 返回通知详情对象
  Future<NotificationDetails> _getNotificationDetails(NotificationType? type) async {
    // 获取通知渠道ID和名称
    final channelId = _getChannelId(type);
    final channelName = _getChannelName(type);
    final channelDescription = _getChannelDescription(type);

    // 配置 Android 通知详情
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: _getImportance(type),
      priority: _getPriority(type),
      showWhen: true, // 显示通知时间
      enableVibration: true, // 启用振动
      playSound: true, // 播放声音
      icon: '@mipmap/ic_launcher', // 通知图标
    );

    // 配置 iOS 通知详情
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true, // 显示提醒
      presentBadge: true, // 显示徽章
      presentSound: true, // 播放声音
    );

    return NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }

  /// 获取通知渠道ID
  /// 
  /// Android 8.0+ 需要为不同类型的通知创建不同的渠道
  String _getChannelId(NotificationType? type) {
    switch (type) {
      case NotificationType.interview:
        return 'interview_channel';
      case NotificationType.jobStatus:
        return 'job_status_channel';
      case NotificationType.columnUpdate:
        return 'column_update_channel';
      case NotificationType.vipExpire:
        return 'vip_expire_channel';
      case NotificationType.activity:
        return 'activity_channel';
      case NotificationType.system:
        return 'system_channel';
      default:
        return 'default_channel';
    }
  }

  /// 获取通知渠道名称
  /// 
  /// 用户可以在系统设置中看到渠道名称
  String _getChannelName(NotificationType? type) {
    switch (type) {
      case NotificationType.interview:
        return '面试提醒';
      case NotificationType.jobStatus:
        return '投递状态';
      case NotificationType.columnUpdate:
        return '专栏更新';
      case NotificationType.vipExpire:
        return 'VIP提醒';
      case NotificationType.activity:
        return '活动通知';
      case NotificationType.system:
        return '系统公告';
      default:
        return '默认通知';
    }
  }

  /// 获取通知渠道描述
  String _getChannelDescription(NotificationType? type) {
    switch (type) {
      case NotificationType.interview:
        return '面试时间提醒通知';
      case NotificationType.jobStatus:
        return '投递状态更新通知';
      case NotificationType.columnUpdate:
        return '专栏内容更新通知';
      case NotificationType.vipExpire:
        return 'VIP会员到期提醒';
      case NotificationType.activity:
        return '活动相关通知';
      case NotificationType.system:
        return '系统公告和重要通知';
      default:
        return '应用通知';
    }
  }

  /// 获取通知重要性
  /// 
  /// 不同类型的通知有不同的重要性级别
  Importance _getImportance(NotificationType? type) {
    switch (type) {
      case NotificationType.interview:
      case NotificationType.vipExpire:
        return Importance.high; // 高重要性，会弹出通知
      case NotificationType.jobStatus:
      case NotificationType.columnUpdate:
      case NotificationType.activity:
        return Importance.defaultImportance; // 默认重要性
      case NotificationType.system:
        return Importance.max; // 最高重要性
      default:
        return Importance.defaultImportance;
    }
  }

  /// 获取通知优先级
  /// 
  /// 不同类型的通知有不同的优先级
  Priority _getPriority(NotificationType? type) {
    switch (type) {
      case NotificationType.interview:
      case NotificationType.vipExpire:
        return Priority.high;
      case NotificationType.jobStatus:
      case NotificationType.columnUpdate:
      case NotificationType.activity:
        return Priority.defaultPriority;
      case NotificationType.system:
        return Priority.max;
      default:
        return Priority.defaultPriority;
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 业务便捷方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 创建面试提醒通知（提前1天和1小时）
  /// 
  /// [interviewId] 面试ID
  /// [companyName] 公司名称
  /// [position] 职位名称
  /// [interviewTime] 面试时间
  Future<void> scheduleInterviewReminders({
    required String interviewId,
    required String companyName,
    required String position,
    required DateTime interviewTime,
  }) async {
    try {
      // 提前1天提醒
      final oneDayBefore = interviewTime.subtract(const Duration(days: 1));
      if (oneDayBefore.isAfter(DateTime.now())) {
        await scheduleNotification(
          id: '${interviewId}_1day'.hashCode,
          title: '面试提醒',
          body: '明天 ${_formatTime(interviewTime)} 您将参加 $companyName 的 $position 面试',
          scheduledTime: oneDayBefore,
          payload: 'interview:$interviewId',
          type: NotificationType.interview,
        );
      }

      // 提前1小时提醒
      final oneHourBefore = interviewTime.subtract(const Duration(hours: 1));
      if (oneHourBefore.isAfter(DateTime.now())) {
        await scheduleNotification(
          id: '${interviewId}_1hour'.hashCode,
          title: '面试即将开始',
          body: '1小时后您将参加 $companyName 的 $position 面试，请做好准备',
          scheduledTime: oneHourBefore,
          payload: 'interview:$interviewId',
          type: NotificationType.interview,
        );
      }

      debugPrint('面试提醒创建成功: $companyName - $position');
    } catch (e) {
      debugPrint('创建面试提醒失败: $e');
      rethrow;
    }
  }

  /// 发送投递状态更新通知（立即发送）
  /// 
  /// [companyName] 公司名称
  /// [position] 职位名称
  /// [status] 投递状态
  Future<void> showJobStatusNotification({
    required String companyName,
    required String position,
    required String status,
  }) async {
    try {
      await showNotification(
        id: DateTime.now().millisecondsSinceEpoch,
        title: '投递状态更新',
        body: '$companyName - $position 的投递状态已更新为: $status',
        payload: 'job_status:$companyName:$position',
        type: NotificationType.jobStatus,
      );

      debugPrint('投递状态通知发送成功: $companyName - $position');
    } catch (e) {
      debugPrint('发送投递状态通知失败: $e');
      rethrow;
    }
  }

  /// 发送专栏更新通知（立即发送）
  /// 
  /// [columnTitle] 专栏标题
  /// [articleTitle] 文章标题
  Future<void> showColumnUpdateNotification({
    required String columnTitle,
    required String articleTitle,
  }) async {
    try {
      await showNotification(
        id: DateTime.now().millisecondsSinceEpoch,
        title: '专栏更新',
        body: '您关注的专栏「$columnTitle」发布了新文章: $articleTitle',
        payload: 'column:$columnTitle',
        type: NotificationType.columnUpdate,
      );

      debugPrint('专栏更新通知发送成功: $columnTitle');
    } catch (e) {
      debugPrint('发送专栏更新通知失败: $e');
      rethrow;
    }
  }

  /// 创建VIP到期提醒（提前3天）
  /// 
  /// [userId] 用户ID
  /// [expireDate] 到期日期
  Future<void> scheduleVipExpireReminder({
    required String userId,
    required DateTime expireDate,
  }) async {
    try {
      // 提前3天提醒
      final threeDaysBefore = expireDate.subtract(const Duration(days: 3));
      
      if (threeDaysBefore.isAfter(DateTime.now())) {
        await scheduleNotification(
          id: 'vip_expire_$userId'.hashCode,
          title: 'VIP会员到期提醒',
          body: '您的VIP会员将在3天后到期，续费可继续享受会员权益',
          scheduledTime: threeDaysBefore,
          payload: 'vip:$userId',
          type: NotificationType.vipExpire,
        );
      }

      debugPrint('VIP到期提醒创建成功: 用户$userId');
    } catch (e) {
      debugPrint('创建VIP到期提醒失败: $e');
      rethrow;
    }
  }

  /// 发送活动通知（按配置时间发送）
  /// 
  /// [activityId] 活动ID
  /// [title] 活动标题
  /// [content] 活动内容
  /// [scheduledTime] 发送时间
  Future<void> scheduleActivityNotification({
    required String activityId,
    required String title,
    required String content,
    required DateTime scheduledTime,
  }) async {
    try {
      await scheduleNotification(
        id: 'activity_$activityId'.hashCode,
        title: title,
        body: content,
        scheduledTime: scheduledTime,
        payload: 'activity:$activityId',
        type: NotificationType.activity,
      );

      debugPrint('活动通知创建成功: $title');
    } catch (e) {
      debugPrint('创建活动通知失败: $e');
      rethrow;
    }
  }

  /// 发送系统公告（立即发送）
  /// 
  /// [announcementId] 公告ID
  /// [title] 公告标题
  /// [content] 公告内容
  Future<void> showSystemAnnouncement({
    required String announcementId,
    required String title,
    required String content,
  }) async {
    try {
      await showNotification(
        id: 'system_$announcementId'.hashCode,
        title: title,
        body: content,
        payload: 'system:$announcementId',
        type: NotificationType.system,
      );

      debugPrint('系统公告发送成功: $title');
    } catch (e) {
      debugPrint('发送系统公告失败: $e');
      rethrow;
    }
  }

  /// 格式化时间显示
  /// 
  /// [dateTime] 日期时间
  /// 返回格式化后的时间字符串
  String _formatTime(DateTime dateTime) {
    return '${dateTime.month}月${dateTime.day}日 ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
