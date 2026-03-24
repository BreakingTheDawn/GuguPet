/// 通知类型枚举
/// 定义系统中所有可能的通知类型
enum NotificationType {
  /// 面试提醒
  interview,
  
  /// 投递状态更新
  jobStatus,
  
  /// 专栏更新
  columnUpdate,
  
  /// VIP到期提醒
  vipExpire,
  
  /// 活动通知
  activity,
  
  /// 系统公告
  system,
}

/// 通知消息模型
/// 用于存储和传输通知消息的完整信息
class Notification {
  /// 通知唯一标识ID
  final String id;
  
  /// 接收通知的用户ID
  final String userId;
  
  /// 通知类型
  final NotificationType type;
  
  /// 通知标题
  final String title;
  
  /// 通知内容
  final String content;
  
  /// 额外数据（JSON格式，用于存储通知相关的扩展信息）
  final Map<String, dynamic>? extraData;
  
  /// 是否已读
  final bool isRead;
  
  /// 是否已处理（例如：面试提醒已确认、活动已参加等）
  final bool isActioned;
  
  /// 定时通知的触发时间（用于预约通知）
  final DateTime? scheduledTime;
  
  /// 实际发送时间
  final DateTime? sentAt;
  
  /// 记录创建时间
  final DateTime createdAt;

  Notification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.content,
    this.extraData,
    this.isRead = false,
    this.isActioned = false,
    this.scheduledTime,
    this.sentAt,
    required this.createdAt,
  });

  /// 将模型转换为JSON格式
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.name,
      'title': title,
      'content': content,
      'extraData': extraData,
      'isRead': isRead,
      'isActioned': isActioned,
      'scheduledTime': scheduledTime?.toIso8601String(),
      'sentAt': sentAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// 从JSON数据创建模型实例
  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.system,
      ),
      title: json['title'] as String,
      content: json['content'] as String,
      extraData: json['extraData'] as Map<String, dynamic>?,
      isRead: json['isRead'] as bool? ?? false,
      isActioned: json['isActioned'] as bool? ?? false,
      scheduledTime: json['scheduledTime'] != null
          ? DateTime.parse(json['scheduledTime'] as String)
          : null,
      sentAt: json['sentAt'] != null
          ? DateTime.parse(json['sentAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// 从数据库Map创建模型实例
  /// 数据库字段使用下划线命名，需要映射
  factory Notification.fromDatabase(Map<String, dynamic> map) {
    return Notification(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => NotificationType.system,
      ),
      title: map['title'] as String,
      content: map['content'] as String,
      extraData: map['extra_data'] != null
          ? Map<String, dynamic>.from(map['extra_data'] as Map)
          : null,
      isRead: map['is_read'] as bool? ?? false,
      isActioned: map['is_actioned'] as bool? ?? false,
      scheduledTime: map['scheduled_time'] != null
          ? DateTime.parse(map['scheduled_time'] as String)
          : null,
      sentAt: map['sent_at'] != null
          ? DateTime.parse(map['sent_at'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// 将模型转换为数据库Map
  Map<String, dynamic> toDatabaseMap() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.name,
      'title': title,
      'content': content,
      'extra_data': extraData,
      'is_read': isRead,
      'is_actioned': isActioned,
      'scheduled_time': scheduledTime?.toIso8601String(),
      'sent_at': sentAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// 复制并修改模型属性
  Notification copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? content,
    Map<String, dynamic>? extraData,
    bool? isRead,
    bool? isActioned,
    DateTime? scheduledTime,
    DateTime? sentAt,
    DateTime? createdAt,
  }) {
    return Notification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      content: content ?? this.content,
      extraData: extraData ?? this.extraData,
      isRead: isRead ?? this.isRead,
      isActioned: isActioned ?? this.isActioned,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      sentAt: sentAt ?? this.sentAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
