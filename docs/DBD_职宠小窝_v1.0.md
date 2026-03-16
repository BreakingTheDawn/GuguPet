# 《职宠小窝》APP 数据库设计文档

**文档编号：** DBD-JOBPET-001  
**版本号：** v1.0  
**编写日期：** 2026-03-16  
**文档状态：** 正式发布  

---

## 修订历史

| 版本 | 日期 | 修订人 | 修订内容 |
|------|------|--------|----------|
| v1.0 | 2026-03-16 | 架构师 | 初始版本，基于V3.1产品全案 |

---

## 目录

1. [概述](#1-概述)
2. [数据库架构](#2-数据库架构)
3. [云端数据表设计](#3-云端数据表设计)
4. [本地数据表设计](#4-本地数据表设计)
5. [索引设计](#5-索引设计)
6. [数据字典](#6-数据字典)
7. [数据同步策略](#7-数据同步策略)
8. [附录](#8-附录)

---

## 1. 概述

### 1.1 文档目的

本文档定义《职宠小窝》APP的数据库结构设计，包括云端数据库和本地数据库两部分，为开发团队提供数据存储和访问的技术规范。

### 1.2 数据库选型

| 存储类型 | 数据库 | 用途 |
|----------|--------|------|
| 云端数据库 | LeanCloud LeanDB | 用户数据、求职事件、公园数据 |
| 本地数据库 | SQLite 3.x | 对话记录、本地缓存、宠物记忆 |

### 1.3 设计原则

| 原则 | 说明 |
|------|------|
| 本地优先 | 对话记录优先存储本地，保证零延迟交互 |
| 差异同步 | 仅同步核心事件，减少网络开销 |
| 隐私保护 | 敏感数据加密存储 |
| 可扩展性 | 预留扩展字段，支持后续迭代 |

---

## 2. 数据库架构

### 2.1 整体架构图

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              数据存储架构                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐  │
│  │                        客户端 (Flutter APP)                          │  │
│  │  ┌───────────────────────────────────────────────────────────────┐  │  │
│  │  │                     SQLite 本地数据库                          │  │  │
│  │  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐             │  │  │
│  │  │  │interactions │ │ job_events  │ │ pet_memory  │             │  │  │
│  │  │  │ 对话记录    │ │ 求职事件    │ │ 宠物记忆    │             │  │  │
│  │  │  └─────────────┘ └─────────────┘ └─────────────┘             │  │  │
│  │  │  ┌─────────────┐ ┌─────────────┐                              │  │  │
│  │  │  │ user_cache  │ │ skin_cache  │                              │  │  │
│  │  │  │ 用户缓存    │ │ 皮肤缓存    │                              │  │  │
│  │  │  └─────────────┘ └─────────────┘                              │  │  │
│  │  └───────────────────────────────────────────────────────────────┘  │  │
│  └─────────────────────────────────────────────────────────────────────┘  │
│                                      │                                     │
│                                      │ 同步策略                             │
│                                      ▼                                     │
│  ┌─────────────────────────────────────────────────────────────────────┐  │
│  │                    LeanCloud 云端数据库                              │  │
│  │  ┌───────────────────────────────────────────────────────────────┐  │  │
│  │  │                        核心数据表                               │  │  │
│  │  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐             │  │  │
│  │  │  │user_profile │ │interactions │ │job_applications│           │  │  │
│  │  │  │ 用户画像    │ │ 对话记录    │ │ 求职事件    │             │  │  │
│  │  │  └─────────────┘ └─────────────┘ └─────────────┘             │  │  │
│  │  └───────────────────────────────────────────────────────────────┘  │  │
│  │  ┌───────────────────────────────────────────────────────────────┐  │  │
│  │  │                        公园数据表                               │  │  │
│  │  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐             │  │  │
│  │  │  │victory_park │ │park_interact│ │ wish_letters│             │  │  │
│  │  │  │ 公园档案    │ │ 公园交互    │ │ 许愿信封    │             │  │  │
│  │  │  └─────────────┘ └─────────────┘ └─────────────┘             │  │  │
│  │  └───────────────────────────────────────────────────────────────┘  │  │
│  │  ┌───────────────────────────────────────────────────────────────┐  │  │
│  │  │                        系统数据表                               │  │  │
│  │  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐             │  │  │
│  │  │  │  pet_skins  │ │ user_skins  │ │    jobs     │             │  │  │
│  │  │  │ 宠物皮肤    │ │ 用户皮肤    │ │ 岗位数据    │             │  │  │
│  │  │  └─────────────┘ └─────────────┘ └─────────────┘             │  │  │
│  │  └───────────────────────────────────────────────────────────────┘  │  │
│  └─────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2.2 ER图

```
┌──────────────────┐       ┌──────────────────┐       ┌──────────────────┐
│   user_profile   │       │   interactions   │       │  job_applications│
│    (用户画像)     │       │    (对话记录)     │       │    (求职事件)     │
├──────────────────┤       ├──────────────────┤       ├──────────────────┤
│ user_id (PK)     │◄──────│ user_id (FK)     │       │ user_id (FK)     │──────►│
│ user_name        │       │ id (PK)          │       │ id (PK)          │
│ job_intention    │       │ user_content     │       │ event_type       │
│ city             │       │ action_type      │       │ event_content    │
│ salary_expect    │       │ emotion_type     │       │ event_time       │
│ pet_memory       │       │ pet_action       │       │ source_type      │
│ vip_status       │       │ pet_bubble       │       └──────────────────┘
│ vip_expire_time  │       │ create_time      │
│ is_onboarded     │       │ is_synced        │
│ industry_tag     │       └──────────────────┘
│ onboarding_report│
│ pet_evolution    │       ┌──────────────────┐       ┌──────────────────┐
│ park_visitor     │       │ victory_park_    │       │ park_interactions│
│ created_at       │       │    profiles      │       │   (公园交互)      │
│ updated_at       │       │   (公园档案)      │       ├──────────────────┤
└────────┬─────────┘       ├──────────────────┤       │ id (PK)          │
         │                 │ id (PK)          │       │ from_user_id(FK) │──────►│
         │                 │ user_id (FK)     │──────►│ to_user_id (FK)  │──────►│
         │                 │ pet_avatar_url   │       │ interaction_type │
         │                 │ pet_stage        │       │ interaction_data │
         │                 │ industry_zone    │       │ create_time      │
         │                 │ onboarding_date  │       └──────────────────┘
         │                 │ job_company      │
         │                 │ job_position     │       ┌──────────────────┐
         │                 │ battle_report    │       │  wish_letters    │
         │                 │ is_visible       │       │   (许愿信封)      │
         │                 │ last_visit_time  │       ├──────────────────┤
         │                 └──────────────────┘       │ id (PK)          │
         │                                            │ from_user_id(FK) │──────►│
         │                                            │ to_user_id (FK)  │──────►│
         │                                            │ letter_content   │
         │                                            │ industry_tag     │
         │                                            │ is_sent          │
         │                                            │ sent_time        │
         │                                            │ create_time      │
         │                                            └──────────────────┘
         │
         │                 ┌──────────────────┐       ┌──────────────────┐
         │                 │    pet_skins     │       │    user_skins    │
         │                 │    (宠物皮肤)     │       │   (用户皮肤)      │
         │                 ├──────────────────┤       ├──────────────────┤
         │                 │ id (PK)          │       │ id (PK)          │
         │                 │ skin_name        │       │ user_id (FK)     │──────►│
         │                 │ skin_type        │       │ skin_id (FK)     │◄─────┐
         │                 │ skin_assets_url  │       │ is_equipped      │      │
         │                 │ unlock_condition │       │ unlock_time      │      │
         │                 │ is_pro_only      │       └──────────────────┘      │
         │                 │ price            │                                 │
         │                 │ is_active        │◄────────────────────────────────┘
         │                 └──────────────────┘
         │
         │                 ┌──────────────────┐
         │                 │      jobs        │
         │                 │    (岗位数据)     │
         │                 ├──────────────────┤
         │                 │ id (PK)          │
         │                 │ job_title        │
         │                 │ company_name     │
         │                 │ salary_range     │
         │                 │ requirements     │
         │                 │ source_url       │
         │                 │ source_platform  │
         │                 │ industry_tag     │
         │                 │ city             │
         │                 │ publish_time     │
         │                 │ expire_time      │
         │                 │ is_active        │
         │                 └──────────────────┘
```

---

## 3. 云端数据表设计

### 3.1 user_profile（用户画像表）

**表名：** user_profile  
**说明：** 存储用户基本信息、求职画像、会员状态及宠物相关数据  
**存储位置：** LeanCloud 云端数据库

| 字段名称 | 字段类型 | 长度 | 必填 | 默认值 | 说明 |
|----------|----------|------|------|--------|------|
| objectId | String | 32 | 是 | - | LeanCloud自动生成，主键 |
| user_id | String | 64 | 是 | - | 用户唯一标识（自定义生成） |
| user_name | String | 50 | 否 | "咕咕用户" | 用户昵称 |
| avatar_url | String | 512 | 否 | null | 用户头像URL |
| phone | String | 20 | 否 | null | 手机号（加密存储） |
| job_intention | String | 100 | 否 | null | 求职意向（如"前端开发"） |
| city | String | 50 | 否 | null | 求职城市 |
| salary_expect | String | 50 | 否 | null | 薪资期望（如"8k-12k"） |
| pet_memory | Text | - | 否 | null | 宠物记忆内容（JSON格式） |
| vip_status | Boolean | - | 是 | false | 是否为Pro版用户 |
| vip_expire_time | Date | - | 否 | null | Pro版过期时间 |
| is_onboarded | Boolean | - | 是 | false | 是否已上岸 |
| industry_tag | String | 50 | 否 | null | 行业标签（公园分区用） |
| onboarding_report | Text | - | 否 | null | 求职阶段纪念总结（JSON） |
| pet_evolution_stage | Number | - | 是 | 1 | 宠物进化阶段（1=求职期, 2=职场期） |
| park_visitor_mode | Boolean | - | 是 | false | 是否开启公园访客模式 |
| created_at | Date | - | 是 | now() | 创建时间 |
| updated_at | Date | - | 是 | now() | 更新时间 |

**ACL权限：** 用户仅可读写自己的记录

---

### 3.2 interactions（对话交互记录表）

**表名：** interactions  
**说明：** 存储用户与宠物的对话记录  
**存储位置：** LeanCloud 云端数据库（核心事件同步）

| 字段名称 | 字段类型 | 长度 | 必填 | 默认值 | 说明 |
|----------|----------|------|------|--------|------|
| objectId | String | 32 | 是 | - | LeanCloud自动生成，主键 |
| user_id | String | 64 | 是 | - | 用户唯一标识 |
| user_content | Text | - | 是 | - | 用户倾诉的原话 |
| action_type | String | 20 | 是 | - | 识别出的求职行为 |
| emotion_type | String | 20 | 是 | - | 识别出的情绪类型 |
| pet_action | String | 50 | 是 | - | 宠物触发的动作ID |
| pet_bubble | String | 20 | 是 | - | 宠物气泡内容 |
| keywords_matched | String | 200 | 否 | null | 匹配到的关键词（逗号分隔） |
| confidence_score | Number | - | 否 | null | 识别置信度（0-1） |
| is_synced | Boolean | - | 是 | true | 是否已从本地同步 |
| local_id | String | 64 | 否 | null | 本地数据库记录ID |
| create_time | Date | - | 是 | now() | 对话发生时间 |

**枚举值定义：**

**action_type（求职行为类型）：**
| 值 | 说明 |
|----|------|
| resume_submit | 简历投递 |
| interview_received | 收到面试 |
| job_rejected | 求职被拒 |
| offer_received | 拿到Offer |
| slacking | 摆烂/休息 |
| anxiety | 焦虑/低落 |
| unknown | 未识别 |

**emotion_type（情绪类型）：**
| 值 | 说明 |
|----|------|
| positive | 正向 |
| negative | 负向 |
| neutral | 中性 |

---

### 3.3 job_applications（求职事件记录表）

**表名：** job_applications  
**说明：** 存储用户的求职事件（投递、面试、Offer等）  
**存储位置：** LeanCloud 云端数据库

| 字段名称 | 字段类型 | 长度 | 必填 | 默认值 | 说明 |
|----------|----------|------|------|--------|------|
| objectId | String | 32 | 是 | - | LeanCloud自动生成，主键 |
| user_id | String | 64 | 是 | - | 用户唯一标识 |
| event_type | String | 20 | 是 | - | 事件类型 |
| event_content | Text | - | 否 | null | 事件核心信息 |
| company_name | String | 100 | 否 | null | 公司名称 |
| position_name | String | 100 | 否 | null | 职位名称 |
| event_time | Date | - | 是 | now() | 事件发生时间 |
| source_type | String | 20 | 是 | "voice" | 来源类型（voice/manual） |
| interaction_id | String | 32 | 否 | null | 关联的对话记录ID |
| extra_data | Text | - | 否 | null | 扩展数据（JSON格式） |

**枚举值定义：**

**event_type（事件类型）：**
| 值 | 说明 |
|----|------|
| submit | 投递 |
| interview | 面试 |
| reject | 拒信 |
| offer | Offer |
| slack | 摆烂 |

---

### 3.4 victory_park_profiles（彼岸公园档案表）

**表名：** victory_park_profiles  
**说明：** 存储已上岸用户在彼岸公园的展示档案  
**存储位置：** LeanCloud 云端数据库

| 字段名称 | 字段类型 | 长度 | 必填 | 默认值 | 说明 |
|----------|----------|------|------|--------|------|
| objectId | String | 32 | 是 | - | LeanCloud自动生成，主键 |
| user_id | String | 64 | 是 | - | 用户唯一标识 |
| pet_avatar_url | String | 512 | 是 | - | 宠物头像URL |
| pet_stage | Number | - | 是 | 2 | 宠物进化阶段 |
| industry_zone | String | 50 | 是 | - | 所属行业分区 |
| onboarding_date | Date | - | 是 | now() | 上岸日期 |
| job_company | String | 100 | 否 | null | 入职公司（脱敏展示） |
| job_position | String | 100 | 否 | null | 职位名称 |
| battle_report | Text | - | 否 | null | 求职战报摘要 |
| is_visible | Boolean | - | 是 | true | 是否在公园展示 |
| last_visit_time | Date | - | 否 | null | 最近访问时间 |
| visit_count | Number | - | 是 | 0 | 访问次数 |
| created_at | Date | - | 是 | now() | 创建时间 |

**行业分区映射：**
| industry_zone | 分区名称 |
|---------------|----------|
| internet | 码农森林 |
| finance | 金币湖畔 |
| education | 书香花园 |
| other | 综合广场 |

---

### 3.5 park_interactions（公园交互记录表）

**表名：** park_interactions  
**说明：** 存储彼岸公园内的用户交互记录  
**存储位置：** LeanCloud 云端数据库

| 字段名称 | 字段类型 | 长度 | 必填 | 默认值 | 说明 |
|----------|----------|------|------|--------|------|
| objectId | String | 32 | 是 | - | LeanCloud自动生成，主键 |
| from_user_id | String | 64 | 是 | - | 发起者用户ID |
| to_user_id | String | 64 | 是 | - | 接收者用户ID |
| interaction_type | String | 20 | 是 | - | 交互类型 |
| interaction_data | Text | - | 否 | null | 交互附加数据（JSON） |
| is_read | Boolean | - | 是 | false | 是否已读 |
| create_time | Date | - | 是 | now() | 交互时间 |

**枚举值定义：**

**interaction_type（交互类型）：**
| 值 | 说明 |
|----|------|
| touch | 贴一贴 |
| flower | 送花 |
| report | 交换战报 |

---

### 3.6 wish_letters（许愿信封表）

**表名：** wish_letters  
**说明：** 存储上岸用户发送的鼓励信封  
**存储位置：** LeanCloud 云端数据库

| 字段名称 | 字段类型 | 长度 | 必填 | 默认值 | 说明 |
|----------|----------|------|------|--------|------|
| objectId | String | 32 | 是 | - | LeanCloud自动生成，主键 |
| from_user_id | String | 64 | 是 | - | 发送者用户ID（上岸者） |
| letter_content | Text | - | 是 | - | 鼓励内容 |
| industry_tag | String | 50 | 否 | null | 目标行业标签 |
| is_approved | Boolean | - | 是 | false | 是否通过审核 |
| is_sent | Boolean | - | 是 | false | 是否已送出 |
| to_user_id | String | 64 | 否 | null | 接收者用户ID |
| sent_time | Date | - | 否 | null | 送出时间 |
| create_time | Date | - | 是 | now() | 创建时间 |

---

### 3.7 pet_skins（宠物皮肤表）

**表名：** pet_skins  
**说明：** 存储宠物皮肤资源信息  
**存储位置：** LeanCloud 云端数据库

| 字段名称 | 字段类型 | 长度 | 必填 | 默认值 | 说明 |
|----------|----------|------|------|--------|------|
| objectId | String | 32 | 是 | - | LeanCloud自动生成，主键 |
| skin_id | String | 32 | 是 | - | 皮肤唯一标识 |
| skin_name | String | 50 | 是 | - | 皮肤名称 |
| skin_type | String | 20 | 是 | - | 皮肤类型 |
| skin_assets_url | String | 512 | 是 | - | 皮肤资源URL |
| skin_preview_url | String | 512 | 否 | null | 皮肤预览图URL |
| unlock_condition | String | 100 | 否 | null | 解锁条件描述 |
| is_pro_only | Boolean | - | 是 | false | 是否Pro专属 |
| price | Number | - | 否 | null | 单独购买价格（分） |
| is_active | Boolean | - | 是 | true | 是否上架 |
| sort_order | Number | - | 是 | 0 | 排序权重 |
| created_at | Date | - | 是 | now() | 创建时间 |

**枚举值定义：**

**skin_type（皮肤类型）：**
| 值 | 说明 |
|----|------|
| basic | 基础皮肤 |
| workplace | 职场皮肤 |
| seasonal | 季节限定 |
| premium | 付费皮肤 |

---

### 3.8 user_skins（用户皮肤拥有表）

**表名：** user_skins  
**说明：** 存储用户拥有的皮肤记录  
**存储位置：** LeanCloud 云端数据库

| 字段名称 | 字段类型 | 长度 | 必填 | 默认值 | 说明 |
|----------|----------|------|------|--------|------|
| objectId | String | 32 | 是 | - | LeanCloud自动生成，主键 |
| user_id | String | 64 | 是 | - | 用户ID |
| skin_id | String | 32 | 是 | - | 皮肤ID |
| is_equipped | Boolean | - | 是 | false | 是否当前装备 |
| unlock_time | Date | - | 是 | now() | 解锁时间 |
| unlock_source | String | 20 | 是 | - | 解锁来源 |

**枚举值定义：**

**unlock_source（解锁来源）：**
| 值 | 说明 |
|----|------|
| default | 默认拥有 |
| vip | 会员解锁 |
| purchase | 购买解锁 |
| event | 活动解锁 |

---

### 3.9 jobs（岗位数据表）

**表名：** jobs  
**说明：** 存储从第三方招聘平台抓取的岗位信息  
**存储位置：** LeanCloud 云端数据库

| 字段名称 | 字段类型 | 长度 | 必填 | 默认值 | 说明 |
|----------|----------|------|------|--------|------|
| objectId | String | 32 | 是 | - | LeanCloud自动生成，主键 |
| job_id | String | 64 | 是 | - | 岗位唯一标识（来源平台+ID） |
| job_title | String | 200 | 是 | - | 岗位名称 |
| company_name | String | 200 | 是 | - | 公司名称 |
| salary_range | String | 50 | 否 | null | 薪资范围 |
| salary_min | Number | - | 否 | null | 最低薪资（元/月） |
| salary_max | Number | - | 否 | null | 最高薪资（元/月） |
| requirements | Text | - | 否 | null | 核心要求 |
| source_url | String | 512 | 是 | - | 原平台链接 |
| source_platform | String | 50 | 是 | - | 来源平台 |
| industry_tag | String | 50 | 否 | null | 行业标签 |
| city | String | 50 | 否 | null | 工作城市 |
| experience_require | String | 50 | 否 | null | 经验要求 |
| education_require | String | 50 | 否 | null | 学历要求 |
| publish_time | Date | - | 否 | null | 发布时间 |
| expire_time | Date | - | 否 | null | 过期时间 |
| is_active | Boolean | - | 是 | true | 是否有效 |
| created_at | Date | - | 是 | now() | 抓取时间 |

---

## 4. 本地数据表设计

### 4.1 本地数据库概述

**数据库名称：** jobpet_local.db  
**数据库版本：** 1  
**存储位置：** APP沙盒目录

### 4.2 local_interactions（本地对话记录表）

**表名：** local_interactions  
**说明：** 本地存储的对话记录，优先于云端存储

| 字段名称 | 字段类型 | 约束 | 说明 |
|----------|----------|------|------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT | 本地主键 |
| cloud_id | TEXT | UNIQUE | 云端记录ID（同步后写入） |
| user_id | TEXT | NOT NULL | 用户ID |
| user_content | TEXT | NOT NULL | 用户倾诉内容 |
| action_type | TEXT | NOT NULL | 求职行为类型 |
| emotion_type | TEXT | NOT NULL | 情绪类型 |
| pet_action | TEXT | NOT NULL | 宠物动作ID |
| pet_bubble | TEXT | NOT NULL | 气泡内容 |
| keywords_matched | TEXT | 匹配到的关键词 |
| confidence_score | REAL | 识别置信度 |
| is_synced | INTEGER | DEFAULT 0 | 是否已同步（0=否, 1=是） |
| create_time | INTEGER | NOT NULL | 创建时间戳（毫秒） |

**建表语句：**
```sql
CREATE TABLE local_interactions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    cloud_id TEXT UNIQUE,
    user_id TEXT NOT NULL,
    user_content TEXT NOT NULL,
    action_type TEXT NOT NULL,
    emotion_type TEXT NOT NULL,
    pet_action TEXT NOT NULL,
    pet_bubble TEXT NOT NULL,
    keywords_matched TEXT,
    confidence_score REAL,
    is_synced INTEGER DEFAULT 0,
    create_time INTEGER NOT NULL
);

CREATE INDEX idx_local_interactions_user ON local_interactions(user_id);
CREATE INDEX idx_local_interactions_sync ON local_interactions(is_synced);
CREATE INDEX idx_local_interactions_time ON local_interactions(create_time);
```

---

### 4.3 local_job_events（本地求职事件表）

**表名：** local_job_events  
**说明：** 本地存储的求职事件

| 字段名称 | 字段类型 | 约束 | 说明 |
|----------|----------|------|------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT | 本地主键 |
| cloud_id | TEXT | UNIQUE | 云端记录ID |
| user_id | TEXT | NOT NULL | 用户ID |
| event_type | TEXT | NOT NULL | 事件类型 |
| event_content | TEXT | 事件内容 |
| company_name | TEXT | 公司名称 |
| position_name | TEXT | 职位名称 |
| event_time | INTEGER | NOT NULL | 事件时间戳 |
| interaction_id | INTEGER | 关联的本地对话ID |
| is_synced | INTEGER | DEFAULT 0 | 是否已同步 |
| create_time | INTEGER | NOT NULL | 创建时间戳 |

**建表语句：**
```sql
CREATE TABLE local_job_events (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    cloud_id TEXT UNIQUE,
    user_id TEXT NOT NULL,
    event_type TEXT NOT NULL,
    event_content TEXT,
    company_name TEXT,
    position_name TEXT,
    event_time INTEGER NOT NULL,
    interaction_id INTEGER,
    is_synced INTEGER DEFAULT 0,
    create_time INTEGER NOT NULL,
    FOREIGN KEY (interaction_id) REFERENCES local_interactions(id)
);

CREATE INDEX idx_local_job_events_user ON local_job_events(user_id);
CREATE INDEX idx_local_job_events_type ON local_job_events(event_type);
CREATE INDEX idx_local_job_events_time ON local_job_events(event_time);
```

---

### 4.4 local_pet_memory（本地宠物记忆表）

**表名：** local_pet_memory  
**说明：** 本地存储的宠物记忆（Pro版功能）

| 字段名称 | 字段类型 | 约束 | 说明 |
|----------|----------|------|------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT | 本地主键 |
| user_id | TEXT | NOT NULL | 用户ID |
| memory_type | TEXT | NOT NULL | 记忆类型 |
| memory_key | TEXT | NOT NULL | 记忆键（如"面试时间"） |
| memory_value | TEXT | NOT NULL | 记忆值 |
| interaction_id | INTEGER | 关联的对话ID |
| is_valid | INTEGER | DEFAULT 1 | 是否有效 |
| create_time | INTEGER | NOT NULL | 创建时间戳 |
| update_time | INTEGER | 更新时间戳 |

**建表语句：**
```sql
CREATE TABLE local_pet_memory (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id TEXT NOT NULL,
    memory_type TEXT NOT NULL,
    memory_key TEXT NOT NULL,
    memory_value TEXT NOT NULL,
    interaction_id INTEGER,
    is_valid INTEGER DEFAULT 1,
    create_time INTEGER NOT NULL,
    update_time INTEGER,
    FOREIGN KEY (interaction_id) REFERENCES local_interactions(id)
);

CREATE INDEX idx_local_pet_memory_user ON local_pet_memory(user_id);
CREATE INDEX idx_local_pet_memory_type ON local_pet_memory(memory_type);
```

---

### 4.5 local_user_cache（本地用户缓存表）

**表名：** local_user_cache  
**说明：** 缓存用户画像数据

| 字段名称 | 字段类型 | 约束 | 说明 |
|----------|----------|------|------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT | 本地主键 |
| user_id | TEXT | UNIQUE NOT NULL | 用户ID |
| user_name | TEXT | 用户昵称 |
| job_intention | TEXT | 求职意向 |
| city | TEXT | 城市 |
| salary_expect | TEXT | 薪资期望 |
| vip_status | INTEGER | DEFAULT 0 | 会员状态 |
| vip_expire_time | INTEGER | 会员过期时间戳 |
| is_onboarded | INTEGER | DEFAULT 0 | 是否上岸 |
| industry_tag | TEXT | 行业标签 |
| pet_evolution_stage | INTEGER | DEFAULT 1 | 宠物进化阶段 |
| current_skin_id | TEXT | 当前装备皮肤ID |
| last_sync_time | INTEGER | 最后同步时间戳 |

**建表语句：**
```sql
CREATE TABLE local_user_cache (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id TEXT UNIQUE NOT NULL,
    user_name TEXT,
    job_intention TEXT,
    city TEXT,
    salary_expect TEXT,
    vip_status INTEGER DEFAULT 0,
    vip_expire_time INTEGER,
    is_onboarded INTEGER DEFAULT 0,
    industry_tag TEXT,
    pet_evolution_stage INTEGER DEFAULT 1,
    current_skin_id TEXT,
    last_sync_time INTEGER
);
```

---

### 4.6 local_skin_cache（本地皮肤缓存表）

**表名：** local_skin_cache  
**说明：** 缓存皮肤资源信息

| 字段名称 | 字段类型 | 约束 | 说明 |
|----------|----------|------|------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT | 本地主键 |
| skin_id | TEXT | UNIQUE NOT NULL | 皮肤ID |
| skin_name | TEXT | NOT NULL | 皮肤名称 |
| skin_type | TEXT | NOT NULL | 皮肤类型 |
| skin_assets_url | TEXT | NOT NULL | 资源URL |
| local_assets_path | TEXT | 本地存储路径 |
| is_owned | INTEGER | DEFAULT 0 | 是否拥有 |
| is_equipped | INTEGER | DEFAULT 0 | 是否装备 |
| is_downloaded | INTEGER | DEFAULT 0 | 是否已下载 |

**建表语句：**
```sql
CREATE TABLE local_skin_cache (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    skin_id TEXT UNIQUE NOT NULL,
    skin_name TEXT NOT NULL,
    skin_type TEXT NOT NULL,
    skin_assets_url TEXT NOT NULL,
    local_assets_path TEXT,
    is_owned INTEGER DEFAULT 0,
    is_equipped INTEGER DEFAULT 0,
    is_downloaded INTEGER DEFAULT 0
);
```

---

### 4.7 sync_queue（同步队列表）

**表名：** sync_queue  
**说明：** 管理待同步的数据队列

| 字段名称 | 字段类型 | 约束 | 说明 |
|----------|----------|------|------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT | 本地主键 |
| table_name | TEXT | NOT NULL | 来源表名 |
| record_id | INTEGER | NOT NULL | 来源记录ID |
| operation | TEXT | NOT NULL | 操作类型（INSERT/UPDATE/DELETE） |
| priority | INTEGER | DEFAULT 0 | 优先级（越大越优先） |
| retry_count | INTEGER | DEFAULT 0 | 重试次数 |
| last_error | TEXT | 最后错误信息 |
| create_time | INTEGER | NOT NULL | 创建时间戳 |
| update_time | INTEGER | 更新时间戳 |

**建表语句：**
```sql
CREATE TABLE sync_queue (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    table_name TEXT NOT NULL,
    record_id INTEGER NOT NULL,
    operation TEXT NOT NULL,
    priority INTEGER DEFAULT 0,
    retry_count INTEGER DEFAULT 0,
    last_error TEXT,
    create_time INTEGER NOT NULL,
    update_time INTEGER
);

CREATE INDEX idx_sync_queue_priority ON sync_queue(priority DESC);
CREATE INDEX idx_sync_queue_table ON sync_queue(table_name, record_id);
```

---

## 5. 索引设计

### 5.1 云端数据库索引

| 表名 | 索引名 | 索引字段 | 索引类型 | 说明 |
|------|--------|----------|----------|------|
| user_profile | idx_user_id | user_id | UNIQUE | 用户ID唯一索引 |
| user_profile | idx_industry_tag | industry_tag | NORMAL | 行业标签索引（公园分区查询） |
| interactions | idx_user_time | user_id, create_time | COMPOUND | 用户对话时间线查询 |
| interactions | idx_action_type | action_type | NORMAL | 行为类型统计 |
| job_applications | idx_user_time | user_id, event_time | COMPOUND | 用户求职事件查询 |
| job_applications | idx_event_type | event_type | NORMAL | 事件类型统计 |
| victory_park_profiles | idx_industry_zone | industry_zone | NORMAL | 公园分区查询 |
| victory_park_profiles | idx_visible | is_visible | NORMAL | 可见性筛选 |
| park_interactions | idx_to_user | to_user_id, is_read | COMPOUND | 接收者未读消息查询 |
| wish_letters | idx_sent | is_sent, industry_tag | COMPOUND | 待发送信封查询 |
| jobs | idx_active | is_active, expire_time | COMPOUND | 有效岗位查询 |
| jobs | idx_industry_city | industry_tag, city | COMPOUND | 行业城市筛选 |

### 5.2 本地数据库索引

见各表建表语句中的 `CREATE INDEX` 语句。

---

## 6. 数据字典

### 6.1 枚举值字典

#### 6.1.1 action_type（求职行为类型）

| 值 | 显示名称 | 关键词 | 情绪 |
|----|----------|--------|------|
| resume_submit | 简历投递 | 投了、投递、发简历、海投 | positive |
| interview_received | 收到面试 | 面试、邀约、进面 | positive |
| job_rejected | 求职被拒 | 拒了、没通过、不合适、拒信 | negative |
| offer_received | 拿到Offer | offer、录用、录取、通过 | positive |
| slacking | 摆烂/休息 | 没投、躺平、摆烂、不想动 | neutral |
| anxiety | 焦虑/低落 | 烦、难过、崩溃、焦虑、迷茫 | negative |
| unknown | 未识别 | - | neutral |

#### 6.1.2 emotion_type（情绪类型）

| 值 | 显示名称 | 说明 |
|----|----------|------|
| positive | 正向 | 积极情绪 |
| negative | 负向 | 消极情绪 |
| neutral | 中性 | 平静情绪 |

#### 6.1.3 pet_action（宠物动作）

| 动作ID | 动作名称 | 触发条件 | 气泡内容 |
|--------|----------|----------|----------|
| wing_flap_nod | 翅膀拍拍+点头 | resume_submit | 嗯！ |
| jump_excited | 跳跃+眼睛变亮 | interview_received | ！！ |
| head_down_snuggle | 低头+蹭一蹭 | job_rejected | 呜… |
| spin_celebrate | 转圈+撒花 | offer_received | ♡♡♡ |
| sit_quiet | 安静坐下 | slacking | … |
| gentle_approach | 轻轻靠过来 | anxiety | 🫂 |

#### 6.1.4 industry_zone（行业分区）

| 值 | 分区名称 | 匹配行业 |
|----|----------|----------|
| internet | 码农森林 | 互联网/IT/软件 |
| finance | 金币湖畔 | 金融/银行/投资 |
| education | 书香花园 | 教育/培训/学术 |
| other | 综合广场 | 其他行业 |

#### 6.1.5 skin_type（皮肤类型）

| 值 | 显示名称 | 获取方式 |
|----|----------|----------|
| basic | 基础皮肤 | 默认拥有 |
| workplace | 职场皮肤 | 上岸解锁 |
| seasonal | 季节限定 | Pro会员专属 |
| premium | 付费皮肤 | 单独购买 |

---

### 6.2 字段约束字典

| 约束类型 | 说明 | 示例 |
|----------|------|------|
| NOT NULL | 必填字段 | user_id NOT NULL |
| UNIQUE | 唯一约束 | user_id UNIQUE |
| DEFAULT | 默认值 | is_synced DEFAULT 0 |
| FOREIGN KEY | 外键约束 | user_id REFERENCES user_profile(user_id) |
| CHECK | 检查约束 | CHECK(vip_status IN (0, 1)) |

---

## 7. 数据同步策略

### 7.1 同步架构

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              数据同步架构                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────┐                              ┌─────────────┐              │
│  │  本地SQLite  │                              │ LeanCloud   │              │
│  │             │                              │ 云端数据库   │              │
│  └──────┬──────┘                              └──────┬──────┘              │
│         │                                            │                     │
│         │              ┌─────────────┐               │                     │
│         └─────────────►│  同步管理器  │◄──────────────┘                     │
│                        │             │                                     │
│                        │ ┌─────────┐ │                                     │
│                        │ │增量检测 │ │                                     │
│                        │ └─────────┘ │                                     │
│                        │ ┌─────────┐ │                                     │
│                        │ │冲突解决 │ │                                     │
│                        │ └─────────┘ │                                     │
│                        │ ┌─────────┐ │                                     │
│                        │ │重试队列 │ │                                     │
│                        │ └─────────┘ │                                     │
│                        └─────────────┘                                     │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 7.2 同步策略表

| 数据类型 | 同步方向 | 同步时机 | 冲突策略 | 优先级 |
|----------|----------|----------|----------|--------|
| 对话记录 | 本地→云端 | 延迟同步（WiFi下） | 本地优先 | 低 |
| 求职事件 | 本地→云端 | 实时同步 | 时间戳优先 | 高 |
| 用户画像 | 双向 | 修改后延迟同步 | 云端优先 | 中 |
| 宠物记忆 | 本地→云端 | 对话结束后 | 合并策略 | 中 |
| 公园数据 | 云端→本地 | 进入公园时 | 云端优先 | 低 |
| 皮肤数据 | 云端→本地 | 启动时检查 | 云端优先 | 低 |

### 7.3 冲突解决规则

| 冲突场景 | 解决规则 | 说明 |
|----------|----------|------|
| 同一记录两端修改 | 时间戳优先 | 最后修改时间戳大的生效 |
| 本地删除云端更新 | 云端优先 | 保留云端更新 |
| 云端删除本地更新 | 本地优先 | 恢复本地记录 |
| 新增记录冲突 | 合并 | 两端新增都保留 |

### 7.4 同步流程

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│ 检查网络状态 │────►│ 查询同步队列 │────►│ 批量上传数据 │────►│ 更新同步状态 │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
                           │                    │
                           │ 队列为空           │ 上传失败
                           ▼                    ▼
                     ┌─────────────┐     ┌─────────────┐
                     │ 拉取云端更新 │     │ 加入重试队列 │
                     └─────────────┘     └─────────────┘
                           │
                           ▼
                     ┌─────────────┐
                     │ 合并本地数据 │
                     └─────────────┘
```

---

## 8. 附录

### 8.1 数据库版本迁移

**版本迁移脚本示例：**

```dart
class DatabaseMigration {
  static const int VERSION_1 = 1;
  
  static Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < VERSION_1) {
      await _createTablesV1(db);
    }
  }
  
  static Future<void> _createTablesV1(Database db) async {
    await db.execute('''
      CREATE TABLE local_interactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cloud_id TEXT UNIQUE,
        user_id TEXT NOT NULL,
        user_content TEXT NOT NULL,
        action_type TEXT NOT NULL,
        emotion_type TEXT NOT NULL,
        pet_action TEXT NOT NULL,
        pet_bubble TEXT NOT NULL,
        keywords_matched TEXT,
        confidence_score REAL,
        is_synced INTEGER DEFAULT 0,
        create_time INTEGER NOT NULL
      )
    ''');
  }
}
```

### 8.2 数据清理策略

| 数据类型 | 保留策略 | 清理条件 |
|----------|----------|----------|
| 本地对话记录 | 最近1000条 | 超出后删除最早记录 |
| 本地求职事件 | 永久保留 | 用户主动删除 |
| 同步队列 | 成功后删除 | 同步成功后清理 |
| 皮肤缓存 | 永久保留 | 用户卸载APP |
| 岗位数据 | 30天 | 过期后标记无效 |

### 8.3 数据备份策略

| 备份类型 | 频率 | 保留时间 | 存储位置 |
|----------|------|----------|----------|
| 云端全量备份 | 每日 | 30天 | LeanCloud备份服务 |
| 本地数据导出 | 用户触发 | 用户决定 | 用户本地存储 |

---

**文档结束**

*本文档为《职宠小窝》APP数据库设计文档v1.0版，如有变更请及时更新版本号。*
