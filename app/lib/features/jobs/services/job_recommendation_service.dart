import 'package:flutter/foundation.dart';
import '../../../data/models/job.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/models/favorite_job.dart';
import '../../../data/models/job_event.dart';
import '../../../data/repositories/favorite_job_repository.dart';
import '../../../data/repositories/favorite_job_repository_impl.dart';
import '../../../data/repositories/job_repository.dart';
import '../../../data/repositories/job_repository_impl.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/repositories/user_repository_impl.dart';

/// 职位推荐服务
/// 负责实现职位推荐算法，包括用户画像分析和职位匹配度计算
class JobRecommendationService {
  // ═══════════════════════════════════════════════════════════
  // 依赖注入
  // ═══════════════════════════════════════════════════════════

  final FavoriteJobRepository _favoriteRepository;
  final JobRepository _jobRepository;
  final UserRepository _userRepository;

  /// 构造函数
  JobRecommendationService({
    FavoriteJobRepository? favoriteRepository,
    JobRepository? jobRepository,
    UserRepository? userRepository,
  })  : _favoriteRepository = favoriteRepository ?? FavoriteJobRepositoryImpl(),
        _jobRepository = jobRepository ?? JobRepositoryImpl(),
        _userRepository = userRepository ?? UserRepositoryImpl();

  // ═══════════════════════════════════════════════════════════
  // 权重配置常量
  // ═══════════════════════════════════════════════════════════

  /// 职位类型匹配权重（30%）
  static const double categoryWeight = 30.0;

  /// 薪资匹配权重（25%）
  static const double salaryWeight = 25.0;

  /// 地点匹配权重（20%）
  static const double locationWeight = 20.0;

  /// 经验匹配权重（15%）
  static const double experienceWeight = 15.0;

  /// 新鲜度权重（10%）
  static const double freshnessWeight = 10.0;

  // ═══════════════════════════════════════════════════════════
  // 核心推荐方法
  // ═══════════════════════════════════════════════════════════

  /// 获取推荐职位列表
  /// [userId] 用户ID
  /// [jobs] 待推荐的职位列表
  /// [limit] 返回数量限制，默认20条
  /// [excludeApplied] 是否排除已投递的职位，默认true
  /// [excludeFavorited] 是否排除已收藏的职位，默认false
  Future<List<JobWithScore>> getRecommendedJobs({
    required String userId,
    required List<Job> jobs,
    int limit = 20,
    bool excludeApplied = true,
    bool excludeFavorited = false,
  }) async {
    try {
      // 1. 获取用户画像
      final userProfile = await _getUserProfile(userId);
      if (userProfile == null) {
        debugPrint('[JobRecommendationService] 未找到用户画像，使用默认推荐');
        return _getDefaultRecommendations(jobs, limit);
      }

      // 2. 获取用户行为数据
      final userBehavior = await _getUserBehaviorData(userId);

      // 3. 构建用户画像（结合求职意向和行为数据）
      final enhancedProfile = _buildEnhancedProfile(userProfile, userBehavior);

      // 4. 获取已投递和已收藏的职位ID集合
      final appliedJobIds = await _getAppliedJobIds(userId);
      final favoritedJobIds = await _getFavoritedJobIds(userId);

      // 5. 计算每个职位的匹配度得分
      final scoredJobs = <JobWithScore>[];
      for (final job in jobs) {
        // 检查是否需要排除
        if (excludeApplied && appliedJobIds.contains(job.id)) continue;
        if (excludeFavorited && favoritedJobIds.contains(job.id)) continue;

        // 计算匹配度得分
        final scoreDetails = calculateMatchScoreWithDetails(job, enhancedProfile);
        final jobWithScore = JobWithScore(
          job: job,
          score: scoreDetails.totalScore,
          scoreDetails: scoreDetails,
          isApplied: appliedJobIds.contains(job.id),
          isFavorited: favoritedJobIds.contains(job.id),
        );
        scoredJobs.add(jobWithScore);
      }

      // 6. 按匹配度得分降序排序
      scoredJobs.sort((a, b) => b.score.compareTo(a.score));

      // 7. 返回前limit条结果
      return scoredJobs.take(limit).toList();
    } catch (e, stackTrace) {
      debugPrint('[JobRecommendationService] 获取推荐职位失败: $e');
      debugPrint('[JobRecommendationService] 堆栈跟踪: $stackTrace');
      // 出错时返回默认推荐
      return _getDefaultRecommendations(jobs, limit);
    }
  }

  /// 计算单个职位的匹配度得分
  /// [job] 职位信息
  /// [profile] 用户画像
  /// 返回匹配度得分（0-100）
  double calculateMatchScore(Job job, UserProfile profile) {
    final details = calculateMatchScoreWithDetails(job, profile);
    return details.totalScore;
  }

  /// 计算单个职位的匹配度得分（带详情）
  /// [job] 职位信息
  /// [profile] 用户画像（支持 UserProfile 或 EnhancedUserProfile）
  /// 返回匹配度得分详情
  MatchScoreDetails calculateMatchScoreWithDetails(Job job, dynamic profile) {
    // 将 profile 转换为 EnhancedUserProfile
    EnhancedUserProfile enhancedProfile;
    if (profile is EnhancedUserProfile) {
      enhancedProfile = profile;
    } else if (profile is UserProfile) {
      enhancedProfile = EnhancedUserProfile(baseProfile: profile);
    } else {
      // 未知类型，使用空画像
      enhancedProfile = EnhancedUserProfile(
        baseProfile: UserProfile(
          userId: '',
          userName: '',
        ),
      );
    }

    // 计算各维度得分
    final categoryScore = _calculateCategoryScore(job, enhancedProfile);
    final salaryScore = _calculateSalaryScore(job, enhancedProfile);
    final locationScore = _calculateLocationScore(job, enhancedProfile);
    final experienceScore = _calculateExperienceScore(job, enhancedProfile);
    final freshnessScore = _calculateFreshnessScore(job);

    // 构建得分详情
    return MatchScoreDetails.fromScores(
      categoryScore: categoryScore,
      salaryScore: salaryScore,
      locationScore: locationScore,
      experienceScore: experienceScore,
      freshnessScore: freshnessScore,
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 用户画像分析方法
  // ═══════════════════════════════════════════════════════════

  /// 获取用户画像
  /// [userId] 用户ID
  Future<UserProfile?> _getUserProfile(String userId) async {
    try {
      return await _userRepository.getUser(userId);
    } catch (e) {
      debugPrint('[JobRecommendationService] 获取用户画像失败: $e');
      return null;
    }
  }

  /// 获取用户行为数据
  /// [userId] 用户ID
  Future<UserBehaviorData> _getUserBehaviorData(String userId) async {
    try {
      // 获取浏览历史（从PetMemory中提取）
      // 获取收藏记录
      final favorites = await _favoriteRepository.getFavoriteJobs(userId);
      // 获取投递记录
      final jobEvents = await _jobRepository.getJobEvents(userId);

      return UserBehaviorData(
        favorites: favorites,
        jobEvents: jobEvents,
      );
    } catch (e) {
      debugPrint('[JobRecommendationService] 获取用户行为数据失败: $e');
      return UserBehaviorData();
    }
  }

  /// 构建增强用户画像
  /// 结合用户求职意向和行为数据
  EnhancedUserProfile _buildEnhancedProfile(
    UserProfile baseProfile,
    UserBehaviorData behaviorData,
  ) {
    // 从行为数据中提取偏好
    final categoryPreferences = _extractCategoryPreferences(behaviorData);
    final locationPreferences = _extractLocationPreferences(behaviorData);
    final salaryPreferences = _extractSalaryPreferences(behaviorData, baseProfile);

    return EnhancedUserProfile(
      baseProfile: baseProfile,
      categoryPreferences: categoryPreferences,
      locationPreferences: locationPreferences,
      salaryPreferences: salaryPreferences,
    );
  }

  /// 从行为数据中提取职位类型偏好
  Map<String, double> _extractCategoryPreferences(UserBehaviorData behaviorData) {
    final preferences = <String, double>{};
    
    // 从收藏记录中提取
    for (final favorite in behaviorData.favorites) {
      final title = favorite.jobTitle?.toLowerCase() ?? '';
      final category = _inferCategoryFromTitle(title);
      if (category != null) {
        preferences[category] = (preferences[category] ?? 0) + 2.0; // 收藏权重更高
      }
    }

    // 从投递记录中提取
    for (final event in behaviorData.jobEvents) {
      if (event.eventType == '投递') {
        final title = event.positionName?.toLowerCase() ?? '';
        final category = _inferCategoryFromTitle(title);
        if (category != null) {
          preferences[category] = (preferences[category] ?? 0) + 1.5; // 投递权重次之
        }
      }
    }

    return preferences;
  }

  /// 从行为数据中提取地点偏好
  Map<String, double> _extractLocationPreferences(UserBehaviorData behaviorData) {
    final preferences = <String, double>{};
    
    // 从收藏记录中提取
    for (final favorite in behaviorData.favorites) {
      final location = favorite.jobLocation ?? '';
      final city = _extractCityFromLocation(location);
      if (city != null) {
        preferences[city] = (preferences[city] ?? 0) + 2.0;
      }
    }

    // 从投递记录中提取
    for (final event in behaviorData.jobEvents) {
      if (event.eventType == '投递') {
        // 从事件内容中提取城市（简化处理）
        final content = event.eventContent;
        final city = _extractCityFromText(content);
        if (city != null) {
          preferences[city] = (preferences[city] ?? 0) + 1.5;
        }
      }
    }

    return preferences;
  }

  /// 从行为数据中提取薪资偏好
  SalaryRange _extractSalaryPreferences(
    UserBehaviorData behaviorData,
    UserProfile baseProfile,
  ) {
    // 优先使用用户设置的期望薪资
    if (baseProfile.salaryExpect != null && baseProfile.salaryExpect!.isNotEmpty) {
      return _parseSalaryRange(baseProfile.salaryExpect!);
    }

    // 从收藏和投递记录中推断薪资范围
    int minSalary = 0;
    int maxSalary = 0;

    for (final favorite in behaviorData.favorites) {
      final range = _parseSalaryRange(favorite.salaryRange ?? '');
      if (range.min > 0) {
        minSalary = minSalary == 0 ? range.min : (minSalary + range.min) ~/ 2;
      }
      if (range.max > 0) {
        maxSalary = maxSalary == 0 ? range.max : (maxSalary + range.max) ~/ 2;
      }
    }

    return SalaryRange(min: minSalary, max: maxSalary);
  }

  // ═══════════════════════════════════════════════════════════
  // 匹配度计算方法
  // ═══════════════════════════════════════════════════════════

  /// 计算职位类型匹配度得分
  /// 满分30分
  double _calculateCategoryScore(Job job, EnhancedUserProfile profile) {
    final jobCategory = job.category?.toLowerCase() ?? '';
    final jobTitle = job.title.toLowerCase();
    
    // 如果职位有明确的类型标签
    if (jobCategory.isNotEmpty) {
      // 检查是否与用户求职意向匹配
      final intention = profile.jobIntention?.toLowerCase() ?? '';
      if (intention.contains(jobCategory) || jobCategory.contains(intention)) {
        return categoryWeight;
      }
      
      // 检查是否与用户行业标签匹配
      final industryTag = profile.industryTag?.toLowerCase() ?? '';
      if (industryTag.contains(jobCategory) || jobCategory.contains(industryTag)) {
        return categoryWeight * 0.8;
      }
    }

    // 从职位标题推断类型并匹配
    final inferredCategory = _inferCategoryFromTitle(jobTitle);
    if (inferredCategory != null) {
      final intention = profile.jobIntention?.toLowerCase() ?? '';
      if (intention.contains(inferredCategory.toLowerCase())) {
        return categoryWeight * 0.9;
      }
    }

    // 默认返回基础分
    return categoryWeight * 0.3;
  }

  /// 计算薪资匹配度得分
  /// 满分25分
  double _calculateSalaryScore(Job job, EnhancedUserProfile profile) {
    // 解析职位薪资范围
    final jobSalary = _parseSalaryRange(job.salary);
    if (jobSalary.min == 0 && jobSalary.max == 0) {
      // 无法解析薪资，返回基础分
      return salaryWeight * 0.5;
    }

    // 解析用户期望薪资
    final expectSalary = _parseSalaryRange(profile.salaryExpect ?? '');
    if (expectSalary.min == 0 && expectSalary.max == 0) {
      // 用户未设置期望薪资，返回基础分
      return salaryWeight * 0.5;
    }

    // 计算薪资重叠度
    final overlapMin = [jobSalary.min, expectSalary.min].reduce((a, b) => a > b ? a : b);
    final overlapMax = [jobSalary.max, expectSalary.max].reduce((a, b) => a < b ? a : b);
    
    if (overlapMin > overlapMax) {
      // 无重叠，薪资不匹配
      return salaryWeight * 0.2;
    }

    // 计算重叠比例
    final overlapRange = overlapMax - overlapMin;
    final jobRange = jobSalary.max - jobSalary.min;
    final expectRange = expectSalary.max - expectSalary.min;
    
    final overlapRatio = overlapRange / (jobRange > expectRange ? jobRange : expectRange);
    
    return salaryWeight * overlapRatio;
  }

  /// 计算地点匹配度得分
  /// 满分20分
  double _calculateLocationScore(Job job, EnhancedUserProfile profile) {
    final jobLocation = job.location;
    final userCity = profile.city ?? '';

    if (userCity.isEmpty) {
      // 用户未设置期望城市，返回基础分
      return locationWeight * 0.5;
    }

    // 检查职位地点是否包含用户期望城市
    if (jobLocation.contains(userCity)) {
      return locationWeight;
    }

    // 检查是否为同城不同区
    final jobCity = _extractCityFromLocation(jobLocation);
    if (jobCity != null && jobCity == userCity) {
      return locationWeight * 0.9;
    }

    // 检查是否为相邻城市（简化处理）
    final nearbyCities = _getNearbyCities(userCity);
    if (jobCity != null && nearbyCities.contains(jobCity)) {
      return locationWeight * 0.7;
    }

    // 不匹配
    return locationWeight * 0.2;
  }

  /// 计算经验匹配度得分
  /// 满分15分
  double _calculateExperienceScore(Job job, EnhancedUserProfile profile) {
    final jobExperience = job.experience ?? '';
    
    if (jobExperience.isEmpty || jobExperience == '不限') {
      // 职位对经验无要求，满分
      return experienceWeight;
    }

    // 从用户行为数据中推断经验水平（简化处理）
    // 实际项目中可以从用户简历或设置中获取
    // 这里使用基础分
    return experienceWeight * 0.6;
  }

  /// 计算新鲜度得分
  /// 满分10分
  double _calculateFreshnessScore(Job job) {
    final postedAt = job.postedAt;
    
    if (postedAt == null) {
      // 无法确定发布时间，返回基础分
      return freshnessWeight * 0.5;
    }

    final now = DateTime.now();
    final daysSincePosted = now.difference(postedAt).inDays;

    if (daysSincePosted <= 1) {
      // 1天内发布
      return freshnessWeight;
    } else if (daysSincePosted <= 3) {
      // 3天内发布
      return freshnessWeight * 0.8;
    } else if (daysSincePosted <= 7) {
      // 1周内发布
      return freshnessWeight * 0.6;
    } else if (daysSincePosted <= 14) {
      // 2周内发布
      return freshnessWeight * 0.4;
    } else if (daysSincePosted <= 30) {
      // 1个月内发布
      return freshnessWeight * 0.2;
    } else {
      // 超过1个月
      return freshnessWeight * 0.1;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 辅助方法
  // ═══════════════════════════════════════════════════════════

  /// 获取已投递的职位ID集合
  Future<Set<String>> _getAppliedJobIds(String userId) async {
    try {
      final events = await _jobRepository.getJobEvents(userId);
      return events
          .where((e) => e.eventType == '投递')
          .map((e) => e.id)
          .toSet();
    } catch (e) {
      return {};
    }
  }

  /// 获取已收藏的职位ID集合
  Future<Set<String>> _getFavoritedJobIds(String userId) async {
    try {
      final favorites = await _favoriteRepository.getFavoriteJobs(userId);
      return favorites.map((f) => f.jobId).toSet();
    } catch (e) {
      return {};
    }
  }

  /// 获取默认推荐（当无法获取用户画像时使用）
  List<JobWithScore> _getDefaultRecommendations(List<Job> jobs, int limit) {
    // 按新鲜度和是否急招排序
    final sortedJobs = List<Job>.from(jobs)
      ..sort((a, b) {
        // 急招优先
        if (a.isUrgent != b.isUrgent) {
          return a.isUrgent ? -1 : 1;
        }
        // 新职位优先
        if (a.isNew != b.isNew) {
          return a.isNew ? -1 : 1;
        }
        // 按发布时间排序
        final aTime = a.postedAt ?? DateTime(1970);
        final bTime = b.postedAt ?? DateTime(1970);
        return bTime.compareTo(aTime);
      });

    return sortedJobs
        .take(limit)
        .map((job) => JobWithScore.withScore(job, 50.0))
        .toList();
  }

  /// 从职位标题推断职位类型
  String? _inferCategoryFromTitle(String title) {
    final titleLower = title.toLowerCase();
    
    // 设计类
    if (titleLower.contains('设计') ||
        titleLower.contains('ui') ||
        titleLower.contains('ux') ||
        titleLower.contains('视觉') ||
        titleLower.contains('平面')) {
      return '设计';
    }
    
    // 技术类
    if (titleLower.contains('工程师') ||
        titleLower.contains('开发') ||
        titleLower.contains('前端') ||
        titleLower.contains('后端') ||
        titleLower.contains('ios') ||
        titleLower.contains('android') ||
        titleLower.contains('java') ||
        titleLower.contains('python')) {
      return '技术';
    }
    
    // 产品类
    if (titleLower.contains('产品') ||
        titleLower.contains('pm') ||
        titleLower.contains('需求')) {
      return '产品';
    }
    
    // 运营类
    if (titleLower.contains('运营') ||
        titleLower.contains('市场') ||
        titleLower.contains('推广') ||
        titleLower.contains('品牌')) {
      return '运营';
    }
    
    // 数据类
    if (titleLower.contains('数据') ||
        titleLower.contains('分析') ||
        titleLower.contains('算法') ||
        titleLower.contains('机器学习')) {
      return '数据';
    }

    return null;
  }

  /// 从地点字符串中提取城市
  String? _extractCityFromLocation(String location) {
    // 常见城市列表
    const cities = [
      '北京', '上海', '广州', '深圳', '杭州', '成都',
      '武汉', '西安', '南京', '苏州', '天津', '重庆',
      '长沙', '郑州', '青岛', '厦门', '福州', '合肥',
    ];

    for (final city in cities) {
      if (location.contains(city)) {
        return city;
      }
    }

    return null;
  }

  /// 从文本中提取城市（简化处理）
  String? _extractCityFromText(String text) {
    return _extractCityFromLocation(text);
  }

  /// 解析薪资范围字符串
  /// 支持 "15k-20k", "15-20k", "15k-20K", "面议" 等格式
  SalaryRange _parseSalaryRange(String salaryStr) {
    if (salaryStr.isEmpty || salaryStr.contains('面议')) {
      return const SalaryRange(min: 0, max: 0);
    }

    try {
      // 移除空格，统一小写
      final normalized = salaryStr.replaceAll(' ', '').toLowerCase();
      
      // 提取数字
      final numbers = RegExp(r'(\d+)').allMatches(normalized);
      final values = numbers.map((m) => int.parse(m.group(1)!)).toList();

      if (values.isEmpty) {
        return const SalaryRange(min: 0, max: 0);
      }

      // 判断单位（k表示千）
      final hasK = normalized.contains('k');
      final multiplier = hasK ? 1000 : 1;

      if (values.length >= 2) {
        return SalaryRange(
          min: values[0] * multiplier,
          max: values[1] * multiplier,
        );
      } else {
        // 只有一个数字的情况
        return SalaryRange(
          min: values[0] * multiplier,
          max: values[0] * multiplier,
        );
      }
    } catch (e) {
      return const SalaryRange(min: 0, max: 0);
    }
  }

  /// 获取相邻城市列表（简化处理）
  List<String> _getNearbyCities(String city) {
    // 简化处理：返回空列表
    // 实际项目中可以维护一个城市关系映射表
    return [];
  }
}

// ═══════════════════════════════════════════════════════════
// 辅助数据类
// ═══════════════════════════════════════════════════════════

/// 用户行为数据
/// 包含收藏记录和投递记录
class UserBehaviorData {
  /// 收藏记录
  final List<FavoriteJob> favorites;

  /// 求职事件记录
  final List<JobEvent> jobEvents;

  const UserBehaviorData({
    this.favorites = const [],
    this.jobEvents = const [],
  });
}

/// 增强用户画像
/// 结合基础画像和行为偏好
class EnhancedUserProfile {
  /// 基础用户画像
  final UserProfile baseProfile;

  /// 职位类型偏好（类型 -> 权重）
  final Map<String, double> categoryPreferences;

  /// 地点偏好（城市 -> 权重）
  final Map<String, double> locationPreferences;

  /// 薪资偏好
  final SalaryRange salaryPreferences;

  const EnhancedUserProfile({
    required this.baseProfile,
    this.categoryPreferences = const {},
    this.locationPreferences = const {},
    this.salaryPreferences = const SalaryRange(),
  });

  /// 获取求职意向
  String? get jobIntention => baseProfile.jobIntention;

  /// 获取期望城市
  String? get city => baseProfile.city;

  /// 获取期望薪资
  String? get salaryExpect => baseProfile.salaryExpect;

  /// 获取行业标签
  String? get industryTag => baseProfile.industryTag;
}

/// 薪资范围
class SalaryRange {
  /// 最低薪资（单位：元）
  final int min;

  /// 最高薪资（单位：元）
  final int max;

  const SalaryRange({this.min = 0, this.max = 0});

  /// 是否有效
  bool get isValid => min > 0 || max > 0;

  /// 获取平均薪资
  double get average => (min + max) / 2;

  @override
  String toString() => 'SalaryRange(min: $min, max: $max)';
}
