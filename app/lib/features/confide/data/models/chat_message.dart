/// 对话消息角色
enum ChatRole {
  user,       // 用户消息
  assistant,  // 宠物回复
}

/// 对话消息模型
/// 用于存储单条对话记录
class ChatMessage {
  /// 消息ID
  final String messageId;
  
  /// 消息角色
  final ChatRole role;
  
  /// 消息内容
  final String content;
  
  /// 创建时间
  final DateTime timestamp;

  const ChatMessage({
    required this.messageId,
    required this.role,
    required this.content,
    required this.timestamp,
  });

  /// 从JSON创建
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      messageId: json['message_id'] as String,
      role: ChatRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => ChatRole.user,
      ),
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'message_id': messageId,
      'role': role.name,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// 转换为LLM API格式
  Map<String, String> toApiFormat() {
    return {
      'role': role == ChatRole.user ? 'user' : 'assistant',
      'content': content,
    };
  }

  /// 复制并修改
  ChatMessage copyWith({
    String? messageId,
    ChatRole? role,
    String? content,
    DateTime? timestamp,
  }) {
    return ChatMessage(
      messageId: messageId ?? this.messageId,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
