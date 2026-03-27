// AI配置数据模型
// 用于解析和管理assets/config/ai_config.json中的配置

/// AI提供商配置
class AIProviderConfig {
  final String id;
  final String name;
  final bool enabled;
  final int priority;
  final String defaultModel;
  final String endpoint;
  final String apiKeyStorageKey;
  final AIParameters parameters;
  final AIFeatures features;

  const AIProviderConfig({
    required this.id,
    required this.name,
    required this.enabled,
    this.priority = 1,
    required this.defaultModel,
    required this.endpoint,
    this.apiKeyStorageKey = '',
    required this.parameters,
    required this.features,
  });

  factory AIProviderConfig.fromJson(Map<String, dynamic> json) {
    return AIProviderConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      enabled: json['enabled'] as bool,
      priority: json['priority'] as int? ?? 1,
      defaultModel: json['defaultModel'] as String,
      endpoint: json['endpoint'] as String,
      apiKeyStorageKey: json['apiKeyStorageKey'] as String? ?? '',
      parameters: AIParameters.fromJson(json['parameters'] as Map<String, dynamic>),
      features: AIFeatures.fromJson(json['features'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'enabled': enabled,
      'priority': priority,
      'defaultModel': defaultModel,
      'endpoint': endpoint,
      'apiKeyStorageKey': apiKeyStorageKey,
      'parameters': parameters.toJson(),
      'features': features.toJson(),
    };
  }
}

/// AI参数配置
class AIParameters {
  final int maxTokens;
  final double temperature;
  final int timeoutMs;
  final int topK;
  final double topP;

  const AIParameters({
    required this.maxTokens,
    required this.temperature,
    required this.timeoutMs,
    required this.topK,
    required this.topP,
  });

  factory AIParameters.fromJson(Map<String, dynamic> json) {
    return AIParameters(
      maxTokens: json['maxTokens'] as int,
      temperature: (json['temperature'] as num).toDouble(),
      timeoutMs: json['timeoutMs'] as int,
      topK: json['topK'] as int,
      topP: (json['topP'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maxTokens': maxTokens,
      'temperature': temperature,
      'timeoutMs': timeoutMs,
      'topK': topK,
      'topP': topP,
    };
  }
}

/// AI功能特性
class AIFeatures {
  final bool supportsStreaming;
  final bool supportsSystemPrompt;
  final bool supportsHistory;

  const AIFeatures({
    required this.supportsStreaming,
    required this.supportsSystemPrompt,
    required this.supportsHistory,
  });

  factory AIFeatures.fromJson(Map<String, dynamic> json) {
    return AIFeatures(
      supportsStreaming: json['supportsStreaming'] as bool,
      supportsSystemPrompt: json['supportsSystemPrompt'] as bool,
      supportsHistory: json['supportsHistory'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'supportsStreaming': supportsStreaming,
      'supportsSystemPrompt': supportsSystemPrompt,
      'supportsHistory': supportsHistory,
    };
  }
}

/// 系统提示词配置
class SystemPromptConfig {
  final String template;
  final List<String> variables;

  const SystemPromptConfig({
    required this.template,
    required this.variables,
  });

  factory SystemPromptConfig.fromJson(Map<String, dynamic> json) {
    return SystemPromptConfig(
      template: json['template'] as String,
      variables: (json['variables'] as List).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'template': template,
      'variables': variables,
    };
  }

  /// 渲染模板，替换变量
  String render(Map<String, String> values) {
    String result = template;
    values.forEach((key, value) {
      result = result.replaceAll('{$key}', value);
    });
    return result;
  }
}

/// 对话配置
class ConversationConfig {
  final int maxHistoryLength;
  final bool enableAutoFallback;
  final String fallbackMessage;
  final bool enableStreaming;
  final int streamTimeoutMs;

  const ConversationConfig({
    required this.maxHistoryLength,
    required this.enableAutoFallback,
    required this.fallbackMessage,
    this.enableStreaming = true,
    this.streamTimeoutMs = 30000,
  });

  factory ConversationConfig.fromJson(Map<String, dynamic> json) {
    return ConversationConfig(
      maxHistoryLength: json['maxHistoryLength'] as int,
      enableAutoFallback: json['enableAutoFallback'] as bool,
      fallbackMessage: json['fallbackMessage'] as String,
      enableStreaming: json['enableStreaming'] as bool? ?? true,
      streamTimeoutMs: json['streamTimeoutMs'] as int? ?? 30000,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maxHistoryLength': maxHistoryLength,
      'enableAutoFallback': enableAutoFallback,
      'fallbackMessage': fallbackMessage,
      'enableStreaming': enableStreaming,
      'streamTimeoutMs': streamTimeoutMs,
    };
  }
}

/// 故障转移配置
class FallbackConfig {
  final List<String> order;
  final int retryAttempts;
  final int retryDelayMs;

  const FallbackConfig({
    required this.order,
    this.retryAttempts = 2,
    this.retryDelayMs = 1000,
  });

  factory FallbackConfig.fromJson(Map<String, dynamic> json) {
    return FallbackConfig(
      order: (json['order'] as List).cast<String>(),
      retryAttempts: json['retryAttempts'] as int? ?? 2,
      retryDelayMs: json['retryDelayMs'] as int? ?? 1000,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order': order,
      'retryAttempts': retryAttempts,
      'retryDelayMs': retryDelayMs,
    };
  }
}

/// 完整AI配置
class AIConfigModel {
  final String version;
  final List<AIProviderConfig> providers;
  final SystemPromptConfig systemPrompt;
  final ConversationConfig conversation;
  final FallbackConfig fallback;

  const AIConfigModel({
    required this.version,
    required this.providers,
    required this.systemPrompt,
    required this.conversation,
    required this.fallback,
  });

  factory AIConfigModel.fromJson(Map<String, dynamic> json) {
    return AIConfigModel(
      version: json['version'] as String,
      providers: (json['providers'] as List)
          .map((e) => AIProviderConfig.fromJson(e as Map<String, dynamic>))
          .toList(),
      systemPrompt: SystemPromptConfig.fromJson(json['systemPrompt'] as Map<String, dynamic>),
      conversation: ConversationConfig.fromJson(json['conversation'] as Map<String, dynamic>),
      fallback: FallbackConfig.fromJson(json['fallback'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'providers': providers.map((e) => e.toJson()).toList(),
      'systemPrompt': systemPrompt.toJson(),
      'conversation': conversation.toJson(),
      'fallback': fallback.toJson(),
    };
  }

  /// 获取启用的提供商
  AIProviderConfig? get enabledProvider {
    try {
      return providers.firstWhere((p) => p.enabled);
    } catch (_) {
      return null;
    }
  }

  /// 获取指定ID的提供商
  AIProviderConfig? getProvider(String id) {
    try {
      return providers.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
