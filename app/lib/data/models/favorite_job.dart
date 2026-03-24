/// 收藏职位模型
/// 用于存储用户收藏的职位信息
class FavoriteJob {
  /// 收藏记录唯一标识
  final String id;
  
  /// 所属用户ID
  final String userId;
  
  /// 职位ID
  final String jobId;
  
  /// 职位标题
  final String? jobTitle;
  
  /// 公司名称
  final String? companyName;
  
  /// 薪资范围
  final String? salaryRange;
  
  /// 工作地点
  final String? jobLocation;
  
  /// 职位标签（JSON数组字符串）
  final List<String>? jobTags;
  
  /// 收藏时间
  final DateTime? createdAt;

  FavoriteJob({
    required this.id,
    required this.userId,
    required this.jobId,
    this.jobTitle,
    this.companyName,
    this.salaryRange,
    this.jobLocation,
    this.jobTags,
    this.createdAt,
  });

  /// 将模型转换为JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'jobId': jobId,
      'jobTitle': jobTitle,
      'companyName': companyName,
      'salaryRange': salaryRange,
      'jobLocation': jobLocation,
      'jobTags': jobTags,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  /// 从JSON Map创建模型实例
  factory FavoriteJob.fromJson(Map<String, dynamic> json) {
    return FavoriteJob(
      id: json['id'] as String,
      userId: json['userId'] as String,
      jobId: json['jobId'] as String,
      jobTitle: json['jobTitle'] as String?,
      companyName: json['companyName'] as String?,
      salaryRange: json['salaryRange'] as String?,
      jobLocation: json['jobLocation'] as String?,
      jobTags: json['jobTags'] != null
          ? List<String>.from(json['jobTags'] as List<dynamic>)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  /// 从数据库Map创建模型实例
  /// 数据库中jobTags存储为JSON字符串，需要解析
  factory FavoriteJob.fromDatabase(Map<String, dynamic> map) {
    // 解析jobTags JSON字符串
    List<String>? jobTags;
    final jobTagsStr = map['job_tags'] as String?;
    if (jobTagsStr != null && jobTagsStr.isNotEmpty) {
      try {
        final tagsList = jobTagsStr.split(',');
        jobTags = tagsList.where((t) => t.isNotEmpty).toList();
      } catch (e) {
        // 解析失败时保持为null
      }
    }

    return FavoriteJob(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      jobId: map['job_id'] as String,
      jobTitle: map['job_title'] as String?,
      companyName: map['company_name'] as String?,
      salaryRange: map['salary_range'] as String?,
      jobLocation: map['job_location'] as String?,
      jobTags: jobTags,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }

  /// 将模型转换为数据库Map
  /// jobTags转换为逗号分隔的字符串存储
  Map<String, dynamic> toDatabaseMap() {
    return {
      'id': id,
      'user_id': userId,
      'job_id': jobId,
      'job_title': jobTitle,
      'company_name': companyName,
      'salary_range': salaryRange,
      'job_location': jobLocation,
      'job_tags': jobTags?.join(','),
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
