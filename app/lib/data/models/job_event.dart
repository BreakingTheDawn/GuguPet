/// 求职事件模型
/// 用于记录用户的求职相关事件（投递、面试、Offer、拒信等）
class JobEvent {
  /// 事件唯一标识
  final String id;
  
  /// 所属用户ID
  final String userId;
  
  /// 事件类型（投递、面试、Offer、拒信等）
  final String eventType;
  
  /// 事件内容描述
  final String eventContent;
  
  /// 公司名称
  final String? companyName;
  
  /// 职位名称
  final String? positionName;
  
  /// 事件发生时间
  final DateTime eventTime;
  
  /// 记录创建时间
  final DateTime? createdAt;

  JobEvent({
    required this.id,
    required this.userId,
    required this.eventType,
    required this.eventContent,
    this.companyName,
    this.positionName,
    required this.eventTime,
    this.createdAt,
  });

  /// 将模型转换为JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'eventType': eventType,
      'eventContent': eventContent,
      'companyName': companyName,
      'positionName': positionName,
      'eventTime': eventTime.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  /// 从JSON Map创建模型实例
  factory JobEvent.fromJson(Map<String, dynamic> json) {
    return JobEvent(
      id: json['id'] as String,
      userId: json['userId'] as String,
      eventType: json['eventType'] as String,
      eventContent: json['eventContent'] as String,
      companyName: json['companyName'] as String?,
      positionName: json['positionName'] as String?,
      eventTime: DateTime.parse(json['eventTime'] as String),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  /// 从数据库Map创建模型实例
  /// 数据库字段使用下划线命名，需要映射
  factory JobEvent.fromDatabase(Map<String, dynamic> map) {
    return JobEvent(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      eventType: map['event_type'] as String,
      eventContent: map['event_content'] as String,
      companyName: map['company_name'] as String?,
      positionName: map['position_name'] as String?,
      eventTime: DateTime.parse(map['event_time'] as String),
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }

  /// 将模型转换为数据库Map
  Map<String, dynamic> toDatabaseMap() {
    return {
      'id': id,
      'user_id': userId,
      'event_type': eventType,
      'event_content': eventContent,
      'company_name': companyName,
      'position_name': positionName,
      'event_time': eventTime.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
