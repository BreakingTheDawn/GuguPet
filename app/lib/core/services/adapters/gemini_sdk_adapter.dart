// Google Gemini SDK适配器
// 使用官方google_generative_ai包实现LLM服务

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../llm_service.dart';
import '../llm_config.dart';

/// Google Gemini SDK适配器
/// 使用官方google_generative_ai包
class GeminiSDKAdapter implements LLMService {
  final LLMConfig _config;
  GenerativeModel? _model;
  ChatSession? _chatSession;

  GeminiSDKAdapter({required LLMConfig config}) : _config = config {
    _initializeModel();
  }

  /// 初始化模型
  void _initializeModel() {
    if (!_config.isConfigured) {
      debugPrint('GeminiSDKAdapter: 配置不完整，跳过初始化');
      return;
    }

    try {
      _model = GenerativeModel(
        model: _config.model,
        apiKey: _config.apiKey,
        generationConfig: GenerationConfig(
          maxOutputTokens: _config.maxTokens,
          temperature: _config.temperature,
        ),
      );
      debugPrint('GeminiSDKAdapter: 模型初始化成功');
      debugPrint('  模型: ${_config.model}');
      debugPrint('  maxTokens: ${_config.maxTokens}');
      debugPrint('  temperature: ${_config.temperature}');
    } catch (e) {
      debugPrint('GeminiSDKAdapter: 模型初始化失败: $e');
    }
  }

  @override
  Future<LLMResponse> chat({
    required String systemPrompt,
    required String userMessage,
    List<Map<String, String>>? conversationHistory,
    Function(String chunk)? onStream,
  }) async {
    if (_model == null) {
      throw LLMException('Gemini模型未初始化');
    }

    final startTime = DateTime.now();

    try {
      // 创建或复用聊天会话
      if (_chatSession == null) {
        _chatSession = _model!.startChat(
          history: _convertHistory(conversationHistory),
        );
        debugPrint('GeminiSDKAdapter: 创建新的聊天会话');
      }

      // 发送消息
      debugPrint('GeminiSDKAdapter: 发送消息...');
      final response = await _chatSession!.sendMessage(
        Content.text(userMessage),
      );

      final responseTime = DateTime.now().difference(startTime);
      final content = response.text ?? '';

      debugPrint('GeminiSDKAdapter: 响应成功，耗时 ${responseTime.inMilliseconds}ms');
      debugPrint('GeminiSDKAdapter: 响应长度 ${content.length}');

      return LLMResponse(
        content: content,
        tokensUsed: 0, // SDK不返回token使用量
        responseTime: responseTime,
      );
    } on GenerativeAIException catch (e) {
      debugPrint('GeminiSDKAdapter: API错误: ${e.message}');
      
      // 处理特定错误
      if (e.message.contains('quota') || e.message.contains('429')) {
        throw TokenExhaustedException();
      }
      if (e.message.contains('rate limit')) {
        throw RateLimitException();
      }
      if (e.message.contains('401') || e.message.contains('unauthorized')) {
        throw LLMException('API密钥无效');
      }
      
      throw LLMException('Gemini API错误: ${e.message}');
    } catch (e) {
      debugPrint('GeminiSDKAdapter: 未知错误: $e');
      throw LLMException('请求失败: $e');
    }
  }

  @override
  Future<bool> isAvailable() async {
    if (_model == null) return false;

    try {
      // 简单测试
      await _model!.generateContent([Content.text('test')]);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// 转换历史记录格式
  List<Content> _convertHistory(List<Map<String, String>>? history) {
    if (history == null || history.isEmpty) {
      return [];
    }

    return history.map((msg) {
      final role = msg['role'];
      final content = msg['content'] ?? '';
      
      if (role == 'user') {
        return Content.text(content);
      } else {
        return Content.model([TextPart(content)]);
      }
    }).toList();
  }

  /// 重置聊天会话
  void resetChat() {
    _chatSession = null;
    debugPrint('GeminiSDKAdapter: 聊天会话已重置');
  }
}
