import 'package:flutter/foundation.dart';
import '../../../core/services/llm_service.dart';
import '../../../core/services/llm_config.dart';
import '../data/models/chat_session.dart';
import '../services/ai_config_service.dart';
import '../services/chat_service.dart';

/// 倾诉功能Provider
/// 整合对话服务、配置服务、状态管理
class ConfideProvider extends ChangeNotifier {
  final ChatService _chatService;
  final AIConfigService _configService;

  ConfideProvider({
    ChatService? chatService,
    AIConfigService? configService,
  })  : _chatService = chatService ?? ChatService(configService: AIConfigService()),
        _configService = configService ?? AIConfigService();

  // Getters
  ChatSession? get currentSession => _chatService.currentSession;
  bool get isLoading => _chatService.isLoading;
  bool get isAIEnabled => _chatService.canUseAIMode; // 使用canUseAIMode替代isConfigured
  ChatMode get currentMode => _chatService.currentMode;
  String? get error => _chatService.error;
  AIConfig get aiConfig => _configService.config;
  ChatService? get chatService => _chatService; // 暴露ChatService用于流式回调

  /// 初始化
  Future<void> initialize(String userId) async {
    debugPrint('=== ConfideProvider初始化 ===');
    debugPrint('传入用户ID: $userId');
    
    await _configService.initialize(userId: userId);
    await _chatService.initializeSession(userId);
    
    debugPrint('ConfideProvider初始化完成');
    debugPrint('isAIEnabled: $isAIEnabled');
    
    // 根据Token状态决定模式（不再需要手动创建LLM服务）
    // LLM服务由ServiceProvider统一管理
  }

  /// 更新LLM服务
  void _updateLLMService() {
    final config = _configService.config;
    if (config.isConfigured && config.isEnabled) {
      final llmConfig = LLMConfig(
        apiKey: config.apiKey,
        endpoint: config.endpoint,
        model: config.model,
      );
      _chatService.updateLLMService(OpenAICompatibleService(config: llmConfig));
    } else {
      _chatService.updateLLMService(null);
    }
  }

  /// 发送消息
  Future<ChatResult> sendMessage({
    required String userId,
    required String message,
    required String bondTitle,
    required String emotionDescription,
    List<String>? memories,
  }) async {
    return await _chatService.sendMessage(
      userId: userId,
      userMessage: message,
      bondTitle: bondTitle,
      emotionDescription: emotionDescription,
      memories: memories,
    );
  }

  /// 检查是否需要显示解锁弹窗
  /// 条件：
  /// 1. 羁绊等级 >= 1
  /// 2. 弹窗未显示过
  /// 3. 用户未配置AI（如果已配置则不需要提示）
  bool shouldShowUnlockDialog(int bondLevel) {
    // 如果用户已经配置了AI，不再显示弹窗
    if (_configService.isConfigured) {
      return false;
    }
    return bondLevel >= 1 && !_configService.hasShownUnlockDialog;
  }

  /// 标记解锁弹窗已显示
  Future<void> markUnlockDialogShown() async {
    await _configService.markUnlockDialogShown();
  }

  /// 保存AI配置
  Future<void> saveAIConfig(AIConfig config) async {
    await _configService.saveConfig(config);
    _updateLLMService();
  }

  /// 清除AI配置
  Future<void> clearAIConfig() async {
    await _configService.clearConfig();
    _chatService.updateLLMService(null);
  }

  /// 清除对话历史
  Future<void> clearHistory(String userId) async {
    await _chatService.clearAllHistory(userId);
  }

  /// 结束当前会话
  Future<void> endSession() async {
    await _chatService.endCurrentSession();
  }
}
