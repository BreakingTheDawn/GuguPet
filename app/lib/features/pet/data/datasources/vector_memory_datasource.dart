import 'package:sqflite/sqflite.dart';
import '../models/vector_memory.dart';
import '../../services/retrieval_service.dart';

/// 向量记忆数据源实现
/// 负责向量记忆的持久化存储和检索
class VectorMemoryDatasourceImpl implements VectorMemoryDatasource {
  final Database _database;

  VectorMemoryDatasourceImpl(this._database);

  @override
  Future<List<VectorMemory>> getMemoriesByPetId(String petId) async {
    final maps = await _database.query(
      'vector_memories',
      where: 'pet_id = ?',
      whereArgs: [petId],
      orderBy: 'importance DESC, created_at DESC',
    );

    return maps.map((map) => VectorMemory.fromJson(map)).toList();
  }

  @override
  Future<List<VectorMemory>> getMemoriesByType(String petId, MemoryType type) async {
    final maps = await _database.query(
      'vector_memories',
      where: 'pet_id = ? AND type = ?',
      whereArgs: [petId, type.name],
      orderBy: 'importance DESC, created_at DESC',
    );

    return maps.map((map) => VectorMemory.fromJson(map)).toList();
  }

  @override
  Future<void> insertMemory(VectorMemory memory) async {
    await _database.insert(
      'vector_memories',
      memory.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteMemory(String memoryId) async {
    await _database.delete(
      'vector_memories',
      where: 'id = ?',
      whereArgs: [memoryId],
    );
  }

  @override
  Future<void> cleanExpiredMemories(String petId) async {
    final now = DateTime.now().toIso8601String();
    await _database.delete(
      'vector_memories',
      where: 'pet_id = ? AND expires_at IS NOT NULL AND expires_at < ?',
      whereArgs: [petId, now],
    );
  }

  /// 获取记忆数量
  Future<int> getMemoryCount(String petId) async {
    final result = await _database.rawQuery(
      'SELECT COUNT(*) as count FROM vector_memories WHERE pet_id = ?',
      [petId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// 批量插入记忆
  Future<void> insertMemoriesBatch(List<VectorMemory> memories) async {
    final batch = _database.batch();
    for (final memory in memories) {
      batch.insert(
        'vector_memories',
        memory.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  /// 根据ID获取单个记忆
  Future<VectorMemory?> getMemoryById(String memoryId) async {
    final maps = await _database.query(
      'vector_memories',
      where: 'id = ?',
      whereArgs: [memoryId],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return VectorMemory.fromJson(maps.first);
  }

  /// 更新记忆
  Future<void> updateMemory(VectorMemory memory) async {
    await _database.update(
      'vector_memories',
      memory.toJson(),
      where: 'id = ?',
      whereArgs: [memory.id],
    );
  }

  /// 按关键词搜索记忆内容
  Future<List<VectorMemory>> searchByContent(String petId, String keyword) async {
    final maps = await _database.query(
      'vector_memories',
      where: 'pet_id = ? AND content LIKE ?',
      whereArgs: [petId, '%$keyword%'],
      orderBy: 'importance DESC, created_at DESC',
    );

    return maps.map((map) => VectorMemory.fromJson(map)).toList();
  }

  /// 获取指定时间范围内的记忆
  Future<List<VectorMemory>> getMemoriesByTimeRange(
    String petId,
    DateTime start,
    DateTime end,
  ) async {
    final maps = await _database.query(
      'vector_memories',
      where: 'pet_id = ? AND created_at >= ? AND created_at <= ?',
      whereArgs: [petId, start.toIso8601String(), end.toIso8601String()],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => VectorMemory.fromJson(map)).toList();
  }

  /// 清除宠物的所有记忆
  Future<void> clearAllMemories(String petId) async {
    await _database.delete(
      'vector_memories',
      where: 'pet_id = ?',
      whereArgs: [petId],
    );
  }
}
