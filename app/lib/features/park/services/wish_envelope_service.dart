import 'package:sqflite/sqflite.dart';
import '../data/models/models.dart';

// ═══════════════════════════════════════════════════════════════════════════════
/// 许愿树信封服务
/// 负责鼓励信封的创建、分配、查询等业务逻辑
// ═══════════════════════════════════════════════════════════════════════════════
class WishEnvelopeService {
  // ────────────────────────────────────────────────────────────────────────────
  // 依赖注入
  // ────────────────────────────────────────────────────────────────────────────

  final Database _database;

  WishEnvelopeService({required Database database}) : _database = database;

  // ────────────────────────────────────────────────────────────────────────────
  // 信封创建方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 创建鼓励信封
  Future<WishEnvelope> createEnvelope(WishEnvelope envelope) async {
    await _database.insert(
      'wish_envelopes',
      envelope.toDatabaseMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return envelope;
  }

  /// 批量创建信封
  Future<void> createEnvelopes(List<WishEnvelope> envelopes) async {
    final batch = _database.batch();
    for (final envelope in envelopes) {
      batch.insert(
        'wish_envelopes',
        envelope.toDatabaseMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 信封查询方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 获取待分配的信封列表
  Future<List<WishEnvelope>> getPendingEnvelopes({int? limit}) async {
    final List<Map<String, dynamic>> maps = await _database.query(
      'wish_envelopes',
      where: 'status = ?',
      whereArgs: ['pending'],
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return maps.map((map) => WishEnvelope.fromDatabase(map)).toList();
  }

  /// 获取公开的信封列表（许愿树展示）
  Future<List<WishEnvelope>> getPublicEnvelopes({
    int? limit,
    int? offset,
  }) async {
    final List<Map<String, dynamic>> maps = await _database.query(
      'wish_envelopes',
      where: 'is_public = ?',
      whereArgs: [1],
      orderBy: 'created_at DESC',
      limit: limit,
      offset: offset,
    );
    return maps.map((map) => WishEnvelope.fromDatabase(map)).toList();
  }

  /// 获取用户创建的信封列表
  Future<List<WishEnvelope>> getEnvelopesByCreator(
    String creatorId, {
    int? limit,
  }) async {
    final List<Map<String, dynamic>> maps = await _database.query(
      'wish_envelopes',
      where: 'creator_id = ?',
      whereArgs: [creatorId],
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return maps.map((map) => WishEnvelope.fromDatabase(map)).toList();
  }

  /// 获取用户收到的信封列表
  Future<List<WishEnvelope>> getEnvelopesByReceiver(
    String receiverId, {
    int? limit,
  }) async {
    final List<Map<String, dynamic>> maps = await _database.query(
      'wish_envelopes',
      where: 'receiver_id = ?',
      whereArgs: [receiverId],
      orderBy: 'assigned_at DESC',
      limit: limit,
    );
    return maps.map((map) => WishEnvelope.fromDatabase(map)).toList();
  }

  /// 获取信封详情
  Future<WishEnvelope?> getEnvelope(String envelopeId) async {
    final List<Map<String, dynamic>> maps = await _database.query(
      'wish_envelopes',
      where: 'id = ?',
      whereArgs: [envelopeId],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return WishEnvelope.fromDatabase(maps.first);
  }

  /// 获取未读信封数量
  Future<int> getUnreadCount(String receiverId) async {
    final result = await _database.rawQuery(
      'SELECT COUNT(*) as count FROM wish_envelopes WHERE receiver_id = ? AND status = ?',
      [receiverId, 'assigned'],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// 按类型获取信封列表
  Future<List<WishEnvelope>> getEnvelopesByType(
    EnvelopeType type, {
    int? limit,
  }) async {
    final List<Map<String, dynamic>> maps = await _database.query(
      'wish_envelopes',
      where: 'type = ? AND is_public = ?',
      whereArgs: [type.name, 1],
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return maps.map((map) => WishEnvelope.fromDatabase(map)).toList();
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 信封分配方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 分配信封给用户
  Future<bool> assignEnvelope(
    String envelopeId,
    String receiverId,
    String receiverName,
  ) async {
    final count = await _database.update(
      'wish_envelopes',
      {
        'receiver_id': receiverId,
        'receiver_name': receiverName,
        'status': 'assigned',
        'assigned_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ? AND status = ?',
      whereArgs: [envelopeId, 'pending'],
    );
    return count > 0;
  }

  /// 随机分配信封给用户
  Future<WishEnvelope?> randomAssignEnvelope(
    String receiverId,
    String receiverName,
  ) async {
    final pending = await getPendingEnvelopes(limit: 1);
    if (pending.isEmpty) return null;

    final envelope = pending.first;
    final success = await assignEnvelope(envelope.id, receiverId, receiverName);
    
    if (success) {
      return envelope.copyWith(
        receiverId: receiverId,
        receiverName: receiverName,
        status: EnvelopeStatus.assigned,
        assignedAt: DateTime.now(),
      );
    }
    return null;
  }

  /// 获取待分配信封数量
  Future<int> getPendingCount() async {
    final result = await _database.rawQuery(
      'SELECT COUNT(*) as count FROM wish_envelopes WHERE status = ?',
      ['pending'],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 信封状态更新方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 标记信封为已读
  Future<bool> markAsRead(String envelopeId) async {
    final count = await _database.update(
      'wish_envelopes',
      {
        'status': 'read',
        'read_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ? AND status = ?',
      whereArgs: [envelopeId, 'assigned'],
    );
    return count > 0;
  }

  /// 回复信封
  Future<bool> replyEnvelope(String envelopeId, String replyContent) async {
    final count = await _database.update(
      'wish_envelopes',
      {
        'status': 'replied',
        'reply_content': replyContent,
        'replied_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [envelopeId],
    );
    return count > 0;
  }

  /// 点赞信封
  Future<bool> likeEnvelope(String envelopeId) async {
    await _database.rawQuery(
      'UPDATE wish_envelopes SET like_count = like_count + 1 WHERE id = ?',
      [envelopeId],
    );
    return true;
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 信封删除方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 删除信封
  Future<bool> deleteEnvelope(String envelopeId) async {
    final count = await _database.delete(
      'wish_envelopes',
      where: 'id = ?',
      whereArgs: [envelopeId],
    );
    return count > 0;
  }

  /// 删除用户创建的所有信封
  Future<int> deleteEnvelopesByCreator(String creatorId) async {
    return await _database.delete(
      'wish_envelopes',
      where: 'creator_id = ?',
      whereArgs: [creatorId],
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 统计方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 获取信封统计信息
  Future<EnvelopeStats> getStats(String userId) async {
    final created = await _database.rawQuery(
      'SELECT COUNT(*) as count FROM wish_envelopes WHERE creator_id = ?',
      [userId],
    );
    
    final received = await _database.rawQuery(
      'SELECT COUNT(*) as count FROM wish_envelopes WHERE receiver_id = ?',
      [userId],
    );
    
    final unread = await _database.rawQuery(
      'SELECT COUNT(*) as count FROM wish_envelopes WHERE receiver_id = ? AND status = ?',
      [userId, 'assigned'],
    );

    return EnvelopeStats(
      createdCount: Sqflite.firstIntValue(created) ?? 0,
      receivedCount: Sqflite.firstIntValue(received) ?? 0,
      unreadCount: Sqflite.firstIntValue(unread) ?? 0,
    );
  }
}

/// 信封统计信息
class EnvelopeStats {
  /// 创建的信封数量
  final int createdCount;
  
  /// 收到的信封数量
  final int receivedCount;
  
  /// 未读信封数量
  final int unreadCount;

  const EnvelopeStats({
    required this.createdCount,
    required this.receivedCount,
    required this.unreadCount,
  });
}
