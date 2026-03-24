/// 通知设置模型
/// 用于存储用户的通知偏好设置
class NotificationSettings {
  /// 记录唯一标识ID
  final String id;
  
  /// 用户ID（唯一）
  final String userId;
  
  /// 面试提醒开关
  final bool interviewEnabled;
  
  /// 投递状态更新开关
  final bool jobStatusEnabled;
  
  /// 专栏更新开关
  final bool columnUpdateEnabled;
  
  /// VIP到期提醒开关
  final bool vipExpireEnabled;
  
  /// 活动通知开关
  final bool activityEnabled;
  
  /// 系统公告开关
  final bool systemEnabled;
  
  /// 推送总开关（关闭后所有通知都不会推送）
  final bool pushEnabled;
  
  /// 免打扰开始时间（格式：HH:mm，例如 "22:00"）
  final String? quietHoursStart;
  
  /// 免打扰结束时间（格式：HH:mm，例如 "08:00"）
  final String? quietHoursEnd;
  
  /// 记录创建时间
  final DateTime createdAt;
  
  /// 记录更新时间
  final DateTime updatedAt;

  NotificationSettings({
    required this.id,
    required this.userId,
    this.interviewEnabled = true,
    this.jobStatusEnabled = true,
    this.columnUpdateEnabled = true,
    this.vipExpireEnabled = true,
    this.activityEnabled = true,
    this.systemEnabled = true,
    this.pushEnabled = true,
    this.quietHoursStart,
    this.quietHoursEnd,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 将模型转换为JSON格式
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'interviewEnabled': interviewEnabled,
      'jobStatusEnabled': jobStatusEnabled,
      'columnUpdateEnabled': columnUpdateEnabled,
      'vipExpireEnabled': vipExpireEnabled,
      'activityEnabled': activityEnabled,
      'systemEnabled': systemEnabled,
      'pushEnabled': pushEnabled,
      'quietHoursStart': quietHoursStart,
      'quietHoursEnd': quietHoursEnd,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// 从JSON数据创建模型实例
  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      id: json['id'] as String,
      userId: json['userId'] as String,
      interviewEnabled: json['interviewEnabled'] as bool? ?? true,
      jobStatusEnabled: json['jobStatusEnabled'] as bool? ?? true,
      columnUpdateEnabled: json['columnUpdateEnabled'] as bool? ?? true,
      vipExpireEnabled: json['vipExpireEnabled'] as bool? ?? true,
      activityEnabled: json['activityEnabled'] as bool? ?? true,
      systemEnabled: json['systemEnabled'] as bool? ?? true,
      pushEnabled: json['pushEnabled'] as bool? ?? true,
      quietHoursStart: json['quietHoursStart'] as String?,
      quietHoursEnd: json['quietHoursEnd'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// 从数据库Map创建模型实例
  /// 数据库字段使用下划线命名，需要映射
  factory NotificationSettings.fromDatabase(Map<String, dynamic> map) {
    return NotificationSettings(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      interviewEnabled: map['interview_enabled'] as bool? ?? true,
      jobStatusEnabled: map['job_status_enabled'] as bool? ?? true,
      columnUpdateEnabled: map['column_update_enabled'] as bool? ?? true,
      vipExpireEnabled: map['vip_expire_enabled'] as bool? ?? true,
      activityEnabled: map['activity_enabled'] as bool? ?? true,
      systemEnabled: map['system_enabled'] as bool? ?? true,
      pushEnabled: map['push_enabled'] as bool? ?? true,
      quietHoursStart: map['quiet_hours_start'] as String?,
      quietHoursEnd: map['quiet_hours_end'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// 将模型转换为数据库Map
  Map<String, dynamic> toDatabaseMap() {
    return {
      'id': id,
      'user_id': userId,
      'interview_enabled': interviewEnabled,
      'job_status_enabled': jobStatusEnabled,
      'column_update_enabled': columnUpdateEnabled,
      'vip_expire_enabled': vipExpireEnabled,
      'activity_enabled': activityEnabled,
      'system_enabled': systemEnabled,
      'push_enabled': pushEnabled,
      'quiet_hours_start': quietHoursStart,
      'quiet_hours_end': quietHoursEnd,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// 复制并修改模型属性
  NotificationSettings copyWith({
    String? id,
    String? userId,
    bool? interviewEnabled,
    bool? jobStatusEnabled,
    bool? columnUpdateEnabled,
    bool? vipExpireEnabled,
    bool? activityEnabled,
    bool? systemEnabled,
    bool? pushEnabled,
    String? quietHoursStart,
    String? quietHoursEnd,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationSettings(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      interviewEnabled: interviewEnabled ?? this.interviewEnabled,
      jobStatusEnabled: jobStatusEnabled ?? this.jobStatusEnabled,
      columnUpdateEnabled: columnUpdateEnabled ?? this.columnUpdateEnabled,
      vipExpireEnabled: vipExpireEnabled ?? this.vipExpireEnabled,
      activityEnabled: activityEnabled ?? this.activityEnabled,
      systemEnabled: systemEnabled ?? this.systemEnabled,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 创建默认设置
  /// 所有通知类型默认开启，无免打扰时段
  factory NotificationSettings.createDefault(String id, String userId) {
    final now = DateTime.now();
    return NotificationSettings(
      id: id,
      userId: userId,
      interviewEnabled: true,
      jobStatusEnabled: true,
      columnUpdateEnabled: true,
      vipExpireEnabled: true,
      activityEnabled: true,
      systemEnabled: true,
      pushEnabled: true,
      createdAt: now,
      updatedAt: now,
    );
  }
}
