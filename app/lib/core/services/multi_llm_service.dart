// 多模型LLM服务管理器
// 支持主备模型切换、流式调用、安全存储API Key

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'ai_config_loader_service.dart';
import 'llm_service.dart';
import 'llm_config.dart';
import 'llm_provider.dart';
import 'security_service.dart';
import '../models/ai_config_models.dart';

/// 多模型LLM服务管理器
/// 自动管理主备模型切换、流式调用
class MultiLLMService {
  final _secureStorage = const FlutterSecureStorage();
  final Map<String, LLMService> _services = {};
  String? _currentProviderId;
  
  /// 流式响应回调
  Function(String chunk, bool isDone)? onStreamResponse;

  /// 初始化并预加载所有启用的模型
  Future<void> initialize() async {
    debugPrint('=== MultiLLMService初始化 ===');
    
    final config = await AIConfigLoaderService.getConfig();
    
    for (final provider in config.providers) {
      if (provider.enabled) {
        await _initializeProvider(provider);
      }
    }
    
    // 设置当前为主模型
    final primaryProvider = config.enabledProvider;
    if (primaryProvider != null) {
      _currentProviderId = primaryProvider.id;
      debugPrint('主模型: ${primaryProvider.name}');
    }
  }

  /// 初始化单个提供商
  Future<void> _initializeProvider(AIProviderConfig providerConfig) async {
    try {
      // 从安全存储读取API Key
      final apiKey = await _loadApiKey(providerConfig.apiKeyStorageKey);
      
      if (apiKey == null || apiKey.isEmpty) {
        debugPrint('${providerConfig.name}: API Key未配置');
        return;
      }

      // 创建LLM配置
      final llmConfig = LLMConfig(
        apiKey: apiKey,
        endpoint: providerConfig.endpoint,
        model: providerConfig.defaultModel,
      );

      // 创建服务实例
      final provider = _getProviderEnum(providerConfig.id);
      if (provider != null) {
        final service = LLMServiceFactory.create(provider, llmConfig);
        _services[providerConfig.id] = service;
        debugPrint('${providerConfig.name}: 初始化成功');
      }
    } catch (e) {
      debugPrint('${providerConfig.name}: 初始化失败: $e');
    }
  }

  /// 从安全存储加载API Key
  Future<String?> _loadApiKey(String storageKey) async {
    try {
      final securityService = SecurityService();
      final encryptedKey = await _secureStorage.read(key: storageKey);
      
      if (encryptedKey == null || encryptedKey.isEmpty) {
        return null;
      }
      
      return securityService.decryptData(encryptedKey);
    } catch (e) {
      debugPrint('加载API Key失败 ($storageKey): $e');
      return null;
    }
  }

  /// 安全存储API Key
  Future<void> saveApiKey(String providerId, String apiKey) async {
    try {
      final config = await AIConfigLoaderService.getConfig();
      final provider = config.getProvider(providerId);
      
      if (provider == null) {
        throw Exception('未知的提供商: $providerId');
      }

      final securityService = SecurityService();
      final encryptedKey = securityService.encryptData(apiKey);
      
      await _secureStorage.write(
        key: provider.apiKeyStorageKey,
        value: encryptedKey,
      );
      
      debugPrint('API Key已安全存储: ${provider.name}');
      
      // 重新初始化该提供商
      await _initializeProvider(provider);
    } catch (e) {
      debugPrint('保存API Key失败: $e');
      rethrow;
    }
  }

  /// 发送消息（自动故障转移）
  Future<ChatResult> sendMessage({
    required String systemPrompt,
    required String userMessage,
    List<Map<String, String>>? conversationHistory,
    bool enableStreaming = true,
  }) async {
    final config = await AIConfigLoaderService.getConfig();
    final fallbackOrder = config.fallback.order;
    
    // 按优先级尝试各个模型
    for (final providerId in fallbackOrder) {
      final service = _services[providerId];
      if (service == null) continue;

      try {
        debugPrint('尝试使用模型: $providerId');
        
        LLMResponse response;
        
        if (enableStreaming && onStreamResponse != null) {
          // 流式调用
          response = await service.chat(
            systemPrompt: systemPrompt,
            userMessage: userMessage,
            conversationHistory: conversationHistory,
            onStream: (chunk) {
              onStreamResponse!(chunk, false);
            },
          );
          // 标记流结束
          onStreamResponse!('', true);
        } else {
          // 非流式调用
          response = await service.chat(
            systemPrompt: systemPrompt,
            userMessage: userMessage,
            conversationHistory: conversationHistory,
          );
        }

        _currentProviderId = providerId;
        
        return ChatResult(
          content: response.content,
          providerId: providerId,
          success: true,
        );
      } on TokenExhaustedException {
        debugPrint('$providerId: Token耗尽，尝试下一个模型');
        continue;
      } on RateLimitException {
        debugPrint('$providerId: 限流，尝试下一个模型');
        continue;
      } on LLMException catch (e) {
        debugPrint('$providerId: 错误 - $e');
        continue;
      }
    }

    // 所有模型都失败
    return ChatResult(
      content: config.conversation.fallbackMessage,
      providerId: null,
      success: false,
      isFallback: true,
    );
  }

  /// 获取当前使用的提供商ID
  String? get currentProviderId => _currentProviderId;

  /// 检查是否有可用的模型
  bool get hasAvailableService => _services.isNotEmpty;

  /// 获取提供商枚举
  LLMProvider? _getProviderEnum(String id) {
    switch (id) {
      case 'glm':
        return LLMProvider.glm;
      case 'hunyuan':
        return LLMProvider.hunyuan;
      case 'gemini':
        return LLMProvider.gemini;
      case 'geminiSDK':
        return LLMProvider.geminiSDK;
      default:
        return null;
    }
  }

  /// 释放资源
  void dispose() {
    _services.clear();
    onStreamResponse = null;
  }
}

/// 对话结果
class ChatResult {
  final String content;
  final String? providerId;
  final bool success;
  final bool isFallback;

  ChatResult({
    required this.content,
    this.providerId,
    this.success = true,
    this.isFallback = false,
  });
}
