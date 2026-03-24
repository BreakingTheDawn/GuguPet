/// 职位数据模型
/// 用于存储职位基本信息
class Job {
  /// 职位唯一标识
  final String id;

  /// 职位标题
  final String title;

  /// 公司名称
  final String company;

  /// 薪资范围（如 "15k-20k"）
  final String salary;

  /// 工作地点（如 "上海·静安区"）
  final String location;

  /// 职位类型（如 "设计", "技术", "产品", "运营", "数据"）
  final String? category;

  /// 工作经验要求（如 "1-3年", "3-5年"）
  final String? experience;

  /// 学历要求（如 "本科", "硕士"）
  final String? education;

  /// 职位标签（如 ["双休", "五险一金", "扁平管理"]）
  final List<String>? tags;

  /// 职位描述
  final String? description;

  /// 是否为新职位
  final bool isNew;

  /// 是否为急招职位
  final bool isUrgent;

  /// 发布时间
  final DateTime? postedAt;

  /// 发布时间描述（如 "1小时前"）
  final String? postedText;

  /// 公司规模
  final String? companySize;

  /// 融资阶段
  final String? fundingStage;

  /// 行业标签
  final String? industryTag;

  const Job({
    required this.id,
    required this.title,
    required this.company,
    required this.salary,
    required this.location,
    this.category,
    this.experience,
    this.education,
    this.tags,
    this.description,
    this.isNew = false,
    this.isUrgent = false,
    this.postedAt,
    this.postedText,
    this.companySize,
    this.fundingStage,
    this.industryTag,
  });

  /// 将模型转换为JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'company': company,
      'salary': salary,
      'location': location,
      'category': category,
      'experience': experience,
      'education': education,
      'tags': tags,
      'description': description,
      'isNew': isNew,
      'isUrgent': isUrgent,
      'postedAt': postedAt?.toIso8601String(),
      'postedText': postedText,
      'companySize': companySize,
      'fundingStage': fundingStage,
      'industryTag': industryTag,
    };
  }

  /// 从JSON Map创建模型实例
  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'].toString(),
      title: json['title'] as String,
      company: json['company'] as String,
      salary: json['salary'] as String,
      location: json['location'] as String,
      category: json['category'] as String?,
      experience: json['experience'] as String?,
      education: json['education'] as String?,
      tags: json['tags'] != null
          ? List<String>.from(json['tags'] as List<dynamic>)
          : null,
      description: json['desc'] as String? ?? json['description'] as String?,
      isNew: json['isNew'] as bool? ?? false,
      isUrgent: json['isUrgent'] as bool? ?? false,
      postedAt: json['postedAt'] != null
          ? DateTime.parse(json['postedAt'] as String)
          : null,
      postedText: json['posted'] as String? ?? json['postedText'] as String?,
      companySize: json['companySize'] as String?,
      fundingStage: json['fundingStage'] as String?,
      industryTag: json['industryTag'] as String?,
    );
  }

  /// 从数据库Map创建模型实例
  factory Job.fromDatabase(Map<String, dynamic> map) {
    // 解析tags
    List<String>? tags;
    final tagsStr = map['tags'] as String?;
    if (tagsStr != null && tagsStr.isNotEmpty) {
      try {
        tags = tagsStr.split(',').where((t) => t.isNotEmpty).toList();
      } catch (e) {
        // 解析失败时保持为null
      }
    }

    return Job(
      id: map['id'].toString(),
      title: map['title'] as String,
      company: map['company'] as String,
      salary: map['salary'] as String,
      location: map['location'] as String,
      category: map['category'] as String?,
      experience: map['experience'] as String?,
      education: map['education'] as String?,
      tags: tags,
      description: map['description'] as String?,
      isNew: (map['is_new'] as int?) == 1,
      isUrgent: (map['is_urgent'] as int?) == 1,
      postedAt: map['posted_at'] != null
          ? DateTime.parse(map['posted_at'] as String)
          : null,
      postedText: map['posted_text'] as String?,
      companySize: map['company_size'] as String?,
      fundingStage: map['funding_stage'] as String?,
      industryTag: map['industry_tag'] as String?,
    );
  }

  /// 将模型转换为数据库Map
  Map<String, dynamic> toDatabaseMap() {
    return {
      'id': id,
      'title': title,
      'company': company,
      'salary': salary,
      'location': location,
      'category': category,
      'experience': experience,
      'education': education,
      'tags': tags?.join(','),
      'description': description,
      'is_new': isNew ? 1 : 0,
      'is_urgent': isUrgent ? 1 : 0,
      'posted_at': postedAt?.toIso8601String(),
      'posted_text': postedText,
      'company_size': companySize,
      'funding_stage': fundingStage,
      'industry_tag': industryTag,
    };
  }

  /// 转换为职位卡片使用的Map格式（兼容现有UI）
  Map<String, dynamic> toCardMap() {
    return {
      'id': id,
      'title': title,
      'company': company,
      'salary': salary,
      'location': location,
      'tags': tags ?? [],
      'isNew': isNew,
      'isUrgent': isUrgent,
      'posted': postedText,
      'desc': description,
      'experience': experience,
      'education': education,
      'companySize': companySize,
      'fundingStage': fundingStage,
    };
  }
}

/// 带匹配度得分的职位模型
/// 用于推荐列表展示
class JobWithScore {
  /// 职位信息
  final Job job;

  /// 匹配度得分（0-100）
  final double score;

  /// 各维度得分详情
  final MatchScoreDetails scoreDetails;

  /// 是否已投递
  final bool isApplied;

  /// 是否已收藏
  final bool isFavorited;

  const JobWithScore({
    required this.job,
    required this.score,
    required this.scoreDetails,
    this.isApplied = false,
    this.isFavorited = false,
  });

  /// 创建带默认得分详情的实例
  factory JobWithScore.withScore(Job job, double score) {
    return JobWithScore(
      job: job,
      score: score,
      scoreDetails: MatchScoreDetails(totalScore: score),
    );
  }

  /// 复制并更新状态
  JobWithScore copyWith({
    Job? job,
    double? score,
    MatchScoreDetails? scoreDetails,
    bool? isApplied,
    bool? isFavorited,
  }) {
    return JobWithScore(
      job: job ?? this.job,
      score: score ?? this.score,
      scoreDetails: scoreDetails ?? this.scoreDetails,
      isApplied: isApplied ?? this.isApplied,
      isFavorited: isFavorited ?? this.isFavorited,
    );
  }

  /// 转换为职位卡片使用的Map格式
  Map<String, dynamic> toCardMap() {
    final map = job.toCardMap();
    map['matchScore'] = score;
    map['isApplied'] = isApplied;
    map['isFavorited'] = isFavorited;
    return map;
  }
}

/// 匹配度得分详情
/// 记录各维度的匹配得分
class MatchScoreDetails {
  /// 职位类型匹配度得分（权重30%，满分30分）
  final double categoryScore;

  /// 薪资匹配度得分（权重25%，满分25分）
  final double salaryScore;

  /// 地点匹配度得分（权重20%，满分20分）
  final double locationScore;

  /// 经验匹配度得分（权重15%，满分15分）
  final double experienceScore;

  /// 新鲜度得分（权重10%，满分10分）
  final double freshnessScore;

  /// 总得分（满分100分）
  final double totalScore;

  const MatchScoreDetails({
    this.categoryScore = 0,
    this.salaryScore = 0,
    this.locationScore = 0,
    this.experienceScore = 0,
    this.freshnessScore = 0,
    required this.totalScore,
  });

  /// 从各维度得分计算总得分
  factory MatchScoreDetails.fromScores({
    required double categoryScore,
    required double salaryScore,
    required double locationScore,
    required double experienceScore,
    required double freshnessScore,
  }) {
    return MatchScoreDetails(
      categoryScore: categoryScore,
      salaryScore: salaryScore,
      locationScore: locationScore,
      experienceScore: experienceScore,
      freshnessScore: freshnessScore,
      totalScore: categoryScore +
          salaryScore +
          locationScore +
          experienceScore +
          freshnessScore,
    );
  }

  /// 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'categoryScore': categoryScore,
      'salaryScore': salaryScore,
      'locationScore': locationScore,
      'experienceScore': experienceScore,
      'freshnessScore': freshnessScore,
      'totalScore': totalScore,
    };
  }

  /// 获取匹配等级描述
  String get matchLevel {
    if (totalScore >= 80) return '高度匹配';
    if (totalScore >= 60) return '较好匹配';
    if (totalScore >= 40) return '一般匹配';
    return '待提升';
  }
}
