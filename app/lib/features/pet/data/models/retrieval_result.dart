import 'vector_memory.dart';

/// 检索结果模型
/// 包含检索到的记忆列表、相似度分数和token消耗
class RetrievalResult {
  /// 检索到的记忆列表
  final List<VectorMemory> memories;

  /// 每条记忆的相似度分数（与memories一一对应）
  final List<double> scores;

  /// 消耗的总token数
  final int totalTokens;

  /// 检索耗时（毫秒）
  final int? retrievalTimeMs;

  const RetrievalResult({
    required this.memories,
    required this.scores,
    required this.totalTokens,
    this.retrievalTimeMs,
  });

  /// 创建空结果
  factory RetrievalResult.empty() {
    return const RetrievalResult(
      memories: [],
      scores: [],
      totalTokens: 0,
    );
  }

  /// 是否有结果
  bool get hasResults => memories.isNotEmpty;

  /// 结果数量
  int get length => memories.length;

  /// 获取最高分数
  double get maxScore => scores.isEmpty ? 0.0 : scores.reduce((a, b) => a > b ? a : b);

  /// 获取平均分数
  double get avgScore {
    if (scores.isEmpty) return 0.0;
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  /// 按分数排序（降序）
  RetrievalResult sortByScore() {
    if (memories.length <= 1) return this;

    final indices = List.generate(memories.length, (i) => i);
    indices.sort((a, b) => scores[b].compareTo(scores[a]));

    return RetrievalResult(
      memories: indices.map((i) => memories[i]).toList(),
      scores: indices.map((i) => scores[i]).toList(),
      totalTokens: totalTokens,
      retrievalTimeMs: retrievalTimeMs,
    );
  }

  /// 过滤低于阈值的结果
  RetrievalResult filterByThreshold(double threshold) {
    final filteredIndices = <int>[];
    for (var i = 0; i < scores.length; i++) {
      if (scores[i] >= threshold) {
        filteredIndices.add(i);
      }
    }

    return RetrievalResult(
      memories: filteredIndices.map((i) => memories[i]).toList(),
      scores: filteredIndices.map((i) => scores[i]).toList(),
      totalTokens: totalTokens,
      retrievalTimeMs: retrievalTimeMs,
    );
  }

  /// 转换为字符串列表（用于注入提示词）
  List<String> toContentList() {
    return memories.map((m) => m.content).toList();
  }
}
