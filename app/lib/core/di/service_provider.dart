import '../../features/confide/services/ai_config_service.dart';
import '../../features/confide/services/chat_service.dart';
import '../../features/confide/providers/confide_provider.dart';
import '../services/llm_config.dart';
import '../services/llm_provider.dart';

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

  /// 初始化服务
  /// [userId] 当前登录用户的ID，用于隔离用户数据
  Future<void> initialize({String? userId}) async {
    // 创建AI配置服务
    _aiConfigService = AIConfigService();
    await _aiConfigService.initialize(userId: userId);

    // 创建对话服务
    _chatService = ChatService(configService: _aiConfigService);

    // 创建倾诉Provider
    _confideProvider = ConfideProvider(
      configService: _aiConfigService,
      chatService: _chatService,
    );

    // 如果已配置，初始化LLM服务
    if (_aiConfigService.isConfigured) {
      _updateLLMService();
    }
  }

  /// 切换用户
  /// 调用此方法切换到新用户时，会重新加载该用户的AI配置
  Future<void> switchUser(String userId) async {
    await _aiConfigService.switchUser(userId);
    // 重新初始化LLM服务
    if (_aiConfigService.isConfigured) {
      _updateLLMService();
    }
  }

  /// 更新LLM服务
  void _updateLLMService() {
    final config = _aiConfigService.config;
    if (config.isConfigured && config.isEnabled) {
      final llmConfig = LLMConfig(
        apiKey: config.apiKey,
        endpoint: config.endpoint,
        model: config.model,
      );
      
      // 使用工厂创建对应平台的服务
      final service = LLMServiceFactory.create(config.provider, llmConfig);
      _chatService.updateLLMService(service);
    } else {
      _chatService.updateLLMService(null);
    }
  }

  /// 获取AI配置服务
  AIConfigService get aiConfigService => _aiConfigService;

  /// 获取对话服务
  ChatService get chatService => _chatService;

  /// 获取倾诉Provider
  ConfideProvider get confideProvider => _confideProvider;

  /// 保存AI配置并更新服务
  Future<void> saveAIConfig(AIConfig config) async {
    await _aiConfigService.saveConfig(config);
    _updateLLMService();
    // AIConfigService.saveConfig已经调用了notifyListeners()
  }

  /// 清除AI配置
  Future<void> clearAIConfig() async {
    await _aiConfigService.clearConfig();
    _chatService.updateLLMService(null);
    // AIConfigService.clearConfig已经调用了notifyListeners()
  }
}

// 全局服务提供者实例
final serviceProvider = ServiceProvider();
