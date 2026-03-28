import 'package:flutter/foundation.dart';
import '../../../data/repositories/user_repository.dart';
import '../../notifications/services/notification_service.dart';
import '../../notifications/data/models/notification.dart';

/// 公园解锁来源枚举
enum ParkUnlockSource {
  /// 通过获得Offer解锁
  offer,
  /// 手动解锁（管理员操作）
  manual,
  /// Pro VIP用户提前解锁
  proVip,
}

/// 公园解锁服务
/// 负责处理公园解锁逻辑、解锁状态检查、解锁通知等
class ParkUnlockService extends ChangeNotifier {
  // ────────────────────────────────────────────────────────────────────────────
  // 单例模式
  // ────────────────────────────────────────────────────────────────────────────

  static final ParkUnlockService _instance = ParkUnlockService._internal();
  factory ParkUnlockService() => _instance;
  ParkUnlockService._internal();

  // ────────────────────────────────────────────────────────────────────────────
  // 依赖注入
  // ────────────────────────────────────────────────────────────────────────────

  UserRepository? _userRepository;
  NotificationService? _notificationService;

  /// 初始化服务
  /// [userRepository] 用户仓库
  /// [notificationService] 通知服务（可选）
  void initialize({
    required UserRepository userRepository,
    NotificationService? notificationService,
  }) {
    _userRepository = userRepository;
    _notificationService = notificationService;
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 状态变量
  // ────────────────────────────────────────────────────────────────────────────

  /// 缓存的解锁状态
  final Map<String, bool> _unlockCache = {};

  /// 解锁回调列表
  final List<void Function(String userId, String source)> _unlockCallbacks = [];

  // ────────────────────────────────────────────────────────────────────────────
  // 公开方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 检查公园是否已解锁
  /// [userId] 用户ID
  /// 返回解锁状态，如果无法获取则返回false
  Future<bool> isParkUnlocked(String userId) async {
    // 先检查缓存
    if (_unlockCache.containsKey(userId)) {
      return _unlockCache[userId]!;
    }

    // 从数据库获取
    if (_userRepository == null) {
      debugPrint('[ParkUnlockService] 服务未初始化');
      return false;
    }

    try {
      final isUnlocked = await _userRepository!.isParkUnlocked(userId);
      _unlockCache[userId] = isUnlocked;
      return isUnlocked;
    } catch (e) {
      debugPrint('[ParkUnlockService] 检查解锁状态失败: $e');
      return false;
    }
  }

  /// 检查并解锁公园
  /// 当用户获得Offer时调用此方法
  /// [userId] 用户ID
  /// [eventType] 事件类型（offer, interview等）
  /// 返回是否执行了解锁操作
  Future<bool> checkAndUnlock(String userId, String eventType) async {
    // 只处理Offer事件
    if (eventType.toLowerCase() != 'offer') {
      return false;
    }

    // 检查是否已解锁
    final isUnlocked = await isParkUnlocked(userId);
    if (isUnlocked) {
      debugPrint('[ParkUnlockService] 公园已解锁，跳过');
      return false;
    }

    // 执行解锁
    return await unlockPark(userId, source: ParkUnlockSource.offer);
  }

  /// 解锁公园
  /// [userId] 用户ID
  /// [source] 解锁来源
  /// 返回是否解锁成功
  Future<bool> unlockPark(
    String userId, {
    ParkUnlockSource source = ParkUnlockSource.offer,
  }) async {
    if (_userRepository == null) {
      debugPrint('[ParkUnlockService] 服务未初始化');
      return false;
    }

    try {
      // 更新数据库
      await _userRepository!.unlockPark(
        userId,
        source: source.name,
      );

      // 更新缓存
      _unlockCache[userId] = true;

      // 发送通知
      await _sendUnlockNotification(userId, source);

      // 触发回调
      for (final callback in _unlockCallbacks) {
        callback(userId, source.name);
      }

      // 通知监听者
      notifyListeners();

      debugPrint('[ParkUnlockService] 公园解锁成功: $userId, 来源: ${source.name}');
      return true;
    } catch (e) {
      debugPrint('[ParkUnlockService] 解锁公园失败: $e');
      return false;
    }
  }

  /// 清除缓存
  /// 用于用户登出时清除缓存
  void clearCache(String userId) {
    _unlockCache.remove(userId);
  }

  /// 清除所有缓存
  void clearAllCache() {
    _unlockCache.clear();
  }

  /// 添加解锁回调
  /// 当公园解锁成功时会调用此回调
  void addUnlockCallback(void Function(String userId, String source) callback) {
    _unlockCallbacks.add(callback);
  }

  /// 移除解锁回调
  void removeUnlockCallback(void Function(String userId, String source) callback) {
    _unlockCallbacks.remove(callback);
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 私有方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 发送解锁通知
  Future<void> _sendUnlockNotification(String userId, ParkUnlockSource source) async {
    if (_notificationService == null) {
      debugPrint('[ParkUnlockService] 通知服务未初始化，跳过通知');
      return;
    }

    try {
      final notification = Notification(
        id: 'park_unlock_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        type: NotificationType.activity,
        title: '🎉 公园已解锁！',
        content: '恭喜你获得Offer！彼岸公园已为你开放，快去看看吧！',
        extraData: {
          'unlock_source': source.name,
          'unlock_time': DateTime.now().toIso8601String(),
        },
        createdAt: DateTime.now(),
      );
      
      await _notificationService!.createNotification(notification);
    } catch (e) {
      debugPrint('[ParkUnlockService] 发送解锁通知失败: $e');
    }
  }
}
