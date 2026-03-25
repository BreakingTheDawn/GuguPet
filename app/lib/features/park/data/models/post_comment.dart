/// 动态评论模型
/// 用于存储用户对动态的评论
class PostComment {
  /// 评论唯一标识
  final String id;
  
  /// 所属动态ID
  final String postId;
  
  /// 评论者ID
  final String userId;
  
  /// 评论者昵称
  final String userName;
  
  /// 评论内容
  final String content;
  
  /// 创建时间
  final DateTime createdAt;

  /// 构造函数
  const PostComment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    required this.content,
    required this.createdAt,
  });

  /// 从JSON Map创建模型实例
  factory PostComment.fromJson(Map<String, dynamic> json) {
    return PostComment(
      id: json['id'] as String,
      postId: json['postId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// 从数据库Map创建模型实例
  factory PostComment.fromDatabase(Map<String, dynamic> map) {
    return PostComment(
      id: map['id'] as String,
      postId: map['post_id'] as String,
      userId: map['user_id'] as String,
      userName: map['user_name'] as String,
      content: map['content'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// 将模型转换为JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'userName': userName,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// 将模型转换为数据库Map
  Map<String, dynamic> toDatabaseMap() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'user_name': userName,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// 复制并修改部分字段
  PostComment copyWith({
    String? id,
    String? postId,
    String? userId,
    String? userName,
    String? content,
    DateTime? createdAt,
  }) {
    return PostComment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'PostComment(id: $id, userName: $userName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PostComment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
