/// 记忆类型枚举
enum MemoryType {
  shortTerm,   // 短期记忆 - 24小时过期
  keyEvent,    // 关键事件 - 永久保存
  preference,  // 用户偏好 - 永久保存
}

/// 记忆分类枚举
enum MemoryCategory {
  job,       // 求职相关
  emotion,   // 情感相关
  preference,// 偏好设置
}

/// 宠物记忆数据模型
/// 存储短期记忆、关键事件、用户偏好
class PetMemoryModel {
  final String id;
  final String petId;
  final MemoryType type;
  final MemoryCategory category;
  final String key;
  final String value;
  final double importance;
  final double emotionalWeight;
  final DateTime createdAt;
  final DateTime? expiresAt;

  PetMemoryModel({
    required this.id,
    required this.petId,
    required this.type,
    required this.category,
    required this.key,
    required this.value,
    this.importance = 0.5,
    this.emotionalWeight = 0,
    required this.createdAt,
    this.expiresAt,
  });

  /// 是否已过期
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// 是否为永久记忆
  bool get isPermanent => type != MemoryType.shortTerm;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'type': type.name,
      'category': category.name,
      'key': key,
      'value': value,
      'importance': importance,
      'emotionalWeight': emotionalWeight,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }

  factory PetMemoryModel.fromJson(Map<String, dynamic> json) {
    return PetMemoryModel(
      id: json['id'] as String,
      petId: json['petId'] as String,
      type: MemoryType.values.firstWhere((e) => e.name == json['type']),
      category: MemoryCategory.values.firstWhere((e) => e.name == json['category']),
      key: json['key'] as String,
      value: json['value'] as String,
      importance: (json['importance'] as num?)?.toDouble() ?? 0.5,
      emotionalWeight: (json['emotionalWeight'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
    );
  }

  /// 创建短期记忆
  factory PetMemoryModel.shortTerm({
    required String id,
    required String petId,
    required MemoryCategory category,
    required String key,
    required String value,
    double importance = 0.5,
  }) {
    return PetMemoryModel(
      id: id,
      petId: petId,
      type: MemoryType.shortTerm,
      category: category,
      key: key,
      value: value,
      importance: importance,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
    );
  }

  /// 创建关键事件记忆
  factory PetMemoryModel.keyEvent({
    required String id,
    required String petId,
    required String key,
    required String value,
    double importance = 1.0,
    double emotionalWeight = 0,
  }) {
    return PetMemoryModel(
      id: id,
      petId: petId,
      type: MemoryType.keyEvent,
      category: MemoryCategory.job,
      key: key,
      value: value,
      importance: importance,
      emotionalWeight: emotionalWeight,
      createdAt: DateTime.now(),
    );
  }
}
