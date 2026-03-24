import '../data/models/pet_emotion.dart';

/// 情感状态转换结果
class EmotionTransitionResult {
  final PetEmotionType newEmotion;
  final int newEmotionValue;
  final String? transitionMessage;

  EmotionTransitionResult({
    required this.newEmotion,
    required this.newEmotionValue,
    this.transitionMessage,
  });
}

/// 情感状态触发类型
enum EmotionTrigger {
  positiveEvent,    // 正面事件（如拿到面试、Offer）
  negativeEvent,    // 负面事件（如被拒）
  feedInteraction,  // 喂食互动
  playInteraction,  // 玩耍互动
  petInteraction,   // 抚摸互动（点击宠物）
  confideInteraction, // 倾诉互动
  longTimeNoSee,    // 长时间未互动
  userLogin,        // 用户登录
  timeDecay,        // 时间自然衰减
  touchPet,         // 点击宠物（触发搞怪动画）
}

/// 宠物情感状态机
/// 管理5种情感状态之间的转换逻辑
class PetStateMachine {
  /// 情感值变化配置
  static const Map<EmotionTrigger, int> _emotionValueChanges = {
    EmotionTrigger.positiveEvent: 20,
    EmotionTrigger.negativeEvent: -15,
    EmotionTrigger.feedInteraction: 15,
    EmotionTrigger.playInteraction: 25,
    EmotionTrigger.petInteraction: 20,
    EmotionTrigger.confideInteraction: 10,
    EmotionTrigger.longTimeNoSee: -20,
    EmotionTrigger.userLogin: 30,
    EmotionTrigger.timeDecay: -2,
  };

  /// 处理情感状态转换
  EmotionTransitionResult transition({
    required PetEmotionType currentEmotion,
    required int currentEmotionValue,
    required EmotionTrigger trigger,
  }) {
    // 计算新的情感值
    int newValue = currentEmotionValue + (_emotionValueChanges[trigger] ?? 0);
    
    // 限制在 0-100 范围内
    newValue = newValue.clamp(0, 100);
    
    // 根据情感值确定新的情感状态
    final newEmotion = PetEmotionTypeExtension.fromValue(newValue);
    
    // 生成转换消息
    final message = _getTransitionMessage(currentEmotion, newEmotion, trigger);
    
    return EmotionTransitionResult(
      newEmotion: newEmotion,
      newEmotionValue: newValue,
      transitionMessage: message,
    );
  }

  /// 获取状态转换消息
  String? _getTransitionMessage(
    PetEmotionType from,
    PetEmotionType to,
    EmotionTrigger trigger,
  ) {
    if (from == to) return null;
    
    // 特殊转换的消息
    switch (trigger) {
      case EmotionTrigger.positiveEvent:
        return '太棒了！为你开心！';
      case EmotionTrigger.negativeEvent:
        return '没关系，我会一直陪着你的';
      case EmotionTrigger.feedInteraction:
        return '好吃！谢谢投喂~';
      case EmotionTrigger.playInteraction:
        return '玩得好开心！';
      case EmotionTrigger.petInteraction:
        if (from == PetEmotionType.angry) {
          return '好吧...原谅你了';
        }
        return '舒服~';
      case EmotionTrigger.userLogin:
        return '你回来啦！好想你~';
      case EmotionTrigger.longTimeNoSee:
        return '你终于来了...我等了好久';
      default:
        return null;
    }
  }

  /// 检查是否需要处理长时间未互动
  bool shouldProcessLongTimeNoSee(DateTime lastInteraction) {
    final hoursSinceLastInteraction = DateTime.now()
        .difference(lastInteraction)
        .inHours;
    return hoursSinceLastInteraction >= 24;
  }

  /// 获取长时间未互动的触发类型
  EmotionTrigger getLongTimeTrigger(DateTime lastInteraction) {
    final hoursSinceLastInteraction = DateTime.now()
        .difference(lastInteraction)
        .inHours;
    if (hoursSinceLastInteraction >= 72) {
      return EmotionTrigger.longTimeNoSee;
    }
    return EmotionTrigger.timeDecay;
  }
}
