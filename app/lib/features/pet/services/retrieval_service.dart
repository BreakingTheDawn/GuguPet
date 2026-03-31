import 'dart:math';
import '../data/models/vector_memory.dart';
import '../data/models/retrieval_result.dart';
import 'embedding_service.dart';

/// 向量记忆数据源接口
abstract class VectorMemoryDatasource {
  /// 获取宠物的所有记忆
  Future<List<VectorMemory>> getMemoriesByPetId(String petId);

  /// 根据类型获取记忆
  Future<List<VectorMemory>> getMemoriesByType(String petId, MemoryType type);

  /// 插入记忆
  Future<void> insertMemory(VectorMemory memory);

  /// 删除记忆
  Future<void> deleteMemory(String memoryId);

  /// 清理过期记忆
  Future<void> cleanExpiredMemories(String petId);
}

/// 检索服务接口
abstract class RetrievalService {
  /// 相似度检索
  Future<RetrievalResult> search({
    required String query,
    required String petId,
    int topK = 5,
    double threshold = 0.0,
    MemoryType? filterType,
  });

  /// 按时间范围检索
  Future<RetrievalResult> searchByTimeRange({
    required String petId,
    required DateTime start,
    required DateTime end,
    int limit = 10,
  });

  /// 添加记忆
  Future<void> addMemory({
    required String petId,
    required String content,
    required MemoryType type,
    required MemoryCategory category,
    double importance = 0.5,
  });

  /// 获取文本的向量嵌入
  Future<List<double>> embed(String text);

  /// 緻加记忆到索引
  Future<void> index(VectorMemory memory);
}

/// 检索服务实现
class RetrievalServiceImpl implements RetrievalService {
  final EmbeddingService _embeddingService;
  final VectorMemoryDatasource _datasource;

  RetrievalServiceImpl({
    required EmbeddingService embeddingService,
    required VectorMemoryDatasource datasource,
  })  : _embeddingService = embeddingService,
        _datasource = datasource;

  @override
  Future<RetrievalResult> search({
    required String query,
    required String petId,
    int topK = 5,
    double threshold = 0.0,
    MemoryType? filterType,
  }) async {
    final startTime = DateTime.now();

    // 1. 获取查询向量
    final queryEmbedding = await _embeddingService.embed(query);
    if (queryEmbedding.isEmpty) {
      return RetrievalResult.empty();
    }

    // 2. 获取所有记忆
    List<VectorMemory> memories;
    if (filterType != null) {
      memories = await _datasource.getMemoriesByType(petId, filterType);
    } else {
      memories = await _datasource.getMemoriesByPetId(petId);
    }

    if (memories.isEmpty) {
      return RetrievalResult.empty();
    }

    // 3. 计算相似度
    final scoredMemories = <_ScoredMemory>[];
    for (final memory in memories) {
      if (memory.embedding.isEmpty) continue;
      if (memory.isExpired) continue;

      final score = _cosineSimilarity(queryEmbedding, memory.embedding);
      if (score >= threshold) {
        scoredMemories.add(_ScoredMemory(memory, score));
      }
    }

    // 4. 排序并取topK
    scoredMemories.sort((a, b) => b.score.compareTo(a.score));
    final topMemories = scoredMemories.take(topK).toList();

    final retrievalTime = DateTime.now().difference(startTime);

    return RetrievalResult(
      memories: topMemories.map((sm) => sm.memory).toList(),
      scores: topMemories.map((sm) => sm.score).toList(),
      totalTokens: query.length,
      retrievalTimeMs: retrievalTime.inMilliseconds,
    );
  }

  @override
  Future<RetrievalResult> searchByTimeRange({
    required String petId,
    required DateTime start,
    required DateTime end,
    int limit = 10,
  }) async {
    final memories = await _datasource.getMemoriesByPetId(petId);
    
    final filtered = memories.where((m) {
      return m.createdAt.isAfter(start) && 
             m.createdAt.isBefore(end) &&
             !m.isExpired;
    }).toList();

    // 按重要性排序
    filtered.sort((a, b) => b.importance.compareTo(a.importance));
    final limited = filtered.take(limit).toList();

    return RetrievalResult(
      memories: limited,
      scores: List.filled(limited.length, 1.0),
      totalTokens: 0,
    );
  }

  @override
  Future<void> addMemory({
    required String petId,
    required String content,
    required MemoryType type,
    required MemoryCategory category,
    double importance = 0.5,
  }) async {
    // 获取向量嵌入
    final embedding = await _embeddingService.embed(content);

    final memory = VectorMemory(
      id: 'mem_${DateTime.now().millisecondsSinceEpoch}',
      petId: petId,
      type: type,
      category: category,
      content: content,
      embedding: embedding,
      importance: importance,
      createdAt: DateTime.now(),
      expiresAt: type == MemoryType.shortTerm
          ? DateTime.now().add(const Duration(hours: 24))
          : null,
    );

    await _datasource.insertMemory(memory);
  }

  @override
  Future<List<double>> embed(String text) async {
    return await _embeddingService.embed(text);
  }

  @override
  Future<void> index(VectorMemory memory) async {
    await _datasource.insertMemory(memory);
  }

  /// 计算余弦相似度
  double _cosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length || a.isEmpty) return 0.0;

    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;

    for (var i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }

    if (normA == 0 || normB == 0) return 0.0;

    return dotProduct / (sqrt(normA) * sqrt(normB));
  }
}

/// 带分数的记忆
class _ScoredMemory {
  final VectorMemory memory;
  final double score;

  _ScoredMemory(this.memory, this.score);
}
