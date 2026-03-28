// AI配置加载服务
// 负责从JSON文件加载AI配置

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/ai_config_models.dart';
import '../constants/app_constants.dart';

/// AI配置加载服务
/// 负责从assets/config/ai_config.json加载AI配置
class AIConfigLoaderService {
  static AIConfigModel? _cachedConfig;
  static bool _isLoading = false;

  /// 获取配置（带缓存）
  static Future<AIConfigModel> getConfig() async {
    if (_cachedConfig != null) {
      return _cachedConfig!;
    }
    return await loadConfig();
  }

  /// 加载配置
  static Future<AIConfigModel> loadConfig() async {
    if (_isLoading) {
      // 等待加载完成
      while (_isLoading) {
        await Future.delayed(const Duration(milliseconds: 10));
      }
      return _cachedConfig!;
    }

    _isLoading = true;
    
    try {
      debugPrint('=== 加载AI配置JSON ===');
      
      // 从assets加载JSON文件
      final jsonString = await rootBundle.loadString(AssetPaths.aiConfig);
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      
      _cachedConfig = AIConfigModel.fromJson(jsonMap);
      
      debugPrint('AI配置加载成功');
      debugPrint('版本: ${_cachedConfig!.version}');
      debugPrint('提供商数量: ${_cachedConfig!.providers.length}');
      debugPrint('启用的提供商: ${_cachedConfig!.enabledProvider?.name}');
      
      return _cachedConfig!;
    } catch (e, stackTrace) {
      debugPrint('加载AI配置失败: $e');
      debugPrint(stackTrace.toString());
      
      // 返回默认配置
      return _getDefaultConfig();
    } finally {
      _isLoading = false;
    }
  }

  /// 清除缓存
  static void clearCache() {
    _cachedConfig = null;
    debugPrint('AI配置缓存已清除');
  }

  /// 重新加载
  static Future<AIConfigModel> reload() async {
    clearCache();
    return await loadConfig();
  }

  /// 默认配置（降级方案）
  static AIConfigModel _getDefaultConfig() {
    return const AIConfigModel(
      version: '1.0.0-default',
      providers: [
        AIProviderConfig(
          id: 'gemini',
          name: 'Google Gemini',
          enabled: true,
          defaultModel: 'gemini-2.0-flash-exp',
          endpoint: 'https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent',
          parameters: AIParameters(
            maxTokens: 500,
            temperature: 0.7,
            timeoutMs: 10000,
            topK: 1,
            topP: 1.0,
          ),
          features: AIFeatures(
            supportsStreaming: true,
            supportsSystemPrompt: true,
            supportsHistory: true,
          ),
        ),
      ],
      systemPrompt: SystemPromptConfig(
        template: '你是一只名叫咕咕的宠物鸟，正在陪伴用户求职。',
        variables: [],
      ),
      conversation: ConversationConfig(
        maxHistoryLength: 10,
        enableAutoFallback: true,
        fallbackMessage: '咕...让我休息一下~',
      ),
      fallback: FallbackConfig(
        order: ['gemini'],
        retryAttempts: 2,
        retryDelayMs: 1000,
      ),
    );
  }
}
