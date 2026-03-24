import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../../../data/datasources/local/database_helper.dart';
import '../models/pet_model.dart';
import '../models/pet_emotion.dart';
import '../models/pet_memory.dart';
import '../models/pet_interaction.dart';
import '../models/pet_growth_record.dart';

/// 宠物本地数据源
/// 负责宠物数据的SQLite存储和读取
class PetLocalDatasource {
  final DatabaseHelper _databaseHelper;

  PetLocalDatasource({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper();

  /// 获取数据库实例
  Future<Database> get _db async => await _databaseHelper.database;

  // ==================== 宠物主表操作 ====================

  /// 创建宠物
  Future<void> insertPet(PetModel pet) async {
    final db = await _db;
    await db.insert(
      'pets',
      _petModelToDb(pet),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 根据用户ID获取宠物
  Future<PetModel?> getPetByUserId(String userId) async {
    final db = await _db;
    final results = await db.query(
      'pets',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    if (results.isEmpty) return null;
    return _petModelFromDb(results.first);
  }

  /// 更新宠物
  Future<void> updatePet(PetModel pet) async {
    final db = await _db;
    await db.update(
      'pets',
      _petModelToDb(pet),
      where: 'id = ?',
      whereArgs: [pet.petId],
    );
  }

  // ==================== 记忆表操作 ====================

  /// 插入记忆
  Future<void> insertMemory(PetMemoryModel memory) async {
    final db = await _db;
    await db.insert(
      'pet_memories',
      memory.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 获取宠物的所有有效记忆
  Future<List<PetMemoryModel>> getMemories(String petId) async {
    final db = await _db;
    final results = await db.query(
      'pet_memories',
      where: 'pet_id = ? AND (expires_at IS NULL OR expires_at > ?)',
      whereArgs: [petId, DateTime.now().toIso8601String()],
      orderBy: 'importance DESC, created_at DESC',
    );
    return results.map((json) => PetMemoryModel.fromJson(json)).toList();
  }

  /// 获取指定类型的记忆
  Future<List<PetMemoryModel>> getMemoriesByType(
    String petId,
    MemoryType type,
  ) async {
    final db = await _db;
    final results = await db.query(
      'pet_memories',
      where: 'pet_id = ? AND type = ? AND (expires_at IS NULL OR expires_at > ?)',
      whereArgs: [petId, type.name, DateTime.now().toIso8601String()],
      orderBy: 'importance DESC, created_at DESC',
    );
    return results.map((json) => PetMemoryModel.fromJson(json)).toList();
  }

  /// 清理过期记忆
  Future<int> cleanExpiredMemories(String petId) async {
    final db = await _db;
    return await db.delete(
      'pet_memories',
      where: 'pet_id = ? AND expires_at IS NOT NULL AND expires_at < ?',
      whereArgs: [petId, DateTime.now().toIso8601String()],
    );
  }

  // ==================== 互动记录操作 ====================

  /// 插入互动记录
  Future<void> insertInteraction(PetInteractionModel interaction) async {
    final db = await _db;
    await db.insert('pet_interactions', interaction.toJson());
  }

  /// 获取最近的互动记录
  Future<List<PetInteractionModel>> getRecentInteractions(
    String petId, {
    int limit = 10,
  }) async {
    final db = await _db;
    final results = await db.query(
      'pet_interactions',
      where: 'pet_id = ?',
      whereArgs: [petId],
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return results.map((json) => PetInteractionModel.fromJson(json)).toList();
  }

  // ==================== 成长记录操作 ====================

  /// 插入成长记录
  Future<void> insertGrowthRecord(PetGrowthRecordModel record) async {
    final db = await _db;
    await db.insert('pet_growth_records', record.toJson());
  }

  /// 获取成长历史
  Future<List<PetGrowthRecordModel>> getGrowthRecords(String petId) async {
    final db = await _db;
    final results = await db.query(
      'pet_growth_records',
      where: 'pet_id = ?',
      whereArgs: [petId],
      orderBy: 'achieved_at DESC',
    );
    return results.map((json) => PetGrowthRecordModel.fromJson(json)).toList();
  }

  // ==================== 数据转换辅助方法 ====================

  /// 将PetModel转换为数据库格式
  Map<String, dynamic> _petModelToDb(PetModel pet) {
    return {
      'id': pet.petId,
      'user_id': pet.userId,
      'name': pet.name,
      'current_emotion': pet.currentEmotion.name,
      'emotion_value': pet.emotionValue,
      'bond_level': pet.bondLevel,
      'bond_exp': pet.bondExp,
      'last_interaction_time': pet.lastInteractionTime.toIso8601String(),
      'stats': jsonEncode(pet.stats),
      'created_at': pet.createdAt.toIso8601String(),
      'updated_at': pet.updatedAt.toIso8601String(),
    };
  }

  /// 从数据库格式转换为PetModel
  PetModel _petModelFromDb(Map<String, dynamic> json) {
    return PetModel(
      petId: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String? ?? '咕咕',
      currentEmotion: PetEmotionType.values.firstWhere(
        (e) => e.name == json['current_emotion'],
        orElse: () => PetEmotionType.normal,
      ),
      emotionValue: json['emotion_value'] as int? ?? 50,
      bondLevel: json['bond_level'] as int? ?? 1,
      bondExp: (json['bond_exp'] as num?)?.toDouble() ?? 0,
      lastInteractionTime: json['last_interaction_time'] != null
          ? DateTime.parse(json['last_interaction_time'] as String)
          : DateTime.now(),
      stats: json['stats'] != null
          ? jsonDecode(json['stats'] as String) as Map<String, dynamic>
          : {},
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }
}
