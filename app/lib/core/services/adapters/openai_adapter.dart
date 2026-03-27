import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../llm_service.dart';
import '../llm_config.dart';

/// OpenAI兼容适配器
/// 适用于: OpenAI、智谱AI、Kimi、豆包
class OpenAICompatibleAdapter implements LLMService {
  final LLMConfig _config;
  final Dio _dio;

  OpenAICompatibleAdapter({
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

    debugPrint('=== OpenAI兼容模式 ===');
    debugPrint('端点: ${_config.endpoint}');
    debugPrint('模型: ${_config.model}');

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
      debugPrint('=== LLM请求异常 ===');
      debugPrint('状态码: ${e.response?.statusCode}');
      debugPrint('错误信息: ${e.message}');
      debugPrint('响应数据: ${e.response?.data}');
      
      // 打印请求详情（用于调试）
      debugPrint('请求端点: ${_config.endpoint}');
      debugPrint('请求模型: ${_config.model}');
      
      if (e.response?.statusCode == 401) {
        throw LLMException('API密钥无效或已过期，请检查配置');
      }
      
      if (e.response?.statusCode == 429) {
        throw RateLimitException();
      }
      if (e.response?.statusCode == 402) {
        throw TokenExhaustedException();
      }
      
      final errorData = e.response?.data;
      if (errorData is Map) {
        // 尝试解析各平台特有的错误格式
        final error = errorData['error'] as Map<String, dynamic>?;
        final message = error?['message'] as String? 
            ?? errorData['message'] as String?
            ?? error?['msg'] as String?;
        final errorType = error?['type'] as String?;
        
        debugPrint('API错误类型: $errorType');
        debugPrint('API错误消息: $message');
        
        if (errorType == 'insufficient_quota' || 
            (message != null && message.contains('quota'))) {
          throw TokenExhaustedException();
        }
        
        if (message != null) {
          throw LLMException('$message');
        }
      }
      
      throw LLMException('网络请求失败: ${e.message}');
    }
  }

  @override
  Future<bool> isAvailable() async {
    try {
      await chat(
        systemPrompt: '测试',
        userMessage: '你好',
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}
