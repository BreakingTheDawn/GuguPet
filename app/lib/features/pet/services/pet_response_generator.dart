import '../../../core/services/llm_service.dart';
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
  final String content;
  final ResponseStrategy strategy;
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
  final LLMService? _llmService;
  final PetGrowthService _growthService;

  /// 本地回复模板库
  static const Map<String, Map<String, List<String>>> _templates = {
    'feed': {
      'happy': [
        '好吃！谢谢投喂~',
        '真香！你对我真好！',
        '吃饱饱了~好满足！',
      ],
      'normal': [
        '谢谢投喂~',
        '好吃！',
      ],
    },
    'play': {
      'happy': [
        '玩得好开心！',
        '再来再来！',
        '太好玩了！',
      ],
      'excited': [
        '太棒了！我最喜欢玩了！',
        '哈哈哈好开心！',
      ],
    },
    'pet': {
      'happy': [
        '舒服~',
        '再摸摸~',
        '好幸福~',
      ],
      'normal': [
        '嗯~',
        '还可以~',
      ],
      'angry': [
        '好吧...原谅你了',
        '哼...算了',
      ],
    },
    'confide_positive': {
      'happy': [
        '太棒了！为你开心！',
        '好消息！继续加油！',
        '你真厉害！',
      ],
      'excited': [
        '哇！太好了！我就知道你可以的！',
        '恭喜恭喜！我们一起庆祝！',
      ],
    },
    'confide_negative': {
      'sad': [
        '没关系，我会一直陪着你的',
        '别难过，一切都会好起来的',
        '我在这里，随时听你说',
      ],
      'normal': [
        '我理解你的感受',
        '有什么我可以帮你的吗？',
      ],
    },
    'greeting': {
      'happy': [
        '你回来啦！好想你~',
        '咕咕！等你很久了！',
      ],
      'normal': [
        '你好呀~',
        '咕咕~',
      ],
      'sad': [
        '你终于来了...我等了好久',
        '咕...我还以为你不来了',
      ],
    },
  };

  /// 触发大模型的场景
  static const Set<String> _llmTriggerScenes = {
    'deep_confide',      // 深度倾诉
    'offer_received',    // 拿到Offer
    'interview_received',// 收到面试
    'job_rejected',      // 被拒绝
    'milestone',         // 里程碑事件
  };

  PetResponseGenerator({
    LLMService? llmService,
    PetGrowthService? growthService,
  })  : _llmService = llmService,
        _growthService = growthService ?? PetGrowthService();

  /// 生成回复
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
  bool _shouldUseLLM(String scene, int bondLevel) {
    // 羁绊等级>=3且是复杂场景
    return bondLevel >= 3 && _llmTriggerScenes.contains(scene);
  }

  /// 本地模板生成
  ResponseResult _generateLocal({
    required String scene,
    required PetEmotionType emotion,
  }) {
    final emotionKey = emotion.name;
    final sceneTemplates = _templates[scene];

    String content;
    if (sceneTemplates != null && sceneTemplates.containsKey(emotionKey)) {
      final options = sceneTemplates[emotionKey]!;
      content = options[DateTime.now().millisecondsSinceEpoch % options.length];
    } else if (sceneTemplates != null && sceneTemplates.containsKey('normal')) {
      final options = sceneTemplates['normal']!;
      content = options[DateTime.now().millisecondsSinceEpoch % options.length];
    } else {
      content = '咕咕~'; // 默认回复
    }

    return ResponseResult(
      content: content,
      strategy: ResponseStrategy.local,
      usedLLM: false,
    );
  }

  /// 大模型生成
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
