import 'package:flutter/foundation.dart';
import '../data/models/models.dart';
import '../services/social_service.dart';

// ═══════════════════════════════════════════════════════════════════════════════
/// 公园状态管理
/// 负责公园区域、用户列表、互动等状态管理
// ═══════════════════════════════════════════════════════════════════════════════
class ParkProvider extends ChangeNotifier {
  // ────────────────────────────────────────────────────────────────────────────
  // 依赖注入
  // ────────────────────────────────────────────────────────────────────────────

  final SocialService _socialService;

  ParkProvider({required SocialService socialService}) : _socialService = socialService;

  // ────────────────────────────────────────────────────────────────────────────
  // 状态变量
  // ────────────────────────────────────────────────────────────────────────────

  /// 当前区域ID
  String _currentZoneId = '码农森林';
  String get currentZoneId => _currentZoneId;

  /// 公园用户列表
  List<ParkUser> _parkUsers = [];
  List<ParkUser> get parkUsers => _parkUsers;

  /// 当前选中的用户（用于显示资料弹窗）
  ParkUser? _selectedUser;
  ParkUser? get selectedUser => _selectedUser;

  /// 是否加载中
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// 错误信息
  String? _error;
  String? get error => _error;

  /// 最近的互动记录
  List<ParkInteraction> _recentInteractions = [];
  List<ParkInteraction> get recentInteractions => _recentInteractions;

  // ────────────────────────────────────────────────────────────────────────────
  // 区域相关方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 切换区域
  /// [zoneId] 区域ID（中文名称）
  Future<void> switchZone(String zoneId) async {
    if (_currentZoneId == zoneId) return;
    
    _currentZoneId = zoneId;
    _parkUsers = [];
    notifyListeners();
    
    await loadParkUsers();
  }

  /// 获取区域显示名称
  String getZoneDisplayName(String zoneId) {
    const zoneNames = {
      '码农森林': '🌲 码农森林',
      '金币湖畔': '💰 金币湖畔',
      '设计师草原': '🎨 设计师草原',
      '产品家园': '📱 产品家园',
    };
    return zoneNames[zoneId] ?? zoneId;
  }

  /// 获取区域用户数量
  int get zoneUserCount => _parkUsers.length;

  // ────────────────────────────────────────────────────────────────────────────
  // 用户相关方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 加载公园用户
  Future<void> loadParkUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _parkUsers = await _socialService.getParkUsers(_currentZoneId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      debugPrint('加载公园用户失败: $e');
      notifyListeners();
    }
  }

  /// 选择用户（显示资料弹窗）
  void selectUser(ParkUser? user) {
    _selectedUser = user;
    notifyListeners();
  }

  /// 清除选中的用户
  void clearSelectedUser() {
    _selectedUser = null;
    notifyListeners();
  }

  /// 获取用户资料
  Future<ParkUser?> getUserProfile(String userId) async {
    try {
      return await _socialService.getUserProfile(userId);
    } catch (e) {
      debugPrint('获取用户资料失败: $e');
      return null;
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 互动相关方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 发送互动
  /// [userId] 发起者ID
  /// [targetUserId] 目标用户ID
  /// [type] 互动类型
  Future<bool> sendInteraction(
    String userId,
    String targetUserId,
    InteractionType type,
  ) async {
    try {
      await _socialService.sendInteraction(userId, targetUserId, type);
      
      // 刷新互动记录
      await loadRecentInteractions(userId);
      
      debugPrint('互动发送成功: ${type.name}');
      return true;
    } catch (e) {
      debugPrint('发送互动失败: $e');
      return false;
    }
  }

  /// 加载最近的互动记录
  /// [userId] 用户ID
  Future<void> loadRecentInteractions(String userId) async {
    try {
      _recentInteractions = await _socialService.getRecentInteractions(
        userId,
        limit: 20,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('加载互动记录失败: $e');
    }
  }

  /// 获取互动类型显示名称
  String getInteractionDisplayName(InteractionType type) {
    switch (type) {
      case InteractionType.pet:
        return '抚摸了宠物';
      case InteractionType.greet:
        return '打了个招呼';
      case InteractionType.gift:
        return '送了一份礼物';
      case InteractionType.like:
        return '点了个赞';
    }
  }

  /// 获取互动类型图标
  String getInteractionIcon(InteractionType type) {
    switch (type) {
      case InteractionType.pet:
        return '🐾';
      case InteractionType.greet:
        return '👋';
      case InteractionType.gift:
        return '🎁';
      case InteractionType.like:
        return '❤️';
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 刷新方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 刷新所有数据
  Future<void> refresh() async {
    await loadParkUsers();
  }

  /// 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
