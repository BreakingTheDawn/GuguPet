/// 统计数据模型
/// 用于存储统计看板的综合数据
class StatsModel {
  /// 本周投递数
  final int weeklySubmissions;
  
  /// 总投递数
  final int totalSubmissions;
  
  /// 本周被查看数
  final int weeklyViews;
  
  /// 本周感兴趣数
  final int weeklyInterests;
  
  /// 本周面试邀约数
  final int weeklyInterviews;
  
  /// 每日投递趋势
  final List<DailyStats> weeklyTrend;
  
  /// 成就徽章列表
  final List<BadgeModel> badges;

  const StatsModel({
    required this.weeklySubmissions,
    required this.totalSubmissions,
    required this.weeklyViews,
    required this.weeklyInterests,
    required this.weeklyInterviews,
    required this.weeklyTrend,
    required this.badges,
  });

  /// 创建空的统计数据
  factory StatsModel.empty() {
    return const StatsModel(
      weeklySubmissions: 0,
      totalSubmissions: 0,
      weeklyViews: 0,
      weeklyInterests: 0,
      weeklyInterviews: 0,
      weeklyTrend: [],
      badges: [],
    );
  }

  /// 复制并更新部分字段
  StatsModel copyWith({
    int? weeklySubmissions,
    int? totalSubmissions,
    int? weeklyViews,
    int? weeklyInterests,
    int? weeklyInterviews,
    List<DailyStats>? weeklyTrend,
    List<BadgeModel>? badges,
  }) {
    return StatsModel(
      weeklySubmissions: weeklySubmissions ?? this.weeklySubmissions,
      totalSubmissions: totalSubmissions ?? this.totalSubmissions,
      weeklyViews: weeklyViews ?? this.weeklyViews,
      weeklyInterests: weeklyInterests ?? this.weeklyInterests,
      weeklyInterviews: weeklyInterviews ?? this.weeklyInterviews,
      weeklyTrend: weeklyTrend ?? this.weeklyTrend,
      badges: badges ?? this.badges,
    );
  }
}

/// 每日统计数据
/// 用于记录单日的投递情况
class DailyStats {
  /// 星期几（如 "周一"）
  final String day;
  
  /// 投递数量
  final int submissions;

  const DailyStats({
    required this.day,
    required this.submissions,
  });

  /// 转换为Map格式（兼容图表组件）
  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'submissions': submissions,
    };
  }
}

/// 徽章模型
/// 用于表示成就徽章的状态
class BadgeModel {
  /// 徽章图标（emoji）
  final String emoji;
  
  /// 徽章名称
  final String name;
  
  /// 徽章描述
  final String desc;
  
  /// 是否已解锁
  final bool unlocked;
  
  /// 解锁时间（可选）
  final String? unlockedAt;

  const BadgeModel({
    required this.emoji,
    required this.name,
    required this.desc,
    required this.unlocked,
    this.unlockedAt,
  });

  /// 复制并更新解锁状态
  BadgeModel copyWith({
    String? emoji,
    String? name,
    String? desc,
    bool? unlocked,
    String? unlockedAt,
  }) {
    return BadgeModel(
      emoji: emoji ?? this.emoji,
      name: name ?? this.name,
      desc: desc ?? this.desc,
      unlocked: unlocked ?? this.unlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  /// 转换为Map格式（兼容现有UI）
  Map<String, dynamic> toMap() {
    return {
      'emoji': emoji,
      'name': name,
      'desc': desc,
      'unlocked': unlocked,
    };
  }
}
