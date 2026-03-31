import 'package:sqflite/sqflite.dart';
import '../models/user_feedback.dart';

/// 本地反馈数据源
/// 将用户反馈存储在本地SQLite数据库中
class FeedbackLocalDatasource {
  final Database _database;

  FeedbackLocalDatasource(this._database);

  /// 插入反馈
  Future<void> insertFeedback(UserFeedback feedback) async {
    await _database.insert(
      'user_feedbacks',
      feedback.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 获取用户的所有反馈
  Future<List<UserFeedback>> getFeedbacksByUserId(String userId, {
    int page = 1,
    int size = 10,
  }) async {
    final offset = (page - 1) * size;
    final maps = await _database.query(
      'user_feedbacks',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
      limit: size,
      offset: offset,
    );

    return maps.map((map) => UserFeedback.fromJson(map)).toList();
  }

  /// 获取单个反馈
  Future<UserFeedback?> getFeedbackById(String id) async {
    final maps = await _database.query(
      'user_feedbacks',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return UserFeedback.fromJson(maps.first);
  }

  /// 更新反馈状态
  Future<void> updateFeedbackStatus(String id, FeedbackStatus status, {
    String? adminReply,
  }) async {
    final data = <String, dynamic>{
      'status': status.name,
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (adminReply != null) {
      data['admin_reply'] = adminReply;
    }

    await _database.update(
      'user_feedbacks',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 删除反馈
  Future<void> deleteFeedback(String id) async {
    await _database.delete(
      'user_feedbacks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 获取反馈数量
  Future<int> getFeedbackCount(String userId) async {
    final result = await _database.rawQuery(
      'SELECT COUNT(*) as count FROM user_feedbacks WHERE user_id = ?',
      [userId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// 获取待处理的反馈数量
  Future<int> getPendingFeedbackCount(String userId) async {
    final result = await _database.rawQuery(
      'SELECT COUNT(*) as count FROM user_feedbacks WHERE user_id = ? AND status = ?',
      [userId, 'pending'],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// 清除用户的所有反馈
  Future<void> clearAllFeedbacks(String userId) async {
    await _database.delete(
      'user_feedbacks',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }
}
