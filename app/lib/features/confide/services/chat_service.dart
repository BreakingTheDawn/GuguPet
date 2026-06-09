import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../../core/services/llm_service.dart';
import '../../../core/services/ai_config_loader_service.dart';
import '../../../core/services/multi_llm_service.dart';
import '../../../core/services/app_strings.dart';
import '../data/models/chat_message.dart';
import '../data/models/chat_session.dart';
import '../data/models/emotion_response.dart';
import '../data/datasources/chat_local_datasource.dart';
import 'ai_config_service.dart';
import '../../pet/services/retrieval_service.dart';
import '../../pet/data/models/vector_memory.dart';

/// 对话模式
enum ChatMode {
  ai, // AI智能对话
  simple, // 简单倾诉
}

/// 对话结果
class ChatResult {
  /// 显示给用户的文本内容
  final String content;

  /// 对话模式
  final ChatMode mode;

  /// Token是否已耗尽
  final bool isTokenExhausted;

  /// 情感响应（包含情感类型和纯净内容）
  final EmotionResponse? emotionResponse;

  const ChatResult({
    required this.content,
    required this.mode,
    this.isTokenExhausted = false,
    this.emotionResponse,
  });

  /// 获取情感类型
  AIEmotionType get emotion => emotionResponse?.emotion ?? AIEmotionType.normal;
}

/// 对话服务
/// 管理对话会话和AI交互
class ChatService extends ChangeNotifier {
  final ChatLocalDatasource _localDatasource;
  final bool _localPersistenceEnabled;
  final AIConfigService _configService;
  LLMService? _llmService;
  MultiLLMService? _multiLLMService;

  /// RAG检索服务（可选）
  RetrievalService? _retrievalService;

  /// 当前宠物ID（用于RAG检索）
  String? _currentPetId;

  ChatSession? _currentSession;
  ChatMode _currentMode = ChatMode.simple;
  bool _isLoading = false;
  String? _error;

  /// Token是否已耗尽（用于自动切换本地模式）
  bool _tokenExhausted = false;

  /// 流式响应回调
  Function(String chunk, bool isDone)? onStreamResponse;

  ChatSession? get currentSession => _currentSession;
  ChatMode get currentMode => _currentMode;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 是否可以使用AI模式（优先检查多模型服务）
  bool get canUseAIMode {
    // 优先检查多模型服务
    if (_multiLLMService != null && _multiLLMService!.hasAvailableService) {
      return true;
    }
    // 回退到旧方式
    return _configService.isConfigured &&
        _llmService != null &&
        !_tokenExhausted;
  }

  ChatService({
    ChatLocalDatasource? localDatasource,
    required AIConfigService configService,
    LLMService? llmService,
    MultiLLMService? multiLLMService,
    bool localPersistenceEnabled = true,
  }) : _localDatasource = localDatasource ?? ChatLocalDatasource(),
       _localPersistenceEnabled = localPersistenceEnabled,
       _configService = configService,
       _llmService = llmService,
       _multiLLMService = multiLLMService;

  /// 更新LLM服务
  void updateLLMService(LLMService? service) {
    _llmService = service;
    // 更新LLM服务时重置Token耗尽状态
    _tokenExhausted = false;
    _currentMode = canUseAIMode ? ChatMode.ai : ChatMode.simple;
    notifyListeners();
  }

  /// 更新多模型LLM服务
  void updateMultiLLMService(MultiLLMService? service) {
    _multiLLMService = service;
    _tokenExhausted = false;
    _currentMode = canUseAIMode ? ChatMode.ai : ChatMode.simple;
    notifyListeners();
  }

  /// 更新RAG检索服务
  void updateRetrievalService(RetrievalService? service, {String? petId}) {
    _retrievalService = service;
    _currentPetId = petId;
    debugPrint('📚 RAG检索服务已${service != null ? '启用' : '禁用'}');
  }

  /// 设置当前宠物ID
  void setCurrentPetId(String? petId) {
    _currentPetId = petId;
  }

  /// 初始化或获取会话
  Future<void> initializeSession(String userId) async {
    if (!_localPersistenceEnabled) {
      _currentSession = ChatSession.create(
        sessionId: 'memory_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
      );
      _currentMode = canUseAIMode ? ChatMode.ai : ChatMode.simple;
      notifyListeners();
      return;
    }

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
      if (_localPersistenceEnabled) {
        await _localDatasource.addMessage(_currentSession!.sessionId, userMsg);
      }

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
      // === RAG记忆检索 ===
      List<String> retrievedMemories = memories ?? [];

      if (_retrievalService != null && _currentPetId != null) {
        try {
          final result = await _retrievalService!.search(
            query: userMessage,
            petId: _currentPetId!,
            topK: 5,
            threshold: 0.6,
          );

          if (result.hasResults) {
            retrievedMemories = result.toContentList();
            debugPrint('📚 RAG检索到 ${result.length} 条相关记忆');
            for (var i = 0; i < result.length; i++) {
              debugPrint(
                '  - [相似度: ${result.scores[i].toStringAsFixed(2)}] ${result.memories[i].content}',
              );
            }
          } else {
            debugPrint('📚 RAG未检索到相关记忆');
          }
        } catch (e) {
          debugPrint('⚠️ RAG检索失败: $e');
        }
      }
      // === RAG集成结束 ===

      // 从JSON配置构建系统提示词
      final systemPrompt = await _buildSystemPrompt(
        bondTitle: bondTitle,
        emotionDescription: emotionDescription,
        memories: retrievedMemories,
      );

      // 从JSON配置获取历史记录限制
      final config = await AIConfigLoaderService.getConfig();
      final maxHistoryLength = config.conversation.maxHistoryLength;

      String responseContent;

      // 优先使用多模型服务（支持流式响应）
      if (_multiLLMService != null && _multiLLMService!.hasAvailableService) {
        debugPrint('>>> 使用多模型LLM服务');

        // 设置流式响应回调
        _multiLLMService!.onStreamResponse = (chunk, isDone) {
          if (onStreamResponse != null) {
            onStreamResponse!(chunk, isDone);
          }
        };

        final result = await _multiLLMService!.sendMessage(
          systemPrompt: systemPrompt,
          userMessage: userMessage,
          conversationHistory: _currentSession!.toApiHistory(
            limit: maxHistoryLength,
          ),
          enableStreaming: true,
        );

        responseContent = result.content;

        if (!result.success) {
          // 所有模型都失败，返回降级消息
          _currentMode = ChatMode.simple;
          _isLoading = false;
          notifyListeners();
          return ChatResult(
            content: result.content,
            mode: ChatMode.simple,
            isTokenExhausted: result.isFallback,
          );
        }
      } else if (_llmService != null) {
        debugPrint('>>> 使用单模型LLM服务');
        // 回退到旧的LLM服务
        final response = await _llmService!.chat(
          systemPrompt: systemPrompt,
          userMessage: userMessage,
          conversationHistory: _currentSession!.toApiHistory(
            limit: maxHistoryLength,
          ),
        );
        responseContent = response.content;
      } else {
        throw LLMException('LLM服务未初始化');
      }

      // 回复长度控制：超过60字自动截断（兜底机制）
      const maxLength = 60;
      if (responseContent.length > maxLength) {
        debugPrint('⚠️ AI回复过长(${responseContent.length}字)，自动截断到$maxLength字');
        responseContent = '${responseContent.substring(0, maxLength)}...';
      }

      // 解析情感响应（提取情感标签并移除）
      final emotionResponse = EmotionResponse.fromRawResponse(responseContent);
      debugPrint('🎭 AI情感解析: ${emotionResponse.emotionName}');
      debugPrint('📝 纯净内容: ${emotionResponse.content}');

      // 添加AI回复（存储纯净内容，不含情感标签）
      final assistantMsg = ChatMessage(
        messageId: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        role: ChatRole.assistant,
        content: emotionResponse.content,
        timestamp: DateTime.now(),
      );

      _currentSession = _currentSession!.addMessage(assistantMsg);
      if (_localPersistenceEnabled) {
        await _localDatasource.addMessage(
          _currentSession!.sessionId,
          assistantMsg,
        );
      }

      // === 对话后记忆存储 ===
      await _storeConversationMemory(
        userMessage: userMessage,
        assistantResponse: emotionResponse.content,
        emotion: emotionResponse.emotionName,
      );
      // === 记忆存储结束 ===

      _currentMode = ChatMode.ai;
      _isLoading = false;
      notifyListeners();

      return ChatResult(
        content: emotionResponse.content,
        mode: ChatMode.ai,
        emotionResponse: emotionResponse,
      );
    } on TokenExhaustedException {
      // Token不足，标记为已耗尽，切换到简单模式
      _tokenExhausted = true;
      _currentMode = ChatMode.simple;
      _isLoading = false;
      notifyListeners();

      return ChatResult(
        content: AppStrings().confide.tokenExhausted,
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
    if (_localPersistenceEnabled) {
      await _localDatasource.addMessage(
        _currentSession!.sessionId,
        assistantMsg,
      );
    }

    _currentMode = ChatMode.simple;
    _isLoading = false;
    notifyListeners();

    return ChatResult(content: response, mode: ChatMode.simple);
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

  /// 根据消息获取回复模板（使用配置化的情绪关键词）
  List<String> _getTemplatesForMessage(String message) {
    final confideStrings = AppStrings().confide;
    final keywords = confideStrings.emotionKeywords;

    // 检测情绪关键词（按优先级匹配）
    if (keywords.matchesKeywords(message, keywords.positive)) {
      return confideStrings.positiveResponses;
    }

    if (keywords.matchesKeywords(message, keywords.negative)) {
      return confideStrings.negativeResponses;
    }

    if (keywords.matchesKeywords(message, keywords.rejected)) {
      return confideStrings.negativeResponses;
    }

    if (keywords.matchesKeywords(message, keywords.lost)) {
      return confideStrings.negativeResponses;
    }

    if (keywords.matchesKeywords(message, keywords.interview)) {
      return confideStrings.interviewResponses;
    }

    // 默认回复
    return confideStrings.defaultResponses;
  }

  /// 结束当前会话
  Future<void> endCurrentSession() async {
    if (_currentSession != null) {
      if (_localPersistenceEnabled) {
        await _localDatasource.endSession(_currentSession!.sessionId);
      }
      _currentSession = null;
      notifyListeners();
    }
  }

  /// 清除所有对话历史
  Future<void> clearAllHistory(String userId) async {
    if (_localPersistenceEnabled) {
      await _localDatasource.clearAllSessions(userId);
    }
    _currentSession = null;
    notifyListeners();
  }

  /// 存储对话记忆到向量数据库
  /// 在对话完成后自动调用，将重要信息存储为向量记忆
  Future<void> _storeConversationMemory({
    required String userMessage,
    required String assistantResponse,
    required String emotion,
  }) async {
    // 检查RAG服务是否可用
    if (_retrievalService == null || _currentPetId == null) {
      debugPrint('📚 RAG服务未初始化，跳过记忆存储');
      return;
    }

    try {
      // 1. 存储用户消息作为短期记忆
      await _storeMemory(
        content: '用户说: $userMessage',
        type: MemoryType.shortTerm,
        category: MemoryCategory.emotion,
        importance: _calculateImportance(userMessage),
      );

      // 2. 检测是否有关键事件需要存储
      final keyEvent = _detectKeyEvent(userMessage, assistantResponse);
      if (keyEvent != null) {
        await _storeMemory(
          content: keyEvent,
          type: MemoryType.keyEvent,
          category: MemoryCategory.job,
          importance: 1.0,
        );
        debugPrint('📚 检测到关键事件，已存储: $keyEvent');
      }

      // 3. 检测是否有用户偏好需要存储
      final preference = _detectPreference(userMessage);
      if (preference != null) {
        await _storeMemory(
          content: preference,
          type: MemoryType.preference,
          category: MemoryCategory.preference,
          importance: 0.8,
        );
        debugPrint('📚 检测到用户偏好，已存储: $preference');
      }

      debugPrint('📚 对话记忆存储完成');
    } catch (e) {
      debugPrint('⚠️ 存储对话记忆失败: $e');
    }
  }

  /// 存储单条记忆
  Future<void> _storeMemory({
    required String content,
    required MemoryType type,
    required MemoryCategory category,
    required double importance,
  }) async {
    if (_retrievalService == null || _currentPetId == null) return;

    try {
      // 生成向量嵌入
      final embedding = await _retrievalService!.embed(content);
      if (embedding.isEmpty) {
        debugPrint('⚠️ 生成向量嵌入失败');
        return;
      }

      // 创建记忆对象
      final memory = VectorMemory(
        id: 'mem_${DateTime.now().millisecondsSinceEpoch}_${type.name}',
        petId: _currentPetId!,
        type: type,
        category: category,
        content: content,
        embedding: embedding,
        importance: importance,
        createdAt: DateTime.now(),
        expiresAt: type == MemoryType.shortTerm
            ? DateTime.now().add(const Duration(hours: 24))
            : null,
      );

      // 通过检索服务存储
      await _retrievalService!.index(memory);
    } catch (e) {
      debugPrint('⚠️ 存储记忆失败: $e');
    }
  }

  /// 计算消息重要性
  double _calculateImportance(String message) {
    // 基于消息长度和关键词判断重要性
    var importance = 0.3;

    // 长消息更重要
    if (message.length > 100) importance += 0.2;
    if (message.length > 200) importance += 0.1;

    // 包含关键事件关键词
    final keyEventKeywords = ['面试', 'offer', '入职', '离职', '升职', '转正'];
    for (final keyword in keyEventKeywords) {
      if (message.contains(keyword)) {
        importance += 0.3;
        break;
      }
    }

    return importance.clamp(0.0, 1.0);
  }

  /// 检测关键事件
  String? _detectKeyEvent(String userMessage, String assistantResponse) {
    final keyEventPatterns = [
      {'pattern': RegExp(r'面试'), 'template': '有面试安排'},
      {'pattern': RegExp(r'offer|录取|录用'), 'template': '收到Offer'},
      {'pattern': RegExp(r'入职'), 'template': '即将入职新公司'},
      {'pattern': RegExp(r'离职|辞职'), 'template': '从公司离职'},
      {'pattern': RegExp(r'升职|晋升'), 'template': '获得晋升'},
      {'pattern': RegExp(r'转正'), 'template': '工作转正'},
    ];

    for (final item in keyEventPatterns) {
      final pattern = item['pattern'] as RegExp;
      final template = item['template'] as String;

      if (pattern.hasMatch(userMessage) ||
          pattern.hasMatch(assistantResponse)) {
        // 提取具体信息
        final match = pattern.firstMatch(userMessage);
        if (match != null) {
          return '$template: ${userMessage.substring(0, userMessage.length > 100 ? 100 : userMessage.length)}';
        }
      }
    }

    return null;
  }

  /// 检测用户偏好
  String? _detectPreference(String message) {
    final preferencePatterns = [
      RegExp(r'我喜欢(.{1,20})'),
      RegExp(r'我希望(.{1,20})'),
      RegExp(r'我想要(.{1,20})'),
      RegExp(r'我不喜欢(.{1,20})'),
      RegExp(r'我讨厌(.{1,20})'),
    ];

    for (final pattern in preferencePatterns) {
      final match = pattern.firstMatch(message);
      if (match != null) {
        return '用户偏好: ${match.group(0)}';
      }
    }

    return null;
  }
}
