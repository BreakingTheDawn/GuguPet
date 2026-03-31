import 'dart:convert';
import 'dart:typed_data';

/// 记忆类型枚举
enum MemoryType {
  shortTerm,
  keyEvent,
  preference,
}

/// 记忆分类枚举
enum MemoryCategory {
  job,
  emotion,
  preference,
}

/// 向量化记忆模型
/// 存储带向量嵌入的记忆，支持语义检索
class VectorMemory {
  /// 唯一标识符
  final String id;
  
  /// 关联的宠物ID
  final String petId;
  
  /// 记忆类型
  final MemoryType type;
  
  /// 记忆分类
  final MemoryCategory category;
  
  /// 记忆内容
  final String content;
  
  /// 向量嵌入（用于语义检索）
  final List<double> embedding;
  
  /// 重要性权重（0.0-1.0）
  final double importance;
  
  /// 创建时间
  final DateTime createdAt;
  
  /// 过期时间（仅短期记忆）
  final DateTime? expiresAt;
  
  /// 扩展元数据
  final Map<String, dynamic>? metadata;

  VectorMemory({
    required this.id,
    required this.petId,
    required this.type,
    required this.category,
    required this.content,
    required this.embedding,
    this.importance = 0.5,
    required this.createdAt,
    this.expiresAt,
    this.metadata,
  });

  /// 是否已过期
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// 是否为永久记忆
  bool get isPermanent => type != MemoryType.shortTerm;

  /// 序列化为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pet_id': petId,
      'type': type.name,
      'category': category.name,
      'content': content,
      'embedding': _encodeEmbedding(embedding),
      'importance': importance,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'metadata': metadata != null ? jsonEncode(metadata) : null,
    };
  }

  /// 从JSON反序列化
  factory VectorMemory.fromJson(Map<String, dynamic> json) {
    return VectorMemory(
      id: json['id'] as String,
      petId: json['pet_id'] as String,
      type: MemoryType.values.firstWhere((e) => e.name == json['type']),
      category: MemoryCategory.values.firstWhere((e) => e.name == json['category']),
      content: json['content'] as String,
      embedding: _decodeEmbedding(json['embedding'] as String?),
      importance: (json['importance'] as num?)?.toDouble() ?? 0.5,
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      metadata: json['metadata'] != null
          ? jsonDecode(json['metadata'] as String) as Map<String, dynamic>
          : null,
    );
  }

  /// 创建短期记忆（24小时过期）
  factory VectorMemory.shortTerm({
    required String id,
    required String petId,
    required MemoryCategory category,
    required String content,
    required List<double> embedding,
    double importance = 0.5,
  }) {
    return VectorMemory(
      id: id,
      petId: petId,
      type: MemoryType.shortTerm,
      category: category,
      content: content,
      embedding: embedding,
      importance: importance,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
    );
  }

  /// 创建关键事件记忆（永久保存）
  factory VectorMemory.keyEvent({
    required String id,
    required String petId,
    required String content,
    required List<double> embedding,
    double importance = 1.0,
    Map<String, dynamic>? metadata,
  }) {
    return VectorMemory(
      id: id,
      petId: petId,
      type: MemoryType.keyEvent,
      category: MemoryCategory.job,
      content: content,
      embedding: embedding,
      importance: importance,
      createdAt: DateTime.now(),
      metadata: metadata,
    );
  }

  /// 编码向量为Base64字符串
  static String _encodeEmbedding(List<double> embedding) {
    final bytes = ByteData(embedding.length * 8);
    for (var i = 0; i < embedding.length; i++) {
      bytes.setFloat64(i * 8, embedding[i]);
    }
    return base64Encode(bytes.buffer.asUint8List());
  }

  /// 解码Base64字符串为向量
  static List<double> _decodeEmbedding(String? encoded) {
    if (encoded == null || encoded.isEmpty) return [];
    final bytes = base64Decode(encoded);
    final byteData = ByteData.sublistView(bytes);
    final embedding = <double>[];
    for (var i = 0; i < bytes.length; i += 8) {
      embedding.add(byteData.getFloat64(i));
    }
    return embedding;
  }

  /// 复制并更新部分字段
  VectorMemory copyWith({
    String? id,
    String? petId,
    MemoryType? type,
    MemoryCategory? category,
    String? content,
    List<double>? embedding,
    double? importance,
    DateTime? createdAt,
    DateTime? expiresAt,
    Map<String, dynamic>? metadata,
  }) {
    return VectorMemory(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      type: type ?? this.type,
      category: category ?? this.category,
      content: content ?? this.content,
      embedding: embedding ?? this.embedding,
      importance: importance ?? this.importance,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      metadata: metadata ?? this.metadata,
    );
  }
}
