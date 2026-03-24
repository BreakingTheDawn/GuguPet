import 'package:flutter/foundation.dart';
import '../data/models/notification.dart';
import '../data/models/notification_settings.dart';
import '../services/notification_service.dart';

// ═══════════════════════════════════════════════════════════════════════════════
/// 通知状态管理Provider
/// 负责管理通知相关状态，包括通知列表、设置、加载状态等
// ═══════════════════════════════════════════════════════════════════════════════
class NotificationProvider extends ChangeNotifier {
  // ────────────────────────────────────────────────────────────────────────────
  // 依赖注入
  // ────────────────────────────────────────────────────────────────────────────

  /// 通知业务服务
  final NotificationService _notificationService;

  NotificationProvider({
    required NotificationService notificationService,
  }) : _notificationService = notificationService;

  // ────────────────────────────────────────────────────────────────────────────
  // 状态变量
  // ────────────────────────────────────────────────────────────────────────────

  /// 通知列表
  List<Notification> _notifications = [];

  /// 通知设置
  NotificationSettings? _settings;

  /// 是否正在加载
  bool _isLoading = false;

  /// 错误信息
  String? _errorMessage;

  /// 当前筛选的通知类型
  NotificationType? _selectedType;

  /// 当前用户ID
  String _userId = 'default_user';

  /// 未读通知数量
  int _unreadCount = 0;

  // ────────────────────────────────────────────────────────────────────────────
  // Getter方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 获取通知列表
  List<Notification> get notifications => _notifications;

  /// 获取通知设置
  NotificationSettings? get settings => _settings;

  /// 获取加载状态
  bool get isLoading => _isLoading;

  /// 获取错误信息
  String? get errorMessage => _errorMessage;

  /// 获取当前筛选类型
  NotificationType? get selectedType => _selectedType;

  /// 获取用户ID
  String get userId => _userId;

  /// 获取未读数量
  int get unreadCount => _unreadCount;

  /// 获取筛选后的通知列表
  List<Notification> get filteredNotifications {
    if (_selectedType == null) {
      return _notifications;
    }
    return _notifications.where((n) => n.type == _selectedType).toList();
  }

  /// 获取未读通知列表
  List<Notification> get unreadNotifications {
    return _notifications.where((n) => !n.isRead).toList();
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 通知加载方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 加载通知列表
  /// [userId] 用户ID
  /// [type] 通知类型，可选，不传则加载所有类型
  Future<void> loadNotifications(
    String userId, {
    NotificationType? type,
  }) async {
    // 设置加载状态
    _isLoading = true;
    _errorMessage = null;
    _userId = userId;
    _selectedType = type;
    notifyListeners();

    try {
      // 获取通知列表
      final notifications = await _notificationService.getNotifications(
        userId,
        type: type,
      );

      // 按创建时间倒序排序
      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // 更新状态
      _notifications = notifications;
      _isLoading = false;

      // 更新未读数量
      await _updateUnreadCount();

      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = '加载通知失败: $e';
      debugPrint('NotificationProvider Error: $e');
      notifyListeners();
    }
  }

  /// 刷新通知列表
  Future<void> refreshNotifications() async {
    await loadNotifications(_userId, type: _selectedType);
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 通知操作方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 创建通知
  /// [notification] 通知对象
  Future<void> createNotification(Notification notification) async {
    try {
      await _notificationService.createNotification(notification);

      // 添加到列表开头
      _notifications.insert(0, notification);
      notifyListeners();

      debugPrint('通知创建成功: ${notification.title}');
    } catch (e) {
      _errorMessage = '创建通知失败: $e';
      debugPrint('创建通知失败: $e');
      notifyListeners();
      rethrow;
    }
  }

  /// 标记通知为已读
  /// [id] 通知ID
  Future<void> markAsRead(String id) async {
    try {
      // 调用服务标记已读
      await _notificationService.markAsRead(id);

      // 更新本地状态
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        _unreadCount = (_unreadCount > 0) ? _unreadCount - 1 : 0;
        notifyListeners();
      }

      debugPrint('通知已标记为已读: $id');
    } catch (e) {
      _errorMessage = '标记已读失败: $e';
      debugPrint('标记已读失败: $e');
      notifyListeners();
      rethrow;
    }
  }

  /// 标记所有通知为已读
  Future<void> markAllAsRead() async {
    try {
      // 调用服务标记所有已读
      await _notificationService.markAllAsRead(_userId);

      // 更新本地状态
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      _unreadCount = 0;
      notifyListeners();

      debugPrint('所有通知已标记为已读');
    } catch (e) {
      _errorMessage = '标记所有已读失败: $e';
      debugPrint('标记所有已读失败: $e');
      notifyListeners();
      rethrow;
    }
  }

  /// 更新未读数量
  Future<void> _updateUnreadCount() async {
    try {
      _unreadCount = await _notificationService.getUnreadCount(_userId);
      notifyListeners();
    } catch (e) {
      debugPrint('更新未读数量失败: $e');
    }
  }

  /// 刷新未读数量
  Future<void> refreshUnreadCount() async {
    await _updateUnreadCount();
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 通知设置方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 加载通知设置
  /// [userId] 用户ID
  Future<void> loadSettings(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    _userId = userId;
    notifyListeners();

    try {
      final settings = await _notificationService.getSettings(userId);
      _settings = settings;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = '加载通知设置失败: $e';
      debugPrint('加载通知设置失败: $e');
      notifyListeners();
    }
  }

  /// 更新通知设置
  /// [settings] 通知设置对象
  Future<void> updateSettings(NotificationSettings settings) async {
    try {
      await _notificationService.updateSettings(_userId, settings);
      _settings = settings.copyWith(updatedAt: DateTime.now());
      notifyListeners();

      debugPrint('通知设置更新成功');
    } catch (e) {
      _errorMessage = '更新通知设置失败: $e';
      debugPrint('更新通知设置失败: $e');
      notifyListeners();
      rethrow;
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 筛选和清理方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 按类型筛选通知
  /// [type] 通知类型，传null则显示所有类型
  void filterByType(NotificationType? type) {
    _selectedType = type;
    notifyListeners();
  }

  /// 清除错误信息
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// 清除所有数据
  void clear() {
    _notifications = [];
    _settings = null;
    _isLoading = false;
    _errorMessage = null;
    _selectedType = null;
    _unreadCount = 0;
    notifyListeners();
  }

  /// 设置用户ID
  void setUserId(String userId) {
    _userId = userId;
    notifyListeners();
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 便捷创建通知方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 创建面试提醒通知
  /// [title] 通知标题
  /// [content] 通知内容
  /// [interviewTime] 面试时间
  /// [extraData] 额外数据，可选
  Future<void> createInterviewReminder(
    String title,
    String content,
    DateTime interviewTime, {
    Map<String, dynamic>? extraData,
  }) async {
    try {
      await _notificationService.createInterviewReminder(
        _userId,
        title,
        content,
        interviewTime,
        extraData: extraData,
      );

      // 刷新通知列表
      await refreshNotifications();
    } catch (e) {
      debugPrint('创建面试提醒失败: $e');
      rethrow;
    }
  }

  /// 创建投递状态通知
  /// [companyName] 公司名称
  /// [position] 职位名称
  /// [status] 投递状态
  Future<void> createJobStatusNotification(
    String companyName,
    String position,
    String status,
  ) async {
    try {
      await _notificationService.createJobStatusNotification(
        _userId,
        companyName,
        position,
        status,
      );

      // 刷新通知列表
      await refreshNotifications();
    } catch (e) {
      debugPrint('创建投递状态通知失败: $e');
      rethrow;
    }
  }

  /// 创建专栏更新通知
  /// [columnTitle] 专栏标题
  Future<void> createColumnUpdateNotification(String columnTitle) async {
    try {
      await _notificationService.createColumnUpdateNotification(
        _userId,
        columnTitle,
      );

      // 刷新通知列表
      await refreshNotifications();
    } catch (e) {
      debugPrint('创建专栏更新通知失败: $e');
      rethrow;
    }
  }

  /// 创建VIP到期通知
  /// [expireDate] 到期日期
  Future<void> createVipExpireNotification(DateTime expireDate) async {
    try {
      await _notificationService.createVipExpireNotification(
        _userId,
        expireDate,
      );

      // 刷新通知列表
      await refreshNotifications();
    } catch (e) {
      debugPrint('创建VIP到期通知失败: $e');
      rethrow;
    }
  }
}
