/// 好友状态枚举
/// 定义好友关系的不同状态
enum FriendStatus {
  /// 待确认 - 好友申请已发送，等待对方确认
  pending,
  /// 已接受 - 双方已成为好友
  accepted,
  /// 已拉黑 - 已将对方加入黑名单
  blocked,
}

/// 好友关系模型
/// 用于存储用户之间的好友关系
class Friend {
  /// 关系唯一标识
  final String id;
  
  /// 当前用户ID
  final String userId;
  
  /// 好友用户ID
  final String friendId;
  
  /// 好友昵称
  final String friendName;
  
  /// 好友头像URL（预留后端对接）
  final String? friendAvatar;
  
  /// 好友职位标签
  final String? friendTitle;
  
  /// 好友状态
  final FriendStatus status;
  
  /// 添加时间
  final DateTime? addedAt;
  
  /// 最后互动时间
  final DateTime? lastInteract;
  
  /// 创建时间
  final DateTime createdAt;

  /// 构造函数
  const Friend({
    required this.id,
    required this.userId,
    required this.friendId,
    required this.friendName,
    this.friendAvatar,
    this.friendTitle,
    required this.status,
    this.addedAt,
    this.lastInteract,
    required this.createdAt,
  });

  /// 从JSON Map创建模型实例
  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'] as String,
      userId: json['userId'] as String,
      friendId: json['friendId'] as String,
      friendName: json['friendName'] as String,
      friendAvatar: json['friendAvatar'] as String?,
      friendTitle: json['friendTitle'] as String?,
      status: FriendStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => FriendStatus.pending,
      ),
      addedAt: json['addedAt'] != null
          ? DateTime.parse(json['addedAt'] as String)
          : null,
      lastInteract: json['lastInteract'] != null
          ? DateTime.parse(json['lastInteract'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// 从数据库Map创建模型实例
  /// 数据库字段使用下划线命名，需要映射
  factory Friend.fromDatabase(Map<String, dynamic> map) {
    return Friend(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      friendId: map['friend_id'] as String,
      friendName: map['friend_name'] as String,
      friendAvatar: map['friend_avatar'] as String?,
      friendTitle: map['friend_title'] as String?,
      status: FriendStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => FriendStatus.pending,
      ),
      addedAt: map['added_at'] != null
          ? DateTime.parse(map['added_at'] as String)
          : null,
      lastInteract: map['last_interact'] != null
          ? DateTime.parse(map['last_interact'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// 将模型转换为JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'friendId': friendId,
      'friendName': friendName,
      'friendAvatar': friendAvatar,
      'friendTitle': friendTitle,
      'status': status.name,
      'addedAt': addedAt?.toIso8601String(),
      'lastInteract': lastInteract?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// 将模型转换为数据库Map
  Map<String, dynamic> toDatabaseMap() {
    return {
      'id': id,
      'user_id': userId,
      'friend_id': friendId,
      'friend_name': friendName,
      'friend_avatar': friendAvatar,
      'friend_title': friendTitle,
      'status': status.name,
      'added_at': addedAt?.toIso8601String(),
      'last_interact': lastInteract?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// 复制并修改部分字段
  Friend copyWith({
    String? id,
    String? userId,
    String? friendId,
    String? friendName,
    String? friendAvatar,
    String? friendTitle,
    FriendStatus? status,
    DateTime? addedAt,
    DateTime? lastInteract,
    DateTime? createdAt,
  }) {
    return Friend(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      friendId: friendId ?? this.friendId,
      friendName: friendName ?? this.friendName,
      friendAvatar: friendAvatar ?? this.friendAvatar,
      friendTitle: friendTitle ?? this.friendTitle,
      status: status ?? this.status,
      addedAt: addedAt ?? this.addedAt,
      lastInteract: lastInteract ?? this.lastInteract,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Friend(id: $id, friendName: $friendName, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Friend && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
