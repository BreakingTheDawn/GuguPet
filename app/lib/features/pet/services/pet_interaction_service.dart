import '../data/models/pet_model.dart';
import '../data/models/pet_interaction.dart';
import '../data/datasources/pet_local_datasource.dart';
import 'pet_state_machine.dart';
import 'pet_growth_service.dart';

/// 互动结果
class InteractionResult {
  /// 更新后的宠物数据
  final PetModel updatedPet;

  /// 互动记录
  final PetInteractionModel interactionRecord;

  /// 是否升级
  final bool levelUp;

  /// 升级后的称号
  final String? levelUpTitle;

  /// 情感变化消息
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
  /// 互动类型
  final String interactionType;

  /// 上次使用时间
  final DateTime lastUsed;

  /// 冷却时长
  final Duration cooldownDuration;

  /// 是否就绪
  final bool isReady;

  InteractionCooldown({
    required this.interactionType,
    required this.lastUsed,
    required this.cooldownDuration,
    required this.isReady,
  });

  /// 获取剩余冷却时间
  Duration get remainingTime {
    if (isReady) return Duration.zero;
    final elapsed = DateTime.now().difference(lastUsed);
    final remaining = cooldownDuration - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }
}

/// 宠物互动服务
/// 处理喂食、玩耍、抚摸等互动逻辑
/// 支持VIP用户的羁绊加速和互动冷却缩短
class PetInteractionService {
  /// 宠物本地数据源
  final PetLocalDatasource _localDatasource;

  /// 情感状态机
  final PetStateMachine _stateMachine;

  /// 羁绊成长服务
  final PetGrowthService _growthService;

  /// 互动冷却时间配置（毫秒）
  /// 普通用户的冷却时间，VIP用户冷却时间缩短50%
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
  /// [pet] 当前宠物数据
  /// [interactionType] 互动类型
  /// [isVip] 是否为VIP用户
  /// 返回互动结果
  Future<InteractionResult> performInteraction({
    required PetModel pet,
    required InteractionType interactionType,
    bool isVip = false,
  }) async {
    // 检查冷却（VIP用户冷却时间缩短50%）
    if (!_isInteractionReady(pet, interactionType.name, isVip)) {
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

    // 计算羁绊成长（VIP用户经验值+50%）
    final growthResult = _growthService.addBondExp(
      currentExp: pet.bondExp,
      currentLevel: pet.bondLevel,
      gain: bondGain,
      actionType: interactionType.name,
      isVip: isVip,
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
  /// [pet] 宠物数据
  /// [interactionType] 互动类型
  /// [isVip] 是否为VIP用户
  /// 返回是否可以执行互动
  bool _isInteractionReady(PetModel pet, String interactionType, bool isVip) {
    final lastUsedStr = pet.stats['last${interactionType[0].toUpperCase()}${interactionType.substring(1)}Time'] as String?;
    if (lastUsedStr == null) return true;

    final lastUsed = DateTime.parse(lastUsedStr);
    var cooldownMs = _cooldownDurations[interactionType] ?? 0;
    
    // VIP用户冷却时间缩短50%
    if (isVip) {
      cooldownMs = cooldownMs ~/ 2;
    }
    
    final elapsed = DateTime.now().difference(lastUsed).inMilliseconds;

    return elapsed >= cooldownMs;
  }

  /// 获取互动冷却信息
  /// [pet] 宠物数据
  /// [interactionType] 互动类型
  /// [isVip] 是否为VIP用户
  /// 返回冷却信息
  InteractionCooldown getCooldownInfo(PetModel pet, String interactionType, bool isVip) {
    final lastUsedStr = pet.stats['last${interactionType[0].toUpperCase()}${interactionType.substring(1)}Time'] as String?;
    final lastUsed = lastUsedStr != null ? DateTime.parse(lastUsedStr) : DateTime.now().subtract(const Duration(days: 1));
    var cooldownMs = _cooldownDurations[interactionType] ?? 0;
    
    // VIP用户冷却时间缩短50%
    if (isVip) {
      cooldownMs = cooldownMs ~/ 2;
    }

    return InteractionCooldown(
      interactionType: interactionType,
      lastUsed: lastUsed,
      cooldownDuration: Duration(milliseconds: cooldownMs),
      isReady: _isInteractionReady(pet, interactionType, isVip),
    );
  }

  /// 获取基础冷却时间（毫秒）
  /// [interactionType] 互动类型
  /// 返回基础冷却时间
  int getBaseCooldownMs(String interactionType) {
    return _cooldownDurations[interactionType] ?? 0;
  }

  /// 获取VIP冷却时间（毫秒）
  /// [interactionType] 互动类型
  /// 返回VIP冷却时间（基础冷却的50%）
  int getVipCooldownMs(String interactionType) {
    return (_cooldownDurations[interactionType] ?? 0) ~/ 2;
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
