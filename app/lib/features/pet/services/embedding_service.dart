import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

/// 向量嵌入服务异常
class EmbeddingException implements Exception {
  final String message;
  final String? provider;

  EmbeddingException(this.message, {this.provider});

  @override
  String toString() => 'EmbeddingException: $message (provider: $provider)';
}

/// 向量嵌入服务接口
/// 支持多种后端（OpenAI、GLM、Gemini等）
abstract class EmbeddingService {
  /// 获取文本的向量嵌入
  /// [text] 需要嵌入的文本
  /// 返回向量列表（通常为384维或768维或1536维）
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
    this.dimension = 1536,
    this.timeoutMs = 30000,
  });

  bool get isConfigured => apiKey.isNotEmpty && endpoint.isNotEmpty;

  /// Local deployment providers such as Ollama do not require a cloud API key.
  bool get hasEndpoint => endpoint.isNotEmpty;
}

/// 嵌入服务工厂
class EmbeddingServiceFactory {
  /// 创建嵌入服务实例
  static EmbeddingService create({
    required String provider,
    required EmbeddingConfig config,
  }) {
    switch (provider.toLowerCase()) {
      case 'openai':
        return OpenAIEmbeddingService(config);
      case 'glm':
        return GLMEmbeddingService(config);
      case 'gemini':
        return GeminiEmbeddingService(config);
      case 'ollama':
        return OllamaEmbeddingService(config);
      case 'local':
        return LocalEmbeddingService(config);
      default:
        throw EmbeddingException('Unknown provider: $provider');
    }
  }
}

/// Ollama embedding service for locally deployed models.
class OllamaEmbeddingService implements EmbeddingService {
  final EmbeddingConfig _config;
  final Dio _dio;

  OllamaEmbeddingService(this._config)
    : _dio = Dio(
        BaseOptions(
          connectTimeout: Duration(milliseconds: _config.timeoutMs),
          receiveTimeout: Duration(milliseconds: _config.timeoutMs),
          headers: {'Content-Type': 'application/json'},
        ),
      );

  @override
  String get providerName => 'Ollama';

  @override
  int get dimension => _config.dimension;

  @override
  Future<List<double>> embed(String text) async {
    if (text.isEmpty) return [];

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        _config.endpoint,
        data: {'model': _config.model, 'input': text},
      );

      if (response.statusCode == 200 && response.data != null) {
        return _parseSingleEmbedding(response.data!);
      }
      return [];
    } on DioException catch (e) {
      debugPrint('Ollama Embedding error: ${e.message}');
      return [];
    }
  }

  @override
  Future<List<List<double>>> embedBatch(List<String> texts) async {
    if (texts.isEmpty) return [];

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        _config.endpoint,
        data: {'model': _config.model, 'input': texts},
      );

      if (response.statusCode == 200 && response.data != null) {
        final embeddings = response.data!['embeddings'] as List<dynamic>?;
        if (embeddings != null) {
          return embeddings
              .map((embedding) => _toDoubleVector(embedding as List<dynamic>))
              .toList();
        }

        final singleEmbedding = _parseSingleEmbedding(response.data!);
        return singleEmbedding.isEmpty ? [] : [singleEmbedding];
      }
      return [];
    } on DioException catch (e) {
      debugPrint('Ollama Embedding batch error: ${e.message}');
      return [];
    }
  }

  @override
  Future<bool> isAvailable() async {
    return _config.hasEndpoint && _config.model.isNotEmpty;
  }

  // Ollama /api/embed returns `embeddings`; older /api/embeddings returns `embedding`.
  List<double> _parseSingleEmbedding(Map<String, dynamic> data) {
    final embeddings = data['embeddings'] as List<dynamic>?;
    if (embeddings != null && embeddings.isNotEmpty) {
      return _toDoubleVector(embeddings.first as List<dynamic>);
    }

    final embedding = data['embedding'] as List<dynamic>?;
    if (embedding != null) {
      return _toDoubleVector(embedding);
    }

    return [];
  }

  List<double> _toDoubleVector(List<dynamic> values) {
    return values.map((value) => (value as num).toDouble()).toList();
  }
}

/// OpenAI embedding service implementation.
class OpenAIEmbeddingService implements EmbeddingService {
  final EmbeddingConfig _config;
  final Dio _dio;

  OpenAIEmbeddingService(this._config)
    : _dio = Dio(
        BaseOptions(
          connectTimeout: Duration(milliseconds: _config.timeoutMs),
          receiveTimeout: Duration(milliseconds: _config.timeoutMs),
          headers: {
            'Authorization': 'Bearer ${_config.apiKey}',
            'Content-Type': 'application/json',
          },
        ),
      );

  @override
  String get providerName => 'OpenAI';

  @override
  int get dimension => _config.dimension;

  @override
  Future<List<double>> embed(String text) async {
    if (text.isEmpty) return [];

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        _config.endpoint,
        data: {'model': _config.model, 'input': text},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data!['data'] as List<dynamic>?;
        if (data != null && data.isNotEmpty) {
          final embedding = data.first['embedding'] as List<dynamic>;
          return embedding.cast<double>();
        }
      }
      return [];
    } on DioException catch (e) {
      debugPrint('OpenAI Embedding error: ${e.message}');
      return [];
    }
  }

  @override
  Future<List<List<double>>> embedBatch(List<String> texts) async {
    if (texts.isEmpty) return [];

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        _config.endpoint,
        data: {'model': _config.model, 'input': texts},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data!['data'] as List<dynamic>?;
        if (data != null) {
          return data.map((item) {
            final embedding = item['embedding'] as List<dynamic>;
            return embedding.cast<double>();
          }).toList();
        }
      }
      return [];
    } on DioException catch (e) {
      debugPrint('OpenAI Embedding batch error: ${e.message}');
      return [];
    }
  }

  @override
  Future<bool> isAvailable() async {
    return _config.isConfigured;
  }
}

/// GLM嵌入服务实现（智谱AI）
class GLMEmbeddingService implements EmbeddingService {
  final EmbeddingConfig _config;
  final Dio _dio;

  GLMEmbeddingService(this._config)
    : _dio = Dio(
        BaseOptions(
          connectTimeout: Duration(milliseconds: _config.timeoutMs),
          receiveTimeout: Duration(milliseconds: _config.timeoutMs),
          headers: {
            'Authorization': 'Bearer ${_config.apiKey}',
            'Content-Type': 'application/json',
          },
        ),
      );

  @override
  String get providerName => 'GLM';

  @override
  int get dimension => _config.dimension;

  @override
  Future<List<double>> embed(String text) async {
    if (text.isEmpty) return [];

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        _config.endpoint,
        data: {'model': _config.model, 'input': text},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data!['data'] as List<dynamic>?;
        if (data != null && data.isNotEmpty) {
          final embedding = data.first['embedding'] as List<dynamic>;
          return embedding.cast<double>();
        }
      }
      return [];
    } on DioException catch (e) {
      debugPrint('GLM Embedding error: ${e.message}');
      return [];
    }
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
  final Dio _dio;

  GeminiEmbeddingService(this._config)
    : _dio = Dio(
        BaseOptions(
          connectTimeout: Duration(milliseconds: _config.timeoutMs),
          receiveTimeout: Duration(milliseconds: _config.timeoutMs),
        ),
      );

  @override
  String get providerName => 'Gemini';

  @override
  int get dimension => _config.dimension;

  @override
  Future<List<double>> embed(String text) async {
    if (text.isEmpty) return [];

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '${_config.endpoint}?key=${_config.apiKey}',
        data: {
          'model': _config.model,
          'content': {
            'parts': [
              {'text': text},
            ],
          },
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final embedding = response.data!['embedding'] as Map<String, dynamic>?;
        if (embedding != null) {
          final values = embedding['values'] as List<dynamic>?;
          if (values != null) {
            return values.cast<double>();
          }
        }
      }
      return [];
    } on DioException catch (e) {
      debugPrint('Gemini Embedding error: ${e.message}');
      return [];
    }
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

/// 本地嵌入服务实现（简化版，用于离线场景）
/// 使用简单的TF-IDF风格的特征向量
class LocalEmbeddingService implements EmbeddingService {
  final EmbeddingConfig _config;

  LocalEmbeddingService(this._config);

  @override
  String get providerName => 'Local';

  @override
  int get dimension => _config.dimension;

  @override
  Future<List<double>> embed(String text) async {
    if (text.isEmpty) return [];

    // 简单的词频向量（用于离线场景）
    // 这是一个简化实现，实际生产环境应使用真正的嵌入模型
    final words = _tokenize(text);
    final vector = List.generate(dimension, (i) => 0.0);

    for (final word in words) {
      final hash = _hashWord(word);
      final index = hash % dimension;
      vector[index] += 1.0;
    }

    // 归一化
    final norm = _calculateNorm(vector);
    if (norm > 0) {
      for (var i = 0; i < vector.length; i++) {
        vector[i] /= norm;
      }
    }

    return vector;
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
    return true; // 本地服务始终可用
  }

  /// 分词
  List<String> _tokenize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty && w.length > 1)
        .toList();
  }

  /// 词哈希
  int _hashWord(String word) {
    var hash = 0;
    for (var i = 0; i < word.length; i++) {
      hash = ((hash << 5) - hash) + word.codeUnitAt(i);
      hash = hash & 0x7fffffff; // 保持正数
    }
    return hash;
  }

  /// 计算向量范数
  double _calculateNorm(List<double> vector) {
    var sum = 0.0;
    for (final v in vector) {
      sum += v * v;
    }
    return sqrt(sum);
  }
}

/// 向量工具类
class VectorUtils {
  /// 计算余弦相似度
  static double cosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length || a.isEmpty) return 0.0;

    var dotProduct = 0.0;
    var normA = 0.0;
    var normB = 0.0;

    for (var i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }

    final denominator = sqrt(normA) * sqrt(normB);
    if (denominator == 0) return 0.0;
    return dotProduct / denominator;
  }

  /// 向量转Base64
  static String vectorToBase64(List<double> vector) {
    final float32List = Float32List.fromList(vector);
    final bytes = Uint8List.view(float32List.buffer);
    return base64Encode(bytes);
  }

  /// Base64转向量
  static List<double> base64ToVector(String base64String) {
    final bytes = base64Decode(base64String);
    final float32List = Float32List.view(bytes.buffer);
    return float32List.toList();
  }
}
