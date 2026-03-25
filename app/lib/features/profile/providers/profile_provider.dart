import 'package:flutter/foundation.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/repositories/job_repository.dart';
import '../../../core/di/repository_provider.dart';

/// 个人中心状态管理
/// 负责管理用户信息、统计数据和VIP状态的加载与刷新
class ProfileProvider extends ChangeNotifier {
  // ═══════════════════════════════════════════════════════════
  // 依赖注入
  // ═══════════════════════════════════════════════════════════
  final UserRepository _userRepository;
  final JobRepository _jobRepository;

  ProfileProvider({
    UserRepository? userRepository,
    JobRepository? jobRepository,
  })  : _userRepository = userRepository ?? repositoryProvider.userRepository,
        _jobRepository = jobRepository ?? repositoryProvider.jobRepository;

  // ═══════════════════════════════════════════════════════════
  // 状态变量
  // ═══════════════════════════════════════════════════════════

  /// 用户信息
  UserProfile? _userProfile;

  /// 投递数量
  int _submissionCount = 0;

  /// 面试数量
  int _interviewCount = 0;

  /// Offer数量
  int _offerCount = 0;

  /// 是否正在加载
  bool _isLoading = false;

  /// 错误信息
  String? _errorMessage;

  // ═══════════════════════════════════════════════════════════
  // Getter方法
  // ═══════════════════════════════════════════════════════════

  UserProfile? get userProfile => _userProfile;
  int get submissionCount => _submissionCount;
  int get interviewCount => _interviewCount;
  int get offerCount => _offerCount;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// 用户名，默认显示"求职者"
  String get userName => _userProfile?.userName ?? '求职者';

  /// VIP状态
  bool get isVip => _userProfile?.vipStatus ?? false;

  /// VIP过期时间
  DateTime? get vipExpireTime => _userProfile?.vipExpireTime;

  /// 求职状态标签
  String get jobStatusTag {
    if (_userProfile?.jobIntention == null) {
      return '暂无求职意向';
    }
    return _userProfile!.jobIntention!;
  }

  // ═══════════════════════════════════════════════════════════
  // 公共方法
  // ═══════════════════════════════════════════════════════════

  /// 加载用户数据
  /// [userId] 用户ID，默认使用 'default_user'
  Future<void> loadUserData({String userId = 'default_user'}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 并行加载用户信息和统计数据
      final results = await Future.wait([
        _userRepository.getUser(userId),
        _loadJobStats(userId),
      ]);

      _userProfile = results[0] as UserProfile?;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = '加载用户数据失败: $e';
      debugPrint('ProfileProvider Error: $e');
      notifyListeners();
    }
  }

  /// 刷新数据
  Future<void> refresh({String userId = 'default_user'}) async {
    await loadUserData(userId: userId);
  }

  /// 清空用户数据（退出登录时调用）
  void clearUserData() {
    _userProfile = null;
    _submissionCount = 0;
    _interviewCount = 0;
    _offerCount = 0;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  /// 更新用户资料
  /// [userName] 用户名
  /// [jobIntention] 求职意向
  /// [city] 期望城市
  /// [salaryExpect] 期望薪资
  /// 返回是否更新成功
  Future<bool> updateUserProfile({
    String? userName,
    String? jobIntention,
    String? city,
    String? salaryExpect,
    String userId = 'default_user',
  }) async {
    try {
      // 获取当前用户资料
      final currentProfile = _userProfile;
      
      if (currentProfile == null) {
        _errorMessage = '用户资料不存在';
        notifyListeners();
        return false;
      }

      // 创建更新后的用户资料
      final updatedProfile = UserProfile(
        userId: currentProfile.userId,
        userName: userName ?? currentProfile.userName,
        jobIntention: jobIntention ?? currentProfile.jobIntention,
        city: city ?? currentProfile.city,
        salaryExpect: salaryExpect ?? currentProfile.salaryExpect,
        petMemory: currentProfile.petMemory,
        vipStatus: currentProfile.vipStatus,
        vipExpireTime: currentProfile.vipExpireTime,
        isOnboarded: currentProfile.isOnboarded,
        industryTag: currentProfile.industryTag,
        onboardingReport: currentProfile.onboardingReport,
      );

      // 保存到数据库
      await _userRepository.updateUser(updatedProfile);
      
      // 更新本地状态
      _userProfile = updatedProfile;
      notifyListeners();
      
      return true;
    } catch (e) {
      _errorMessage = '更新用户资料失败: $e';
      debugPrint('ProfileProvider Update Error: $e');
      notifyListeners();
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 私有方法
  // ═══════════════════════════════════════════════════════════

  /// 加载求职统计数据
  Future<void> _loadJobStats(String userId) async {
    try {
      // 获取所有求职事件
      final events = await _jobRepository.getJobEvents(userId);

      // 统计各类事件数量
      _submissionCount = events.where((e) => e.eventType == '投递').length;
      _interviewCount = events.where((e) => e.eventType == '面试').length;
      _offerCount = events.where((e) => e.eventType == 'Offer').length;
    } catch (e) {
      debugPrint('加载统计数据失败: $e');
      // 统计数据加载失败不影响整体流程
      _submissionCount = 0;
      _interviewCount = 0;
      _offerCount = 0;
    }
  }
}
