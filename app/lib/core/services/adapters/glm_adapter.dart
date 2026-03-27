// 智谱GLM-4.7适配器
// 支持流式调用 (stream=true)

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../llm_service.dart';
import '../llm_config.dart';
import '../utils/stream_response_handler.dart';

/// GLM-4.7适配器
/// 支持流式响应 (Server-Sent Events)
class GLMAdapter implements LLMService {
  final LLMConfig _config;
  final Dio _dio;
  CancelToken? _cancelToken;

  GLMAdapter({required LLMConfig config})
      : _config = config,
        _dio = Dio(BaseOptions(
          connectTimeout: Duration(milliseconds: config.timeoutMs),
          receiveTimeout: Duration(milliseconds: config.timeoutMs),
        ));

  @override
  Future<LLMResponse> chat({
    required String systemPrompt,
    required String userMessage,
    List<Map<String, String>>? conversationHistory,
    Function(String chunk)? onStream, // 流式回调
  }) async {
    if (!_config.isConfigured) {
      throw LLMException('GLM配置不完整');
    }

    final startTime = DateTime.now();
    _cancelToken = CancelToken();

    try {
      // 步骤1：构建消息列表
      debugPrint('⏱️ [GLM] 步骤1：开始构建消息列表');
      final step1Start = DateTime.now();
      final messages = _buildMessages(
        systemPrompt: systemPrompt,
        userMessage: userMessage,
        history: conversationHistory,
      );
      debugPrint('⏱️ [GLM] 步骤1完成：耗时 ${DateTime.now().difference(step1Start).inMilliseconds}ms');

      // 步骤2：构建请求体
      debugPrint('⏱️ [GLM] 步骤2：开始构建请求体');
      final step2Start = DateTime.now();
      final requestBody = {
        'model': _config.model,
        'messages': messages,
        'stream': onStream != null, // 如果有回调则启用流式
        'temperature': _config.temperature,
        'max_tokens': _config.maxTokens,
        'top_p': 0.7,
      };
      debugPrint('⏱️ [GLM] 步骤2完成：耗时 ${DateTime.now().difference(step2Start).inMilliseconds}ms');

      debugPrint('GLMAdapter: 发送请求');
      debugPrint('  模型: ${_config.model}');
      debugPrint('  流式: ${onStream != null}');
      debugPrint('  maxTokens: ${_config.maxTokens}');
      debugPrint('  timeoutMs: ${_config.timeoutMs}');

      if (onStream != null) {
        // 流式调用
        return await _chatStream(
          requestBody: requestBody,
          onChunk: onStream,
          startTime: startTime,
        );
      } else {
        // 非流式调用
        return await _chatNonStream(
          requestBody: requestBody,
          startTime: startTime,
        );
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      debugPrint('GLMAdapter: 未知错误: $e');
      throw LLMException('请求失败: $e');
    } finally {
      _cancelToken = null;
    }
  }

  /// 非流式调用
  Future<LLMResponse> _chatNonStream({
    required Map<String, dynamic> requestBody,
    required DateTime startTime,
  }) async {
    final response = await _dio.post(
      _config.endpoint,
      data: requestBody,
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_config.apiKey}',
        },
      ),
      cancelToken: _cancelToken,
    );

    final responseTime = DateTime.now().difference(startTime);
    final data = response.data as Map<String, dynamic>;
    
    if (data['choices'] == null || (data['choices'] as List).isEmpty) {
      throw LLMException('GLM响应格式错误');
    }

    final content = data['choices'][0]['message']['content'] as String? ?? '';
    
    debugPrint('GLMAdapter: 响应成功，耗时 ${responseTime.inMilliseconds}ms');

    return LLMResponse(
      content: content,
      tokensUsed: data['usage']?['total_tokens'] as int? ?? 0,
      responseTime: responseTime,
    );
  }

  /// 流式调用 (SSE)
  Future<LLMResponse> _chatStream({
    required Map<String, dynamic> requestBody,
    required Function(String chunk) onChunk,
    required DateTime startTime,
  }) async {
    try {
      // 步骤3：发送HTTP请求
      debugPrint('⏱️ [GLM] 步骤3：开始发送HTTP请求');
      final step3Start = DateTime.now();
      
      final response = await _dio.post(
        _config.endpoint,
        data: requestBody,
        options: StreamResponseHandler.createStreamOptions(
          headers: {
            'Authorization': 'Bearer ${_config.apiKey}',
          },
        ),
        cancelToken: _cancelToken,
      );
      
      debugPrint('⏱️ [GLM] 步骤3完成：HTTP响应到达，耗时 ${DateTime.now().difference(step3Start).inMilliseconds}ms');

      // 步骤4：获取字节流
      debugPrint('⏱️ [GLM] 步骤4：开始获取字节流');
      final step4Start = DateTime.now();
      final stream = StreamResponseHandler.getStreamFromResponse(response);
      debugPrint('⏱️ [GLM] 步骤4完成：耗时 ${DateTime.now().difference(step4Start).inMilliseconds}ms');
      
      // 步骤5：解析SSE流
      debugPrint('⏱️ [GLM] 步骤5：开始解析SSE流');
      final step5Start = DateTime.now();
      final fullContent = await StreamResponseHandler.parseSSEStream(
        stream: stream,
        onChunk: onChunk,
        contentPath: SSEContentPaths.openAICompatible,
      );
      debugPrint('⏱️ [GLM] 步骤5完成：耗时 ${DateTime.now().difference(step5Start).inMilliseconds}ms');

      final responseTime = DateTime.now().difference(startTime);
      
      debugPrint('GLMAdapter: 流式响应完成，总耗时 ${responseTime.inMilliseconds}ms');
      debugPrint('GLMAdapter: 总长度 ${fullContent.length}');

      return LLMResponse(
        content: fullContent,
        tokensUsed: 0, // 流式不返回token统计
        responseTime: responseTime,
      );
    } on StreamHandlerException catch (e) {
      debugPrint('GLMAdapter: 流处理错误: $e');
      throw LLMException('流式响应处理失败: $e');
    }
  }

  /// 构建消息列表
  List<Map<String, String>> _buildMessages({
    required String systemPrompt,
    required String userMessage,
    List<Map<String, String>>? history,
  }) {
    final messages = <Map<String, String>>[];

    // 系统提示词
    messages.add({
      'role': 'system',
      'content': systemPrompt,
    });

    // 历史对话
    if (history != null) {
      for (final msg in history) {
        messages.add({
          'role': msg['role'] == 'user' ? 'user' : 'assistant',
          'content': msg['content'] ?? '',
        });
      }
    }

    // 当前消息
    messages.add({
      'role': 'user',
      'content': userMessage,
    });

    return messages;
  }

  /// 处理Dio错误
  void _handleDioError(DioException e) {
    debugPrint('GLMAdapter: Dio错误');
    debugPrint('  类型: ${e.type}');
    debugPrint('  消息: ${e.message}');

    if (e.response != null) {
      final statusCode = e.response?.statusCode;
      final data = e.response?.data;
      
      debugPrint('  状态码: $statusCode');
      debugPrint('  响应: $data');

      if (statusCode == 401) {
        throw LLMException('GLM API密钥无效');
      }
      if (statusCode == 429) {
        throw TokenExhaustedException();
      }
      if (statusCode == 500) {
        throw LLMException('GLM服务内部错误');
      }
    }
  }

  @override
  Future<bool> isAvailable() async {
    if (!_config.isConfigured) return false;

    try {
      final response = await _dio.post(
        _config.endpoint,
        data: {
          'model': _config.model,
          'messages': [{'role': 'user', 'content': 'test'}],
          'max_tokens': 1,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${_config.apiKey}',
          },
        ),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// 取消当前请求
  void cancel() {
    _cancelToken?.cancel('用户取消');
    debugPrint('GLMAdapter: 请求已取消');
  }
}
