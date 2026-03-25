import 'package:flutter/foundation.dart';
import '../../../data/models/job_event.dart';
import '../../../data/repositories/job_repository.dart';
import '../../../data/repositories/job_repository_impl.dart';

/// 投递记录状态管理
/// 负责加载和管理用户的投递记录
class SubmissionsProvider extends ChangeNotifier {
  // ═══════════════════════════════════════════════════════════
  // 依赖注入
  // ═══════════════════════════════════════════════════════════
  final JobRepository _jobRepository;

  // ═══════════════════════════════════════════════════════════
  // 状态变量
  // ═══════════════════════════════════════════════════════════
  List<JobEvent> _submissions = [];
  List<JobEvent> _filteredSubmissions = [];
  bool _isLoading = false;
  String? _error;
  String _selectedStatus = '全部';

  // ═══════════════════════════════════════════════════════════
  // Getters
  // ═══════════════════════════════════════════════════════════
  List<JobEvent> get submissions => _filteredSubmissions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedStatus => _selectedStatus;

  // 统计数据
  int get totalCount => _submissions.length;
  int get submittedCount => _submissions.where((s) => s.eventType == 'submit').length;
  int get viewedCount => _submissions.where((s) => s.eventType == 'viewed').length;
  int get interviewCount => _submissions.where((s) => s.eventType == 'interview').length;
  int get rejectedCount => _submissions.where((s) => s.eventType == 'rejected').length;

  // ═══════════════════════════════════════════════════════════
  // 构造函数
  // ═══════════════════════════════════════════════════════════
  SubmissionsProvider({JobRepository? jobRepository})
      : _jobRepository = jobRepository ?? JobRepositoryImpl();

  // ═══════════════════════════════════════════════════════════
  // 公共方法
  // ═══════════════════════════════════════════════════════════

  /// 加载投递记录
  /// [userId] 用户ID
  Future<void> loadSubmissions(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _submissions = await _jobRepository.getJobEvents(userId);
      _applyFilter();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 筛选状态
  /// [status] 状态名称
  void filterByStatus(String status) {
    _selectedStatus = status;
    _applyFilter();
  }

  /// 删除记录
  /// [id] 记录ID
  /// [userId] 用户ID
  Future<void> deleteSubmission(String id, String userId) async {
    try {
      await _jobRepository.deleteJobEvent(id);
      await loadSubmissions(userId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// 刷新数据
  /// [userId] 用户ID
  Future<void> refresh(String userId) async {
    await loadSubmissions(userId);
  }

  // ═══════════════════════════════════════════════════════════
  // 私有方法
  // ═══════════════════════════════════════════════════════════

  /// 应用筛选条件
  void _applyFilter() {
    // 状态映射
    final typeMap = {
      '全部': null,
      '已投递': 'submit',
      '已查看': 'viewed',
      '面试中': 'interview',
      '已拒绝': 'rejected',
    };

    final targetType = typeMap[_selectedStatus];
    
    if (targetType == null) {
      _filteredSubmissions = List.from(_submissions);
    } else {
      _filteredSubmissions = _submissions
          .where((s) => s.eventType == targetType)
          .toList();
    }

    // 按时间倒序排列
    _filteredSubmissions.sort((a, b) => b.eventTime.compareTo(a.eventTime));

    notifyListeners();
  }
}
