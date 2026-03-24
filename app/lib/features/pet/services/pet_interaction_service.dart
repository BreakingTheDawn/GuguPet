import '../data/models/pet_model.dart';
import '../data/models/pet_interaction.dart';
import '../data/datasources/pet_local_datasource.dart';
import 'pet_state_machine.dart';
import 'pet_growth_service.dart';

/// 互动结果
class InteractionResult {
  final PetModel updatedPet;
  final PetInteractionModel interactionRecord;
  final bool levelUp;
  final String? levelUpTitle;
  final String? emotionMessage;

  InteractionResult({
    required this.updatedPet,
    required this.interactionRecord,
    this.levelUp = false,
    this.levelUpTitle,
    this.emotionMessage,
  });
}

/// 互动冷却信息
class InteractionCooldown {
  final String interactionType;
  final DateTime lastUsed;
  final Duration cooldownDuration;
  final bool isReady;

  InteractionCooldown({
    required this.interactionType,
    required this.lastUsed,
    required this.cooldownDuration,
    required this.isReady,
  });

  Duration get remainingTime {
    if (isReady) return Duration.zero;
    final elapsed = DateTime.now().difference(lastUsed);
    final remaining = cooldownDuration - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }
}

/// 宠物互动服务
/// 处理喂食、玩耍、抚摸等互动逻辑
class PetInteractionService {
  final PetLocalDatasource _localDatasource;
  final PetStateMachine _stateMachine;
  final PetGrowthService _growthService;

  /// 互动冷却时间配置（毫秒）
  static const Map<String, int> _cooldownDurations = {
    'feed': 2 * 60 * 60 * 1000,    // 2小时
    'play': 3 * 60 * 60 * 1000,   // 3小时
    'pet': 1 * 60 * 60 * 1000,    // 1小时
  };

  PetInteractionService({
    PetLocalDatasource? localDatasource,
    PetStateMachine? stateMachine,
    PetGrowthService? growthService,
  })  : _localDatasource = localDatasource ?? PetLocalDatasource(),
        _stateMachine = stateMachine ?? PetStateMachine(),
        _growthService = growthService ?? PetGrowthService();

  /// 执行互动
  Future<InteractionResult> performInteraction({
    required PetModel pet,
    required InteractionType interactionType,
  }) async {
    // 检查冷却
    if (!_isInteractionReady(pet, interactionType.name)) {
      throw Exception('互动冷却中');
    }

    // 获取情感触发类型
    final trigger = _getEmotionTrigger(interactionType);

    // 计算情感变化
    final emotionResult = _stateMachine.transition(
      currentEmotion: pet.currentEmotion,
      currentEmotionValue: pet.emotionValue,
      trigger: trigger,
    );

    // 获取羁绊值变化
    final (bondGain, _) = _growthService.getBondGainConfig(interactionType.name);

    // 计算羁绊成长
    final growthResult = _growthService.addBondExp(
      currentExp: pet.bondExp,
      currentLevel: pet.bondLevel,
      gain: bondGain,
      actionType: interactionType.name,
    );

    // 更新统计数据
    final newStats = Map<String, dynamic>.from(pet.stats);
    newStats['${interactionType.name}Count'] = 
        (newStats['${interactionType.name}Count'] as int? ?? 0) + 1;
    newStats['last${interactionType.name[0].toUpperCase()}${interactionType.name.substring(1)}Time'] = 
        DateTime.now().toIso8601String();

    // 创建更新后的宠物数据
    final updatedPet = pet.copyWith(
      currentEmotion: emotionResult.newEmotion,
      emotionValue: emotionResult.newEmotionValue,
      bondLevel: growthResult.newLevel,
      bondExp: growthResult.newExp,
      lastInteractionTime: DateTime.now(),
      stats: newStats,
      updatedAt: DateTime.now(),
    );

    // 创建互动记录
    final interactionRecord = PetInteractionModel(
      id: _generateId(),
      petId: pet.petId,
      interactionType: interactionType,
      emotionBefore: pet.currentEmotion,
      emotionAfter: emotionResult.newEmotion,
      bondChange: bondGain,
      timestamp: DateTime.now(),
    );

    // 保存到数据库
    await _localDatasource.updatePet(updatedPet);
    await _localDatasource.insertInteraction(interactionRecord);

    return InteractionResult(
      updatedPet: updatedPet,
      interactionRecord: interactionRecord,
      levelUp: growthResult.levelUp,
      levelUpTitle: growthResult.newLevelConfig?.title,
      emotionMessage: emotionResult.transitionMessage,
    );
  }

  /// 检查互动是否就绪
  bool _isInteractionReady(PetModel pet, String interactionType) {
    final lastUsedStr = pet.stats['last${interactionType[0].toUpperCase()}${interactionType.substring(1)}Time'] as String?;
    if (lastUsedStr == null) return true;

    final lastUsed = DateTime.parse(lastUsedStr);
    final cooldownMs = _cooldownDurations[interactionType] ?? 0;
    final elapsed = DateTime.now().difference(lastUsed).inMilliseconds;

    return elapsed >= cooldownMs;
  }

  /// 获取互动冷却信息
  InteractionCooldown getCooldownInfo(PetModel pet, String interactionType) {
    final lastUsedStr = pet.stats['last${interactionType[0].toUpperCase()}${interactionType.substring(1)}Time'] as String?;
    final lastUsed = lastUsedStr != null ? DateTime.parse(lastUsedStr) : DateTime.now().subtract(const Duration(days: 1));
    final cooldownMs = _cooldownDurations[interactionType] ?? 0;

    return InteractionCooldown(
      interactionType: interactionType,
      lastUsed: lastUsed,
      cooldownDuration: Duration(milliseconds: cooldownMs),
      isReady: _isInteractionReady(pet, interactionType),
    );
  }

  /// 获取情感触发类型
  EmotionTrigger _getEmotionTrigger(InteractionType type) {
    switch (type) {
      case InteractionType.feed:
        return EmotionTrigger.feedInteraction;
      case InteractionType.play:
        return EmotionTrigger.playInteraction;
      case InteractionType.pet:
        return EmotionTrigger.petInteraction;
      case InteractionType.confide:
        return EmotionTrigger.confideInteraction;
    }
  }

  /// 生成ID
  String _generateId() {
    return 'int_${DateTime.now().millisecondsSinceEpoch}';
  }
}
