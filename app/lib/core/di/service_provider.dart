import 'package:flutter/foundation.dart';
import '../../features/confide/services/ai_config_service.dart';
import '../../features/confide/services/chat_service.dart';
import '../../features/confide/providers/confide_provider.dart';
import '../../features/park/services/park_unlock_service.dart';
import '../services/llm_config.dart';
import '../services/llm_provider.dart';
import '../services/multi_llm_service.dart';
import 'repository_provider.dart';

/// 全局服务提供者
/// 管理应用级别的服务实例，确保单例模式
class ServiceProvider {
  // 单例实例
  static final ServiceProvider _instance = ServiceProvider._internal();
  factory ServiceProvider() => _instance;
  ServiceProvider._internal();

  // AI配置服务（全局单例）
  late final AIConfigService _aiConfigService;
  
  // 对话服务（全局单例）
  late final ChatService _chatService;
  
  // 倾诉Provider（全局单例）
  late final ConfideProvider _confideProvider;
  
  // 多模型LLM服务（新增）
  MultiLLMService? _multiLLMService;
  
  // 公园解锁服务（新增）
  ParkUnlockService? _parkUnlockService;

  /// 初始化服务
  /// [userId] 当前登录用户的ID，用于隔离用户数据
  Future<void> initialize({String? userId}) async {
    debugPrint('=== ServiceProvider初始化开始 ===');
    debugPrint('用户ID: $userId');
    
    // 创建AI配置服务
    _aiConfigService = AIConfigService();
    await _aiConfigService.initialize(userId: userId);
    
    debugPrint('AI配置服务初始化完成');
    debugPrint('isConfigured: ${_aiConfigService.isConfigured}');
    debugPrint('config.isEnabled: ${_aiConfigService.config.isEnabled}');

    // 创建对话服务
    _chatService = ChatService(configService: _aiConfigService);

    // 创建倾诉Provider
    _confideProvider = ConfideProvider(
      configService: _aiConfigService,
      chatService: _chatService,
    );

    // 初始化多模型LLM服务（新增）
    await _initializeMultiLLMService();
    
    // 将多模型服务传递给ChatService
    _chatService.updateMultiLLMService(_multiLLMService);
    
    // 初始化公园解锁服务
    _initializeParkUnlockService();
    
    debugPrint('=== ServiceProvider初始化完成 ===');
    debugPrint('canUseAIMode: $canUseAIMode');
  }

  /// 初始化多模型LLM服务
  Future<void> _initializeMultiLLMService() async {
    try {
      debugPrint('>>> 初始化多模型LLM服务');
      
      _multiLLMService = MultiLLMService();
      await _multiLLMService!.initialize();
      
      // 设置流式响应回调
      _multiLLMService!.onStreamResponse = (chunk, isDone) {
        // 这里可以通知UI更新流式内容
        debugPrint('流式响应: ${chunk.substring(0, chunk.length > 20 ? 20 : chunk.length)}...');
      };
      
      debugPrint('多模型LLM服务初始化完成');
      debugPrint('可用模型数: ${_multiLLMService!.hasAvailableService ? '有' : '无'}');
    } catch (e) {
      debugPrint('多模型LLM服务初始化失败: $e');
      _multiLLMService = null;
    }
  }
  
  /// 初始化公园解锁服务
  void _initializeParkUnlockService() {
    try {
      debugPrint('>>> 初始化公园解锁服务');
      
      _parkUnlockService = ParkUnlockService();
      _parkUnlockService!.initialize(
        userRepository: repositoryProvider.userRepository,
      );
      
      debugPrint('公园解锁服务初始化完成');
    } catch (e) {
      debugPrint('公园解锁服务初始化失败: $e');
      _parkUnlockService = null;
    }
  }

  /// 切换用户
  /// 调用此方法切换到新用户时，会重新加载该用户的AI配置
  Future<void> switchUser(String userId) async {
    await _aiConfigService.switchUser(userId);
    // 重新初始化多模型服务
    await _initializeMultiLLMService();
  }

  /// 更新LLM服务（兼容旧代码）
  void _updateLLMService() {
    debugPrint('=== 更新LLM服务 ===');
    final config = _aiConfigService.config;
    debugPrint('config.isConfigured: ${config.isConfigured}');
    debugPrint('config.isEnabled: ${config.isEnabled}');
    
    // 优先使用多模型服务
    if (_multiLLMService != null && _multiLLMService!.hasAvailableService) {
      debugPrint('使用多模型LLM服务');
      return;
    }
    
    // 回退到旧方式
    if (config.isConfigured && config.isEnabled) {
      final llmConfig = LLMConfig(
        apiKey: config.apiKey,
        endpoint: config.endpoint,
        model: config.model,
      );
      
      debugPrint('创建LLM服务 - Provider: ${config.provider}');
      
      // 默认使用SDK版本（更稳定）
      final service = LLMServiceFactory.create(LLMProvider.geminiSDK, llmConfig);
      _chatService.updateLLMService(service);
      debugPrint('LLM服务已更新（使用SDK）');
    } else {
      debugPrint('配置未完成或未启用，清除LLM服务');
      _chatService.updateLLMService(null);
    }
  }

  /// 使用多模型服务发送消息
  Future<MultiModelChatResult> sendMessageWithMultiModel({
    required String systemPrompt,
    required String userMessage,
    List<Map<String, String>>? conversationHistory,
    bool enableStreaming = true,
  }) async {
    if (_multiLLMService == null) {
      return MultiModelChatResult(
        content: 'AI服务未初始化',
        success: false,
      );
    }

    return await _multiLLMService!.sendMessage(
      systemPrompt: systemPrompt,
      userMessage: userMessage,
      conversationHistory: conversationHistory,
      enableStreaming: enableStreaming,
    );
  }

  /// 获取AI配置服务
  AIConfigService get aiConfigService => _aiConfigService;

  /// 获取对话服务
  ChatService get chatService => _chatService;

  /// 获取倾诉Provider
  ConfideProvider get confideProvider => _confideProvider;
  
  /// 获取多模型LLM服务
  MultiLLMService? get multiLLMService => _multiLLMService;
  
  /// 获取公园解锁服务
  ParkUnlockService? get parkUnlockService => _parkUnlockService;

  /// 检查是否可以使用AI模式（优先检查多模型服务）
  bool get canUseAIMode {
    // 优先检查多模型服务
    if (_multiLLMService != null && _multiLLMService!.hasAvailableService) {
      return true;
    }
    // 回退到旧方式
    return _aiConfigService.isConfigured && _aiConfigService.config.isEnabled;
  }

  /// 保存AI配置并更新服务（保留用于兼容）
  Future<void> saveAIConfig(AIConfig config) async {
    await _aiConfigService.saveConfig(config);
    _updateLLMService();
  }

  /// 清除AI配置（保留用于兼容）
  Future<void> clearAIConfig() async {
    await _aiConfigService.clearConfig();
    _chatService.updateLLMService(null);
  }
}

// 全局服务提供者实例
final serviceProvider = ServiceProvider();
