import 'chat_message.dart';

/// 对话会话模型
/// 管理一次完整的对话会话，包含多轮对话历史
class ChatSession {
  /// 会话ID
  final String sessionId;
  
  /// 用户ID
  final String userId;
  
  /// 对话消息列表
  final List<ChatMessage> messages;
  
  /// 会话创建时间
  final DateTime createdAt;
  
  /// 最后活跃时间
  final DateTime lastActiveAt;
  
  /// 会话是否已结束
  final bool isEnded;

  const ChatSession({
    required this.sessionId,
    required this.userId,
    required this.messages,
    required this.createdAt,
    required this.lastActiveAt,
    this.isEnded = false,
  });

  /// 创建新会话
  factory ChatSession.create({
    required String sessionId,
    required String userId,
  }) {
    final now = DateTime.now();
    return ChatSession(
      sessionId: sessionId,
      userId: userId,
      messages: [],
      createdAt: now,
      lastActiveAt: now,
    );
  }

  /// 从JSON创建
  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      sessionId: json['session_id'] as String,
      userId: json['user_id'] as String,
      messages: (json['messages'] as List<dynamic>?)
              ?.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
      lastActiveAt: DateTime.parse(json['last_active_at'] as String),
      isEnded: json['is_ended'] as bool? ?? false,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'user_id': userId,
      'messages': messages.map((e) => e.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'last_active_at': lastActiveAt.toIso8601String(),
      'is_ended': isEnded,
    };
  }

  /// 添加消息
  ChatSession addMessage(ChatMessage message) {
    return copyWith(
      messages: [...messages, message],
      lastActiveAt: DateTime.now(),
    );
  }

  /// 获取最近N条消息（用于LLM上下文）
  List<ChatMessage> getRecentMessages({int limit = 10}) {
    if (messages.length <= limit) return messages;
    return messages.sublist(messages.length - limit);
  }

  /// 转换为LLM API格式的对话历史
  List<Map<String, String>> toApiHistory({int limit = 10}) {
    return getRecentMessages(limit: limit)
        .map((e) => e.toApiFormat())
        .toList();
  }

  /// 结束会话
  ChatSession end() {
    return copyWith(isEnded: true);
  }

  /// 复制并修改
  ChatSession copyWith({
    String? sessionId,
    String? userId,
    List<ChatMessage>? messages,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    bool? isEnded,
  }) {
    return ChatSession(
      sessionId: sessionId ?? this.sessionId,
      userId: userId ?? this.userId,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      isEnded: isEnded ?? this.isEnded,
    );
  }
}
