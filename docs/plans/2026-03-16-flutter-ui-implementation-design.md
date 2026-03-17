# 职宠小窝 Flutter UI 实现设计文档

## 1. 概述

### 1.1 背景
suchAs文件夹包含基于React/TypeScript的UI实现，源自Figma设计。由于技术栈不兼容（React vs Flutter），需要使用Flutter重新实现所有UI组件和页面。

### 1.2 目标
- 将suchAs UI设计完整迁移到Flutter
- 保持视觉一致性和交互体验
- 建立可维护的设计系统
- 实现全部4个核心页面

### 1.3 范围
| 页面 | 功能描述 |
|------|----------|
| 倾诉室 | 宠物互动、情感倾诉、智能回复 |
| 看板 | 求职数据统计、图表展示、勋章墙 |
| 公园 | 社交场景、企鹅互动、许愿树 |
| 岗位聚合馆 | 岗位搜索、卡片展示、详情弹窗 |

---

## 2. 技术架构

### 2.1 整体架构

```
┌─────────────────────────────────────────────────────────┐
│                     Presentation Layer                   │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐   │
│  │ 倾诉室   │ │  看板    │ │  公园    │ │  岗位    │   │
│  │ConfidePage│ │StatsPage│ │ParkPage │ │JobsPage │   │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘   │
├─────────────────────────────────────────────────────────┤
│                     Widget Layer                         │
│  ┌──────────────────────────────────────────────────┐   │
│  │ PetAvatar │ Charts │ GlassContainer │ JobCard   │   │
│  └──────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│                     Core Layer                           │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐               │
│  │  Theme   │ │ Provider │ │ Services │               │
│  └──────────┘ └──────────┘ └──────────┘               │
├─────────────────────────────────────────────────────────┤
│                     Assets Layer                         │
│  ┌──────────────────────────────────────────────────┐   │
│  │ Lottie Animations │ Images │ SVG Assets          │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

### 2.2 目录结构

```
lib/
├── core/
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_typography.dart
│   │   ├── app_spacing.dart
│   │   ├── app_shadows.dart
│   │   ├── app_gradients.dart
│   │   └── app_theme.dart
│   ├── constants/
│   │   └── app_constants.dart
│   └── errors/
│       ├── exceptions.dart
│       └── failures.dart
├── features/
│   ├── confide/
│   │   ├── pages/
│   │   ├── widgets/
│   │   └── services/
│   ├── stats/
│   │   ├── pages/
│   │   └── widgets/
│   ├── park/
│   │   ├── pages/
│   │   └── widgets/
│   └── jobs/
│       ├── pages/
│       └── widgets/
├── shared/
│   ├── widgets/
│   └── utils/
├── routes/
│   ├── app_routes.dart
│   └── route_generator.dart
└── main.dart
```

---

## 3. 设计系统

### 3.1 颜色令牌

```dart
class AppColors {
  // 基础色
  static const Color background = Color(0xFFFFFFFF);
  static const Color foreground = Color(0xFF030213);
  
  // 主色调
  static const Color primary = Color(0xFF030213);
  static const Color primaryForeground = Color(0xFFFFFFFF);
  
  // 次要色
  static const Color secondary = Color(0xFFF5F5FA);
  static const Color secondaryForeground = Color(0xFF030213);
  
  // 强调色
  static const Color accent = Color(0xFFE9EBEF);
  static const Color accentForeground = Color(0xFF030213);
  
  // 语义色
  static const Color destructive = Color(0xFFD4183D);
  static const Color success = Color(0xFF5ABE8A);
  static const Color warning = Color(0xFFF5A840);
  
  // 渐变色
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
  );
  
  // 页面背景渐变
  static const LinearGradient confideBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.45, 1.0],
    colors: [Color(0xFFFFF8EF), Color(0xFFEEF2FF), Color(0xFFF0EBFF)],
  );
}
```

### 3.2 间距系统

```dart
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  
  // 圆角
  static const double radiusSm = 6.0;
  static const double radiusMd = 10.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 999.0;
}
```

### 3.3 阴影效果

```dart
class AppShadows {
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.07),
      blurRadius: 20,
      offset: Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> modalShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 32,
      offset: Offset(0, 20),
    ),
  ];
}
```

### 3.4 毛玻璃效果

```dart
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(AppSpacing.radiusLg),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: (backgroundColor ?? Colors.white).withOpacity(0.65),
            borderRadius: borderRadius ?? BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: Colors.white.withOpacity(0.88),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
```

---

## 4. 页面设计

### 4.1 倾诉室 (ConfidePage)

#### 功能需求
- 宠物形象展示（带动画）
- 用户输入倾诉内容
- 智能回复生成
- 情绪状态反馈

#### 组件结构

```
ConfidePage
├── AnimatedStars          # 背景星星动画
├── ResponseBubble         # 回复气泡（条件显示）
├── PetAvatar              # 宠物头像（Lottie动画）
│   └── SideBubble         # 侧边情绪气泡
├── WaitingHint            # 等待提示文字
└── InputArea              # 输入区域
    ├── TextField          # 文本输入
    └── SendButton         # 发送按钮
```

#### 动画方案
| 动画元素 | 实现方式 | 说明 |
|----------|----------|------|
| 宠物跳动 | Lottie | pet_happy.json / pet_idle.json |
| 星星闪烁 | Flutter原生 | AnimationController + Tween |
| 气泡出现 | Flutter原生 | ScaleTransition + FadeTransition |
| 宠物情绪 | Lottie | 根据回复内容切换动画 |

### 4.2 看板 (StatsPage)

#### 功能需求
- 今日数据统计展示
- 本周行动轨迹图表
- 阶段进度展示
- 勋章墙

#### 组件结构

```
StatsPage
├── Header                 # 渐变头部
│   ├── DateDisplay        # 日期显示
│   └── StatsRow           # 统计数字行
│       └── StatCard       # 单个统计卡片
├── WeeklyChartCard        # 周图表卡片
│   └── AreaChart          # fl_chart面积图
├── ProgressCard           # 进度卡片
│   └── ProgressBar[]      # 进度条列表
└── BadgeWall              # 勋章墙
    └── BadgeCard[]        # 勋章卡片
```

#### 图表配置
```dart
AreaChart(
  data: weekData,
  gradientColors: [Color(0xFF667EEA), Color(0xFF667EEA).withOpacity(0)],
  strokeColor: Color(0xFF667EEA),
  strokeWidth: 2.5,
)
```

### 4.3 公园 (ParkPage)

#### 功能需求
- 公园场景展示
- 区域切换
- 企鹅角色互动
- 许愿树功能

#### 组件结构

```
ParkPage
├── ZoneHeader             # 区域头部
│   ├── ZoneSelector       # 区域下拉选择
│   └── VisitorCount       # 访客数量
├── ParkScene              # 公园场景
│   ├── SkyBackground      # 天空背景
│   ├── Clouds             # 云朵动画
│   ├── Trees              # 树木动画
│   ├── River              # 河流
│   ├── Flowers            # 花朵动画
│   └── BirdAvatars[]      # 企鹅角色
├── WishingTree            # 许愿树
│   └── Envelopes[]        # 信封动画
└── InteractionPanel       # 交互面板（Modal）
```

#### 企鹅SVG组件
```dart
class PenguinSVG extends StatelessWidget {
  final Color color;
  final String accessory; // tie, glasses, bow, hardhat, crown
  final double size;
  
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 1.15),
      painter: PenguinPainter(color: color, accessory: accessory),
    );
  }
}
```

### 4.4 岗位聚合馆 (JobsPage)

#### 功能需求
- 岗位搜索过滤
- 岗位卡片列表
- 分类标签筛选
- 详情弹窗

#### 组件结构

```
JobsPage
├── Header                 # 头部
│   ├── Title              # 标题
│   └── FilterButton       # 筛选按钮
├── SearchBar              # 搜索栏
├── CategoryPills          # 分类标签
├── ResultsCount           # 结果数量
├── JobCardList            # 岗位卡片列表
│   └── JobCard[]          # 单个岗位卡片
│       ├── Badges         # NEW/急招标签
│       ├── Title          # 职位名称
│       ├── Salary         # 薪资
│       ├── Company        # 公司信息
│       ├── Tags           # 福利标签
│       └── DetailButton   # 查看详情按钮
├── FishingBird            # 钓鱼鸟动画
└── JobDetailSheet         # 详情弹窗（Modal）
```

---

## 5. 动画策略

### 5.1 Lottie动画清单

| 动画名称 | 文件名 | 用途 | 页面 |
|----------|--------|------|------|
| 宠物待机 | pet_idle.json | 默认状态 | 倾诉室 |
| 宠物开心 | pet_happy.json | 收到消息后 | 倾诉室 |
| 宠物跳动 | pet_jump.json | 互动反馈 | 倾诉室 |
| 气泡浮动 | bubble_float.json | 背景装饰 | 倾诉室 |
| 信封发光 | envelope_glow.json | 许愿树 | 公园 |
| 钓鱼动画 | fishing.json | 底部装饰 | 岗位 |

### 5.2 Flutter原生动画

| 动画类型 | 实现方式 | 用途 |
|----------|----------|------|
| 星星闪烁 | AnimationController + Tween | 背景装饰 |
| 云朵飘动 | AnimatedPositioned | 公园场景 |
| 树木摇摆 | RotationTransition | 公园场景 |
| 数字滚动 | AnimatedBuilder | 统计数字 |
| 进度条填充 | AnimatedContainer | 进度展示 |
| 卡片入场 | SlideTransition + FadeTransition | 列表项 |

---

## 6. 依赖管理

### 6.1 新增依赖

```yaml
dependencies:
  # 动画
  lottie: ^3.1.0
  flutter_animate: ^4.3.0
  
  # 图表
  fl_chart: ^0.66.0
  
  # SVG
  flutter_svg: ^2.0.9
```

### 6.2 依赖用途说明

| 依赖包 | 用途 | 必要性 |
|--------|------|--------|
| lottie | Lottie动画播放 | 高 |
| flutter_animate | 简化动画编写 | 中 |
| fl_chart | 图表展示 | 高 |
| flutter_svg | SVG图形渲染 | 高 |

---

## 7. 实现计划

### 7.1 阶段划分

| 阶段 | 内容 | 预计工时 |
|------|------|----------|
| Phase 1 | 设计系统 + 基础框架 | 1天 |
| Phase 2 | 倾诉室页面 | 2天 |
| Phase 3 | 看板页面 | 2天 |
| Phase 4 | 公园页面 | 2.5天 |
| Phase 5 | 岗位页面 | 2天 |
| Phase 6 | 优化和测试 | 1天 |

### 7.2 里程碑

- **M1**: 设计系统完成，可运行空壳应用
- **M2**: 倾诉室功能完整，宠物互动正常
- **M3**: 看板数据展示正常，图表可交互
- **M4**: 公园场景完整，角色可互动
- **M5**: 岗位搜索和详情功能完整
- **M6**: 全部功能测试通过，可发布

---

## 8. 风险与缓解

| 风险 | 等级 | 缓解措施 |
|------|------|----------|
| Lottie动画资源缺失 | 中 | 使用占位图片，后续替换 |
| SVG渲染性能 | 低 | 使用flutter_svg优化配置 |
| 图表交互复杂度 | 中 | 简化交互，保留核心功能 |
| 毛玻璃效果性能 | 中 | 提供降级方案 |

---

## 9. 验收标准

### 9.1 视觉一致性
- [ ] 颜色与设计稿一致
- [ ] 字体大小和行高正确
- [ ] 间距符合设计规范
- [ ] 圆角和阴影效果正确

### 9.2 功能完整性
- [ ] 倾诉室：输入、回复、动画正常
- [ ] 看板：图表、进度、勋章正常
- [ ] 公园：场景、互动、许愿正常
- [ ] 岗位：搜索、筛选、详情正常

### 9.3 性能指标
- [ ] 页面切换流畅（<300ms）
- [ ] 动画帧率稳定（>55fps）
- [ ] 内存占用合理（<150MB）

---

## 10. 附录

### 10.1 参考资源
- suchAs UI源码：`e:\GuguPet\suchAs\`
- 产品文档：`e:\GuguPet\docs\《职宠小窝》APP 产品全案（V3.1 迭代修订版）.markdown`

### 10.2 相关文档
- SRS_职宠小窝_v1.0.md
- DDD_职宠小窝_v1.0.md
- API_职宠小窝_v1.0.md
