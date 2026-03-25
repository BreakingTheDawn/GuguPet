import 'package:flutter/foundation.dart';
import '../../../data/models/job.dart';
import '../../../data/models/job_event.dart';
import '../../../data/models/favorite_job.dart';
import '../../../data/repositories/job_repository.dart';
import '../../../data/repositories/job_repository_impl.dart';
import '../../../data/repositories/favorite_job_repository.dart';
import '../../../data/repositories/favorite_job_repository_impl.dart';
import '../../../data/datasources/local/job_list_local_datasource.dart';

/// 求职看板状态管理
/// 负责职位列表的加载、筛选、投递和收藏功能
class JobsProvider extends ChangeNotifier {
  // ═══════════════════════════════════════════════════════════
  // 依赖注入
  // ═══════════════════════════════════════════════════════════
  final JobRepository _jobRepository;
  final FavoriteJobRepository _favoriteRepository;
  final JobListLocalDatasource _jobListDatasource;

  // ═══════════════════════════════════════════════════════════
  // 状态变量
  // ═══════════════════════════════════════════════════════════
  List<Job> _jobs = [];
  List<Job> _filteredJobs = [];
  bool _isLoading = false;
  String? _error;
  String _searchText = '';
  String _selectedCategory = '全部';
  Set<String> _favoritedJobIds = {};

  // ═══════════════════════════════════════════════════════════
  // Getters
  // ═══════════════════════════════════════════════════════════
  List<Job> get jobs => _filteredJobs;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;
  int get newJobsCount => _jobs.where((j) => j.isNew).length;

  // ═══════════════════════════════════════════════════════════
  // 构造函数
  // ═══════════════════════════════════════════════════════════
  JobsProvider({
    JobRepository? jobRepository,
    FavoriteJobRepository? favoriteRepository,
    JobListLocalDatasource? jobListDatasource,
  })  : _jobRepository = jobRepository ?? JobRepositoryImpl(),
        _favoriteRepository = favoriteRepository ?? FavoriteJobRepositoryImpl(),
        _jobListDatasource = jobListDatasource ?? SqliteJobListLocalDatasource();

  // ═══════════════════════════════════════════════════════════
  // 公共方法
  // ═══════════════════════════════════════════════════════════

  /// 加载职位列表
  /// [userId] 用户ID
  Future<void> loadJobs(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 从数据库加载真实职位数据
      _jobs = await _jobListDatasource.getAllJobs();
      
      debugPrint('[JobsProvider] 从数据库加载了 ${_jobs.length} 个职位');
      
      // 如果数据库没有数据，使用模拟数据作为备用
      if (_jobs.isEmpty) {
        debugPrint('[JobsProvider] 数据库为空，使用模拟数据');
        _jobs = _getMockJobs();
      }
      
      // 加载用户收藏状态
      await _loadFavorites(userId);
      
      _applyFilters();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('[JobsProvider] 加载职位失败: $e');
      // 出错时使用模拟数据
      _jobs = _getMockJobs();
      _error = e.toString();
      _isLoading = false;
      _applyFilters();
      notifyListeners();
    }
  }

  /// 投递职位
  /// [userId] 用户ID
  /// [job] 职位信息
  /// 返回是否投递成功
  Future<bool> submitJob(String userId, Job job) async {
    try {
      // 创建投递事件
      final event = JobEvent(
        id: 'event_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        eventType: 'submit',
        eventContent: '投递了 ${job.title} - ${job.company}',
        companyName: job.company,
        positionName: job.title,
        eventTime: DateTime.now(),
        createdAt: DateTime.now(),
      );

      // 保存到数据库
      await _jobRepository.saveJobEvent(event);

      // 通知UI更新
      notifyListeners();
      
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// 收藏/取消收藏职位
  /// [userId] 用户ID
  /// [job] 职位信息
  Future<void> toggleFavorite(String userId, Job job) async {
    try {
      final isFavorited = _favoritedJobIds.contains(job.id);

      if (isFavorited) {
        // 取消收藏
        await _favoriteRepository.removeFavoriteJob(userId, job.id);
        _favoritedJobIds.remove(job.id);
      } else {
        // 添加收藏
        final favorite = FavoriteJob(
          id: 'fav_${DateTime.now().millisecondsSinceEpoch}',
          userId: userId,
          jobId: job.id,
          jobTitle: job.title,
          companyName: job.company,
          salaryRange: job.salary,
          jobLocation: job.location,
          jobTags: job.tags,
          createdAt: DateTime.now(),
        );
        await _favoriteRepository.addFavoriteJob(favorite);
        _favoritedJobIds.add(job.id);
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// 检查职位是否已收藏
  /// [jobId] 职位ID
  bool isFavorited(String jobId) {
    return _favoritedJobIds.contains(jobId);
  }

  /// 搜索职位
  /// [query] 搜索关键词
  void search(String query) {
    _searchText = query;
    _applyFilters();
  }

  /// 选择分类
  /// [category] 分类名称
  void selectCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
  }

  /// 刷新职位列表
  /// [userId] 用户ID
  Future<void> refresh(String userId) async {
    // 清除数据源的缓存
    await _jobListDatasource.refresh();
    await loadJobs(userId);
  }
  
  /// 强制刷新（从assets重新加载数据）
  Future<void> forceRefresh(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // 刷新数据源
      await _jobListDatasource.refresh();
      // 重新加载
      await loadJobs(userId);
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 私有方法
  // ═══════════════════════════════════════════════════════════

  /// 加载用户收藏状态
  Future<void> _loadFavorites(String userId) async {
    try {
      final favorites = await _favoriteRepository.getFavoriteJobs(userId);
      _favoritedJobIds = favorites.map((f) => f.jobId).toSet();
    } catch (e) {
      // 加载失败不影响主流程
      print('[JobsProvider] 加载收藏状态失败: $e');
    }
  }

  /// 应用筛选条件
  void _applyFilters() {
    _filteredJobs = _jobs.where((job) {
      // 搜索过滤
      if (_searchText.isNotEmpty) {
        final searchLower = _searchText.toLowerCase();
        if (!job.title.toLowerCase().contains(searchLower) &&
            !job.company.toLowerCase().contains(searchLower)) {
          // 检查标签
          if (job.tags == null ||
              !job.tags!.any((tag) => tag.toLowerCase().contains(searchLower))) {
            return false;
          }
        }
      }

      // 分类过滤
      if (_selectedCategory != '全部') {
        if (job.category != _selectedCategory) {
          return false;
        }
      }

      return true;
    }).toList();

    notifyListeners();
  }

  /// 获取模拟职位数据
  /// TODO: 替换为真实API调用
  List<Job> _getMockJobs() {
    return [
      Job(
        id: 'job_001',
        title: 'UI设计师',
        company: '某创意科技有限公司',
        salary: '15k-20k',
        location: '上海·静安区',
        category: '设计',
        tags: ['双休', '五险一金', '扁平管理'],
        description: '负责公司核心产品的视觉设计，包括移动端App、Web端界面设计，参与品牌视觉规范制定。',
        isNew: true,
        isUrgent: false,
        postedText: '1小时前',
      ),
      Job(
        id: 'job_002',
        title: '产品经理',
        company: '某知名互联网大厂',
        salary: '18k-25k',
        location: '北京·朝阳区',
        category: '产品',
        tags: ['六险一金', '期权激励', '免费三餐'],
        description: '主导2C产品从0到1的设计规划，深入分析用户需求，驱动产品功能迭代优化。',
        isNew: false,
        isUrgent: true,
        postedText: '3小时前',
      ),
      Job(
        id: 'job_003',
        title: '前端工程师',
        company: '某头部电商平台',
        salary: '20k-30k',
        location: '杭州·余杭区',
        category: '技术',
        tags: ['双休', '五险一金', '弹性工作'],
        description: '负责核心业务前端研发，技术栈React/TypeScript，参与架构设计。',
        isNew: true,
        isUrgent: false,
        postedText: '5小时前',
      ),
      Job(
        id: 'job_004',
        title: '品牌运营专员',
        company: '某新消费品牌',
        salary: '8k-12k',
        location: '广州·天河区',
        category: '运营',
        tags: ['双休', '五险一金', '餐补'],
        description: '负责品牌社媒运营，包括小红书、微博、微信公众号等平台内容策划与发布。',
        isNew: false,
        isUrgent: false,
        postedText: '昨天',
      ),
      Job(
        id: 'job_005',
        title: '数据分析师',
        company: '某头部本地生活平台',
        salary: '15k-22k',
        location: '北京·海淀区',
        category: '数据',
        tags: ['双休', '年终奖', '补充医疗'],
        description: '负责业务数据的统计分析，搭建数据指标体系，输出数据报告。',
        isNew: false,
        isUrgent: true,
        postedText: '昨天',
      ),
    ];
  }
}
