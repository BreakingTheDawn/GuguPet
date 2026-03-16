# 《职宠小窝》APP 详细设计文档

**文档编号：** DDD-JOBPET-001  
**版本号：** v1.0  
**编写日期：** 2026-03-16  
**文档状态：** 正式发布  

---

## 修订历史

| 版本 | 日期 | 修订人 | 修订内容 |
|------|------|--------|----------|
| v1.0 | 2026-03-16 | 架构师 | 初始版本 |

---

## 目录

1. [系统架构设计](#1-系统架构设计)
2. [模块详细设计](#2-模块详细设计)
3. [核心类设计](#3-核心类设计)
4. [时序图](#4-时序图)
5. [核心算法设计](#5-核心算法设计)
6. [异常处理设计](#6-异常处理设计)
7. [性能优化设计](#7-性能优化设计)

---

## 1. 系统架构设计

### 1.1 整体架构

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              《职宠小窝》系统架构                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐  │
│  │                         表现层 (Presentation Layer)                   │  │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐   │  │
│  │  │  Pages      │ │  Widgets    │ │  Providers  │ │  Routes     │   │  │
│  │  │  页面组件    │ │  UI组件     │ │  状态管理    │ │  路由管理    │   │  │
│  │  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘   │  │
│  └─────────────────────────────────────────────────────────────────────┘  │
│                                      │                                     │
│                                      ▼                                     │
│  ┌─────────────────────────────────────────────────────────────────────┐  │
│  │                         业务逻辑层 (Business Layer)                   │  │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐   │  │
│  │  │ ConfideSvc  │ │ JobEventSvc │ │ ParkService │ │ VipService  │   │  │
│  │  │ 倾诉服务    │ │ 求职事件服务 │ │ 公园服务    │ │ 会员服务    │   │  │
│  │  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘   │  │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐   │  │
│  │  │ IntentEngine│ │ MemorySvc   │ │ SyncService │ │ PushService │   │  │
│  │  │ 意图识别引擎 │ │ 记忆服务    │ │ 同步服务    │ │ 推送服务    │   │  │
│  │  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘   │  │
│  └─────────────────────────────────────────────────────────────────────┘  │
│                                      │                                     │
│                                      ▼                                     │
│  ┌─────────────────────────────────────────────────────────────────────┐  │
│  │                         数据访问层 (Data Access Layer)                │  │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐   │  │
│  │  │ LocalRepo   │ │ CloudRepo   │ │ CacheRepo   │ │ FileRepo    │   │  │
│  │  │ 本地数据仓库 │ │ 云端数据仓库 │ │ 缓存仓库    │ │ 文件仓库    │   │  │
│  │  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘   │  │
│  └─────────────────────────────────────────────────────────────────────┘  │
│                                      │                                     │
│                                      ▼                                     │
│  ┌─────────────────────────────────────────────────────────────────────┐  │
│  │                         基础设施层 (Infrastructure Layer)             │  │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐   │  │
│  │  │ LeanCloud   │ │ SQLite      │ │ Lottie      │ │ HTTP Client │   │  │
│  │  │ SDK         │ │ Database    │ │ Animation   │ │ (Dio)       │   │  │
│  │  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘   │  │
│  └─────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 1.2 技术栈分层

| 层级 | 技术选型 | 说明 |
|------|----------|------|
| 表现层 | Flutter + Provider | 跨平台UI框架 + 状态管理 |
| 业务逻辑层 | Dart | 核心业务逻辑 |
| 数据访问层 | sqflite + leancloud_flutter | 本地存储 + 云端SDK |
| 基础设施层 | Dio + Lottie + shared_preferences | 网络请求 + 动画 + 本地缓存 |

### 1.3 项目目录结构

```
lib/
├── main.dart                    # 应用入口
├── app.dart                     # App配置
│
├── core/                        # 核心模块
│   ├── constants/               # 常量定义
│   │   ├── app_constants.dart
│   │   ├── api_constants.dart
│   │   └── storage_keys.dart
│   ├── errors/                  # 错误处理
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── network/                 # 网络层
│   │   ├── dio_client.dart
│   │   └── interceptors/
│   ├── storage/                 # 存储层
│   │   ├── local_storage.dart
│   │   └── secure_storage.dart
│   └── utils/                   # 工具类
│       ├── date_utils.dart
│       ├── logger.dart
│       └── validators.dart
│
├── data/                        # 数据层
│   ├── models/                  # 数据模型
│   │   ├── user_profile.dart
│   │   ├── interaction.dart
│   │   ├── job_event.dart
│   │   └── pet_skin.dart
│   ├── repositories/            # 数据仓库
│   │   ├── local/
│   │   │   ├── local_interaction_repo.dart
│   │   │   └── local_job_event_repo.dart
│   │   └── cloud/
│   │       ├── cloud_user_repo.dart
│   │       └── cloud_job_repo.dart
│   └── datasources/             # 数据源
│       ├── local_datasource.dart
│       └── cloud_datasource.dart
│
├── domain/                      # 领域层
│   ├── entities/                # 实体
│   │   ├── user.dart
│   │   └── pet.dart
│   ├── repositories/            # 仓库接口
│   │   └── repository_interface.dart
│   └── usecases/                # 用例
│       ├── submit_confide.dart
│       └── sync_data.dart
│
├── services/                    # 业务服务
│   ├── confide_service.dart     # 倾诉服务
│   ├── intent_engine.dart       # 意图识别引擎
│   ├── pet_memory_service.dart  # 宠物记忆服务
│   ├── job_event_service.dart   # 求职事件服务
│   ├── park_service.dart        # 公园服务
│   ├── sync_service.dart        # 同步服务
│   └── vip_service.dart         # 会员服务
│
├── providers/                   # 状态管理
│   ├── user_provider.dart
│   ├── pet_provider.dart
│   ├── confide_provider.dart
│   ├── job_board_provider.dart
│   └── park_provider.dart
│
├── pages/                       # 页面
│   ├── home/
│   │   ├── home_page.dart
│   │   └── home_controller.dart
│   ├── confide/
│   │   ├── confide_page.dart
│   │   └── pet_widget.dart
│   ├── job_board/
│   │   └── job_board_page.dart
│   ├── park/
│   │   └── park_page.dart
│   ├── jobs/
│   │   └── jobs_page.dart
│   └── profile/
│       └── profile_page.dart
│
├── widgets/                     # 通用组件
│   ├── pet_animation.dart
│   ├── bubble_widget.dart
│   ├── achievement_badge.dart
│   └── loading_overlay.dart
│
└── routes/                      # 路由
    ├── app_routes.dart
    └── route_generator.dart
```

---

## 2. 模块详细设计

### 2.1 模块划分

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              模块划分图                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐  │
│  │                         核心模块 (Core Modules)                       │  │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐   │  │
│  │  │ 倾诉交互    │ │ 意图识别    │ │ 宠物响应    │ │ 行为记录    │   │  │
│  │  │ Confide     │ │ Intent      │ │ PetResponse │ │ Record      │   │  │
│  │  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘   │  │
│  └─────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐  │
│  │                         功能模块 (Feature Modules)                    │  │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐   │  │
│  │  │ 求职看板    │ │ 彼岸公园    │ │ 岗位聚合    │ │ 宠物进化    │   │  │
│  │  │ JobBoard    │ │ VictoryPark │ │ JobAggreg   │ │ PetEvolve   │   │  │
│  │  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘   │  │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐                   │  │
│  │  │ 会员服务    │ │ 数据同步    │ │ 推送服务    │                   │  │
│  │  │ VipService  │ │ SyncService │ │ PushService │                   │  │
│  │  └─────────────┘ └─────────────┘ └─────────────┘                   │  │
│  └─────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐  │
│  │                         基础模块 (Base Modules)                       │  │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐   │  │
│  │  │ 用户认证    │ │ 本地存储    │ │ 云端存储    │ │ 网络请求    │   │  │
│  │  │ Auth        │ │ LocalStore  │ │ CloudStore  │ │ Network     │   │  │
│  │  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘   │  │
│  └─────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2.2 模块依赖关系

```
                    ┌─────────────┐
                    │   Pages     │
                    │   页面层     │
                    └──────┬──────┘
                           │
                           ▼
                    ┌─────────────┐
                    │  Providers  │
                    │  状态管理层 │
                    └──────┬──────┘
                           │
          ┌────────────────┼────────────────┐
          │                │                │
          ▼                ▼                ▼
   ┌─────────────┐  ┌─────────────┐  ┌─────────────┐
   │  Services   │  │  Services   │  │  Services   │
   │  业务服务层 │  │  业务服务层 │  │  业务服务层 │
   └──────┬──────┘  └──────┬──────┘  └──────┬──────┘
          │                │                │
          └────────────────┼────────────────┘
                           │
                           ▼
                    ┌─────────────┐
                    │ Repositories│
                    │  数据仓库层  │
                    └──────┬──────┘
                           │
          ┌────────────────┼────────────────┐
          │                │                │
          ▼                ▼                ▼
   ┌─────────────┐  ┌─────────────┐  ┌─────────────┐
   │ LocalRepo   │  │ CloudRepo   │  │ CacheRepo   │
   │ 本地数据     │  │ 云端数据     │  │ 缓存数据     │
   └─────────────┘  └─────────────┘  └─────────────┘
```

---

## 3. 核心类设计

### 3.1 类图

#### 3.1.1 倾诉交互模块类图

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              倾诉交互模块类图                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────┐         ┌─────────────────────┐                   │
│  │   ConfideService    │         │   IntentEngine      │                   │
│  ├─────────────────────┤         ├─────────────────────┤                   │
│  │ - _repository: Repo │         │ - _keywordRules: Map│                   │
│  │ - _intentEngine     │         │ - _negationWords    │                   │
│  │ - _petResponder     │         │ - _emotionAnalyzer  │                   │
│  ├─────────────────────┤         ├─────────────────────┤                   │
│  │ + submitConfide()   │         │ + analyze(content)  │                   │
│  │ + getHistory()      │         │ + extractKeywords() │                   │
│  │ + syncToCloud()     │         │ + detectNegation()  │                   │
│  └──────────┬──────────┘         │ + classifyEmotion() │                   │
│             │                    └──────────┬──────────┘                   │
│             │                               │                              │
│             │ uses                          │ produces                     │
│             ▼                               ▼                              │
│  ┌─────────────────────┐         ┌─────────────────────┐                   │
│  │   PetResponder      │         │   IntentResult      │                   │
│  ├─────────────────────┤         ├─────────────────────┤                   │
│  │ - _actionMap: Map   │         │ + actionType: String│                   │
│  │ - _bubbleMap: Map   │         │ + emotionType: String│                  │
│  │ - _animationCache   │         │ + keywords: List    │                   │
│  ├─────────────────────┤         │ + confidence: double│                   │
│  │ + respond(intent)   │         └─────────────────────┘                   │
│  │ + getAction(type)   │                                                    │
│  │ + getBubble(type)   │                                                    │
│  └─────────────────────┘                                                    │
│                                                                             │
│  ┌─────────────────────┐         ┌─────────────────────┐                   │
│  │   Interaction       │         │   InteractionRepo   │                   │
│  ├─────────────────────┤         ├─────────────────────┤                   │
│  │ + id: String        │         │ + saveLocal()       │                   │
│  │ + userId: String    │         │ + saveCloud()       │                   │
│  │ + content: String   │         │ + getLocalList()    │                   │
│  │ + actionType: String│         │ + getCloudList()    │                   │
│  │ + emotionType: String│        │ + syncPending()     │                   │
│  │ + petAction: String │         └─────────────────────┘                   │
│  │ + petBubble: String │                                                    │
│  │ + createTime: DateTime│                                                  │
│  └─────────────────────┘                                                    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### 3.1.2 数据同步模块类图

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              数据同步模块类图                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐  │
│  │                         SyncService                                  │  │
│  ├─────────────────────────────────────────────────────────────────────┤  │
│  │ - _localRepo: LocalRepository                                       │  │
│  │ - _cloudRepo: CloudRepository                                       │  │
│  │ - _syncQueue: SyncQueue                                             │  │
│  │ - _conflictResolver: ConflictResolver                               │  │
│  │ - _networkMonitor: NetworkMonitor                                   │  │
│  ├─────────────────────────────────────────────────────────────────────┤  │
│  │ + syncAll(): Future<SyncResult>                                     │  │
│  │ + syncInteractions(): Future<void>                                  │  │
│  │ + syncJobEvents(): Future<void>                                     │  │
│  │ + resolveConflict(local, cloud): ConflictResult                     │  │
│  │ + getPendingCount(): int                                            │  │
│  └─────────────────────────────────────────────────────────────────────┘  │
│                                      │                                     │
│             ┌────────────────────────┼────────────────────────┐           │
│             │                        │                        │           │
│             ▼                        ▼                        ▼           │
│  ┌─────────────────────┐  ┌─────────────────────┐  ┌─────────────────────┐│
│  │   SyncQueue         │  │  ConflictResolver   │  │  NetworkMonitor     ││
│  ├─────────────────────┤  ├─────────────────────┤  ├─────────────────────┤│
│  │ + add(item)         │  │ + resolve(conflict) │  │ + isConnected()     ││
│  │ + getNext(): Item   │  │ + setStrategy(s)    │  │ + onStatusChange()  ││
│  │ + markDone(id)      │  │ + getLastWin()      │  │ + getConnectionType()││
│  │ + retry(id)         │  │ + getMergeStrategy()│  └─────────────────────┘│
│  │ + getPending()      │  └─────────────────────┘                          │
│  └─────────────────────┘                                                   │
│                                                                            │
│  ┌─────────────────────┐         ┌─────────────────────┐                  │
│  │   SyncItem          │         │   SyncResult        │                  │
│  ├─────────────────────┤         ├─────────────────────┤                  │
│  │ + id: String        │         │ + success: int      │                  │
│  │ + tableName: String │         │ + failed: int       │                  │
│  │ + recordId: String  │         │ + conflicts: List   │                  │
│  │ + operation: String │         │ + timestamp: DateTime│                 │
│  │ + priority: int     │         └─────────────────────┘                  │
│  │ + retryCount: int   │                                                   │
│  │ + lastError: String │                                                   │
│  └─────────────────────┘                                                   │
│                                                                            │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 3.2 核心类定义

#### 3.2.1 IntentEngine（意图识别引擎）

```dart
class IntentEngine {
  final Map<String, List<String>> _keywordRules;
  final List<String> _negationWords;
  final Map<String, String> _emotionMapping;
  
  IntentEngine({
    required Map<String, List<String>> keywordRules,
    required List<String> negationWords,
    required Map<String, String> emotionMapping,
  }) : _keywordRules = keywordRules,
       _negationWords = negationWords,
       _emotionMapping = emotionMapping;
  
  Future<IntentResult> analyze(String content) async {
    final cleanedContent = _preprocess(content);
    final negationContext = _detectNegation(cleanedContent);
    final keywords = _extractKeywords(cleanedContent);
    final actionType = _classifyAction(keywords, negationContext);
    final emotionType = _classifyEmotion(actionType);
    final confidence = _calculateConfidence(keywords, actionType);
    
    return IntentResult(
      actionType: actionType,
      emotionType: emotionType,
      keywords: keywords,
      confidence: confidence,
    );
  }
  
  String _preprocess(String content) {
    return content
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s\u4e00-\u9fa5]'), '');
  }
  
  NegationContext _detectNegation(String content) {
    for (final word in _negationWords) {
      if (content.contains(word)) {
        final parts = content.split(word);
        return NegationContext(
          hasNegation: true,
          negationWord: word,
          affectedPart: parts.isNotEmpty ? parts.last : '',
        );
      }
    }
    return NegationContext(hasNegation: false);
  }
  
  List<String> _extractKeywords(String content) {
    final matchedKeywords = <String>[];
    for (final entry in _keywordRules.entries) {
      for (final keyword in entry.value) {
        if (content.contains(keyword)) {
          matchedKeywords.add(keyword);
        }
      }
    }
    return matchedKeywords;
  }
  
  String _classifyAction(List<String> keywords, NegationContext negation) {
    if (keywords.isEmpty) return 'unknown';
    
    for (final entry in _keywordRules.entries) {
      for (final keyword in keywords) {
        if (entry.value.contains(keyword)) {
          if (negation.hasNegation && _isNegationApplicable(keyword, negation)) {
            return _getNegatedAction(entry.key);
          }
          return entry.key;
        }
      }
    }
    return 'unknown';
  }
  
  String _classifyEmotion(String actionType) {
    return _emotionMapping[actionType] ?? 'neutral';
  }
  
  double _calculateConfidence(List<String> keywords, String actionType) {
    if (actionType == 'unknown') return 0.0;
    final ruleKeywords = _keywordRules[actionType] ?? [];
    final matchCount = keywords.where((k) => ruleKeywords.contains(k)).length;
    return (matchCount / ruleKeywords.length).clamp(0.0, 1.0);
  }
}
```

#### 3.2.2 PetResponder（宠物响应器）

```dart
class PetResponder {
  final Map<String, PetAction> _actionMap;
  final Map<String, String> _bubbleMap;
  final Map<String, LottieComposition> _animationCache;
  
  PetResponder({
    required Map<String, PetAction> actionMap,
    required Map<String, String> bubbleMap,
  }) : _actionMap = actionMap,
       _bubbleMap = bubbleMap,
       _animationCache = {};
  
  Future<PetResponse> respond(IntentResult intent) async {
    final action = _getAction(intent.actionType);
    final bubble = _getBubble(intent.actionType);
    final animation = await _loadAnimation(action.animationPath);
    
    return PetResponse(
      action: action,
      bubble: bubble,
      animation: animation,
    );
  }
  
  PetAction _getAction(String actionType) {
    return _actionMap[actionType] ?? _actionMap['unknown']!;
  }
  
  String _getBubble(String actionType) {
    return _bubbleMap[actionType] ?? '…';
  }
  
  Future<LottieComposition?> _loadAnimation(String path) async {
    if (_animationCache.containsKey(path)) {
      return _animationCache[path];
    }
    
    final composition = await AssetLottie(path).load();
    _animationCache[path] = composition;
    return composition;
  }
}

class PetAction {
  final String id;
  final String name;
  final String animationPath;
  final int durationMs;
  final bool loop;
  
  PetAction({
    required this.id,
    required this.name,
    required this.animationPath,
    this.durationMs = 2000,
    this.loop = false,
  });
}

class PetResponse {
  final PetAction action;
  final String bubble;
  final LottieComposition? animation;
  
  PetResponse({
    required this.action,
    required this.bubble,
    this.animation,
  });
}
```

#### 3.2.3 SyncService（同步服务）

```dart
class SyncService {
  final LocalRepository _localRepo;
  final CloudRepository _cloudRepo;
  final SyncQueue _syncQueue;
  final ConflictResolver _conflictResolver;
  final NetworkMonitor _networkMonitor;
  
  StreamSubscription<NetworkStatus>? _networkSubscription;
  
  SyncService({
    required LocalRepository localRepo,
    required CloudRepository cloudRepo,
    required SyncQueue syncQueue,
    required ConflictResolver conflictResolver,
    required NetworkMonitor networkMonitor,
  }) : _localRepo = localRepo,
       _cloudRepo = cloudRepo,
       _syncQueue = syncQueue,
       _conflictResolver = conflictResolver,
       _networkMonitor = networkMonitor;
  
  void initialize() {
    _networkSubscription = _networkMonitor.onStatusChange.listen((status) {
      if (status.isConnected && status.isWifi) {
        syncAll();
      }
    });
  }
  
  Future<SyncResult> syncAll() async {
    if (!_networkMonitor.isConnected) {
      return SyncResult(success: 0, failed: 0, conflicts: []);
    }
    
    final results = await Future.wait([
      syncInteractions(),
      syncJobEvents(),
      syncUserProfile(),
    ]);
    
    return SyncResult(
      success: results.fold(0, (sum, r) => sum + r.success),
      failed: results.fold(0, (sum, r) => sum + r.failed),
      conflicts: results.expand((r) => r.conflicts).toList(),
      timestamp: DateTime.now(),
    );
  }
  
  Future<SyncResult> syncInteractions() async {
    final pending = await _syncQueue.getPending('interactions');
    var success = 0;
    var failed = 0;
    final conflicts = <Conflict>[];
    
    for (final item in pending) {
      try {
        final local = await _localRepo.getInteraction(item.recordId);
        final cloud = await _cloudRepo.getInteraction(item.recordId);
        
        if (cloud != null && _hasConflict(local, cloud)) {
          final resolved = await _conflictResolver.resolve(local, cloud);
          await _applyResolution(resolved);
          conflicts.add(Conflict(local: local, cloud: cloud, resolved: resolved));
        } else {
          await _cloudRepo.saveInteraction(local);
        }
        
        await _syncQueue.markDone(item.id);
        success++;
      } catch (e) {
        await _syncQueue.retry(item.id, e.toString());
        failed++;
      }
    }
    
    return SyncResult(success: success, failed: failed, conflicts: conflicts);
  }
  
  bool _hasConflict(Interaction local, Interaction? cloud) {
    if (cloud == null) return false;
    return local.updatedAt.isAfter(cloud.updatedAt) && 
           local.createdAt.isBefore(cloud.updatedAt);
  }
  
  Future<void> _applyResolution(ConflictResolution resolved) async {
    await _localRepo.updateInteraction(resolved.winner);
    await _cloudRepo.saveInteraction(resolved.winner);
  }
  
  void dispose() {
    _networkSubscription?.cancel();
  }
}
```

---

## 4. 时序图

### 4.1 倾诉交互时序图

```
┌─────────┐     ┌─────────┐     ┌─────────┐     ┌─────────┐     ┌─────────┐
│  User   │     │ConfidePg│     │ConfideSvc│    │IntentEng│     │PetRspndr│
└────┬────┘     └────┬────┘     └────┬────┘     └────┬────┘     └────┬────┘
     │               │               │               │               │
     │  输入倾诉内容  │               │               │               │
     │──────────────►│               │               │               │
     │               │               │               │               │
     │               │  submitConfide()              │               │
     │               │──────────────►│               │               │
     │               │               │               │               │
     │               │               │  analyze()    │               │
     │               │               │──────────────►│               │
     │               │               │               │               │
     │               │               │               │  匹配关键词    │
     │               │               │               │  检测否定词    │
     │               │               │               │  分类情绪      │
     │               │               │               │               │
     │               │               │  IntentResult │               │
     │               │               │◄──────────────│               │
     │               │               │               │               │
     │               │               │  respond()    │               │
     │               │               │──────────────────────────────►│
     │               │               │               │               │
     │               │               │               │  加载动画      │
     │               │               │               │  获取气泡      │
     │               │               │               │               │
     │               │               │  PetResponse  │               │
     │               │               │◄──────────────────────────────│
     │               │               │               │               │
     │               │               │  保存本地      │               │
     │               │               │  同步云端      │               │
     │               │               │               │               │
     │               │  PetResponse  │               │               │
     │               │◄──────────────│               │               │
     │               │               │               │               │
     │  播放动画      │               │               │               │
     │  显示气泡      │               │               │               │
     │◄──────────────│               │               │               │
     │               │               │               │               │
```

### 4.2 数据同步时序图

```
┌─────────┐     ┌─────────┐     ┌─────────┐     ┌─────────┐     ┌─────────┐
│ App Init│     │SyncSvc  │     │NetworkM │     │ LocalRepo│    │CloudRepo│
└────┬────┘     └────┬────┘     └────┬────┘     └────┬────┘     └────┬────┘
     │               │               │               │               │
     │  initialize() │               │               │               │
     │──────────────►│               │               │               │
     │               │               │               │               │
     │               │  监听网络状态  │               │               │
     │               │──────────────►│               │               │
     │               │               │               │               │
     │               │               │  网络状态变化  │               │
     │               │◄──────────────│               │               │
     │               │  (WiFi连接)   │               │               │
     │               │               │               │               │
     │               │  syncAll()    │               │               │
     │               │──────────────┐│               │               │
     │               │              ││               │               │
     │               │              ▼│               │               │
     │               │  getPending() │               │               │
     │               │──────────────────────────────►│               │
     │               │               │               │               │
     │               │               │  待同步列表    │               │
     │               │◄──────────────────────────────│               │
     │               │               │               │               │
     │               │  saveCloud()  │               │               │
     │               │──────────────────────────────────────────────►│
     │               │               │               │               │
     │               │               │               │  保存成功      │
     │               │◄──────────────────────────────────────────────│
     │               │               │               │               │
     │               │  markDone()   │               │               │
     │               │──────────────────────────────►│               │
     │               │               │               │               │
     │               │  SyncResult   │               │               │
     │               │◄─────────────┐│               │               │
     │               │              ││               │               │
     │  同步完成通知  │              ││               │               │
     │◄──────────────│              ││               │               │
     │               │               │               │               │
```

### 4.3 公园交互时序图

```
┌─────────┐     ┌─────────┐     ┌─────────┐     ┌─────────┐     ┌─────────┐
│  User   │     │ ParkPage│     │ParkSvc  │     │CloudRepo│     │ContentSrv│
└────┬────┘     └────┬────┘     └────┬────┘     └────┬────┘     └────┬────┘
     │               │               │               │               │
     │  进入公园      │               │               │               │
     │──────────────►│               │               │               │
     │               │               │               │               │
     │               │  getParkProfiles()            │               │
     │               │──────────────►│               │               │
     │               │               │               │               │
     │               │               │  查询公园档案  │               │
     │               │               │──────────────►│               │
     │               │               │               │               │
     │               │               │  档案列表      │               │
     │               │               │◄──────────────│               │
     │               │               │               │               │
     │               │  档案列表      │               │               │
     │               │◄──────────────│               │               │
     │               │               │               │               │
     │  显示公园场景  │               │               │               │
     │◄──────────────│               │               │               │
     │               │               │               │               │
     │  发起交互(送花)│               │               │               │
     │──────────────►│               │               │               │
     │               │               │               │               │
     │               │  createInteraction()          │               │
     │               │──────────────►│               │               │
     │               │               │               │               │
     │               │               │  内容审核      │               │
     │               │               │──────────────────────────────►│
     │               │               │               │               │
     │               │               │  审核通过      │               │
     │               │               │◄──────────────────────────────│
     │               │               │               │               │
     │               │               │  保存交互记录  │               │
     │               │               │──────────────►│               │
     │               │               │               │               │
     │               │               │  保存成功      │               │
     │               │               │◄──────────────│               │
     │               │               │               │               │
     │               │  交互成功      │               │               │
     │               │◄──────────────│               │               │
     │               │               │               │               │
     │  播放交互动画  │               │               │               │
     │◄──────────────│               │               │               │
     │               │               │               │               │
```

---

## 5. 核心算法设计

### 5.1 意图识别算法

#### 5.1.1 算法流程

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              意图识别算法流程                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   输入: 用户倾诉内容 (String)                                                │
│                                                                             │
│   ┌─────────────┐                                                           │
│   │ 1. 文本预处理 │                                                          │
│   │   - 转小写   │                                                          │
│   │   - 去除标点  │                                                          │
│   │   - 分词     │                                                          │
│   └──────┬──────┘                                                           │
│          │                                                                  │
│          ▼                                                                  │
│   ┌─────────────┐                                                           │
│   │ 2. 否定词检测 │                                                          │
│   │   - 扫描否定词│                                                          │
│   │   - 标记否定域│                                                          │
│   └──────┬──────┘                                                           │
│          │                                                                  │
│          ▼                                                                  │
│   ┌─────────────┐                                                           │
│   │ 3. 关键词匹配 │                                                          │
│   │   - 遍历规则库│                                                          │
│   │   - 收集匹配词│                                                          │
│   └──────┬──────┘                                                           │
│          │                                                                  │
│          ▼                                                                  │
│   ┌─────────────┐     ┌─────────────┐                                      │
│   │ 4. 行为分类  │────►│ 有否定词?   │                                      │
│   └──────┬──────┘     └──────┬──────┘                                      │
│          │                   │                                              │
│          │            ┌──────┴──────┐                                      │
│          │            │             │                                      │
│          │            ▼             ▼                                      │
│          │     ┌──────────┐ ┌──────────┐                                   │
│          │     │ 取反行为  │ │ 正常行为  │                                   │
│          │     │ (如:摆烂) │ │          │                                   │
│          │     └──────────┘ └──────────┘                                   │
│          │                                                                  │
│          ▼                                                                  │
│   ┌─────────────┐                                                           │
│   │ 5. 情绪映射  │                                                           │
│   │   - 查表映射  │                                                          │
│   └──────┬──────┘                                                           │
│          │                                                                  │
│          ▼                                                                  │
│   ┌─────────────┐                                                           │
│   │ 6. 置信度计算│                                                           │
│   │   - 匹配率   │                                                           │
│   │   - 权重调整  │                                                          │
│   └──────┬──────┘                                                           │
│          │                                                                  │
│          ▼                                                                  │
│   输出: IntentResult { actionType, emotionType, keywords, confidence }      │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### 5.1.2 关键词规则库

```dart
const Map<String, List<String>> kKeywordRules = {
  'resume_submit': [
    '投了', '投递', '发简历', '海投', '投了几份', 
    '投完', '简历发', '发了简历', '投出去'
  ],
  'interview_received': [
    '面试', '邀约', '叫我去面试', '进面', '收到面试',
    '面试邀请', '约面试', '面试通知'
  ],
  'job_rejected': [
    '拒了', '没通过', '不合适', '拒信', '挂了',
    '被拒', '没过', '刷了', '凉凉'
  ],
  'offer_received': [
    'offer', '录用', '录取', '通过了', '上班',
    '入职', 'offer了', '拿到offer', '定下来了'
  ],
  'slacking': [
    '没投', '躺平', '摆烂', '没看', '不想动',
    '休息', '摸鱼', '懒得'
  ],
  'anxiety': [
    '烦', '难过', '崩溃', '焦虑', '迷茫', '没用',
    '压力大', '心累', '绝望', '想哭'
  ],
};

const List<String> kNegationWords = [
  '没', '没有', '不', '还没', '不是', '别'
];

const Map<String, String> kNegationMapping = {
  'resume_submit': 'slacking',      // "没投" -> 摆烂
  'interview_received': 'slacking', // "没面试" -> 摆烂
  'offer_received': 'slacking',     // "没offer" -> 摆烂
};

const Map<String, String> kEmotionMapping = {
  'resume_submit': 'positive',
  'interview_received': 'positive',
  'job_rejected': 'negative',
  'offer_received': 'positive',
  'slacking': 'neutral',
  'anxiety': 'negative',
  'unknown': 'neutral',
};
```

### 5.2 宠物记忆算法

#### 5.2.1 记忆提取算法

```dart
class MemoryExtractor {
  static const int kMaxMemoryCount = 20;
  
  final List<MemoryPattern> _patterns;
  
  MemoryExtractor() : _patterns = _buildPatterns();
  
  List<PetMemory> extract(String content, String actionType) {
    final memories = <PetMemory>[];
    
    for (final pattern in _patterns) {
      final match = pattern.regex.firstMatch(content);
      if (match != null) {
        memories.add(PetMemory(
          type: pattern.memoryType,
          key: pattern.keyExtractor(match),
          value: pattern.valueExtractor(match),
          source: content,
          createdAt: DateTime.now(),
        ));
      }
    }
    
    return memories;
  }
  
  List<PetMemory> merge(
    List<PetMemory> existing,
    List<PetMemory> newMemories,
  ) {
    final merged = Map<String, PetMemory>.from(
      existing.asMap().map((_, m) => MapEntry(m.key, m)),
    );
    
    for (final memory in newMemories) {
      merged[memory.key] = memory;
    }
    
    final sorted = merged.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return sorted.take(kMaxMemoryCount).toList();
  }
  
  static List<MemoryPattern> _buildPatterns() {
    return [
      MemoryPattern(
        regex: RegExp(r'面试[是]?(\d{1,2})[号日]'),
        memoryType: 'interview',
        keyExtractor: (m) => '面试日期',
        valueExtractor: (m) => m.group(1) ?? '',
      ),
      MemoryPattern(
        regex: RegExp(r'(明天|后天|下周[一二三四五六日]?)有面试'),
        memoryType: 'interview',
        keyExtractor: (m) => '面试时间',
        valueExtractor: (m) => m.group(1) ?? '',
      ),
      MemoryPattern(
        regex: RegExp(r'(?:去|在)([^，。！？]+)面试'),
        memoryType: 'interview',
        keyExtractor: (m) => '面试公司',
        valueExtractor: (m) => m.group(1) ?? '',
      ),
      MemoryPattern(
        regex: RegExp(r'想做([^\s，。！？]+)'),
        memoryType: 'preference',
        keyExtractor: (m) => '求职方向',
        valueExtractor: (m) => m.group(1) ?? '',
      ),
    ];
  }
}

class MemoryPattern {
  final RegExp regex;
  final String memoryType;
  final String Function(Match) keyExtractor;
  final String Function(Match) valueExtractor;
  
  MemoryPattern({
    required this.regex,
    required this.memoryType,
    required this.keyExtractor,
    required this.valueExtractor,
  });
}
```

### 5.3 数据同步冲突解决算法

```dart
class ConflictResolver {
  final ConflictStrategy _strategy;
  
  ConflictResolver({ConflictStrategy strategy = ConflictStrategy.lastWriteWins})
      : _strategy = strategy;
  
  Future<ConflictResolution> resolve(
    dynamic local,
    dynamic cloud,
  ) async {
    switch (_strategy) {
      case ConflictStrategy.lastWriteWins:
        return _lastWriteWins(local, cloud);
      case ConflictStrategy.cloudWins:
        return _cloudWins(local, cloud);
      case ConflictStrategy.localWins:
        return _localWins(local, cloud);
      case ConflictStrategy.merge:
        return _merge(local, cloud);
    }
  }
  
  ConflictResolution _lastWriteWins(dynamic local, dynamic cloud) {
    final winner = local.updatedAt.isAfter(cloud.updatedAt) ? local : cloud;
    return ConflictResolution(
      winner: winner,
      strategy: ConflictStrategy.lastWriteWins,
      reason: '选择最后修改时间较新的记录',
    );
  }
  
  ConflictResolution _cloudWins(dynamic local, dynamic cloud) {
    return ConflictResolution(
      winner: cloud,
      strategy: ConflictStrategy.cloudWins,
      reason: '云端数据优先',
    );
  }
  
  ConflictResolution _localWins(dynamic local, dynamic cloud) {
    return ConflictResolution(
      winner: local,
      strategy: ConflictStrategy.localWins,
      reason: '本地数据优先',
    );
  }
  
  ConflictResolution _merge(dynamic local, dynamic cloud) {
    final merged = _mergeFields(local, cloud);
    return ConflictResolution(
      winner: merged,
      strategy: ConflictStrategy.merge,
      reason: '合并本地和云端数据',
    );
  }
  
  dynamic _mergeFields(dynamic local, dynamic cloud) {
    if (local is Interaction && cloud is Interaction) {
      return Interaction(
        id: local.id,
        userId: local.userId,
        content: local.content,
        actionType: local.actionType,
        emotionType: local.emotionType,
        petAction: local.petAction,
        petBubble: local.petBubble,
        createdAt: local.createdAt,
        updatedAt: DateTime.now(),
        cloudId: cloud.cloudId,
      );
    }
    return local;
  }
}

enum ConflictStrategy {
  lastWriteWins,
  cloudWins,
  localWins,
  merge,
}

class ConflictResolution {
  final dynamic winner;
  final ConflictStrategy strategy;
  final String reason;
  
  ConflictResolution({
    required this.winner,
    required this.strategy,
    required this.reason,
  });
}
```

---

## 6. 异常处理设计

### 6.1 异常分类

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              异常分类体系                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│                         ┌─────────────────┐                                │
│                         │   AppException  │                                │
│                         │   (基类)         │                                │
│                         └────────┬────────┘                                │
│                                  │                                          │
│          ┌───────────────────────┼───────────────────────┐                 │
│          │                       │                       │                 │
│          ▼                       ▼                       ▼                 │
│   ┌─────────────┐         ┌─────────────┐         ┌─────────────┐         │
│   │NetworkError │         │ StorageError│         │ BusinessError│        │
│   │  网络异常    │         │  存储异常    │         │  业务异常     │        │
│   └──────┬──────┘         └──────┬──────┘         └──────┬──────┘         │
│          │                       │                       │                 │
│   ┌──────┴──────┐         ┌──────┴──────┐         ┌──────┴──────┐         │
│   │             │         │             │         │             │         │
│   ▼             ▼         ▼             ▼         ▼             ▼         │
│ ┌─────┐   ┌─────┐   ┌─────┐   ┌─────┐   ┌─────┐   ┌─────┐               │
│ │Timeout│ │NoNet│   │DBErr│   │Cache│   │AuthErr│ │VipErr│               │
│ │超时   │ │无网络│   │数据库│   │缓存 │   │认证失败│ │会员 │               │
│ └─────┘   └─────┘   └─────┘   └─────┘   └─────┘   └─────┘               │
│                                                                           │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 6.2 异常定义

```dart
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  
  AppException({
    required this.message,
    this.code,
    this.originalError,
  });
  
  @override
  String toString() => '[$code] $message';
}

class NetworkException extends AppException {
  NetworkException({
    String? message,
    String? code,
    dynamic originalError,
  }) : super(
    message: message ?? '网络请求失败',
    code: code ?? 'NETWORK_ERROR',
    originalError: originalError,
  );
}

class TimeoutException extends NetworkException {
  TimeoutException({dynamic originalError})
      : super(
    message: '请求超时',
    code: 'TIMEOUT',
    originalError: originalError,
  );
}

class NoConnectionException extends NetworkException {
  NoConnectionException({dynamic originalError})
      : super(
    message: '网络连接不可用',
    code: 'NO_CONNECTION',
    originalError: originalError,
  );
}

class StorageException extends AppException {
  StorageException({
    String? message,
    String? code,
    dynamic originalError,
  }) : super(
    message: message ?? '存储操作失败',
    code: code ?? 'STORAGE_ERROR',
    originalError: originalError,
  );
}

class DatabaseException extends StorageException {
  DatabaseException({dynamic originalError})
      : super(
    message: '数据库操作失败',
    code: 'DATABASE_ERROR',
    originalError: originalError,
  );
}

class BusinessException extends AppException {
  BusinessException({
    required String message,
    String? code,
    dynamic originalError,
  }) : super(
    message: message,
    code: code ?? 'BUSINESS_ERROR',
    originalError: originalError,
  );
}

class AuthException extends BusinessException {
  AuthException({String? message, dynamic originalError})
      : super(
    message: message ?? '认证失败',
    code: 'AUTH_ERROR',
    originalError: originalError,
  );
}

class VipRequiredException extends BusinessException {
  VipRequiredException({String? feature, dynamic originalError})
      : super(
    message: feature != null ? '$feature需要Pro版会员' : '需要Pro版会员',
    code: 'VIP_REQUIRED',
    originalError: originalError,
  );
}
```

### 6.3 全局异常处理

```dart
class GlobalExceptionHandler {
  static void handle(Object error, StackTrace stackTrace) {
    if (error is AppException) {
      _handleAppException(error);
    } else if (error is DioException) {
      _handleDioException(error);
    } else {
      _handleUnknownError(error, stackTrace);
    }
  }
  
  static void _handleAppException(AppException e) {
    switch (e.runtimeType) {
      case NetworkException:
      case TimeoutException:
      case NoConnectionException:
        Toast.show('网络异常，请检查网络连接');
        break;
      case StorageException:
      case DatabaseException:
        Toast.show('数据存储异常，请稍后重试');
        break;
      case AuthException:
        Toast.show('登录已过期，请重新登录');
        Navigator.pushNamedAndRemoveUntil(
          context, '/login', (route) => false);
        break;
      case VipRequiredException:
        _showVipDialog();
        break;
      default:
        Toast.show(e.message);
    }
    
    Logger.error('AppException: ${e.toString()}');
  }
  
  static void _handleDioException(DioException e) {
    String message;
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = '请求超时，请稍后重试';
        break;
      case DioExceptionType.badResponse:
        message = _getHttpErrorMessage(e.response?.statusCode);
        break;
      default:
        message = '网络异常，请稍后重试';
    }
    Toast.show(message);
    Logger.error('DioException: ${e.toString()}');
  }
  
  static void _handleUnknownError(Object error, StackTrace stackTrace) {
    Toast.show('发生未知错误');
    Logger.error('Unknown error: $error', stackTrace);
  }
  
  static String _getHttpErrorMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return '请求参数错误';
      case 401:
        return '未授权，请登录';
      case 403:
        return '禁止访问';
      case 404:
        return '资源不存在';
      case 429:
        return '请求过于频繁';
      case 500:
        return '服务器错误';
      default:
        return '网络异常';
    }
  }
  
  static void _showVipDialog() {
    showDialog(
      context: context,
      builder: (context) => VipRequiredDialog(),
    );
  }
}
```

---

## 7. 性能优化设计

### 7.1 性能优化策略

| 优化维度 | 优化策略 | 实现方式 |
|----------|----------|----------|
| 启动速度 | 延迟加载、预缓存 | 首页资源预加载、非核心模块延迟初始化 |
| 列表性能 | 虚拟列表、分页加载 | ListView.builder、分页请求 |
| 动画性能 | 硬件加速、资源压缩 | Lottie动画、图片压缩 |
| 网络请求 | 缓存、并发控制 | Dio缓存拦截器、请求队列 |
| 本地存储 | 索引优化、批量操作 | SQLite索引、批量插入 |
| 内存管理 | 对象池、及时释放 | 动画对象复用、页面销毁释放 |

### 7.2 缓存策略

```dart
enum CacheLevel {
  memory,      // 内存缓存
  disk,        // 磁盘缓存
  network,     // 网络请求
}

class CacheManager {
  final Map<String, CacheEntry> _memoryCache = {};
  final SharedPreferences _prefs;
  
  CacheManager(this._prefs);
  
  Future<T?> get<T>(
    String key, {
    CacheLevel level = CacheLevel.memory,
    Duration? ttl,
    Future<T> Function()? fetch,
  }) async {
    if (level == CacheLevel.memory) {
      final entry = _memoryCache[key];
      if (entry != null && !entry.isExpired) {
        return entry.value as T;
      }
    }
    
    if (level.index >= CacheLevel.disk.index) {
      final json = _prefs.getString(key);
      if (json != null) {
        final entry = CacheEntry.fromJson(json);
        if (!entry.isExpired) {
          if (level == CacheLevel.memory) {
            _memoryCache[key] = entry;
          }
          return entry.value as T;
        }
      }
    }
    
    if (fetch != null) {
      final value = await fetch();
      await set(key, value, level: level, ttl: ttl);
      return value;
    }
    
    return null;
  }
  
  Future<void> set<T>(
    String key,
    T value, {
    CacheLevel level = CacheLevel.memory,
    Duration? ttl,
  }) async {
    final entry = CacheEntry(
      value: value,
      expireAt: ttl != null 
        ? DateTime.now().add(ttl) 
        : null,
    );
    
    if (level == CacheLevel.memory || level == CacheLevel.disk) {
      _memoryCache[key] = entry;
    }
    
    if (level.index >= CacheLevel.disk.index) {
      await _prefs.setString(key, entry.toJson());
    }
  }
  
  Future<void> remove(String key) async {
    _memoryCache.remove(key);
    await _prefs.remove(key);
  }
  
  Future<void> clear() async {
    _memoryCache.clear();
    await _prefs.clear();
  }
}

class CacheEntry {
  final dynamic value;
  final DateTime? expireAt;
  
  CacheEntry({required this.value, this.expireAt});
  
  bool get isExpired => 
    expireAt != null && DateTime.now().isAfter(expireAt!);
  
  String toJson() => jsonEncode({
    'value': value,
    'expireAt': expireAt?.toIso8601String(),
  });
  
  factory CacheEntry.fromJson(String json) {
    final map = jsonDecode(json);
    return CacheEntry(
      value: map['value'],
      expireAt: map['expireAt'] != null 
        ? DateTime.parse(map['expireAt']) 
        : null,
    );
  }
}
```

### 7.3 图片加载优化

```dart
class OptimizedImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String? placeholder;
  
  const OptimizedImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
  });
  
  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => Container(
        color: Colors.grey[200],
        child: placeholder != null
          ? Lottie.asset(placeholder!)
          : const Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[200],
        child: const Icon(Icons.error_outline),
      ),
      memCacheWidth: width != null ? (width! * 2).toInt() : null,
      memCacheHeight: height != null ? (height! * 2).toInt() : null,
      maxWidthDiskCache: 500,
      maxHeightDiskCache: 500,
    );
  }
}
```

### 7.4 列表性能优化

```dart
class OptimizedListView<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final VoidCallback? onLoadMore;
  final bool hasMore;
  final ScrollController? controller;
  
  const OptimizedListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.onLoadMore,
    this.hasMore = false,
    this.controller,
  });
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      itemCount: items.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == items.length) {
          onLoadMore?.call();
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        return itemBuilder(context, items[index], index);
      },
      cacheExtent: 500,
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
    );
  }
}
```

---

## 附录

### A. 设计模式应用

| 模式 | 应用场景 | 说明 |
|------|----------|------|
| 单例模式 | SyncService, CacheManager | 全局唯一实例 |
| 工厂模式 | IntentEngine, PetResponder | 根据类型创建对象 |
| 策略模式 | ConflictResolver | 可切换的冲突解决策略 |
| 观察者模式 | NetworkMonitor, Provider | 状态变化通知 |
| 仓库模式 | LocalRepository, CloudRepository | 数据访问抽象 |
| 依赖注入 | Service层 | 通过构造函数注入依赖 |

### B. 代码规范

1. **命名规范**
   - 类名：大驼峰（PascalCase）
   - 变量/方法：小驼峰（camelCase）
   - 常量：小驼峰 + k前缀（如 kKeywordRules）
   - 私有成员：下划线前缀（如 _repository）

2. **文件组织**
   - 每个文件一个公开类
   - 相关类可放在同一文件，用 `part` 关联
   - 导出文件使用 `export` 语句

3. **注释规范**
   - 公开API必须有文档注释
   - 复杂逻辑必须有行内注释
   - 使用 `///` 进行文档注释

---

**文档结束**

*本文档为《职宠小窝》APP详细设计文档v1.0版，如有变更请及时更新版本号。*
