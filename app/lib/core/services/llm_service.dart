import 'package:flutter/foundation.dart';
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

    // 调试日志：打印配置信息（隐藏API密钥）
    debugPrint('=== LLM配置信息 ===');
    debugPrint('端点: ${_config.endpoint}');
    debugPrint('模型: ${_config.model}');
    debugPrint('API密钥长度: ${_config.apiKey.length}');
    debugPrint('API密钥前10位: ${_config.apiKey.substring(0, _config.apiKey.length > 10 ? 10 : _config.apiKey.length)}...');

    final messages = <Map<String, String>>[
      {'role': 'system', 'content': systemPrompt},
      if (conversationHistory != null) ...conversationHistory,
      {'role': 'user', 'content': userMessage},
    ];

    final startTime = DateTime.now();

    try {
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
      debugPrint('LLM响应成功，耗时: ${responseTime.inMilliseconds}ms');

      // 检查HTTP状态码
      if (response.statusCode == 429) {
        throw RateLimitException();
      }

      if (response.statusCode == 402) {
        throw TokenExhaustedException();
      }

      if (response.statusCode != 200) {
        throw LLMException('API请求失败: ${response.statusCode}');
      }

      final data = response.data!;
      
      // 检查是否有错误信息
      if (data.containsKey('error')) {
        final error = data['error'] as Map<String, dynamic>;
        final errorType = error['type'] as String?;
        
        if (errorType == 'insufficient_quota') {
          throw TokenExhaustedException();
        }
        
        throw LLMException(error['message'] as String? ?? '未知错误');
      }
      
      final content = data['choices'][0]['message']['content'] as String;
      final tokensUsed = data['usage']['total_tokens'] as int? ?? 0;

      return LLMResponse(
        content: content,
        tokensUsed: tokensUsed,
        responseTime: responseTime,
      );
    } on DioException catch (e) {
      // 处理Dio异常
      debugPrint('=== LLM请求异常 ===');
      debugPrint('状态码: ${e.response?.statusCode}');
      debugPrint('错误信息: ${e.message}');
      debugPrint('响应数据: ${e.response?.data}');
      
      if (e.response?.statusCode == 401) {
        throw LLMException('API密钥无效或已过期，请检查配置');
      }
      
      if (e.response?.statusCode == 429) {
        throw RateLimitException();
      }
      if (e.response?.statusCode == 402) {
        throw TokenExhaustedException();
      }
      
      // 检查响应体中的错误类型
      final errorData = e.response?.data;
      if (errorData is Map && errorData.containsKey('error')) {
        final error = errorData['error'] as Map<String, dynamic>;
        final errorType = error['type'] as String?;
        final errorMessage = error['message'] as String?;
        debugPrint('API错误类型: $errorType');
        debugPrint('API错误消息: $errorMessage');
        
        if (errorType == 'insufficient_quota') {
          throw TokenExhaustedException();
        }
      }
      
      throw LLMException('网络请求失败: ${e.message}');
    }
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

/// LLM异常基类
class LLMException implements Exception {
  final String message;
  LLMException(this.message);

  @override
  String toString() => 'LLMException: $message';
}

/// Token不足异常
/// 当API配额用尽时抛出
class TokenExhaustedException extends LLMException {
  TokenExhaustedException() : super('API配额不足，请检查您的Token余额');
}

/// API限流异常
/// 当请求过于频繁时抛出
class RateLimitException extends LLMException {
  RateLimitException() : super('请求过于频繁，请稍后再试');
}
