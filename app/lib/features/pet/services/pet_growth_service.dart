/// 羁绊等级配置
class BondLevelConfig {
  final int level;
  final String title;
  final double requiredExp;
  final String description;

  const BondLevelConfig({
    required this.level,
    required this.title,
    required this.requiredExp,
    required this.description,
  });
}

/// 羁绊成长结果
class BondGrowthResult {
  final int newLevel;
  final double newExp;
  final bool levelUp;
  final BondLevelConfig? newLevelConfig;

  BondGrowthResult({
    required this.newLevel,
    required this.newExp,
    required this.levelUp,
    this.newLevelConfig,
  });
}

/// 宠物羁绊成长服务
/// 管理羁绊等级和经验值
class PetGrowthService {
  /// 羁绊等级配置表
  static const List<BondLevelConfig> _levelConfigs = [
    BondLevelConfig(
      level: 1,
      title: '陌生人',
      requiredExp: 0,
      description: '礼貌但疏远，回复简短',
    ),
    BondLevelConfig(
      level: 2,
      title: '熟悉',
      requiredExp: 100,
      description: '开始关心，回复更丰富',
    ),
    BondLevelConfig(
      level: 3,
      title: '朋友',
      requiredExp: 300,
      description: '主动询问，分享心情',
    ),
    BondLevelConfig(
      level: 4,
      title: '好友',
      requiredExp: 600,
      description: '深度共情，记住细节',
    ),
    BondLevelConfig(
      level: 5,
      title: '挚友',
      requiredExp: 1000,
      description: '默契十足，专属称呼',
    ),
  ];

  /// 羁绊值获取配置
  static const Map<String, (double value, double dailyLimit)> _bondGains = {
    'confide': (10.0, 50.0),
    'feed': (5.0, 15.0),
    'play': (8.0, 24.0),
    'pet': (10.0, 20.0),
    'dailyLogin': (10.0, 10.0),
  };

  /// 获取等级配置
  BondLevelConfig getLevelConfig(int level) {
    return _levelConfigs.firstWhere(
      (config) => config.level == level,
      orElse: () => _levelConfigs.last,
    );
  }

  /// 根据经验值计算等级
  int calculateLevel(double exp) {
    for (var i = _levelConfigs.length - 1; i >= 0; i--) {
      if (exp >= _levelConfigs[i].requiredExp) {
        return _levelConfigs[i].level;
      }
    }
    return 1;
  }

  /// 获取下一级所需经验
  double getExpForNextLevel(int currentLevel) {
    final nextLevel = currentLevel + 1;
    if (nextLevel > _levelConfigs.length) return double.infinity;
    return _levelConfigs[nextLevel - 1].requiredExp;
  }

  /// 获取当前等级进度 (0.0 - 1.0)
  double getLevelProgress(double currentExp, int currentLevel) {
    final currentLevelExp = getLevelConfig(currentLevel).requiredExp;
    final nextLevelExp = getExpForNextLevel(currentLevel);
    if (nextLevelExp == double.infinity) return 1.0;
    return (currentExp - currentLevelExp) / (nextLevelExp - currentLevelExp);
  }

  /// 增加羁绊值
  /// [currentExp] 当前经验值
  /// [currentLevel] 当前等级
  /// [gain] 基础经验值增益
  /// [actionType] 行为类型
  /// [isVip] 是否为VIP用户（VIP用户经验值+50%）
  BondGrowthResult addBondExp({
    required double currentExp,
    required int currentLevel,
    required double gain,
    required String actionType,
    bool isVip = false,
  }) {
    // VIP用户羁绊值获取提升50%
    final actualGain = isVip ? gain * 1.5 : gain;
    final newExp = currentExp + actualGain;
    final newLevel = calculateLevel(newExp);
    final levelUp = newLevel > currentLevel;
    
    BondLevelConfig? newConfig;
    if (levelUp) {
      newConfig = getLevelConfig(newLevel);
    }

    return BondGrowthResult(
      newLevel: newLevel,
      newExp: newExp,
      levelUp: levelUp,
      newLevelConfig: newConfig,
    );
  }

  /// 减少羁绊值（长时间未互动）
  BondGrowthResult reduceBondExp({
    required double currentExp,
    required int currentLevel,
    required double loss,
  }) {
    final newExp = (currentExp - loss).clamp(0.0, double.infinity);
    final newLevel = calculateLevel(newExp);
    
    return BondGrowthResult(
      newLevel: newLevel,
      newExp: newExp,
      levelUp: false,
    );
  }

  /// 获取羁绊值获取配置
  (double value, double dailyLimit) getBondGainConfig(String actionType) {
    return _bondGains[actionType] ?? (0.0, 0.0);
  }
}
