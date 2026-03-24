import 'package:flutter/foundation.dart';
import '../../../data/models/favorite_job.dart';
import '../../../data/repositories/favorite_job_repository.dart';
import '../../../data/repositories/favorite_job_repository_impl.dart';

/// 收藏状态管理
/// 负责管理收藏列表数据、收藏状态和加载状态
class FavoriteProvider extends ChangeNotifier {
  // ═══════════════════════════════════════════════════════════
  // 依赖注入
  // ═══════════════════════════════════════════════════════════
  final FavoriteJobRepository _repository;

  /// 构造函数
  /// [currentUserId] 当前用户ID,应从认证服务获取
  /// [repository] 收藏仓库实例
  FavoriteProvider({
    String? currentUserId,
    FavoriteJobRepository? repository,
  })  : _currentUserId = currentUserId ?? 'default_user',
        _repository = repository ?? FavoriteJobRepositoryImpl();

  // ═══════════════════════════════════════════════════════════
  // 状态变量
  // ═══════════════════════════════════════════════════════════

  /// 收藏列表
  List<FavoriteJob> _favorites = [];

  /// 是否正在加载
  bool _isLoading = false;

  /// 错误信息
  String? _errorMessage;

  /// 当前用户ID (应从认证服务获取)
  String _currentUserId;

  // ═══════════════════════════════════════════════════════════
  // Getter方法
  // ═══════════════════════════════════════════════════════════

  /// 获取收藏列表
  List<FavoriteJob> get favorites => _favorites;

  /// 获取收藏数量
  int get favoriteCount => _favorites.length;

  /// 是否正在加载
  bool get isLoading => _isLoading;

  /// 获取错误信息
  String? get errorMessage => _errorMessage;

  /// 是否为空
  bool get isEmpty => _favorites.isEmpty;

  // ═══════════════════════════════════════════════════════════
  // 公共方法
  // ═══════════════════════════════════════════════════════════

  /// 更新当前用户ID (登录后调用)
  /// [userId] 新的用户ID
  void updateCurrentUserId(String userId) {
    if (_currentUserId != userId) {
      _currentUserId = userId;
      loadFavorites();
    }
  }

  /// 加载收藏列表
  /// [userId] 用户ID，默认使用当前用户ID
  Future<void> loadFavorites({String? userId}) async {
    if (userId != null) {
      _currentUserId = userId;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _favorites = await _repository.getFavoriteJobs(_currentUserId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = '加载收藏列表失败: $e';
      debugPrint('FavoriteProvider Error: $e');
      notifyListeners();
    }
  }

  /// 刷新收藏列表
  Future<void> refresh() async {
    await loadFavorites();
  }

  /// 添加收藏
  /// [job] 职位数据Map
  /// [userId] 用户ID，默认使用当前用户ID
  Future<bool> addFavorite(Map<String, dynamic> job, {String? userId}) async {
    try {
      final currentUserId = userId ?? _currentUserId;
      final jobId = job['id']?.toString();

      if (jobId == null || jobId.isEmpty) {
        debugPrint('职位ID无效，无法添加收藏');
        return false;
      }

      // 检查是否已收藏
      if (await isFavorited(jobId, userId: currentUserId)) {
        debugPrint('职位已收藏，无需重复添加');
        return true;
      }

      // 创建收藏记录
      final favoriteJob = FavoriteJob(
        id: '${currentUserId}_${jobId}_${DateTime.now().millisecondsSinceEpoch}',
        userId: currentUserId,
        jobId: jobId,
        jobTitle: job['title'] as String?,
        companyName: job['company'] as String?,
        salaryRange: job['salary'] as String?,
        jobLocation: job['location'] as String?,
        jobTags: job['tags'] != null
            ? List<String>.from(job['tags'] as List<dynamic>)
            : null,
        createdAt: DateTime.now(),
      );

      await _repository.addFavoriteJob(favoriteJob);

      // 重新加载列表
      await loadFavorites(userId: currentUserId);

      return true;
    } catch (e) {
      debugPrint('添加收藏失败: $e');
      return false;
    }
  }

  /// 取消收藏
  /// [jobId] 职位ID
  /// [userId] 用户ID，默认使用当前用户ID
  Future<bool> removeFavorite(String jobId, {String? userId}) async {
    try {
      final currentUserId = userId ?? _currentUserId;

      await _repository.removeFavoriteJob(currentUserId, jobId);

      // 从本地列表中移除
      _favorites.removeWhere((job) => job.jobId == jobId);
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint('取消收藏失败: $e');
      return false;
    }
  }

  /// 检查是否已收藏
  /// [jobId] 职位ID
  /// [userId] 用户ID，默认使用当前用户ID
  Future<bool> isFavorited(String jobId, {String? userId}) async {
    try {
      final currentUserId = userId ?? _currentUserId;
      return await _repository.isFavorited(currentUserId, jobId);
    } catch (e) {
      debugPrint('检查收藏状态失败: $e');
      return false;
    }
  }

  /// 切换收藏状态
  /// [job] 职位数据Map
  /// [userId] 用户ID，默认使用当前用户ID
  /// 返回切换后的收藏状态
  Future<bool> toggleFavorite(Map<String, dynamic> job, {String? userId}) async {
    try {
      final currentUserId = userId ?? _currentUserId;
      final jobId = job['id']?.toString();

      if (jobId == null || jobId.isEmpty) {
        debugPrint('职位ID无效，无法切换收藏状态');
        return false;
      }

      final isCurrentlyFavorited = await isFavorited(jobId, userId: currentUserId);

      if (isCurrentlyFavorited) {
        await removeFavorite(jobId, userId: currentUserId);
        return false;
      } else {
        await addFavorite(job, userId: currentUserId);
        return true;
      }
    } catch (e) {
      debugPrint('切换收藏状态失败: $e');
      rethrow;
    }
  }

  /// 清除数据
  void clear() {
    _favorites = [];
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
