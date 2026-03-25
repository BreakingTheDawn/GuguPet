/// 互动类型枚举
/// 定义公园内用户之间的互动类型
enum InteractionType {
  /// 抚摸宠物
  pet,
  /// 打招呼
  greet,
  /// 送礼物
  gift,
  /// 点赞
  like,
}

/// 公园互动记录模型
/// 用于记录用户在公园内的互动行为
class ParkInteraction {
  /// 互动唯一标识
  final String id;
  
  /// 发起者ID
  final String userId;
  
  /// 目标用户ID
  final String targetId;
  
  /// 互动类型
  final InteractionType type;
  
  /// 创建时间
  final DateTime createdAt;

  /// 构造函数
  const ParkInteraction({
    required this.id,
    required this.userId,
    required this.targetId,
    required this.type,
    required this.createdAt,
  });

  /// 从JSON Map创建模型实例
  factory ParkInteraction.fromJson(Map<String, dynamic> json) {
    return ParkInteraction(
      id: json['id'] as String,
      userId: json['userId'] as String,
      targetId: json['targetId'] as String,
      type: InteractionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => InteractionType.greet,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// 从数据库Map创建模型实例
  factory ParkInteraction.fromDatabase(Map<String, dynamic> map) {
    return ParkInteraction(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      targetId: map['target_id'] as String,
      type: InteractionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => InteractionType.greet,
      ),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// 将模型转换为JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'targetId': targetId,
      'type': type.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// 将模型转换为数据库Map
  Map<String, dynamic> toDatabaseMap() {
    return {
      'id': id,
      'user_id': userId,
      'target_id': targetId,
      'type': type.name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// 复制并修改部分字段
  ParkInteraction copyWith({
    String? id,
    String? userId,
    String? targetId,
    InteractionType? type,
    DateTime? createdAt,
  }) {
    return ParkInteraction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      targetId: targetId ?? this.targetId,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'ParkInteraction(id: $id, type: $type, targetId: $targetId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ParkInteraction && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
