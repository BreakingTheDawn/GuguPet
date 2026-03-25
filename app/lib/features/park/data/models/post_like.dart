/// 点赞记录模型
/// 用于存储用户对动态的点赞记录
class PostLike {
  /// 记录唯一标识
  final String id;
  
  /// 动态ID
  final String postId;
  
  /// 点赞用户ID
  final String userId;
  
  /// 创建时间
  final DateTime createdAt;

  /// 构造函数
  const PostLike({
    required this.id,
    required this.postId,
    required this.userId,
    required this.createdAt,
  });

  /// 从JSON Map创建模型实例
  factory PostLike.fromJson(Map<String, dynamic> json) {
    return PostLike(
      id: json['id'] as String,
      postId: json['postId'] as String,
      userId: json['userId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// 从数据库Map创建模型实例
  factory PostLike.fromDatabase(Map<String, dynamic> map) {
    return PostLike(
      id: map['id'] as String,
      postId: map['post_id'] as String,
      userId: map['user_id'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// 将模型转换为JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// 将模型转换为数据库Map
  Map<String, dynamic> toDatabaseMap() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'PostLike(id: $id, postId: $postId, userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PostLike && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
