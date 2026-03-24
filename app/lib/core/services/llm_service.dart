import 'package:dio/dio.dart';
import 'llm_config.dart';

/// 大模型响应结果
class LLMResponse {
  final String content;
  final int tokensUsed;
  final Duration responseTime;

  LLMResponse({
    required this.content,
    required this.tokensUsed,
    required this.responseTime,
  });
}

/// 大模型服务接口
/// 支持多种后端（OpenAI、Azure、本地模型等）
abstract class LLMService {
  /// 发送聊天请求
  Future<LLMResponse> chat({
    required String systemPrompt,
    required String userMessage,
    List<Map<String, String>>? conversationHistory,
  });

  /// 检查服务是否可用
  Future<bool> isAvailable();
}

/// OpenAI兼容服务实现
class OpenAICompatibleService implements LLMService {
  final LLMConfig _config;
  final Dio _dio;

  OpenAICompatibleService({
    required LLMConfig config,
    Dio? dio,
  })  : _config = config,
        _dio = dio ?? Dio(BaseOptions(
          connectTimeout: Duration(milliseconds: config.timeoutMs),
          receiveTimeout: Duration(milliseconds: config.timeoutMs),
        ));

  @override
  Future<LLMResponse> chat({
    required String systemPrompt,
    required String userMessage,
    List<Map<String, String>>? conversationHistory,
  }) async {
    if (!_config.isConfigured) {
      throw LLMException('LLM服务未配置');
    }

    final messages = <Map<String, String>>[
      {'role': 'system', 'content': systemPrompt},
      if (conversationHistory != null) ...conversationHistory,
      {'role': 'user', 'content': userMessage},
    ];

    final startTime = DateTime.now();

    final response = await _dio.post<Map<String, dynamic>>(
      _config.endpoint,
      data: {
        'model': _config.model,
        'messages': messages,
        'max_tokens': _config.maxTokens,
        'temperature': _config.temperature,
      },
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_config.apiKey}',
        },
      ),
    );

    final responseTime = DateTime.now().difference(startTime);

    if (response.statusCode != 200) {
      throw LLMException('API请求失败: ${response.statusCode}');
    }

    final data = response.data!;
    final content = data['choices'][0]['message']['content'] as String;
    final tokensUsed = data['usage']['total_tokens'] as int? ?? 0;

    return LLMResponse(
      content: content,
      tokensUsed: tokensUsed,
      responseTime: responseTime,
    );
  }

  @override
  Future<bool> isAvailable() async {
    if (!_config.isConfigured) return false;

    try {
      // 简单的健康检查
      await _dio
          .get(_config.endpoint.replaceAll('/chat/completions', '/models'))
          .timeout(const Duration(seconds: 5));
      return true;
    } catch (_) {
      return false;
    }
  }
}

/// 空服务实现（禁用LLM时使用）
class DisabledLLMService implements LLMService {
  @override
  Future<LLMResponse> chat({
    required String systemPrompt,
    required String userMessage,
    List<Map<String, String>>? conversationHistory,
  }) async {
    throw LLMException('LLM服务已禁用');
  }

  @override
  Future<bool> isAvailable() async => false;
}

/// LLM异常
class LLMException implements Exception {
  final String message;
  LLMException(this.message);

  @override
  String toString() => 'LLMException: $message';
}
