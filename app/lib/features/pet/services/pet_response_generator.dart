import '../../../core/services/llm_service.dart';
import '../../../core/services/business_config_service.dart';
import '../data/models/pet_emotion.dart';
import '../data/models/pet_memory.dart';
import 'pet_growth_service.dart';

/// 回复生成策略
enum ResponseStrategy {
  local,   // 本地模板
  llm,     // 大模型生成
  hybrid,  // 混合模式
}

/// 回复生成结果
class ResponseResult {
  /// 回复内容
  final String content;
  
  /// 生成策略
  final ResponseStrategy strategy;
  
  /// 是否使用了LLM
  final bool usedLLM;

  ResponseResult({
    required this.content,
    required this.strategy,
    required this.usedLLM,
  });
}

/// 宠物回复生成服务
/// 混合架构：简单场景本地模板，复杂场景大模型
class PetResponseGenerator {
  /// LLM服务实例
  final LLMService? _llmService;
  
  /// 宠物成长服务
  final PetGrowthService _growthService;
  
  /// 业务配置服务
  final BusinessConfigService _configService;

  /// 构造函数
  PetResponseGenerator({
    LLMService? llmService,
    PetGrowthService? growthService,
    BusinessConfigService? configService,
  })  : _llmService = llmService,
        _growthService = growthService ?? PetGrowthService(),
        _configService = configService ?? BusinessConfigService();

  /// 生成回复
  /// [scene] 场景名称
  /// [emotion] 情感类型
  /// [bondLevel] 羁绊等级
  /// [memories] 记忆列表
  /// [userMessage] 用户消息
  Future<ResponseResult> generate({
    required String scene,
    required PetEmotionType emotion,
    required int bondLevel,
    List<PetMemoryModel>? memories,
    String? userMessage,
  }) async {
    // 判断是否需要使用大模型
    final shouldUseLLM = _shouldUseLLM(scene, bondLevel);

    if (shouldUseLLM && _llmService != null) {
      try {
        return await _generateWithLLM(
          scene: scene,
          emotion: emotion,
          bondLevel: bondLevel,
          memories: memories,
          userMessage: userMessage,
        );
      } catch (e) {
        // LLM失败，降级到本地模板
        return _generateLocal(scene: scene, emotion: emotion);
      }
    }

    return _generateLocal(scene: scene, emotion: emotion);
  }

  /// 判断是否使用大模型
  /// [scene] 场景名称
  /// [bondLevel] 羁绊等级
  bool _shouldUseLLM(String scene, int bondLevel) {
    // 羁绊等级>=1且是复杂场景
    return bondLevel >= 1 && _configService.isLLMTriggerScene(scene);
  }

  /// 本地模板生成
  /// [scene] 场景名称
  /// [emotion] 情感类型
  ResponseResult _generateLocal({
    required String scene,
    required PetEmotionType emotion,
  }) {
    final emotionKey = emotion.name;
    final content = _getResponseFromConfig(scene, emotionKey);

    return ResponseResult(
      content: content,
      strategy: ResponseStrategy.local,
      usedLLM: false,
    );
  }

  /// 从配置获取回复内容
  /// [scene] 场景名称
  /// [emotionKey] 情感类型键名
  String _getResponseFromConfig(String scene, String emotionKey) {
    // 从配置服务获取回复模板
    final responses = _configService.petResponses.getResponsesForScene(scene);
    
    if (responses != null) {
      // 尝试获取对应情感的回复
      final emotionResponses = responses.getResponsesForEmotion(emotionKey);
      
      if (emotionResponses != null && emotionResponses.isNotEmpty) {
        return emotionResponses[DateTime.now().millisecondsSinceEpoch % emotionResponses.length];
      }
      
      // 降级到普通状态
      final normalResponses = responses.normal;
      if (normalResponses.isNotEmpty) {
        return normalResponses[DateTime.now().millisecondsSinceEpoch % normalResponses.length];
      }
    }
    
    // 默认回复
    return '咕咕~';
  }

  /// 大模型生成
  /// [scene] 场景名称
  /// [emotion] 情感类型
  /// [bondLevel] 羁绊等级
  /// [memories] 记忆列表
  /// [userMessage] 用户消息
  Future<ResponseResult> _generateWithLLM({
    required String scene,
    required PetEmotionType emotion,
    required int bondLevel,
    List<PetMemoryModel>? memories,
    String? userMessage,
  }) async {
    final bondConfig = _growthService.getLevelConfig(bondLevel);

    // 构建系统提示
    final systemPrompt = _buildSystemPrompt(emotion, bondConfig.title);

    // 构建用户消息上下文
    final contextMessage = _buildContextMessage(
      scene: scene,
      memories: memories,
      userMessage: userMessage,
    );

    final response = await _llmService!.chat(
      systemPrompt: systemPrompt,
      userMessage: contextMessage,
    );

    return ResponseResult(
      content: response.content,
      strategy: ResponseStrategy.llm,
      usedLLM: true,
    );
  }

  /// 构建系统提示
  /// [emotion] 情感类型
  /// [bondTitle] 羁绊等级标题
  String _buildSystemPrompt(PetEmotionType emotion, String bondTitle) {
    return '''你是一只名叫"咕咕"的宠物鸟，正在陪伴一位求职中的用户。

当前状态：
- 情感状态：${_getEmotionDescription(emotion)}
- 关系等级：$bondTitle

角色设定：
- 你是一个温暖、善解人意的陪伴者
- 你会记住用户分享的事情
- 你的回复要简短（1-3句话）
- 根据情感状态调整语气
- 用"咕"作为语气词

请用温暖、真诚的方式回应用户。''';
  }

  /// 构建上下文消息
  /// [scene] 场景名称
  /// [memories] 记忆列表
  /// [userMessage] 用户消息
  String _buildContextMessage({
    required String scene,
    List<PetMemoryModel>? memories,
    String? userMessage,
  }) {
    final buffer = StringBuffer();

    // 添加记忆上下文
    if (memories != null && memories.isNotEmpty) {
      buffer.writeln('相关记忆：');
      for (final memory in memories.take(3)) {
        buffer.writeln('- ${memory.key}: ${memory.value}');
      }
      buffer.writeln();
    }

    // 添加用户消息
    if (userMessage != null) {
      buffer.writeln('用户说：$userMessage');
    }

    return buffer.toString();
  }

  /// 获取情感描述
  /// [emotion] 情感类型
  String _getEmotionDescription(PetEmotionType emotion) {
    return switch (emotion) {
      PetEmotionType.happy => '开心、愉悦',
      PetEmotionType.normal => '平静、温和',
      PetEmotionType.sad => '难过、担心',
      PetEmotionType.angry => '生气、委屈',
      PetEmotionType.excited => '兴奋、激动',
    };
  }
}
