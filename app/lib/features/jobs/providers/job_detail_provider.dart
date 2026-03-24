import 'package:flutter/foundation.dart';
import '../../../data/datasources/local/favorite_job_local_datasource.dart';
import '../../../data/models/favorite_job.dart';

/// 职位详情状态管理
/// 负责管理职位详情数据、收藏状态和加载状态
class JobDetailProvider extends ChangeNotifier {
  // ═══════════════════════════════════════════════════════════
  // 依赖注入
  // ═══════════════════════════════════════════════════════════
  final FavoriteJobLocalDatasource _favoriteJobLocalDatasource;

  JobDetailProvider({
    FavoriteJobLocalDatasource? favoriteJobLocalDatasource,
  }) : _favoriteJobLocalDatasource =
           favoriteJobLocalDatasource ?? MockFavoriteJobLocalDatasource();

  // ═══════════════════════════════════════════════════════════
  // 状态变量
  // ═══════════════════════════════════════════════════════════

  /// 职位数据
  Map<String, dynamic>? _jobData;

  /// 是否已收藏
  bool _isFavorited = false;

  /// 是否正在加载
  bool _isLoading = false;

  /// 错误信息
  String? _errorMessage;

  // ═══════════════════════════════════════════════════════════
  // Getter方法
  // ═══════════════════════════════════════════════════════════

  Map<String, dynamic>? get jobData => _jobData;
  bool get isFavorited => _isFavorited;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ═══════════════════════════════════════════════════════════
  // 公共方法
  // ═══════════════════════════════════════════════════════════

  /// 加载职位详情
  /// [job] 职位数据
  /// [userId] 用户ID，默认使用 'default_user'
  Future<void> loadJobDetail(
    Map<String, dynamic> job, {
    String userId = 'default_user',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _jobData = job;
    notifyListeners();

    try {
      // 检查职位ID是否有效
      final jobId = job['id']?.toString();
      if (jobId == null || jobId.isEmpty) {
        _isLoading = false;
        _errorMessage = '职位ID无效';
        notifyListeners();
        return;
      }

      // 检查收藏状态
      _isFavorited = await _favoriteJobLocalDatasource.isFavorited(userId, jobId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = '加载职位详情失败: $e';
      debugPrint('JobDetailProvider Error: $e');
      notifyListeners();
    }
  }

  /// 切换收藏状态
  /// [userId] 用户ID，默认使用 'default_user'
  Future<void> toggleFavorite({String userId = 'default_user'}) async {
    if (_jobData == null) return;

    try {
      // 检查职位ID是否有效
      final jobId = _jobData!['id']?.toString();
      if (jobId == null || jobId.isEmpty) {
        debugPrint('职位ID无效，无法切换收藏状态');
        return;
      }

      if (_isFavorited) {
        // 取消收藏
        await _favoriteJobLocalDatasource.removeFavoriteJob(userId, jobId);
        _isFavorited = false;
      } else {
        // 添加收藏
        final favoriteJob = FavoriteJob(
          id: '${userId}_${jobId}_${DateTime.now().millisecondsSinceEpoch}',
          userId: userId,
          jobId: jobId,
          jobTitle: _jobData!['title'] as String?,
          companyName: _jobData!['company'] as String?,
          salaryRange: _jobData!['salary'] as String?,
          jobLocation: _jobData!['location'] as String?,
          jobTags: _jobData!['tags'] != null
              ? List<String>.from(_jobData!['tags'] as List<dynamic>)
              : null,
          createdAt: DateTime.now(),
        );
        await _favoriteJobLocalDatasource.addFavoriteJob(favoriteJob);
        _isFavorited = true;
      }

      notifyListeners();
    } catch (e) {
      debugPrint('切换收藏状态失败: $e');
      rethrow;
    }
  }

  /// 清除数据
  void clear() {
    _jobData = null;
    _isFavorited = false;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
