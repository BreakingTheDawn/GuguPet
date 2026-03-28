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
      case 5:
        return _version5;
      case 6:
        return _version6;
      case 7:
        return _version7;
      case 8:
        return _version8;
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

  // ==================== 版本5迁移脚本 ====================

  /// 版本5的迁移脚本
  /// 为用户表添加账号密码字段，支持用户登录注册功能
  static final List<String> _version5 = [
    // 为用户表添加账号字段（唯一约束）
    '''
    ALTER TABLE users ADD COLUMN account TEXT
    ''',
    
    // 为用户表添加密码字段（存储加密后的密码）
    '''
    ALTER TABLE users ADD COLUMN password TEXT
    ''',
    
    // 为用户表添加登录状态字段
    '''
    ALTER TABLE users ADD COLUMN is_logged_in INTEGER DEFAULT 0
    ''',
    
    // 创建账号索引，用于快速查询
    '''
    CREATE INDEX idx_users_account ON users (account)
    ''',
  ];

  // ==================== 版本6迁移脚本 ====================

  /// 版本6的迁移脚本
  /// 为宠物表添加外观相关字段，支持VIP宠物皮肤和配饰功能
  static final List<String> _version6 = [
    // 为宠物表添加皮肤ID字段
    '''
    ALTER TABLE pets ADD COLUMN skin_id TEXT DEFAULT 'default'
    ''',
    
    // 为宠物表添加配饰ID字段
    '''
    ALTER TABLE pets ADD COLUMN accessory_id TEXT DEFAULT 'none'
    ''',
    
    // 为宠物表添加已解锁皮肤列表字段（JSON格式）
    '''
    ALTER TABLE pets ADD COLUMN unlocked_skins TEXT DEFAULT '["default"]'
    ''',
    
    // 为宠物表添加已解锁配饰列表字段（JSON格式）
    '''
    ALTER TABLE pets ADD COLUMN unlocked_accessories TEXT DEFAULT '["none"]'
    ''',
  ];

  // ==================== 版本7迁移脚本 ====================

  /// 版本7的迁移脚本
  /// 添加AI对话功能相关表：对话会话表、对话消息表
  static final List<String> _version7 = [
    // ==================== 对话会话表 ====================
    // 存储用户的对话会话信息
    '''
    CREATE TABLE chat_sessions (
      session_id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      created_at TEXT NOT NULL,
      last_active_at TEXT NOT NULL,
      is_ended INTEGER DEFAULT 0,
      FOREIGN KEY (user_id) REFERENCES users(user_id)
    )
    ''',

    // 对话会话表索引 - 按用户ID查询
    '''
    CREATE INDEX idx_chat_sessions_user_id ON chat_sessions (user_id)
    ''',

    // 对话会话表索引 - 按最后活跃时间查询
    '''
    CREATE INDEX idx_chat_sessions_last_active_at ON chat_sessions (last_active_at)
    ''',

    // ==================== 对话消息表 ====================
    // 存储对话中的每条消息
    '''
    CREATE TABLE chat_messages (
      message_id TEXT PRIMARY KEY,
      session_id TEXT NOT NULL,
      role TEXT NOT NULL,
      content TEXT NOT NULL,
      timestamp TEXT NOT NULL,
      FOREIGN KEY (session_id) REFERENCES chat_sessions(session_id) ON DELETE CASCADE
    )
    ''',

    // 对话消息表索引 - 按会话ID查询
    '''
    CREATE INDEX idx_chat_messages_session_id ON chat_messages (session_id)
    ''',

    // 对话消息表索引 - 按时间戳查询
    '''
    CREATE INDEX idx_chat_messages_timestamp ON chat_messages (timestamp)
    ''',
  ];

  // ==================== 版本8迁移脚本 ====================

  /// 版本8的迁移脚本
  /// 为用户表添加公园解锁相关字段
  static final List<String> _version8 = [
    // 为用户表添加公园解锁状态字段
    '''
    ALTER TABLE users ADD COLUMN is_park_unlocked INTEGER DEFAULT 0
    ''',
    
    // 为用户表添加公园解锁时间字段
    '''
    ALTER TABLE users ADD COLUMN park_unlocked_at TEXT
    ''',
    
    // 为用户表添加公园解锁来源字段
    '''
    ALTER TABLE users ADD COLUMN park_unlock_source TEXT
    ''',
  ];
}
