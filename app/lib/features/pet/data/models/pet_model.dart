import 'pet_emotion.dart';

/// 宠物数据模型
/// 存储宠物的核心数据：羁绊等级、情感状态、互动统计
class PetModel {
  final String petId;
  final String userId;
  final String name;
  final PetEmotionType currentEmotion;
  final int emotionValue;
  final int bondLevel;
  final double bondExp;
  final DateTime lastInteractionTime;
  final Map<String, dynamic> stats;
  final DateTime createdAt;
  final DateTime updatedAt;

  PetModel({
    required this.petId,
    required this.userId,
    this.name = '咕咕',
    this.currentEmotion = PetEmotionType.normal,
    this.emotionValue = 50,
    this.bondLevel = 1,
    this.bondExp = 0,
    required this.lastInteractionTime,
    this.stats = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  /// 复制并更新部分字段
  PetModel copyWith({
    String? petId,
    String? userId,
    String? name,
    PetEmotionType? currentEmotion,
    int? emotionValue,
    int? bondLevel,
    double? bondExp,
    DateTime? lastInteractionTime,
    Map<String, dynamic>? stats,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PetModel(
      petId: petId ?? this.petId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      currentEmotion: currentEmotion ?? this.currentEmotion,
      emotionValue: emotionValue ?? this.emotionValue,
      bondLevel: bondLevel ?? this.bondLevel,
      bondExp: bondExp ?? this.bondExp,
      lastInteractionTime: lastInteractionTime ?? this.lastInteractionTime,
      stats: stats ?? this.stats,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 序列化为JSON
  Map<String, dynamic> toJson() {
    return {
      'petId': petId,
      'userId': userId,
      'name': name,
      'currentEmotion': currentEmotion.name,
      'emotionValue': emotionValue,
      'bondLevel': bondLevel,
      'bondExp': bondExp,
      'lastInteractionTime': lastInteractionTime.toIso8601String(),
      'stats': stats,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// 从JSON反序列化
  factory PetModel.fromJson(Map<String, dynamic> json) {
    return PetModel(
      petId: json['petId'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String? ?? '咕咕',
      currentEmotion: PetEmotionType.values.firstWhere(
        (e) => e.name == json['currentEmotion'],
        orElse: () => PetEmotionType.normal,
      ),
      emotionValue: json['emotionValue'] as int? ?? 50,
      bondLevel: json['bondLevel'] as int? ?? 1,
      bondExp: (json['bondExp'] as num?)?.toDouble() ?? 0,
      lastInteractionTime: json['lastInteractionTime'] != null
          ? DateTime.parse(json['lastInteractionTime'] as String)
          : DateTime.now(),
      stats: json['stats'] as Map<String, dynamic>? ?? {},
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  /// 创建默认宠物
  factory PetModel.createDefault(String userId) {
    final now = DateTime.now();
    return PetModel(
      petId: 'pet_${userId}_${now.millisecondsSinceEpoch}',
      userId: userId,
      lastInteractionTime: now,
      createdAt: now,
      updatedAt: now,
    );
  }
}
