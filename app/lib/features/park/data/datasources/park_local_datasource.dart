import 'package:sqflite/sqflite.dart';
import '../../../../data/datasources/local/database_helper.dart';
import '../models/models.dart';

// ═══════════════════════════════════════════════════════════════════════════════
/// 公园社交功能本地数据源
/// 负责好友、动态、评论、点赞、互动等数据的本地SQLite操作
// ═══════════════════════════════════════════════════════════════════════════════
class ParkLocalDatasource {
  // ────────────────────────────────────────────────────────────────────────────
  // 单例模式
  // ────────────────────────────────────────────────────────────────────────────

  static final ParkLocalDatasource _instance = ParkLocalDatasource._internal();
  factory ParkLocalDatasource() => _instance;
  ParkLocalDatasource._internal();

  // ────────────────────────────────────────────────────────────────────────────
  // 表名常量
  // ────────────────────────────────────────────────────────────────────────────

  static const String _tableFriends = 'friends';
  static const String _tableUserPosts = 'user_posts';
  static const String _tablePostComments = 'post_comments';
  static const String _tablePostLikes = 'post_likes';
  static const String _tableParkInteractions = 'park_interactions';

  // ═══════════════════════════════════════════════════════════════════════════════
  // 好友相关操作
  // ═══════════════════════════════════════════════════════════════════════════════

  /// 获取好友列表
  /// [userId] 用户ID
  /// [status] 好友状态过滤，可选
  Future<List<Friend>> getFriends(String userId, {FriendStatus? status}) async {
    final db = await DatabaseHelper().database;
    
    String whereClause = 'user_id = ?';
    List<dynamic> whereArgs = [userId];
    
    if (status != null) {
      whereClause += ' AND status = ?';
      whereArgs.add(status.name);
    }
    
    final List<Map<String, dynamic>> maps = await db.query(
      _tableFriends,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'created_at DESC',
    );
    
    return maps.map((map) => Friend.fromDatabase(map)).toList();
  }

  /// 获取单个好友关系
  /// [userId] 当前用户ID
  /// [friendId] 好友ID
  Future<Friend?> getFriend(String userId, String friendId) async {
    final db = await DatabaseHelper().database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      _tableFriends,
      where: 'user_id = ? AND friend_id = ?',
      whereArgs: [userId, friendId],
      limit: 1,
    );
    
    if (maps.isEmpty) return null;
    return Friend.fromDatabase(maps.first);
  }

  /// 添加好友关系
  /// [friend] 好友关系对象
  Future<void> addFriend(Friend friend) async {
    final db = await DatabaseHelper().database;
    await db.insert(
      _tableFriends,
      friend.toDatabaseMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 更新好友状态
  /// [id] 关系ID
  /// [status] 新状态
  Future<void> updateFriendStatus(String id, FriendStatus status) async {
    final db = await DatabaseHelper().database;
    await db.update(
      _tableFriends,
      {'status': status.name},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 删除好友关系
  /// [id] 关系ID
  Future<void> removeFriend(String id) async {
    final db = await DatabaseHelper().database;
    await db.delete(
      _tableFriends,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 检查是否为好友
  /// [userId] 当前用户ID
  /// [friendId] 目标用户ID
  Future<bool> isFriend(String userId, String friendId) async {
    final db = await DatabaseHelper().database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      _tableFriends,
      where: 'user_id = ? AND friend_id = ? AND status = ?',
      whereArgs: [userId, friendId, FriendStatus.accepted.name],
      limit: 1,
    );
    
    return maps.isNotEmpty;
  }

  /// 获取好友数量
  /// [userId] 用户ID
  Future<int> getFriendCount(String userId) async {
    final db = await DatabaseHelper().database;
    
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableFriends WHERE user_id = ? AND status = ?',
      [userId, FriendStatus.accepted.name],
    );
    
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  // 动态相关操作
  // ═══════════════════════════════════════════════════════════════════════════════

  /// 获取动态列表
  /// [limit] 数量限制
  /// [userId] 用户ID过滤
  /// [type] 类型过滤
  Future<List<UserPost>> getPosts({
    int? limit,
    String? userId,
    PostType? type,
  }) async {
    final db = await DatabaseHelper().database;
    
    String whereClause = '1=1';
    List<dynamic> whereArgs = [];
    
    if (userId != null) {
      whereClause += ' AND user_id = ?';
      whereArgs.add(userId);
    }
    
    if (type != null) {
      whereClause += ' AND type = ?';
      whereArgs.add(type.name);
    }
    
    final List<Map<String, dynamic>> maps = await db.query(
      _tableUserPosts,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'created_at DESC',
      limit: limit,
    );
    
    return maps.map((map) => UserPost.fromDatabase(map)).toList();
  }

  /// 获取单条动态
  /// [postId] 动态ID
  Future<UserPost?> getPost(String postId) async {
    final db = await DatabaseHelper().database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      _tableUserPosts,
      where: 'id = ?',
      whereArgs: [postId],
      limit: 1,
    );
    
    if (maps.isEmpty) return null;
    return UserPost.fromDatabase(maps.first);
  }

  /// 创建动态
  /// [post] 动态对象
  Future<void> createPost(UserPost post) async {
    final db = await DatabaseHelper().database;
    await db.insert(
      _tableUserPosts,
      post.toDatabaseMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 删除动态
  /// [postId] 动态ID
  Future<void> deletePost(String postId) async {
    final db = await DatabaseHelper().database;
    // 由于外键级联删除，评论会自动删除
    await db.delete(
      _tableUserPosts,
      where: 'id = ?',
      whereArgs: [postId],
    );
  }

  /// 更新点赞数
  /// [postId] 动态ID
  /// [delta] 变化量（+1 或 -1）
  Future<void> updateLikeCount(String postId, int delta) async {
    final db = await DatabaseHelper().database;
    await db.rawUpdate(
      'UPDATE $_tableUserPosts SET like_count = like_count + ? WHERE id = ?',
      [delta, postId],
    );
  }

  /// 更新评论数
  /// [postId] 动态ID
  /// [delta] 变化量
  Future<void> updateCommentCount(String postId, int delta) async {
    final db = await DatabaseHelper().database;
    await db.rawUpdate(
      'UPDATE $_tableUserPosts SET comment_count = comment_count + ? WHERE id = ?',
      [delta, postId],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  // 评论相关操作
  // ═══════════════════════════════════════════════════════════════════════════════

  /// 获取动态的评论列表
  /// [postId] 动态ID
  Future<List<PostComment>> getComments(String postId) async {
    final db = await DatabaseHelper().database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      _tablePostComments,
      where: 'post_id = ?',
      whereArgs: [postId],
      orderBy: 'created_at ASC',
    );
    
    return maps.map((map) => PostComment.fromDatabase(map)).toList();
  }

  /// 添加评论
  /// [comment] 评论对象
  Future<void> addComment(PostComment comment) async {
    final db = await DatabaseHelper().database;
    await db.transaction((txn) async {
      // 插入评论
      await txn.insert(
        _tablePostComments,
        comment.toDatabaseMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      // 更新评论数
      await txn.rawUpdate(
        'UPDATE $_tableUserPosts SET comment_count = comment_count + 1 WHERE id = ?',
        [comment.postId],
      );
    });
  }

  /// 删除评论
  /// [commentId] 评论ID
  Future<void> deleteComment(String commentId) async {
    final db = await DatabaseHelper().database;
    
    // 先获取评论信息以更新计数
    final List<Map<String, dynamic>> maps = await db.query(
      _tablePostComments,
      where: 'id = ?',
      whereArgs: [commentId],
      limit: 1,
    );
    
    if (maps.isNotEmpty) {
      final postId = maps.first['post_id'] as String;
      await db.transaction((txn) async {
        // 删除评论
        await txn.delete(
          _tablePostComments,
          where: 'id = ?',
          whereArgs: [commentId],
        );
        // 更新评论数
        await txn.rawUpdate(
          'UPDATE $_tableUserPosts SET comment_count = comment_count - 1 WHERE id = ?',
          [postId],
        );
      });
    }
  }

  /// 获取评论数量
  /// [postId] 动态ID
  Future<int> getCommentCount(String postId) async {
    final db = await DatabaseHelper().database;
    
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tablePostComments WHERE post_id = ?',
      [postId],
    );
    
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  // 点赞相关操作
  // ═══════════════════════════════════════════════════════════════════════════════

  /// 点赞
  /// [postId] 动态ID
  /// [userId] 用户ID
  Future<void> like(String postId, String userId) async {
    final db = await DatabaseHelper().database;
    
    final like = PostLike(
      id: 'like_${postId}_$userId',
      postId: postId,
      userId: userId,
      createdAt: DateTime.now(),
    );
    
    await db.transaction((txn) async {
      // 插入点赞记录
      await txn.insert(
        _tablePostLikes,
        like.toDatabaseMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      // 更新点赞数
      await txn.rawUpdate(
        'UPDATE $_tableUserPosts SET like_count = like_count + 1 WHERE id = ?',
        [postId],
      );
    });
  }

  /// 取消点赞
  /// [postId] 动态ID
  /// [userId] 用户ID
  Future<void> unlike(String postId, String userId) async {
    final db = await DatabaseHelper().database;
    
    await db.transaction((txn) async {
      // 删除点赞记录
      final count = await txn.delete(
        _tablePostLikes,
        where: 'post_id = ? AND user_id = ?',
        whereArgs: [postId, userId],
      );
      // 只有确实删除了记录才更新计数
      if (count > 0) {
        await txn.rawUpdate(
          'UPDATE $_tableUserPosts SET like_count = like_count - 1 WHERE id = ?',
          [postId],
        );
      }
    });
  }

  /// 检查是否已点赞
  /// [postId] 动态ID
  /// [userId] 用户ID
  Future<bool> isLiked(String postId, String userId) async {
    final db = await DatabaseHelper().database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      _tablePostLikes,
      where: 'post_id = ? AND user_id = ?',
      whereArgs: [postId, userId],
      limit: 1,
    );
    
    return maps.isNotEmpty;
  }

  /// 获取点赞列表
  /// [postId] 动态ID
  Future<List<PostLike>> getLikes(String postId) async {
    final db = await DatabaseHelper().database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      _tablePostLikes,
      where: 'post_id = ?',
      whereArgs: [postId],
      orderBy: 'created_at DESC',
    );
    
    return maps.map((map) => PostLike.fromDatabase(map)).toList();
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  // 公园互动相关操作
  // ═══════════════════════════════════════════════════════════════════════════════

  /// 记录互动
  /// [interaction] 互动对象
  Future<void> recordInteraction(ParkInteraction interaction) async {
    final db = await DatabaseHelper().database;
    await db.insert(
      _tableParkInteractions,
      interaction.toDatabaseMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 获取用户的互动记录
  /// [userId] 用户ID
  /// [limit] 数量限制
  Future<List<ParkInteraction>> getRecentInteractions(
    String userId, {
    int? limit,
  }) async {
    final db = await DatabaseHelper().database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      _tableParkInteractions,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
      limit: limit,
    );
    
    return maps.map((map) => ParkInteraction.fromDatabase(map)).toList();
  }

  /// 获取用户收到的互动
  /// [targetId] 目标用户ID
  /// [limit] 数量限制
  Future<List<ParkInteraction>> getReceivedInteractions(
    String targetId, {
    int? limit,
  }) async {
    final db = await DatabaseHelper().database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      _tableParkInteractions,
      where: 'target_id = ?',
      whereArgs: [targetId],
      orderBy: 'created_at DESC',
      limit: limit,
    );
    
    return maps.map((map) => ParkInteraction.fromDatabase(map)).toList();
  }
}
