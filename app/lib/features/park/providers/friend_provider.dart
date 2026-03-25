import 'package:flutter/foundation.dart';
import '../data/models/models.dart';
import '../services/social_service.dart';

// ═══════════════════════════════════════════════════════════════════════════════
/// 好友状态管理
/// 负责好友列表、好友申请、好友关系等状态管理
// ═══════════════════════════════════════════════════════════════════════════════
class FriendProvider extends ChangeNotifier {
  // ────────────────────────────────────────────────────────────────────────────
  // 依赖注入
  // ────────────────────────────────────────────────────────────────────────────

  final SocialService _socialService;

  FriendProvider({required SocialService socialService}) : _socialService = socialService;

  // ────────────────────────────────────────────────────────────────────────────
  // 状态变量
  // ────────────────────────────────────────────────────────────────────────────

  /// 当前用户ID
  String? _currentUserId;
  String? get currentUserId => _currentUserId;

  /// 好友列表（已接受）
  List<Friend> _friends = [];
  List<Friend> get friends => _friends;

  /// 待处理的好友申请
  List<Friend> _pendingRequests = [];
  List<Friend> get pendingRequests => _pendingRequests;

  /// 是否加载中
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// 错误信息
  String? _error;
  String? get error => _error;

  // ────────────────────────────────────────────────────────────────────────────
  // 初始化方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 设置当前用户ID
  void setCurrentUserId(String userId) {
    _currentUserId = userId;
    notifyListeners();
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 加载方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 加载好友列表
  Future<void> loadFriends() async {
    if (_currentUserId == null) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // 并行加载好友和待处理申请
      final results = await Future.wait([
        _socialService.getFriends(_currentUserId!, status: FriendStatus.accepted),
        _socialService.getFriends(_currentUserId!, status: FriendStatus.pending),
      ]);
      
      _friends = results[0];
      _pendingRequests = results[1];
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      debugPrint('加载好友列表失败: $e');
      notifyListeners();
    }
  }

  /// 刷新好友列表
  Future<void> refresh() async {
    await loadFriends();
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 好友申请方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 发送好友申请
  /// [targetUserId] 目标用户ID
  /// [targetUserName] 目标用户昵称
  /// [targetUserTitle] 目标用户职位标签
  Future<bool> sendFriendRequest(
    String targetUserId,
    String targetUserName, {
    String? targetUserTitle,
  }) async {
    if (_currentUserId == null) return false;
    
    try {
      await _socialService.sendFriendRequest(
        _currentUserId!,
        targetUserId,
        targetUserName,
        targetUserTitle: targetUserTitle,
      );
      
      debugPrint('好友申请已发送: $targetUserName');
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      debugPrint('发送好友申请失败: $e');
      return false;
    }
  }

  /// 接受好友申请
  /// [friendId] 好友关系ID
  Future<bool> acceptRequest(String friendId) async {
    try {
      await _socialService.acceptFriendRequest(friendId);
      await loadFriends();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      debugPrint('接受好友申请失败: $e');
      return false;
    }
  }

  /// 拒绝好友申请
  /// [friendId] 好友关系ID
  Future<bool> rejectRequest(String friendId) async {
    try {
      await _socialService.rejectFriendRequest(friendId);
      await loadFriends();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      debugPrint('拒绝好友申请失败: $e');
      return false;
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 好友管理方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 删除好友
  /// [friendId] 好友ID
  Future<bool> removeFriend(String friendId) async {
    try {
      await _socialService.removeFriend(friendId);
      await loadFriends();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      debugPrint('删除好友失败: $e');
      return false;
    }
  }

  /// 检查是否为好友
  /// [targetUserId] 目标用户ID
  Future<bool> isFriend(String targetUserId) async {
    if (_currentUserId == null) return false;
    return await _socialService.isFriend(_currentUserId!, targetUserId);
  }

  /// 获取好友数量
  int get friendCount => _friends.length;

  /// 获取待处理申请数量
  int get pendingCount => _pendingRequests.length;

  /// 根据ID获取好友
  Friend? getFriendById(String friendId) {
    try {
      return _friends.firstWhere((f) => f.friendId == friendId);
    } catch (e) {
      return null;
    }
  }

  /// 根据名称搜索好友
  List<Friend> searchFriends(String keyword) {
    if (keyword.isEmpty) return _friends;
    
    return _friends.where((friend) {
      return friend.friendName.contains(keyword) ||
          (friend.friendTitle?.contains(keyword) ?? false);
    }).toList();
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 工具方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// 清除所有数据
  void clear() {
    _friends = [];
    _pendingRequests = [];
    _currentUserId = null;
    _error = null;
    notifyListeners();
  }
}
