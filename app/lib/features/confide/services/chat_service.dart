import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../../core/services/llm_service.dart';
import '../../../core/services/ai_config_loader_service.dart';
import '../../../core/models/ai_config_models.dart';
import '../data/models/chat_message.dart';
import '../data/models/chat_session.dart';
import '../data/datasources/chat_local_datasource.dart';
import 'ai_config_service.dart';

/// 对话模式
enum ChatMode {
  ai,       // AI智能对话
  simple,   // 简单倾诉
}

/// 对话结果
class ChatResult {
  final String content;
  final ChatMode mode;
  final bool isTokenExhausted;

  const ChatResult({
    required this.content,
    required this.mode,
    this.isTokenExhausted = false,
  });
}

/// 对话服务
/// 管理对话会话和AI交互
class ChatService extends ChangeNotifier {
  final ChatLocalDatasource _localDatasource;
  final AIConfigService _configService;
  LLMService? _llmService;

  ChatSession? _currentSession;
  ChatMode _currentMode = ChatMode.simple;
  bool _isLoading = false;
  String? _error;
  
  /// Token是否已耗尽（用于自动切换本地模式）
  bool _tokenExhausted = false;

  ChatSession? get currentSession => _currentSession;
  ChatMode get currentMode => _currentMode;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  /// 是否可以使用AI模式（配置正确且Token未耗尽）
  bool get canUseAIMode => _configService.isConfigured && _llmService != null && !_tokenExhausted;

  ChatService({
    ChatLocalDatasource? localDatasource,
    required AIConfigService configService,
    LLMService? llmService,
  })  : _localDatasource = localDatasource ?? ChatLocalDatasource(),
        _configService = configService,
        _llmService = llmService;

  /// 更新LLM服务
  void updateLLMService(LLMService? service) {
    _llmService = service;
    // 更新LLM服务时重置Token耗尽状态
    _tokenExhausted = false;
    _currentMode = canUseAIMode ? ChatMode.ai : ChatMode.simple;
    notifyListeners();
  }

  /// 初始化或获取会话
  Future<void> initializeSession(String userId) async {
    _currentSession = await _localDatasource.getActiveSession(userId);
    
    _currentSession ??= await _localDatasource.createSession(userId);
    
    // 根据配置和Token状态决定模式
    _currentMode = canUseAIMode ? ChatMode.ai : ChatMode.simple;
    
    notifyListeners();
  }

  /// 发送消息并获取回复
  Future<ChatResult> sendMessage({
    required String userId,
    required String userMessage,
    required String bondTitle,
    required String emotionDescription,
    List<String>? memories,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 确保有活跃会话
      if (_currentSession == null || _currentSession!.userId != userId) {
        await initializeSession(userId);
      }

      // 添加用户消息
      final userMsg = ChatMessage(
        messageId: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        role: ChatRole.user,
        content: userMessage,
        timestamp: DateTime.now(),
      );
      
      _currentSession = _currentSession!.addMessage(userMsg);
      await _localDatasource.addMessage(_currentSession!.sessionId, userMsg);

      // 尝试AI对话（使用canUseAIMode判断，避免每次都检查配置）
      debugPrint('=== 对话模式判断 ===');
      debugPrint('canUseAIMode: $canUseAIMode');
      debugPrint('_tokenExhausted: $_tokenExhausted');
      debugPrint('_configService.isConfigured: ${_configService.isConfigured}');
      debugPrint('_llmService != null: ${_llmService != null}');
      
      if (canUseAIMode) {
        debugPrint('>>> 使用AI模式');
        return await _sendAIMessage(
          userMessage: userMessage,
          bondTitle: bondTitle,
          emotionDescription: emotionDescription,
          memories: memories,
        );
      }

      debugPrint('>>> 使用本地简单模式');
      // 降级到简单倾诉模式
      return await _sendSimpleMessage(userMessage);
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// 发送AI消息
  Future<ChatResult> _sendAIMessage({
    required String userMessage,
    required String bondTitle,
    required String emotionDescription,
    List<String>? memories,
  }) async {
    try {
      // 从JSON配置构建系统提示词
      final systemPrompt = await _buildSystemPrompt(
        bondTitle: bondTitle,
        emotionDescription: emotionDescription,
        memories: memories,
      );

      // 从JSON配置获取历史记录限制
      final config = await AIConfigLoaderService.getConfig();
      final maxHistoryLength = config.conversation.maxHistoryLength;
      
      final response = await _llmService!.chat(
        systemPrompt: systemPrompt,
        userMessage: userMessage,
        conversationHistory: _currentSession!.toApiHistory(limit: maxHistoryLength),
      );

      // 添加AI回复
      final assistantMsg = ChatMessage(
        messageId: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        role: ChatRole.assistant,
        content: response.content,
        timestamp: DateTime.now(),
      );
      
      _currentSession = _currentSession!.addMessage(assistantMsg);
      await _localDatasource.addMessage(_currentSession!.sessionId, assistantMsg);

      _currentMode = ChatMode.ai;
      _isLoading = false;
      notifyListeners();

      // 添加AI标记 ++ 用于测试区分
      return ChatResult(
        content: '${response.content}++',
        mode: ChatMode.ai,
      );
    } on TokenExhaustedException {
      // Token不足，标记为已耗尽，切换到简单模式
      _tokenExhausted = true;
      _currentMode = ChatMode.simple;
      _isLoading = false;
      notifyListeners();

      return ChatResult(
        content: '咕...感觉脑袋有点晕晕的，让我休息一下，我们继续聊天吧~',
        mode: ChatMode.simple,
        isTokenExhausted: true,
      );
    } on RateLimitException {
      // 限流，降级到简单模式
      debugPrint('LLM限流');
      return await _sendSimpleMessage(userMessage);
    } on LLMException catch (e) {
      // 其他LLM错误，降级到简单模式
      debugPrint('LLM错误: $e');
      return await _sendSimpleMessage(userMessage);
    }
  }

  /// 发送简单倾诉消息
  Future<ChatResult> _sendSimpleMessage(String userMessage) async {
    // 使用本地模板生成回复
    final response = _generateSimpleResponse(userMessage);

    // 添加回复消息
    final assistantMsg = ChatMessage(
      messageId: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      role: ChatRole.assistant,
      content: response,
      timestamp: DateTime.now(),
    );
    
    _currentSession = _currentSession!.addMessage(assistantMsg);
    await _localDatasource.addMessage(_currentSession!.sessionId, assistantMsg);

    _currentMode = ChatMode.simple;
    _isLoading = false;
    notifyListeners();

    return ChatResult(
      content: response,
      mode: ChatMode.simple,
    );
  }

  /// 构建系统提示词（使用JSON配置模板）
  Future<String> _buildSystemPrompt({
    required String bondTitle,
    required String emotionDescription,
    List<String>? memories,
  }) async {
    final config = await AIConfigLoaderService.getConfig();
    final memoryText = memories != null && memories.isNotEmpty
        ? '\n相关记忆：\n${memories.map((m) => '- $m').join('\n')}'
        : '';

    // 使用JSON配置中的模板渲染
    return config.systemPrompt.render({
      'bondTitle': bondTitle,
      'emotionDescription': emotionDescription,
      'memoryText': memoryText,
    });
  }

  /// 生成简单回复
  String _generateSimpleResponse(String userMessage) {
    // 根据消息内容选择合适的回复模板
    final templates = _getTemplatesForMessage(userMessage);
    final random = Random();
    return templates[random.nextInt(templates.length)];
  }

  /// 根据消息获取回复模板
  List<String> _getTemplatesForMessage(String message) {
    final lowerMessage = message.toLowerCase();
    
    // 检测情绪关键词
    if (lowerMessage.contains('开心') || 
        lowerMessage.contains('高兴') || 
        lowerMessage.contains('好消息')) {
      return [
        '太棒了！为你开心！咕咕~',
        '哇！真好！我就知道你可以的！',
        '恭喜恭喜！咕咕~我们一起庆祝！',
      ];
    }
    
    if (lowerMessage.contains('难过') || 
        lowerMessage.contains('伤心') || 
        lowerMessage.contains('失落')) {
      return [
        '没关系，我会一直陪着你的，咕...',
        '别难过，一切都会好起来的',
        '我在这里，随时听你说，咕~',
      ];
    }
    
    if (lowerMessage.contains('累') || 
        lowerMessage.contains('疲惫') || 
        lowerMessage.contains('压力')) {
      return [
        '辛苦了，记得休息一下，咕~',
        '你已经很努力了，给自己一点时间',
        '咕...抱抱你，会好起来的',
      ];
    }
    
    if (lowerMessage.contains('面试') || 
        lowerMessage.contains('offer') || 
        lowerMessage.contains('工作')) {
      return [
        '求职路上不容易，但我相信你！咕~',
        '加油！每一步都是成长',
        '咕咕~我会一直陪着你的',
      ];
    }
    
    // 默认回复
    return [
      '咕咕~我在听呢',
      '嗯嗯，我明白，咕~',
      '谢谢你跟我分享，咕咕',
      '我会一直陪着你的，咕~',
    ];
  }

  /// 结束当前会话
  Future<void> endCurrentSession() async {
    if (_currentSession != null) {
      await _localDatasource.endSession(_currentSession!.sessionId);
      _currentSession = null;
      notifyListeners();
    }
  }

  /// 清除所有对话历史
  Future<void> clearAllHistory(String userId) async {
    await _localDatasource.clearAllSessions(userId);
    _currentSession = null;
    notifyListeners();
  }
}
