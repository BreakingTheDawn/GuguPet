/// 交互记录模型
/// 用于记录用户与宠物的交互历史
class Interaction {
  /// 交互记录唯一标识
  final String id;
  
  /// 所属用户ID
  final String userId;
  
  /// 交互内容
  final String content;
  
  /// 动作类型
  final String actionType;
  
  /// 情绪类型
  final String emotionType;
  
  /// 宠物动作
  final String petAction;
  
  /// 宠物气泡文字
  final String petBubble;
  
  /// 创建时间
  final DateTime createdAt;
  
  /// 更新时间
  final DateTime? updatedAt;

  Interaction({
    required this.id,
    required this.userId,
    required this.content,
    required this.actionType,
    required this.emotionType,
    required this.petAction,
    required this.petBubble,
    required this.createdAt,
    this.updatedAt,
  });

  /// 将模型转换为JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'content': content,
      'actionType': actionType,
      'emotionType': emotionType,
      'petAction': petAction,
      'petBubble': petBubble,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// 从JSON Map创建模型实例
  factory Interaction.fromJson(Map<String, dynamic> json) {
    return Interaction(
      id: json['id'] as String,
      userId: json['userId'] as String,
      content: json['content'] as String,
      actionType: json['actionType'] as String,
      emotionType: json['emotionType'] as String,
      petAction: json['petAction'] as String,
      petBubble: json['petBubble'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// 从数据库Map创建模型实例
  /// 数据库字段使用下划线命名，需要映射
  factory Interaction.fromDatabase(Map<String, dynamic> map) {
    return Interaction(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      content: map['content'] as String,
      actionType: map['action_type'] as String,
      emotionType: map['emotion_type'] as String,
      petAction: map['pet_action'] as String,
      petBubble: map['pet_bubble'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  /// 将模型转换为数据库Map
  Map<String, dynamic> toDatabaseMap() {
    return {
      'id': id,
      'user_id': userId,
      'content': content,
      'action_type': actionType,
      'emotion_type': emotionType,
      'pet_action': petAction,
      'pet_bubble': petBubble,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
