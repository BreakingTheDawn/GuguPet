import 'package:sqflite/sqflite.dart';
import '../../../../data/datasources/local/database_helper.dart';
import '../models/chat_message.dart';
import '../models/chat_session.dart';

/// 对话历史本地数据源
/// 负责对话历史的持久化存储
class ChatLocalDatasource {
  final DatabaseHelper _dbHelper;

  ChatLocalDatasource({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper();

  /// 保存会话
  Future<void> saveSession(ChatSession session) async {
    final db = await _dbHelper.database;
    
    // 保存会话基本信息
    await db.insert(
      'chat_sessions',
      {
        'session_id': session.sessionId,
        'user_id': session.userId,
        'created_at': session.createdAt.toIso8601String(),
        'last_active_at': session.lastActiveAt.toIso8601String(),
        'is_ended': session.isEnded ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // 保存消息
    for (final message in session.messages) {
      await db.insert(
        'chat_messages',
        {
          'message_id': message.messageId,
          'session_id': session.sessionId,
          'role': message.role.name,
          'content': message.content,
          'timestamp': message.timestamp.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  /// 获取用户的活跃会话
  Future<ChatSession?> getActiveSession(String userId) async {
    final db = await _dbHelper.database;
    
    // 查找未结束的会话
    final sessionMaps = await db.query(
      'chat_sessions',
      where: 'user_id = ? AND is_ended = 0',
      whereArgs: [userId],
      orderBy: 'last_active_at DESC',
      limit: 1,
    );

    if (sessionMaps.isEmpty) return null;

    final sessionMap = sessionMaps.first;
    final sessionId = sessionMap['session_id'] as String;

    // 获取该会话的所有消息
    final messageMaps = await db.query(
      'chat_messages',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'timestamp ASC',
    );

    final messages = messageMaps
        .map((map) => ChatMessage.fromJson({
              'message_id': map['message_id'],
              'role': map['role'],
              'content': map['content'],
              'timestamp': map['timestamp'],
            }))
        .toList();

    return ChatSession(
      sessionId: sessionId,
      userId: userId,
      messages: messages,
      createdAt: DateTime.parse(sessionMap['created_at'] as String),
      lastActiveAt: DateTime.parse(sessionMap['last_active_at'] as String),
      isEnded: (sessionMap['is_ended'] as int) == 1,
    );
  }

  /// 创建新会话
  Future<ChatSession> createSession(String userId) async {
    final sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
    final session = ChatSession.create(
      sessionId: sessionId,
      userId: userId,
    );
    
    final db = await _dbHelper.database;
    await db.insert(
      'chat_sessions',
      {
        'session_id': session.sessionId,
        'user_id': session.userId,
        'created_at': session.createdAt.toIso8601String(),
        'last_active_at': session.lastActiveAt.toIso8601String(),
        'is_ended': 0,
      },
    );
    
    return session;
  }

  /// 添加消息到会话
  Future<void> addMessage(String sessionId, ChatMessage message) async {
    final db = await _dbHelper.database;
    
    await db.insert(
      'chat_messages',
      {
        'message_id': message.messageId,
        'session_id': sessionId,
        'role': message.role.name,
        'content': message.content,
        'timestamp': message.timestamp.toIso8601String(),
      },
    );

    // 更新会话最后活跃时间
    await db.update(
      'chat_sessions',
      {'last_active_at': DateTime.now().toIso8601String()},
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );
  }

  /// 结束会话
  Future<void> endSession(String sessionId) async {
    final db = await _dbHelper.database;
    
    await db.update(
      'chat_sessions',
      {
        'is_ended': 1,
        'last_active_at': DateTime.now().toIso8601String(),
      },
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );
  }

  /// 清除用户所有对话历史
  Future<void> clearAllSessions(String userId) async {
    final db = await _dbHelper.database;
    
    // 先获取所有会话ID
    final sessions = await db.query(
      'chat_sessions',
      columns: ['session_id'],
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    final sessionIds = sessions.map((s) => s['session_id'] as String).toList();

    // 删除消息
    for (final sessionId in sessionIds) {
      await db.delete(
        'chat_messages',
        where: 'session_id = ?',
        whereArgs: [sessionId],
      );
    }

    // 删除会话
    await db.delete(
      'chat_sessions',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }
}
