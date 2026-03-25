/// 动态类型枚举
/// 定义用户动态的不同类型
enum PostType {
  /// 求职经验分享
  experience,
  /// 面试经历分享
  interview,
  /// Offer庆祝动态
  offer,
  /// 日常动态
  daily,
}

/// 用户动态模型
/// 用于存储用户发布的动态内容
class UserPost {
  /// 动态唯一标识
  final String id;
  
  /// 发布者ID
  final String userId;
  
  /// 发布者昵称
  final String userName;
  
  /// 发布者头像URL（预留后端对接）
  final String? userAvatar;
  
  /// 动态内容
  final String content;
  
  /// 图片列表
  final List<String> images;
  
  /// 动态类型
  final PostType type;
  
  /// 点赞数
  final int likeCount;
  
  /// 评论数
  final int commentCount;
  
  /// 发布时间
  final DateTime createdAt;

  /// 构造函数
  const UserPost({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.content,
    this.images = const [],
    required this.type,
    this.likeCount = 0,
    this.commentCount = 0,
    required this.createdAt,
  });

  /// 从JSON Map创建模型实例
  factory UserPost.fromJson(Map<String, dynamic> json) {
    return UserPost(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userAvatar: json['userAvatar'] as String?,
      content: json['content'] as String,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      type: PostType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PostType.daily,
      ),
      likeCount: json['likeCount'] as int? ?? 0,
      commentCount: json['commentCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// 从数据库Map创建模型实例
  factory UserPost.fromDatabase(Map<String, dynamic> map) {
    return UserPost(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      userName: map['user_name'] as String,
      userAvatar: map['user_avatar'] as String?,
      content: map['content'] as String,
      images: map['images'] != null
          ? (map['images'] as String).split(',').where((s) => s.isNotEmpty).toList()
          : [],
      type: PostType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => PostType.daily,
      ),
      likeCount: map['like_count'] as int? ?? 0,
      commentCount: map['comment_count'] as int? ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// 将模型转换为JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'content': content,
      'images': images,
      'type': type.name,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// 将模型转换为数据库Map
  Map<String, dynamic> toDatabaseMap() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'user_avatar': userAvatar,
      'content': content,
      'images': images.join(','),
      'type': type.name,
      'like_count': likeCount,
      'comment_count': commentCount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// 复制并修改部分字段
  UserPost copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatar,
    String? content,
    List<String>? images,
    PostType? type,
    int? likeCount,
    int? commentCount,
    DateTime? createdAt,
  }) {
    return UserPost(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      content: content ?? this.content,
      images: images ?? this.images,
      type: type ?? this.type,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'UserPost(id: $id, userName: $userName, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserPost && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
