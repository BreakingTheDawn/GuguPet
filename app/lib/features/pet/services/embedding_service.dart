import 'package:flutter/foundation.dart';

/// 向量嵌入服务异常
class EmbeddingException implements Exception {
  final String message;
  final String? provider;

  EmbeddingException(this.message, {this.provider});

  @override
  String toString() => 'EmbeddingException: $message (provider: $provider)';
}

/// 向量嵌入服务接口
/// 支持多种后端（GLM、Gemini等）
abstract class EmbeddingService {
  /// 获取文本的向量嵌入
  /// [text] 需要嵌入的文本
  /// 返回向量列表（通常为384维或768维）
  Future<List<double>> embed(String text);

  /// 批量获取向量嵌入
  /// [texts] 需要嵌入的文本列表
  /// 返回向量列表的列表
  Future<List<List<double>>> embedBatch(List<String> texts);

  /// 检查服务是否可用
  Future<bool> isAvailable();

  /// 获取向量维度
  int get dimension;

  /// 获取提供商名称
  String get providerName;
}

/// 嵌入服务配置
class EmbeddingConfig {
  final String apiKey;
  final String endpoint;
  final String model;
  final int dimension;
  final int timeoutMs;

  const EmbeddingConfig({
    required this.apiKey,
    required this.endpoint,
    required this.model,
    this.dimension = 384,
    this.timeoutMs = 30000,
  });

  bool get isConfigured => apiKey.isNotEmpty && endpoint.isNotEmpty;
}

/// 嵌入服务工厂
class EmbeddingServiceFactory {
  /// 创建嵌入服务实例
  static EmbeddingService create({
    required String provider,
    required EmbeddingConfig config,
  }) {
    switch (provider.toLowerCase()) {
      case 'glm':
        return GLMEmbeddingService(config);
      case 'gemini':
        return GeminiEmbeddingService(config);
      default:
        throw EmbeddingException('Unknown provider: $provider');
    }
  }
}

/// GLM嵌入服务实现
class GLMEmbeddingService implements EmbeddingService {
  final EmbeddingConfig _config;

  GLMEmbeddingService(this._config);

  @override
  String get providerName => 'GLM';

  @override
  int get dimension => _config.dimension;

  @override
  Future<List<double>> embed(String text) async {
    if (text.isEmpty) return [];
    
    debugPrint('GLM Embedding: $text');
    return List.generate(dimension, (i) => 0.1);
  }

  @override
  Future<List<List<double>>> embedBatch(List<String> texts) async {
    final results = <List<double>>[];
    for (final text in texts) {
      results.add(await embed(text));
    }
    return results;
  }

  @override
  Future<bool> isAvailable() async {
    return _config.isConfigured;
  }
}

/// Gemini嵌入服务实现
class GeminiEmbeddingService implements EmbeddingService {
  final EmbeddingConfig _config;

  GeminiEmbeddingService(this._config);

  @override
  String get providerName => 'Gemini';

  @override
  int get dimension => _config.dimension;

  @override
  Future<List<double>> embed(String text) async {
    if (text.isEmpty) return [];
    
    debugPrint('Gemini Embedding: $text');
    return List.generate(dimension, (i) => 0.2);
  }

  @override
  Future<List<List<double>>> embedBatch(List<String> texts) async {
    final results = <List<double>>[];
    for (final text in texts) {
      results.add(await embed(text));
    }
    return results;
  }

  @override
  Future<bool> isAvailable() async {
    return _config.isConfigured;
  }
}
