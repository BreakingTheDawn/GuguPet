import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../llm_service.dart';
import '../llm_config.dart';

/// Google Gemini适配器
class GeminiAdapter implements LLMService {
  final LLMConfig _config;
  final Dio _dio;

  GeminiAdapter({
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

    debugPrint('=== Gemini模式 ===');
    debugPrint('模型: ${_config.model}');

    // 直接使用用户填写的完整端点
    // 端点格式应该是: https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent?key={apiKey}
    final endpoint = '${_config.endpoint}?key=${_config.apiKey}';
    
    debugPrint('Gemini完整端点: ${endpoint.substring(0, endpoint.indexOf("?key="))}...');

    // 构建Gemini请求格式
    final contents = <Map<String, dynamic>>[];
    
    // 添加历史对话
    if (conversationHistory != null) {
      for (final msg in conversationHistory) {
        contents.add({
          'role': msg['role'] == 'assistant' ? 'model' : 'user',
          'parts': [{'text': msg['content']}],
        });
      }
    }
    
    // 添加用户消息
    contents.add({
      'role': 'user',
      'parts': [{'text': userMessage}],
    });

    final startTime = DateTime.now();

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        endpoint,
        data: {
          'contents': contents,
          'systemInstruction': {
            'parts': [{'text': systemPrompt}],
          },
          'generationConfig': {
            'temperature': _config.temperature,
            'topK': 1,
            'topP': 1,
            'maxOutputTokens': _config.maxTokens,
          },
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      final responseTime = DateTime.now().difference(startTime);
      debugPrint('Gemini响应成功，耗时: ${responseTime.inMilliseconds}ms');

      if (response.statusCode != 200) {
        throw LLMException('API请求失败: ${response.statusCode}');
      }

      final data = response.data!;
      
      if (data.containsKey('error')) {
        final error = data['error'] as Map<String, dynamic>;
        throw LLMException(error['message'] as String? ?? '未知错误');
      }
      
      // 解析Gemini响应格式
      final candidates = data['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        throw LLMException('Gemini返回空响应');
      }
      
      final content = candidates[0]['content']['parts'][0]['text'] as String;
      final tokensUsed = (data['usageMetadata']?['totalTokenCount'] as int?) ?? 0;

      return LLMResponse(
        content: content,
        tokensUsed: tokensUsed,
        responseTime: responseTime,
      );
    } on DioException catch (e) {
      debugPrint('=== Gemini请求异常 ===');
      debugPrint('状态码: ${e.response?.statusCode}');
      debugPrint('错误信息: ${e.message}');
      debugPrint('响应数据: ${e.response?.data}');
      
      // 打印请求详情（用于调试）
      debugPrint('请求端点: $endpoint');
      debugPrint('请求体: contents=${contents.length}条');
      
      if (e.response?.statusCode == 400) {
        // 解析400错误详情
        final errorData = e.response?.data;
        if (errorData is Map) {
          final error = errorData['error'] as Map<String, dynamic>?;
          if (error != null) {
            final message = error['message'] as String?;
            final details = error['details'] as List?;
            debugPrint('400错误详情: $message');
            if (details != null) {
              for (final detail in details) {
                debugPrint('错误细节: $detail');
              }
            }
            throw LLMException('Gemini请求格式错误: $message');
          }
        }
        throw LLMException('Gemini API请求格式错误，请检查端点和模型名称');
      }
      
      if (e.response?.statusCode == 401) {
        throw LLMException('API密钥无效或已过期，请检查配置');
      }
      
      if (e.response?.statusCode == 429) {
        throw RateLimitException();
      }
      
      final errorData = e.response?.data;
      if (errorData is Map && errorData.containsKey('error')) {
        final error = errorData['error'] as Map<String, dynamic>;
        final errorMessage = error['message'] as String?;
        debugPrint('Gemini错误消息: $errorMessage');
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
