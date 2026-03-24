import 'package:flutter/foundation.dart';
import '../../../data/models/job.dart';
import '../services/job_recommendation_service.dart';

/// 职位推荐状态管理
/// 负责管理推荐职位列表、加载状态和刷新逻辑
class JobRecommendationProvider extends ChangeNotifier {
  // ═══════════════════════════════════════════════════════════
  // 依赖注入
  // ═══════════════════════════════════════════════════════════

  final JobRecommendationService _recommendationService;

  /// 构造函数
  /// [currentUserId] 当前用户ID
  /// [recommendationService] 推荐服务实例
  JobRecommendationProvider({
    String? currentUserId,
    JobRecommendationService? recommendationService,
  })  : _currentUserId = currentUserId ?? 'default_user',
        _recommendationService = recommendationService ?? JobRecommendationService();

  // ═══════════════════════════════════════════════════════════
  // 状态变量
  // ═══════════════════════════════════════════════════════════

  /// 推荐职位列表
  List<JobWithScore> _recommendedJobs = [];

  /// 是否正在加载
  bool _isLoading = false;

  /// 是否正在加载更多
  bool _isLoadingMore = false;

  /// 是否还有更多数据
  bool _hasMore = true;

  /// 错误信息
  String? _errorMessage;

  /// 当前用户ID
  String _currentUserId;

  /// 当前页码
  int _currentPage = 0;

  /// 每页数量
  final int _pageSize = 20;

  /// 是否排除已投递职位
  bool _excludeApplied = true;

  /// 是否排除已收藏职位
  bool _excludeFavorited = false;

  /// 所有职位数据源（用于分页）
  List<Job> _allJobs = [];

  // ═══════════════════════════════════════════════════════════
  // Getter方法
  // ═══════════════════════════════════════════════════════════

  /// 获取推荐职位列表
  List<JobWithScore> get recommendedJobs => _recommendedJobs;

  /// 获取推荐职位数量
  int get recommendationCount => _recommendedJobs.length;

  /// 是否正在加载
  bool get isLoading => _isLoading;

  /// 是否正在加载更多
  bool get isLoadingMore => _isLoadingMore;

  /// 是否还有更多数据
  bool get hasMore => _hasMore;

  /// 获取错误信息
  String? get errorMessage => _errorMessage;

  /// 是否为空
  bool get isEmpty => _recommendedJobs.isEmpty;

  /// 是否有错误
  bool get hasError => _errorMessage != null;

  /// 获取当前用户ID
  String get currentUserId => _currentUserId;

  /// 是否排除已投递职位
  bool get excludeApplied => _excludeApplied;

  /// 是否排除已收藏职位
  bool get excludeFavorited => _excludeFavorited;

  // ═══════════════════════════════════════════════════════════
  // 公共方法
  // ═══════════════════════════════════════════════════════════

  /// 更新当前用户ID
  /// [userId] 新的用户ID
  void updateCurrentUserId(String userId) {
    if (_currentUserId != userId) {
      _currentUserId = userId;
      // 用户变更时重新加载推荐
      loadRecommendations();
    }
  }

  /// 设置职位数据源
  /// [jobs] 所有职位列表
  void setJobs(List<Job> jobs) {
    _allJobs = jobs;
    _currentPage = 0;
    _hasMore = true;
  }

  /// 设置职位数据源（从Map列表转换）
  /// [jobMaps] 职位Map列表
  void setJobsFromMaps(List<Map<String, dynamic>> jobMaps) {
    _allJobs = jobMaps.map((map) => Job.fromJson(map)).toList();
    _currentPage = 0;
    _hasMore = true;
  }

  /// 加载推荐职位
  /// [jobs] 可选的职位数据源，如果不传则使用已设置的数据源
  Future<void> loadRecommendations({List<Job>? jobs}) async {
    if (_isLoading) return;

    // 如果传入了新的职位数据，更新数据源
    if (jobs != null) {
      _allJobs = jobs;
      _currentPage = 0;
      _hasMore = true;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 获取推荐职位
      final recommendedJobs = await _recommendationService.getRecommendedJobs(
        userId: _currentUserId,
        jobs: _allJobs,
        limit: _pageSize,
        excludeApplied: _excludeApplied,
        excludeFavorited: _excludeFavorited,
      );

      _recommendedJobs = recommendedJobs;
      _currentPage = 1;
      _hasMore = recommendedJobs.length >= _pageSize;
      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = '加载推荐职位失败: $e';
      debugPrint('[JobRecommendationProvider] 加载推荐失败: $e');
      debugPrint('[JobRecommendationProvider] 堆栈跟踪: $stackTrace');
      notifyListeners();
    }
  }

  /// 刷新推荐职位
  /// 重新计算推荐并重置分页状态
  Future<void> refresh() async {
    _currentPage = 0;
    _hasMore = true;
    await loadRecommendations();
  }

  /// 加载更多推荐职位
  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      // 获取下一页数据
      final moreJobs = await _recommendationService.getRecommendedJobs(
        userId: _currentUserId,
        jobs: _allJobs,
        limit: _pageSize,
        excludeApplied: _excludeApplied,
        excludeFavorited: _excludeFavorited,
      );

      // 过滤掉已加载的职位（根据ID去重）
      final existingIds = _recommendedJobs.map((j) => j.job.id).toSet();
      final newJobs = moreJobs.where((j) => !existingIds.contains(j.job.id)).toList();

      _recommendedJobs.addAll(newJobs);
      _currentPage++;
      _hasMore = newJobs.length >= _pageSize;
      _isLoadingMore = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _isLoadingMore = false;
      debugPrint('[JobRecommendationProvider] 加载更多失败: $e');
      debugPrint('[JobRecommendationProvider] 堆栈跟踪: $stackTrace');
      notifyListeners();
    }
  }

  /// 设置是否排除已投递职位
  /// [exclude] 是否排除
  Future<void> setExcludeApplied(bool exclude) async {
    if (_excludeApplied != exclude) {
      _excludeApplied = exclude;
      await refresh();
    }
  }

  /// 设置是否排除已收藏职位
  /// [exclude] 是否排除
  Future<void> setExcludeFavorited(bool exclude) async {
    if (_excludeFavorited != exclude) {
      _excludeFavorited = exclude;
      await refresh();
    }
  }

  /// 更新职位投递状态
  /// [jobId] 职位ID
  /// [isApplied] 是否已投递
  void updateJobAppliedStatus(String jobId, bool isApplied) {
    final index = _recommendedJobs.indexWhere((j) => j.job.id == jobId);
    if (index != -1) {
      _recommendedJobs[index] = _recommendedJobs[index].copyWith(
        isApplied: isApplied,
      );
      notifyListeners();
    }
  }

  /// 更新职位收藏状态
  /// [jobId] 职位ID
  /// [isFavorited] 是否已收藏
  void updateJobFavoritedStatus(String jobId, bool isFavorited) {
    final index = _recommendedJobs.indexWhere((j) => j.job.id == jobId);
    if (index != -1) {
      _recommendedJobs[index] = _recommendedJobs[index].copyWith(
        isFavorited: isFavorited,
      );
      notifyListeners();
    }
  }

  /// 从推荐列表中移除职位
  /// [jobId] 职位ID
  void removeJob(String jobId) {
    _recommendedJobs.removeWhere((j) => j.job.id == jobId);
    notifyListeners();
  }

  /// 获取指定职位的匹配度得分
  /// [jobId] 职位ID
  JobWithScore? getJobWithScore(String jobId) {
    try {
      return _recommendedJobs.firstWhere((j) => j.job.id == jobId);
    } catch (e) {
      return null;
    }
  }

  /// 获取高匹配度职位列表（得分 >= 80）
  List<JobWithScore> getHighMatchJobs() {
    return _recommendedJobs.where((j) => j.score >= 80).toList();
  }

  /// 获取新职位列表
  List<JobWithScore> getNewJobs() {
    return _recommendedJobs.where((j) => j.job.isNew).toList();
  }

  /// 获取急招职位列表
  List<JobWithScore> getUrgentJobs() {
    return _recommendedJobs.where((j) => j.job.isUrgent).toList();
  }

  /// 清除所有数据
  void clear() {
    _recommendedJobs = [];
    _isLoading = false;
    _isLoadingMore = false;
    _hasMore = true;
    _errorMessage = null;
    _currentPage = 0;
    _allJobs = [];
    notifyListeners();
  }

  /// 重置状态
  void reset() {
    clear();
  }

  // ═══════════════════════════════════════════════════════════
  // 调试方法
  // ═══════════════════════════════════════════════════════════

  /// 打印当前状态（调试用）
  void debugPrintState() {
    debugPrint('═══ JobRecommendationProvider State ═══');
    debugPrint('Current User: $_currentUserId');
    debugPrint('Total Jobs: ${_recommendedJobs.length}');
    debugPrint('Is Loading: $_isLoading');
    debugPrint('Is Loading More: $_isLoadingMore');
    debugPrint('Has More: $_hasMore');
    debugPrint('Current Page: $_currentPage');
    debugPrint('Exclude Applied: $_excludeApplied');
    debugPrint('Exclude Favorited: $_excludeFavorited');
    debugPrint('Error: $_errorMessage');
    debugPrint('═══════════════════════════════════════');
  }
}
