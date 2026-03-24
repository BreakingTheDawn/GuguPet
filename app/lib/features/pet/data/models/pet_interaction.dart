import 'pet_emotion.dart';

/// 互动类型枚举
enum InteractionType {
  feed,    // 喂食
  play,    // 玩耍
  pet,     // 抚摸
  confide, // 倾诉
}

/// 宠物互动记录模型
/// 记录每次互动的详细信息
class PetInteractionModel {
  final String id;
  final String petId;
  final InteractionType interactionType;
  final PetEmotionType emotionBefore;
  final PetEmotionType emotionAfter;
  final double bondChange;
  final DateTime timestamp;

  PetInteractionModel({
    required this.id,
    required this.petId,
    required this.interactionType,
    required this.emotionBefore,
    required this.emotionAfter,
    this.bondChange = 0,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'interactionType': interactionType.name,
      'emotionBefore': emotionBefore.name,
      'emotionAfter': emotionAfter.name,
      'bondChange': bondChange,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory PetInteractionModel.fromJson(Map<String, dynamic> json) {
    return PetInteractionModel(
      id: json['id'] as String,
      petId: json['petId'] as String,
      interactionType: InteractionType.values.firstWhere(
        (e) => e.name == json['interactionType'],
      ),
      emotionBefore: PetEmotionType.values.firstWhere(
        (e) => e.name == json['emotionBefore'],
      ),
      emotionAfter: PetEmotionType.values.firstWhere(
        (e) => e.name == json['emotionAfter'],
      ),
      bondChange: (json['bondChange'] as num?)?.toDouble() ?? 0,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
