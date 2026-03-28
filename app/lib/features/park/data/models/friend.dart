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

/// 在线状态枚举
/// 定义用户的在线状态
enum OnlineStatus {
  /// 离线
  offline,
  /// 在线
  online,
  /// 忙碌
  busy,
  /// 离开
  away,
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
  
  /// 在线状态
  final OnlineStatus onlineStatus;
  
  /// 最后活跃时间
  final DateTime? lastActiveAt;
  
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
    this.onlineStatus = OnlineStatus.offline,
    this.lastActiveAt,
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
      onlineStatus: OnlineStatus.values.firstWhere(
        (e) => e.name == json['onlineStatus'],
        orElse: () => OnlineStatus.offline,
      ),
      lastActiveAt: json['lastActiveAt'] != null
          ? DateTime.parse(json['lastActiveAt'] as String)
          : null,
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
      onlineStatus: OnlineStatus.values.firstWhere(
        (e) => e.name == map['online_status'],
        orElse: () => OnlineStatus.offline,
      ),
      lastActiveAt: map['last_active_at'] != null
          ? DateTime.parse(map['last_active_at'] as String)
          : null,
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
      'onlineStatus': onlineStatus.name,
      'lastActiveAt': lastActiveAt?.toIso8601String(),
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
      'online_status': onlineStatus.name,
      'last_active_at': lastActiveAt?.toIso8601String(),
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
    OnlineStatus? onlineStatus,
    DateTime? lastActiveAt,
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
      onlineStatus: onlineStatus ?? this.onlineStatus,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      addedAt: addedAt ?? this.addedAt,
      lastInteract: lastInteract ?? this.lastInteract,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// 检查是否在线
  bool get isOnline => onlineStatus == OnlineStatus.online;

  /// 获取在线状态显示文本
  String get onlineStatusText {
    switch (onlineStatus) {
      case OnlineStatus.online:
        return '在线';
      case OnlineStatus.busy:
        return '忙碌';
      case OnlineStatus.away:
        return '离开';
      case OnlineStatus.offline:
        if (lastActiveAt != null) {
          return '上次在线: ${_formatLastActive(lastActiveAt!)}';
        }
        return '离线';
    }
  }

  /// 格式化最后活跃时间
  String _formatLastActive(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    
    if (diff.inMinutes < 1) {
      return '刚刚';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}分钟前';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}小时前';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}天前';
    } else {
      return '${time.month}月${time.day}日';
    }
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
