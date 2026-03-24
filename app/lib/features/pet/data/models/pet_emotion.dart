/// 宠物情感类型枚举
/// 定义5种基础情感状态
enum PetEmotionType {
  happy,   // 开心 - 情感值 70-100
  normal,  // 普通 - 情感值 40-70
  sad,     // 难过 - 情感值 20-40
  angry,   // 生气 - 情感值 0-20
  excited, // 兴奋 - 情感值 80-100
}

/// 情感类型扩展方法
extension PetEmotionTypeExtension on PetEmotionType {
  /// 获取情感值范围
  (int min, int max) get emotionRange {
    switch (this) {
      case PetEmotionType.happy:
        return (70, 100);
      case PetEmotionType.normal:
        return (40, 70);
      case PetEmotionType.sad:
        return (20, 40);
      case PetEmotionType.angry:
        return (0, 20);
      case PetEmotionType.excited:
        return (80, 100);
    }
  }

  /// 根据情感值获取对应情感类型
  static PetEmotionType fromValue(int value) {
    if (value >= 80) return PetEmotionType.excited;
    if (value >= 70) return PetEmotionType.happy;
    if (value >= 40) return PetEmotionType.normal;
    if (value >= 20) return PetEmotionType.sad;
    return PetEmotionType.angry;
  }

  /// 获取对应的动画类型名称
  String get animationType {
    switch (this) {
      case PetEmotionType.happy:
        return 'happy';
      case PetEmotionType.normal:
        return 'idle';
      case PetEmotionType.sad:
        return 'sad';
      case PetEmotionType.angry:
        return 'angry';
      case PetEmotionType.excited:
        return 'excited';
    }
  }
}
