/// 数据库迁移脚本管理类
/// 定义各版本的数据库迁移SQL语句
/// 支持版本升级时自动执行对应的迁移脚本
class DatabaseMigration {
  /// 获取指定版本的迁移SQL语句列表
  /// [version] 数据库版本号
  /// 返回该版本需要执行的SQL语句列表，如果版本不存在则返回null
  static List<String>? getMigration(int version) {
    switch (version) {
      case 1:
        return _version1;
      case 2:
        return _version2;
      case 3:
        return _version3;
      case 4:
        return _version4;
      default:
        return null;
    }
  }

  /// 版本1的迁移脚本
  /// 创建基础表结构：用户表、交互记录表、求职事件表、收藏职位表
  static final List<String> _version1 = [
    // ==================== 用户表 ====================
    // 存储用户基本信息、VIP状态、入职状态、宠物记忆等
    '''
    CREATE TABLE users (
      user_id TEXT PRIMARY KEY,
      user_name TEXT NOT NULL,
      job_intention TEXT,
      city TEXT,
      salary_expect TEXT,
      pet_memory TEXT,
      vip_status INTEGER DEFAULT 0,
      vip_expire_time TEXT,
      is_onboarded INTEGER DEFAULT 0,
      industry_tag TEXT,
      onboarding_report TEXT,
      created_at TEXT,
      updated_at TEXT
    )
    ''',

    // ==================== 交互记录表 ====================
    // 存储用户与宠物的交互历史记录
    '''
    CREATE TABLE interactions (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      content TEXT NOT NULL,
      action_type TEXT,
      emotion_type TEXT,
      pet_action TEXT,
      pet_bubble TEXT,
      created_at TEXT,
      FOREIGN KEY (user_id) REFERENCES users (user_id)
    )
    ''',

    // 交互记录表索引 - 按用户ID查询
    '''
    CREATE INDEX idx_interactions_user_id ON interactions (user_id)
    ''',

    // 交互记录表索引 - 按创建时间查询
    '''
    CREATE INDEX idx_interactions_created_at ON interactions (created_at)
    ''',

    // ==================== 求职事件表 ====================
    // 存储用户的求职相关事件（面试、投递、offer等）
    '''
    CREATE TABLE job_events (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      event_type TEXT NOT NULL,
      event_content TEXT,
      company_name TEXT,
      position_name TEXT,
      event_time TEXT,
      created_at TEXT,
      FOREIGN KEY (user_id) REFERENCES users (user_id)
    )
    ''',

    // 求职事件表索引 - 按用户ID查询
    '''
    CREATE INDEX idx_job_events_user_id ON job_events (user_id)
    ''',

    // 求职事件表索引 - 按事件时间查询
    '''
    CREATE INDEX idx_job_events_event_time ON job_events (event_time)
    ''',

    // 求职事件表索引 - 按事件类型查询
    '''
    CREATE INDEX idx_job_events_event_type ON job_events (event_type)
    ''',

    // ==================== 收藏职位表 ====================
    // 存储用户收藏的职位信息
    '''
    CREATE TABLE favorite_jobs (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      job_id TEXT NOT NULL,
      job_title TEXT,
      company_name TEXT,
      salary_range TEXT,
      job_location TEXT,
      job_tags TEXT,
      created_at TEXT,
      FOREIGN KEY (user_id) REFERENCES users (user_id),
      UNIQUE(user_id, job_id)
    )
    ''',

    // 收藏职位表索引 - 按用户ID查询
    '''
    CREATE INDEX idx_favorite_jobs_user_id ON favorite_jobs (user_id)
    ''',

    // 收藏职位表索引 - 按创建时间查询
    '''
    CREATE INDEX idx_favorite_jobs_created_at ON favorite_jobs (created_at)
    ''',
  ];

  // ==================== 版本2迁移脚本 ====================
  
  /// 版本2的迁移脚本
  /// 添加专栏购买记录表、专栏收藏记录表、通知消息表、通知设置表
  static final List<String> _version2 = [
    // ==================== 专栏购买记录表 ====================
    // 存储用户购买专栏的记录（VIP订阅或单篇购买）
    '''
    CREATE TABLE purchased_columns (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      column_id TEXT NOT NULL,
      purchase_type TEXT NOT NULL,
      purchase_price REAL,
      purchased_at TEXT NOT NULL,
      created_at TEXT,
      FOREIGN KEY (user_id) REFERENCES users (user_id),
      UNIQUE(user_id, column_id)
    )
    ''',

    // 专栏购买记录表索引 - 按用户ID查询
    '''
    CREATE INDEX idx_purchased_columns_user_id ON purchased_columns (user_id)
    ''',

    // 专栏购买记录表索引 - 按专栏ID查询
    '''
    CREATE INDEX idx_purchased_columns_column_id ON purchased_columns (column_id)
    ''',

    // ==================== 专栏收藏记录表 ====================
    // 存储用户收藏的专栏记录
    '''
    CREATE TABLE favorite_columns (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      column_id TEXT NOT NULL,
      created_at TEXT,
      FOREIGN KEY (user_id) REFERENCES users (user_id),
      UNIQUE(user_id, column_id)
    )
    ''',

    // 专栏收藏记录表索引 - 按用户ID查询
    '''
    CREATE INDEX idx_favorite_columns_user_id ON favorite_columns (user_id)
    ''',

    // 专栏收藏记录表索引 - 按专栏ID查询
    '''
    CREATE INDEX idx_favorite_columns_column_id ON favorite_columns (column_id)
    ''',

    // ==================== 通知消息表 ====================
    // 存储系统通知、面试提醒、求职状态更新、专栏更新、VIP到期提醒等
    '''
    CREATE TABLE notifications (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      type TEXT NOT NULL,
      title TEXT NOT NULL,
      content TEXT NOT NULL,
      extra_data TEXT,
      is_read INTEGER DEFAULT 0,
      is_actioned INTEGER DEFAULT 0,
      scheduled_time TEXT,
      sent_at TEXT,
      created_at TEXT,
      FOREIGN KEY (user_id) REFERENCES users (user_id)
    )
    ''',

    // 通知消息表索引 - 按用户ID查询
    '''
    CREATE INDEX idx_notifications_user_id ON notifications (user_id)
    ''',

    // 通知消息表索引 - 按通知类型查询
    '''
    CREATE INDEX idx_notifications_type ON notifications (type)
    ''',

    // 通知消息表索引 - 按是否已读查询
    '''
    CREATE INDEX idx_notifications_is_read ON notifications (is_read)
    ''',

    // 通知消息表索引 - 按定时时间查询
    '''
    CREATE INDEX idx_notifications_scheduled_time ON notifications (scheduled_time)
    ''',

    // ==================== 通知设置表 ====================
    // 存储用户的通知偏好设置
    '''
    CREATE TABLE notification_settings (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL UNIQUE,
      interview_enabled INTEGER DEFAULT 1,
      job_status_enabled INTEGER DEFAULT 1,
      column_update_enabled INTEGER DEFAULT 1,
      vip_expire_enabled INTEGER DEFAULT 1,
      activity_enabled INTEGER DEFAULT 1,
      system_enabled INTEGER DEFAULT 1,
      push_enabled INTEGER DEFAULT 1,
      quiet_hours_start TEXT,
      quiet_hours_end TEXT,
      created_at TEXT,
      updated_at TEXT,
      FOREIGN KEY (user_id) REFERENCES users (user_id)
    )
    ''',

    // 通知设置表索引 - 按用户ID查询
    '''
    CREATE INDEX idx_notification_settings_user_id ON notification_settings (user_id)
    ''',
  ];

  // ==================== 版本3迁移脚本 ====================

  /// 版本3的迁移脚本
  /// 添加宠物系统相关表：宠物主表、宠物记忆表、互动记录表、成长记录表
  static final List<String> _version3 = [
    // ==================== 宠物主表 ====================
    // 存储宠物核心数据：羁绊等级、情感状态、互动统计
    '''
    CREATE TABLE pets (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL UNIQUE,
      name TEXT DEFAULT '咕咕',
      current_emotion TEXT DEFAULT 'normal',
      emotion_value INTEGER DEFAULT 50,
      bond_level INTEGER DEFAULT 1,
      bond_exp REAL DEFAULT 0,
      last_interaction_time TEXT,
      stats TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
    ''',

    // 宠物主表索引 - 按用户ID查询
    '''
    CREATE INDEX idx_pets_user_id ON pets (user_id)
    ''',

    // ==================== 宠物记忆表 ====================
    // 存储短期记忆、关键事件、用户偏好
    '''
    CREATE TABLE pet_memories (
      id TEXT PRIMARY KEY,
      pet_id TEXT NOT NULL,
      type TEXT NOT NULL,
      category TEXT NOT NULL,
      key TEXT NOT NULL,
      value TEXT NOT NULL,
      importance REAL DEFAULT 0.5,
      emotional_weight REAL DEFAULT 0,
      created_at TEXT NOT NULL,
      expires_at TEXT,
      FOREIGN KEY (pet_id) REFERENCES pets(id) ON DELETE CASCADE
    )
    ''',

    // 宠物记忆表索引 - 按宠物ID查询
    '''
    CREATE INDEX idx_pet_memories_pet_id ON pet_memories (pet_id)
    ''',

    // 宠物记忆表索引 - 按记忆类型查询
    '''
    CREATE INDEX idx_pet_memories_type ON pet_memories (type)
    ''',

    // ==================== 互动记录表 ====================
    // 存储喂食、玩耍、抚摸等互动记录
    '''
    CREATE TABLE pet_interactions (
      id TEXT PRIMARY KEY,
      pet_id TEXT NOT NULL,
      interaction_type TEXT NOT NULL,
      emotion_before TEXT NOT NULL,
      emotion_after TEXT NOT NULL,
      bond_change REAL DEFAULT 0,
      timestamp TEXT NOT NULL,
      FOREIGN KEY (pet_id) REFERENCES pets(id) ON DELETE CASCADE
    )
    ''',

    // 互动记录表索引 - 按宠物ID查询
    '''
    CREATE INDEX idx_pet_interactions_pet_id ON pet_interactions (pet_id)
    ''',

    // ==================== 成长记录表 ====================
    // 存储羁绊等级提升历史
    '''
    CREATE TABLE pet_growth_records (
      id TEXT PRIMARY KEY,
      pet_id TEXT NOT NULL,
      from_level INTEGER NOT NULL,
      to_level INTEGER NOT NULL,
      total_exp REAL NOT NULL,
      achieved_at TEXT NOT NULL,
      FOREIGN KEY (pet_id) REFERENCES pets(id) ON DELETE CASCADE
    )
    ''',

    // 成长记录表索引 - 按宠物ID查询
    '''
    CREATE INDEX idx_pet_growth_records_pet_id ON pet_growth_records (pet_id)
    ''',
  ];

  // ==================== 版本4迁移脚本 ====================

  /// 版本4的迁移脚本
  /// 添加公园社交功能相关表：好友表、用户动态表、评论表、点赞表、公园互动表
  static final List<String> _version4 = [
    // ==================== 好友关系表 ====================
    // 存储用户之间的好友关系
    '''
    CREATE TABLE friends (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      friend_id TEXT NOT NULL,
      friend_name TEXT NOT NULL,
      friend_avatar TEXT,
      friend_title TEXT,
      status TEXT NOT NULL DEFAULT 'pending',
      added_at TEXT,
      last_interact TEXT,
      created_at TEXT NOT NULL,
      UNIQUE(user_id, friend_id)
    )
    ''',

    // 好友关系表索引 - 按用户ID查询
    '''
    CREATE INDEX idx_friends_user_id ON friends (user_id)
    ''',

    // 好友关系表索引 - 按好友状态查询
    '''
    CREATE INDEX idx_friends_status ON friends (status)
    ''',

    // ==================== 用户动态表 ====================
    // 存储用户发布的动态内容
    '''
    CREATE TABLE user_posts (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      user_name TEXT NOT NULL,
      user_avatar TEXT,
      content TEXT NOT NULL,
      images TEXT,
      type TEXT NOT NULL DEFAULT 'daily',
      like_count INTEGER DEFAULT 0,
      comment_count INTEGER DEFAULT 0,
      created_at TEXT NOT NULL
    )
    ''',

    // 用户动态表索引 - 按用户ID查询
    '''
    CREATE INDEX idx_user_posts_user_id ON user_posts (user_id)
    ''',

    // 用户动态表索引 - 按动态类型查询
    '''
    CREATE INDEX idx_user_posts_type ON user_posts (type)
    ''',

    // 用户动态表索引 - 按创建时间查询
    '''
    CREATE INDEX idx_user_posts_created_at ON user_posts (created_at DESC)
    ''',

    // ==================== 动态评论表 ====================
    // 存储用户对动态的评论
    '''
    CREATE TABLE post_comments (
      id TEXT PRIMARY KEY,
      post_id TEXT NOT NULL,
      user_id TEXT NOT NULL,
      user_name TEXT NOT NULL,
      content TEXT NOT NULL,
      created_at TEXT NOT NULL,
      FOREIGN KEY (post_id) REFERENCES user_posts(id) ON DELETE CASCADE
    )
    ''',

    // 评论表索引 - 按动态ID查询
    '''
    CREATE INDEX idx_post_comments_post_id ON post_comments (post_id)
    ''',

    // ==================== 点赞记录表 ====================
    // 存储用户对动态的点赞记录
    '''
    CREATE TABLE post_likes (
      id TEXT PRIMARY KEY,
      post_id TEXT NOT NULL,
      user_id TEXT NOT NULL,
      created_at TEXT NOT NULL,
      UNIQUE(post_id, user_id)
    )
    ''',

    // 点赞记录表索引 - 按动态ID查询
    '''
    CREATE INDEX idx_post_likes_post_id ON post_likes (post_id)
    ''',

    // ==================== 公园互动记录表 ====================
    // 存储用户在公园内的互动行为
    '''
    CREATE TABLE park_interactions (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      target_id TEXT NOT NULL,
      type TEXT NOT NULL,
      created_at TEXT NOT NULL
    )
    ''',

    // 公园互动记录表索引 - 按用户ID查询
    '''
    CREATE INDEX idx_park_interactions_user_id ON park_interactions (user_id)
    ''',

    // 公园互动记录表索引 - 按目标用户ID查询
    '''
    CREATE INDEX idx_park_interactions_target_id ON park_interactions (target_id)
    ''',
  ];
}
