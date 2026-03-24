/// 收藏记录模型
/// 用于存储用户收藏专栏的记录信息
class FavoriteColumn {
  /// 记录唯一标识ID
  final String id;

  /// 用户ID
  final String userId;

  /// 专栏ID
  final String columnId;

  /// 专栏标题（用于收藏列表显示）
  final String? columnTitle;

  /// 收藏时间
  final DateTime createdAt;

  FavoriteColumn({
    required this.id,
    required this.userId,
    required this.columnId,
    this.columnTitle,
    required this.createdAt,
  });

  /// 将模型转换为JSON格式
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'columnId': columnId,
      'columnTitle': columnTitle,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// 从JSON数据创建模型实例
  factory FavoriteColumn.fromJson(Map<String, dynamic> json) {
    return FavoriteColumn(
      id: json['id'] as String,
      userId: json['userId'] as String,
      columnId: json['columnId'] as String,
      columnTitle: json['columnTitle'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// 复制并修改模型属性
  FavoriteColumn copyWith({
    String? id,
    String? userId,
    String? columnId,
    String? columnTitle,
    DateTime? createdAt,
  }) {
    return FavoriteColumn(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      columnId: columnId ?? this.columnId,
      columnTitle: columnTitle ?? this.columnTitle,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
