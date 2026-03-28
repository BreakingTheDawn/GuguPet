/// 应用常量
class AppConstants {
  /// 应用名称
  static const String appName = '职宠小窝';
  
  /// 应用版本
  static const String appVersion = '1.0.0';
  
  /// 最大记忆数量
  static const int maxMemoryCount = 20;
  
  /// 动画时长（毫秒）
  static const int animationDurationMs = 2000;
  
  /// 气泡最大长度
  static const int bubbleMaxLength = 3;
}

/// API常量
class ApiConstants {
  /// LeanCloud API地址
  static const String leanCloudApiUrl = 'https://api.leancloud.cn';
  
  /// LeanCloud App ID
  static const String leanCloudAppId = '';
  
  /// LeanCloud App Key
  static const String leanCloudAppKey = '';
}

/// 存储键名
class StorageKeys {
  /// 用户Token
  static const String userToken = 'user_token';
  
  /// 用户资料
  static const String userProfile = 'user_profile';
  
  /// 宠物记忆
  static const String petMemory = 'pet_memory';
  
  /// 最后同步时间
  static const String lastSyncTime = 'last_sync_time';
}

/// 动画时长常量
class AnimationDurations {
  AnimationDurations._();

  /// 快速动画 (150ms)
  static const Duration fast = Duration(milliseconds: 150);
  
  /// 普通动画 (300ms)
  static const Duration normal = Duration(milliseconds: 300);
  
  /// 慢速动画 (500ms)
  static const Duration slow = Duration(milliseconds: 500);
  
  /// 很慢动画 (1000ms)
  static const Duration verySlow = Duration(milliseconds: 1000);
  
  /// Banner轮播 (3000ms)
  static const Duration bannerCarousel = Duration(milliseconds: 3000);
  
  /// 星星动画延迟 (500ms)
  static const Duration starDelay = Duration(milliseconds: 500);
  
  /// 响应气泡动画 (500ms)
  static const Duration responseBubble = Duration(milliseconds: 500);
  
  /// 底部CTA动画 (2800ms)
  static const Duration bottomCta = Duration(milliseconds: 2800);
  
  /// 宠物动画 (2000ms)
  static const Duration petAnimation = Duration(milliseconds: 2000);
}

/// 字体大小常量
class FontSizes {
  FontSizes._();

  /// 超小字体 (10.0)
  static const double xs = 10.0;
  
  /// 小字体 (12.0)
  static const double sm = 12.0;
  
  /// 基础字体 (14.0)
  static const double base = 14.0;
  
  /// 大字体 (16.0)
  static const double lg = 16.0;
  
  /// 超大字体 (18.0)
  static const double xl = 18.0;
  
  /// 特大字体 (20.0)
  static const double xxl = 20.0;
  
  /// 标题字体 (24.0)
  static const double heading = 24.0;
  
  /// 大标题字体 (28.0)
  static const double headingLg = 28.0;
}

/// 间距常量
class Spacing {
  Spacing._();

  /// 超小间距 (4.0)
  static const double xs = 4.0;
  
  /// 小间距 (8.0)
  static const double sm = 8.0;
  
  /// 中等间距 (12.0)
  static const double md = 12.0;
  
  /// 基础间距 (16.0)
  static const double base = 16.0;
  
  /// 大间距 (20.0)
  static const double lg = 20.0;
  
  /// 超大间距 (24.0)
  static const double xl = 24.0;
  
  /// 特大间距 (32.0)
  static const double xxl = 32.0;
}

/// 资源路径常量
class AssetPaths {
  AssetPaths._();

  // ═══════════════════════════════════════════════════════════
  // 配置文件
  // ═══════════════════════════════════════════════════════════

  /// AI配置文件
  static const String aiConfig = 'assets/config/ai_config.json';
  
  /// UI文本配置
  static const String uiStrings = 'assets/config/ui_strings.json';
  
  /// 业务配置
  static const String businessConfig = 'assets/config/business_config.json';
  
  /// 主题配置
  static const String themeConfig = 'assets/config/theme_config.json';

  // ═══════════════════════════════════════════════════════════
  // 宠物动画资源
  // ═══════════════════════════════════════════════════════════

  /// 宠物动画配置
  static const String petAnimations = 'assets/animations/pet_animations.json';
  
  /// 宠物待机精灵图
  static const String petIdleSpritesheet = 'assets/images/pet/pet_idle_spritesheet.png';
  
  /// 宠物高兴精灵图
  static const String petHappySpritesheet = 'assets/images/pet/pet_happy_spritesheet.png';
  
  /// 宠物移动精灵图
  static const String petMoveSpritesheet = 'assets/images/pet/pet_move_spritesheet.png';
  
  /// 宠物生气精灵图
  static const String petAngrySpritesheet = 'assets/images/pet/pet_angry_spritesheet.png';
  
  /// 宠物难过精灵图
  static const String petSadSpritesheet = 'assets/images/pet/pet_sad_spritesheet.png';
  
  /// 宠物兴奋精灵图
  static const String petExcitedSpritesheet = 'assets/images/pet/pet_excited_spritesheet.png';
  
  /// 宠物逗趣精灵图
  static const String petTeasingSpritesheet = 'assets/images/pet/pet_teasing_spritesheet.png';

  // ═══════════════════════════════════════════════════════════
  // 宠物响应动画
  // ═══════════════════════════════════════════════════════════

  /// 投递动画
  static const String petSubmitAnimation = 'assets/animations/pet_submit.json';
  
  /// 面试动画
  static const String petInterviewAnimation = 'assets/animations/pet_interview.json';
  
  /// 拒绝动画
  static const String petRejectedAnimation = 'assets/animations/pet_rejected.json';
  
  /// Offer动画
  static const String petOfferAnimation = 'assets/animations/pet_offer.json';
  
  /// 摸鱼动画
  static const String petSlackingAnimation = 'assets/animations/pet_slacking.json';
  
  /// 焦虑动画
  static const String petAnxietyAnimation = 'assets/animations/pet_anxiety.json';
  
  /// 默认动画
  static const String petDefaultAnimation = 'assets/animations/pet_default.json';

  // ═══════════════════════════════════════════════════════════
  // 数据文件
  // ═══════════════════════════════════════════════════════════

  /// 职位数据库
  static const String jobsDatabase = 'assets/data/jobs.db';
}
