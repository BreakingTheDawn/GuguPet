/// 宠物成长记录模型
/// 记录羁绊等级提升历史
class PetGrowthRecordModel {
  final String id;
  final String petId;
  final int fromLevel;
  final int toLevel;
  final double totalExp;
  final DateTime achievedAt;

  PetGrowthRecordModel({
    required this.id,
    required this.petId,
    required this.fromLevel,
    required this.toLevel,
    required this.totalExp,
    required this.achievedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'fromLevel': fromLevel,
      'toLevel': toLevel,
      'totalExp': totalExp,
      'achievedAt': achievedAt.toIso8601String(),
    };
  }

  factory PetGrowthRecordModel.fromJson(Map<String, dynamic> json) {
    return PetGrowthRecordModel(
      id: json['id'] as String,
      petId: json['petId'] as String,
      fromLevel: json['fromLevel'] as int,
      toLevel: json['toLevel'] as int,
      totalExp: (json['totalExp'] as num).toDouble(),
      achievedAt: DateTime.parse(json['achievedAt'] as String),
    );
  }
}
