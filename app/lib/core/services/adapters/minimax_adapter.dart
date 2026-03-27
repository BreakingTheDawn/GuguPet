import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../llm_service.dart';
import '../llm_config.dart';

/// MiniMax适配器
class MiniMaxAdapter implements LLMService {
  final LLMConfig _config;
  final Dio _dio;

  MiniMaxAdapter({
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
    Function(String chunk)? onStream,
  }) async {
    if (!_config.isConfigured) {
      throw LLMException('LLM服务未配置');
    }

    debugPrint('=== MiniMax模式 ===');
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
      debugPrint('MiniMax响应成功，耗时: ${responseTime.inMilliseconds}ms');

      if (response.statusCode != 200) {
        throw LLMException('API请求失败: ${response.statusCode}');
      }

      final data = response.data!;
      
      if (data.containsKey('error')) {
        final error = data['error'] as Map<String, dynamic>;
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
      debugPrint('=== MiniMax请求异常 ===');
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
      
      if (e.response?.statusCode == 403) {
        throw LLMException('MiniMax权限不足，请检查API密钥和Group ID配置');
      }
      
      final errorData = e.response?.data;
      if (errorData is Map) {
        // 尝试解析MiniMax特有的错误格式
        final error = errorData['error'] as Map<String, dynamic>?;
        final message = error?['message'] as String? 
            ?? errorData['message'] as String?
            ?? errorData['error_msg'] as String?;
        final code = error?['code'] as String? 
            ?? errorData['code'] as String?;
        
        debugPrint('MiniMax错误代码: $code');
        debugPrint('MiniMax错误消息: $message');
        
        if (message != null) {
          if (message.contains('quota') || message.contains('配额')) {
            throw TokenExhaustedException();
          }
          if (message.contains('rate') || message.contains('限流')) {
            throw RateLimitException();
          }
          throw LLMException('MiniMax错误: $message');
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
