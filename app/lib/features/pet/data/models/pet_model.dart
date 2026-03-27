import 'dart:convert';
import 'pet_emotion.dart';

/// 宠物数据模型
/// 存储宠物的核心数据：羁绊等级、情感状态、互动统计、外观配置
class PetModel {
  /// 宠物唯一标识
  final String petId;

  /// 所属用户ID
  final String userId;

  /// 宠物名称
  final String name;

  /// 当前情感类型
  final PetEmotionType currentEmotion;

  /// 情感值（0-100）
  final int emotionValue;

  /// 羁绊等级
  final int bondLevel;

  /// 羁绊经验值
  final double bondExp;

  /// 最后互动时间
  final DateTime lastInteractionTime;

  /// 互动统计数据
  final Map<String, dynamic> stats;

  /// 当前皮肤ID
  final String skinId;

  /// 当前配饰ID
  final String accessoryId;

  /// 已解锁皮肤列表
  final List<String> unlockedSkins;

  /// 已解锁配饰列表
  final List<String> unlockedAccessories;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
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
    this.skinId = 'default',
    this.accessoryId = 'none',
    this.unlockedSkins = const ['default'],
    this.unlockedAccessories = const ['none'],
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
    String? skinId,
    String? accessoryId,
    List<String>? unlockedSkins,
    List<String>? unlockedAccessories,
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
      skinId: skinId ?? this.skinId,
      accessoryId: accessoryId ?? this.accessoryId,
      unlockedSkins: unlockedSkins ?? this.unlockedSkins,
      unlockedAccessories: unlockedAccessories ?? this.unlockedAccessories,
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
      'skinId': skinId,
      'accessoryId': accessoryId,
      'unlockedSkins': jsonEncode(unlockedSkins),
      'unlockedAccessories': jsonEncode(unlockedAccessories),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// 从JSON反序列化
  factory PetModel.fromJson(Map<String, dynamic> json) {
    // 解析已解锁皮肤列表
    List<String> unlockedSkins = ['default'];
    if (json['unlockedSkins'] != null) {
      try {
        final skinsJson = json['unlockedSkins'];
        if (skinsJson is String && skinsJson.isNotEmpty) {
          final List<dynamic> list = jsonDecode(skinsJson);
          unlockedSkins = list.map((e) => e.toString()).toList();
        } else if (skinsJson is List) {
          unlockedSkins = skinsJson.map((e) => e.toString()).toList();
        }
      } catch (e) {
        unlockedSkins = ['default'];
      }
    }

    // 解析已解锁配饰列表
    List<String> unlockedAccessories = ['none'];
    if (json['unlockedAccessories'] != null) {
      try {
        final accessoriesJson = json['unlockedAccessories'];
        if (accessoriesJson is String && accessoriesJson.isNotEmpty) {
          final List<dynamic> list = jsonDecode(accessoriesJson);
          unlockedAccessories = list.map((e) => e.toString()).toList();
        } else if (accessoriesJson is List) {
          unlockedAccessories = accessoriesJson.map((e) => e.toString()).toList();
        }
      } catch (e) {
        unlockedAccessories = ['none'];
      }
    }

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
      skinId: json['skinId'] as String? ?? 'default',
      accessoryId: json['accessoryId'] as String? ?? 'none',
      unlockedSkins: unlockedSkins,
      unlockedAccessories: unlockedAccessories,
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
      skinId: 'default',
      accessoryId: 'none',
      unlockedSkins: ['default'],
      unlockedAccessories: ['none'],
      createdAt: now,
      updatedAt: now,
    );
  }
}
