/// 信封类型枚举
/// 定义鼓励信封的不同类型
enum EnvelopeType {
  /// 鼓励信 - 给予求职者鼓励和祝福
  encouragement,
  /// 经验分享 - 分享求职经验和技巧
  experience,
  /// 祝福信 - 祝福求职者顺利
  blessing,
}

/// 信封状态枚举
/// 定义信封的生命周期状态
enum EnvelopeStatus {
  /// 待分配 - 信封已创建，等待分配给接收者
  pending,
  /// 已分配 - 信封已分配给接收者
  assigned,
  /// 已读 - 接收者已阅读
  read,
  /// 已回复 - 接收者已回复感谢
  replied,
}

/// 鼓励信封模型
/// 用于存储上岸用户创建的鼓励信封
class WishEnvelope {
  /// 信封唯一标识
  final String id;
  
  /// 创建者ID
  final String creatorId;
  
  /// 创建者昵称
  final String creatorName;
  
  /// 创建者头像URL（预留后端对接）
  final String? creatorAvatar;
  
  /// 创建者职位（已上岸的公司/职位）
  final String? creatorTitle;
  
  /// 信封标题
  final String title;
  
  /// 信封内容
  final String content;
  
  /// 信封类型
  final EnvelopeType type;
  
  /// 信封状态
  final EnvelopeStatus status;
  
  /// 接收者ID（分配后填充）
  final String? receiverId;
  
  /// 接收者昵称（分配后填充）
  final String? receiverName;
  
  /// 分配时间
  final DateTime? assignedAt;
  
  /// 阅读时间
  final DateTime? readAt;
  
  /// 回复内容
  final String? replyContent;
  
  /// 回复时间
  final DateTime? repliedAt;
  
  /// 是否公开（其他用户可见）
  final bool isPublic;
  
  /// 点赞数
  final int likeCount;
  
  /// 创建时间
  final DateTime createdAt;

  /// 构造函数
  const WishEnvelope({
    required this.id,
    required this.creatorId,
    required this.creatorName,
    this.creatorAvatar,
    this.creatorTitle,
    required this.title,
    required this.content,
    required this.type,
    this.status = EnvelopeStatus.pending,
    this.receiverId,
    this.receiverName,
    this.assignedAt,
    this.readAt,
    this.replyContent,
    this.repliedAt,
    this.isPublic = true,
    this.likeCount = 0,
    required this.createdAt,
  });

  /// 从JSON Map创建模型实例
  factory WishEnvelope.fromJson(Map<String, dynamic> json) {
    return WishEnvelope(
      id: json['id'] as String,
      creatorId: json['creatorId'] as String,
      creatorName: json['creatorName'] as String,
      creatorAvatar: json['creatorAvatar'] as String?,
      creatorTitle: json['creatorTitle'] as String?,
      title: json['title'] as String,
      content: json['content'] as String,
      type: EnvelopeType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => EnvelopeType.encouragement,
      ),
      status: EnvelopeStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => EnvelopeStatus.pending,
      ),
      receiverId: json['receiverId'] as String?,
      receiverName: json['receiverName'] as String?,
      assignedAt: json['assignedAt'] != null
          ? DateTime.parse(json['assignedAt'] as String)
          : null,
      readAt: json['readAt'] != null
          ? DateTime.parse(json['readAt'] as String)
          : null,
      replyContent: json['replyContent'] as String?,
      repliedAt: json['repliedAt'] != null
          ? DateTime.parse(json['repliedAt'] as String)
          : null,
      isPublic: json['isPublic'] as bool? ?? true,
      likeCount: json['likeCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// 从数据库Map创建模型实例
  factory WishEnvelope.fromDatabase(Map<String, dynamic> map) {
    return WishEnvelope(
      id: map['id'] as String,
      creatorId: map['creator_id'] as String,
      creatorName: map['creator_name'] as String,
      creatorAvatar: map['creator_avatar'] as String?,
      creatorTitle: map['creator_title'] as String?,
      title: map['title'] as String,
      content: map['content'] as String,
      type: EnvelopeType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => EnvelopeType.encouragement,
      ),
      status: EnvelopeStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => EnvelopeStatus.pending,
      ),
      receiverId: map['receiver_id'] as String?,
      receiverName: map['receiver_name'] as String?,
      assignedAt: map['assigned_at'] != null
          ? DateTime.parse(map['assigned_at'] as String)
          : null,
      readAt: map['read_at'] != null
          ? DateTime.parse(map['read_at'] as String)
          : null,
      replyContent: map['reply_content'] as String?,
      repliedAt: map['replied_at'] != null
          ? DateTime.parse(map['replied_at'] as String)
          : null,
      isPublic: map['is_public'] == 1,
      likeCount: map['like_count'] as int? ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// 将模型转换为JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'creatorAvatar': creatorAvatar,
      'creatorTitle': creatorTitle,
      'title': title,
      'content': content,
      'type': type.name,
      'status': status.name,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'assignedAt': assignedAt?.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'replyContent': replyContent,
      'repliedAt': repliedAt?.toIso8601String(),
      'isPublic': isPublic,
      'likeCount': likeCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// 将模型转换为数据库Map
  Map<String, dynamic> toDatabaseMap() {
    return {
      'id': id,
      'creator_id': creatorId,
      'creator_name': creatorName,
      'creator_avatar': creatorAvatar,
      'creator_title': creatorTitle,
      'title': title,
      'content': content,
      'type': type.name,
      'status': status.name,
      'receiver_id': receiverId,
      'receiver_name': receiverName,
      'assigned_at': assignedAt?.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
      'reply_content': replyContent,
      'replied_at': repliedAt?.toIso8601String(),
      'is_public': isPublic ? 1 : 0,
      'like_count': likeCount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// 复制并修改部分字段
  WishEnvelope copyWith({
    String? id,
    String? creatorId,
    String? creatorName,
    String? creatorAvatar,
    String? creatorTitle,
    String? title,
    String? content,
    EnvelopeType? type,
    EnvelopeStatus? status,
    String? receiverId,
    String? receiverName,
    DateTime? assignedAt,
    DateTime? readAt,
    String? replyContent,
    DateTime? repliedAt,
    bool? isPublic,
    int? likeCount,
    DateTime? createdAt,
  }) {
    return WishEnvelope(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      creatorAvatar: creatorAvatar ?? this.creatorAvatar,
      creatorTitle: creatorTitle ?? this.creatorTitle,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      status: status ?? this.status,
      receiverId: receiverId ?? this.receiverId,
      receiverName: receiverName ?? this.receiverName,
      assignedAt: assignedAt ?? this.assignedAt,
      readAt: readAt ?? this.readAt,
      replyContent: replyContent ?? this.replyContent,
      repliedAt: repliedAt ?? this.repliedAt,
      isPublic: isPublic ?? this.isPublic,
      likeCount: likeCount ?? this.likeCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// 获取信封类型显示名称
  String get typeDisplayName {
    switch (type) {
      case EnvelopeType.encouragement:
        return '鼓励信';
      case EnvelopeType.experience:
        return '经验分享';
      case EnvelopeType.blessing:
        return '祝福信';
    }
  }

  /// 获取信封类型图标
  String get typeIcon {
    switch (type) {
      case EnvelopeType.encouragement:
        return '💌';
      case EnvelopeType.experience:
        return '📝';
      case EnvelopeType.blessing:
        return '🌟';
    }
  }

  /// 检查是否已分配
  bool get isAssigned => status != EnvelopeStatus.pending;

  /// 检查是否已读
  bool get isRead => status == EnvelopeStatus.read || status == EnvelopeStatus.replied;

  /// 检查是否已回复
  bool get isReplied => status == EnvelopeStatus.replied;

  @override
  String toString() {
    return 'WishEnvelope(id: $id, title: $title, type: $type, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WishEnvelope && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
