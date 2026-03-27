// 腾讯混元大模型适配器
// 支持流式调用 (stream=true)

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../llm_service.dart';
import '../llm_config.dart';
import '../utils/stream_response_handler.dart';

/// 混元大模型适配器
/// 支持流式响应 (Server-Sent Events)
class HunyuanAdapter implements LLMService {
  final LLMConfig _config;
  final Dio _dio;
  CancelToken? _cancelToken;

  HunyuanAdapter({required LLMConfig config})
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
      throw LLMException('混元配置不完整');
    }

    final startTime = DateTime.now();
    _cancelToken = CancelToken();

    try {
      // 构建消息列表
      final messages = _buildMessages(
        systemPrompt: systemPrompt,
        userMessage: userMessage,
        history: conversationHistory,
      );

      // 构建请求体
      final requestBody = {
        'model': _config.model,
        'messages': messages,
        'stream': onStream != null, // 如果有回调则启用流式
        'temperature': _config.temperature,
        'max_tokens': _config.maxTokens,
      };

      debugPrint('HunyuanAdapter: 发送请求');
      debugPrint('  模型: ${_config.model}');
      debugPrint('  流式: ${onStream != null}');

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
      debugPrint('HunyuanAdapter: 未知错误: $e');
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
      throw LLMException('混元响应格式错误');
    }

    final content = data['choices'][0]['message']['content'] as String? ?? '';
    
    debugPrint('HunyuanAdapter: 响应成功，耗时 ${responseTime.inMilliseconds}ms');

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

      // 使用统一处理器获取字节流
      final stream = StreamResponseHandler.getStreamFromResponse(response);
      
      // 使用统一处理器解析SSE流
      final fullContent = await StreamResponseHandler.parseSSEStream(
        stream: stream,
        onChunk: onChunk,
        contentPath: SSEContentPaths.openAICompatible,
      );

      final responseTime = DateTime.now().difference(startTime);
      
      debugPrint('HunyuanAdapter: 流式响应完成，耗时 ${responseTime.inMilliseconds}ms');
      debugPrint('HunyuanAdapter: 总长度 ${fullContent.length}');

      return LLMResponse(
        content: fullContent,
        tokensUsed: 0, // 流式不返回token统计
        responseTime: responseTime,
      );
    } on StreamHandlerException catch (e) {
      debugPrint('HunyuanAdapter: 流处理错误: $e');
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
    debugPrint('HunyuanAdapter: Dio错误');
    debugPrint('  类型: ${e.type}');
    debugPrint('  消息: ${e.message}');

    if (e.response != null) {
      final statusCode = e.response?.statusCode;
      final data = e.response?.data;
      
      debugPrint('  状态码: $statusCode');
      debugPrint('  响应: $data');

      if (statusCode == 401) {
        throw LLMException('混元API密钥无效');
      }
      if (statusCode == 429) {
        throw TokenExhaustedException();
      }
      if (statusCode == 500) {
        throw LLMException('混元服务内部错误');
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
    debugPrint('HunyuanAdapter: 请求已取消');
  }
}
