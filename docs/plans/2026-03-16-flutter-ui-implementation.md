# Flutter UI Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 将suchAs UI设计完整迁移到Flutter，实现全部4个核心页面（倾诉室、看板、公园、岗位聚合馆）

**Architecture:** 采用Feature-First架构，建立独立设计系统模块，使用Lottie处理核心动效，Flutter原生动画处理辅助动效，fl_chart实现图表功能

**Tech Stack:** Flutter 3.10+, Dart, Provider, Lottie, fl_chart, flutter_svg, flutter_animate

---

## Phase 1: 设计系统与基础框架

### Task 1.1: 创建颜色令牌

**Files:**
- Create: `lib/core/theme/app_colors.dart`

**Step 1: 创建颜色令牌文件**

```dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color background = Color(0xFFFFFFFF);
  static const Color foreground = Color(0xFF030213);

  static const Color primary = Color(0xFF030213);
  static const Color primaryForeground = Color(0xFFFFFFFF);

  static const Color secondary = Color(0xFFF5F5FA);
  static const Color secondaryForeground = Color(0xFF030213);

  static const Color muted = Color(0xFFECECF0);
  static const Color mutedForeground = Color(0xFF717182);

  static const Color accent = Color(0xFFE9EBEF);
  static const Color accentForeground = Color(0xFF030213);

  static const Color destructive = Color(0xFFD4183D);
  static const Color destructiveForeground = Color(0xFFFFFFFF);

  static const Color border = Color(0x1A000000);
  static const Color input = Colors.transparent;
  static const Color inputBackground = Color(0xFFF3F3F5);

  static const Color success = Color(0xFF5ABE8A);
  static const Color warning = Color(0xFFF5A840);
  static const Color info = Color(0xFF5A8AE8);

  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color divider = Color(0x0F000000);

  static const Color indigo500 = Color(0xFF667EEA);
  static const Color purple500 = Color(0xFF764BA2);
  static const Color indigo200 = Color(0xFFB8B8E8);
  static const Color purple200 = Color(0xFFC8C0E8);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [indigo500, purple500],
  );

  static const LinearGradient confideBackground = LinearGradient(
    begin: Alignment(-1, -1),
    end: Alignment(1, 1),
    stops: [0.0, 0.45, 1.0],
    colors: [
      Color(0xFFFFF8EF),
      Color(0xFFEEF2FF),
      Color(0xFFF0EBFF),
    ],
  );

  static const LinearGradient statsHeaderGradient = LinearGradient(
    begin: Alignment(-0.5, -1),
    end: Alignment(0.5, 1),
    colors: [indigo500, purple500],
  );
}
```

**Step 2: 验证文件创建**

Run: `flutter analyze lib/core/theme/app_colors.dart`
Expected: No issues found

---

### Task 1.2: 创建间距系统

**Files:**
- Create: `lib/core/theme/app_spacing.dart`

**Step 1: 创建间距系统文件**

```dart
class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  static const double radiusSm = 6.0;
  static const double radiusMd = 10.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radius2xl = 32.0;
  static const double radius3xl = 44.0;
  static const double radiusFull = 999.0;

  static const double iconXs = 12.0;
  static const double iconSm = 16.0;
  static const double iconMd = 20.0;
  static const double iconLg = 24.0;
  static const double iconXl = 32.0;

  static const double buttonHeightSm = 32.0;
  static const double buttonHeightMd = 40.0;
  static const double buttonHeightLg = 48.0;

  static const double inputHeight = 48.0;
  static const double navBarHeight = 64.0;
  static const double appBarHeight = 56.0;
}
```

**Step 2: 验证文件创建**

Run: `flutter analyze lib/core/theme/app_spacing.dart`
Expected: No issues found

---

### Task 1.3: 创建字体规范

**Files:**
- Create: `lib/core/theme/app_typography.dart`

**Step 1: 创建字体规范文件**

```dart
import 'package:flutter/material.dart';

class AppTypography {
  AppTypography._();

  static const String fontFamily = 'PingFang SC';

  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 0,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: 0,
  );

  static const TextStyle headingLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0,
  );
}
```

**Step 2: 验证文件创建**

Run: `flutter analyze lib/core/theme/app_typography.dart`
Expected: No issues found

---

### Task 1.4: 创建阴影效果

**Files:**
- Create: `lib/core/theme/app_shadows.dart`

**Step 1: 创建阴影效果文件**

```dart
import 'package:flutter/material.dart';

class AppShadows {
  AppShadows._();

  static List<BoxShadow> get card => [
        BoxShadow(
          color: Colors.black.withOpacity(0.07),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get cardHover => [
        BoxShadow(
          color: Colors.black.withOpacity(0.12),
          blurRadius: 28,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get modal => [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 32,
          offset: const Offset(0, 20),
        ),
      ];

  static List<BoxShadow> get button => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 12,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get input => [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 12,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get floating => [
        BoxShadow(
          color: Colors.black.withOpacity(0.28),
          blurRadius: 80,
          offset: const Offset(0, 32),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 1,
          offset: const Offset(0, 0),
        ),
      ];

  static List<BoxShadow> get bubble => [
        BoxShadow(
          color: const Color(0xFF6450C8).withOpacity(0.1),
          blurRadius: 32,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get petGlow => [
        BoxShadow(
          color: const Color(0xFF6450C8).withOpacity(0.18),
          blurRadius: 28,
          offset: const Offset(0, 12),
        ),
      ];
}
```

**Step 2: 验证文件创建**

Run: `flutter analyze lib/core/theme/app_shadows.dart`
Expected: No issues found

---

### Task 1.5: 创建主题整合文件

**Files:**
- Create: `lib/core/theme/app_theme.dart`

**Step 1: 创建主题整合文件**

```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.light(
          primary: AppColors.primary,
          onPrimary: AppColors.primaryForeground,
          secondary: AppColors.secondary,
          onSecondary: AppColors.secondaryForeground,
          surface: AppColors.background,
          onSurface: AppColors.foreground,
          error: AppColors.destructive,
          onError: AppColors.destructiveForeground,
        ),
        scaffoldBackgroundColor: AppColors.background,
        textTheme: const TextTheme(
          displayLarge: AppTypography.displayLarge,
          displayMedium: AppTypography.displayMedium,
          headlineLarge: AppTypography.headingLarge,
          headlineMedium: AppTypography.headingMedium,
          headlineSmall: AppTypography.headingSmall,
          bodyLarge: AppTypography.bodyLarge,
          bodyMedium: AppTypography.bodyMedium,
          bodySmall: AppTypography.bodySmall,
          labelLarge: AppTypography.labelLarge,
          labelMedium: AppTypography.labelMedium,
          labelSmall: AppTypography.labelSmall,
        ),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.foreground,
        ),
        cardTheme: CardTheme(
          color: AppColors.cardBackground,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.inputBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: const BorderSide(color: AppColors.indigo500, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.primaryForeground,
            minimumSize: const Size(double.infinity, AppSpacing.buttonHeightMd),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.divider,
          thickness: 1,
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: AppColors.primaryForeground,
          onPrimary: AppColors.primary,
          secondary: AppColors.secondary,
          onSecondary: AppColors.secondaryForeground,
          surface: const Color(0xFF1A1A2E),
          onSurface: AppColors.primaryForeground,
          error: AppColors.destructive,
          onError: AppColors.destructiveForeground,
        ),
        scaffoldBackgroundColor: const Color(0xFF1A1A2E),
        textTheme: const TextTheme(
          displayLarge: AppTypography.displayLarge.copyWith(color: Colors.white),
          displayMedium: AppTypography.displayMedium.copyWith(color: Colors.white),
          headlineLarge: AppTypography.headingLarge.copyWith(color: Colors.white),
          headlineMedium: AppTypography.headingMedium.copyWith(color: Colors.white),
          headlineSmall: AppTypography.headingSmall.copyWith(color: Colors.white),
          bodyLarge: AppTypography.bodyLarge.copyWith(color: Colors.white70),
          bodyMedium: AppTypography.bodyMedium.copyWith(color: Colors.white70),
          bodySmall: AppTypography.bodySmall.copyWith(color: Colors.white60),
          labelLarge: AppTypography.labelLarge.copyWith(color: Colors.white),
          labelMedium: AppTypography.labelMedium.copyWith(color: Colors.white),
          labelSmall: AppTypography.labelSmall.copyWith(color: Colors.white),
        ),
      );
}
```

**Step 2: 验证文件创建**

Run: `flutter analyze lib/core/theme/app_theme.dart`
Expected: No issues found

---

### Task 1.6: 创建主题导出文件

**Files:**
- Create: `lib/core/theme/theme.dart`

**Step 1: 创建导出文件**

```dart
export 'app_colors.dart';
export 'app_spacing.dart';
export 'app_typography.dart';
export 'app_shadows.dart';
export 'app_theme.dart';
```

**Step 2: 验证文件创建**

Run: `flutter analyze lib/core/theme/theme.dart`
Expected: No issues found

---

### Task 1.7: 更新pubspec.yaml添加依赖

**Files:**
- Modify: `app/pubspec.yaml`

**Step 1: 添加新依赖**

在dependencies部分添加：

```yaml
dependencies:
  flutter:
    sdk: flutter

  cupertino_icons: ^1.0.8
  provider: ^6.1.1
  sqflite: ^2.3.2
  path: ^1.9.0
  dio: ^5.4.0
  lottie: ^3.1.0
  shared_preferences: ^2.2.2
  sensors_plus: ^4.0.2
  cached_network_image: ^3.3.1
  path_provider: ^2.1.2
  intl: ^0.19.0
  logger: ^2.0.2
  fl_chart: ^0.66.0
  flutter_svg: ^2.0.9
  flutter_animate: ^4.3.0
```

**Step 2: 安装依赖**

Run: `cd app && flutter pub get`
Expected: Dependencies resolved successfully

---

### Task 1.8: 更新main.dart使用新主题

**Files:**
- Modify: `app/lib/main.dart`

**Step 1: 更新main.dart**

```dart
import 'package:flutter/material.dart';
import 'core/theme/theme.dart';
import 'routes/app_routes.dart';
import 'routes/route_generator.dart';

void main() {
  runApp(const JobPetApp());
}

class JobPetApp extends StatelessWidget {
  const JobPetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '职宠小窝',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.home,
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
```

**Step 2: 验证应用运行**

Run: `cd app && flutter run -d windows`
Expected: App launches with new theme

---

## Phase 2: 共享组件

### Task 2.1: 创建毛玻璃容器组件

**Files:**
- Create: `lib/shared/widgets/glass_container.dart`

**Step 1: 创建毛玻璃容器**

```dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Border? border;
  final List<BoxShadow>? boxShadow;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 24.0,
    this.backgroundColor,
    this.borderRadius,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.border,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppSpacing.radiusXl);

    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: (backgroundColor ?? Colors.white).withOpacity(0.65),
              borderRadius: radius,
              border: border ??
                  Border.all(
                    color: Colors.white.withOpacity(0.88),
                    width: 1.5,
                  ),
              boxShadow: boxShadow ?? AppShadows.bubble,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
```

**Step 2: 验证文件创建**

Run: `flutter analyze lib/shared/widgets/glass_container.dart`
Expected: No issues found

---

### Task 2.2: 创建动画星星组件

**Files:**
- Create: `lib/shared/widgets/animated_star.dart`

**Step 1: 创建动画星星**

```dart
import 'package:flutter/material.dart';

class AnimatedStar extends StatefulWidget {
  final double left;
  final double top;
  final Duration delay;
  final String symbol;

  const AnimatedStar({
    super.key,
    required this.left,
    required this.top,
    required this.delay,
    this.symbol = '✦',
  });

  @override
  State<AnimatedStar> createState() => _AnimatedStarState();
}

class _AnimatedStarState extends State<AnimatedStar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.3, end: 0.9), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 0.3), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.8, end: 1.2), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 0.8), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.repeat();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.left,
      top: widget.top,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Text(
                widget.symbol,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFFB8B8E8),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
```

**Step 2: 验证文件创建**

Run: `flutter analyze lib/shared/widgets/animated_star.dart`
Expected: No issues found

---

### Task 2.3: 创建底部导航栏组件

**Files:**
- Create: `lib/shared/widgets/app_bottom_nav_bar.dart`

**Step 1: 创建底部导航栏**

```dart
import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

class NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavItem> items;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSpacing.navBarHeight,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -1),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: Colors.black.withOpacity(0.07),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isActive = index == currentIndex;

          return Expanded(
            child: InkWell(
              onTap: () => onTap(index),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isActive ? item.activeIcon : item.icon,
                    size: 22,
                    color: isActive ? AppColors.indigo500 : AppColors.mutedForeground,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      color: isActive ? AppColors.indigo500 : AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
```

**Step 2: 验证文件创建**

Run: `flutter analyze lib/shared/widgets/app_bottom_nav_bar.dart`
Expected: No issues found

---

### Task 2.4: 创建共享组件导出文件

**Files:**
- Create: `lib/shared/widgets/widgets.dart`

**Step 1: 创建导出文件**

```dart
export 'glass_container.dart';
export 'animated_star.dart';
export 'app_bottom_nav_bar.dart';
```

**Step 2: 验证文件创建**

Run: `flutter analyze lib/shared/widgets/widgets.dart`
Expected: No issues found

---

## Phase 3: 倾诉室页面

### Task 3.1: 创建回复服务

**Files:**
- Create: `lib/features/confide/services/response_service.dart`

**Step 1: 创建回复服务**

```dart
class ResponsePattern {
  final RegExp pattern;
  final String text;

  const ResponsePattern({required this.pattern, required this.text});
}

class ResponseService {
  static const List<ResponsePattern> _patterns = [
    ResponsePattern(
      pattern: RegExp(r'累|疲|倦|撑|崩|烦|难|苦|压力'),
      text: '累了就歇歇，你已经很努力了 🤍 轻轻抱抱你~',
    ),
    ResponsePattern(
      pattern: RegExp(r'面试|hr|HR|笔试|offer|Offer|OFFER'),
      text: '面试官看到你一定会心动的！咕咕为你加油 ✨',
    ),
    ResponsePattern(
      pattern: RegExp(r'拒|没过|挂|凉|凉凉|拒绝|失败'),
      text: '他们眼光有问题！你是最棒的，咕咕最喜欢你 🫂',
    ),
    ResponsePattern(
      pattern: RegExp(r'开心|高兴|棒|好消息|发|拿到|通过|过了'),
      text: '太好了！咕咕也为你感到超级开心~ 🎉🎊',
    ),
    ResponsePattern(
      pattern: RegExp(r'不知道|迷茫|迷失|找不到|方向'),
      text: '迷茫也没关系，每一步都算数的，我一直陪着你 🌟',
    ),
  ];

  static const List<String> _defaultResponses = [
    '嗯嗯，我都听到了，说出来感觉好一点了吗？ 🐧',
    '你已经很棒了，不管怎样咕咕都支持你 ✨',
    '今天的委屈，明天变成铠甲，加油！',
    '咕咕在这里，轻轻抱抱你 🤍',
  ];

  String getResponse(String input) {
    for (final pattern in _patterns) {
      if (pattern.pattern.hasMatch(input)) {
        return pattern.text;
      }
    }
    return _defaultResponses[DateTime.now().millisecondsSinceEpoch % _defaultResponses.length];
  }
}
```

**Step 2: 验证文件创建**

Run: `flutter analyze lib/features/confide/services/response_service.dart`
Expected: No issues found

---

### Task 3.2: 创建回复气泡组件

**Files:**
- Create: `lib/features/confide/widgets/response_bubble.dart`

**Step 1: 创建回复气泡**

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class ResponseBubble extends StatelessWidget {
  final String text;
  final Animation<double> animation;

  const ResponseBubble({
    super.key,
    required this.text,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.85, end: 1.0).animate(
        CurvedAnimation(parent: animation, curve: Curves.elasticOut),
      ),
      child: FadeTransition(
        opacity: animation,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 280),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.82),
            borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
            border: Border.all(color: Colors.white.withOpacity(0.9), width: 1),
            boxShadow: AppShadows.bubble,
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: const Color(0xFF5A5A7A),
              height: 1.7,
            ),
          ),
        ),
      ),
    );
  }
}
```

**Step 2: 验证文件创建**

Run: `flutter analyze lib/features/confide/widgets/response_bubble.dart`
Expected: No issues found

---

### Task 3.3: 创建输入区域组件

**Files:**
- Create: `lib/features/confide/widgets/input_area.dart`

**Step 1: 创建输入区域**

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/widgets/widgets.dart';

class InputArea extends StatefulWidget {
  final Function(String) onSubmit;

  const InputArea({super.key, required this.onSubmit});

  @override
  State<InputArea> createState() => _InputAreaState();
}

class _InputAreaState extends State<InputArea> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_controller.text.trim().isNotEmpty) {
      widget.onSubmit(_controller.text.trim());
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '此刻想对咕咕说点什么？',
          style: AppTypography.labelSmall.copyWith(
            color: const Color(0xFFB8B0D0),
            letterSpacing: 0.05,
          ),
        ),
        const SizedBox(height: 8),
        GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          borderRadius: BorderRadius.circular(AppSpacing.radius3xl),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: AppTypography.bodyMedium.copyWith(
                    color: const Color(0xFF5A5A7A),
                  ),
                  decoration: InputDecoration(
                    hintText: '今天又投了5份简历，有点累了...',
                    hintStyle: AppTypography.bodyMedium.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onSubmitted: (_) => _handleSubmit(),
                ),
              ),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _controller,
                builder: (context, value, child) {
                  if (value.text.trim().isEmpty) return const SizedBox.shrink();
                  return GestureDetector(
                    onTap: _handleSubmit,
                    child: const Text('🕊️', style: TextStyle(fontSize: 20)),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
```

**Step 2: 验证文件创建**

Run: `flutter analyze lib/features/confide/widgets/input_area.dart`
Expected: No issues found

---

### Task 3.4: 创建宠物头像组件

**Files:**
- Create: `lib/features/confide/widgets/pet_avatar.dart`

**Step 1: 创建宠物头像**

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

enum PetState { idle, happy }

class PetAvatar extends StatefulWidget {
  final PetState state;
  final double size;

  const PetAvatar({
    super.key,
    this.state = PetState.idle,
    this.size = 210,
  });

  @override
  State<PetAvatar> createState() => _PetAvatarState();
}

class _PetAvatarState extends State<PetAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _yAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: widget.state == PetState.happy ? 1800 : 3500,
      ),
    );

    if (widget.state == PetState.happy) {
      _yAnimation = TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 0, end: -22), weight: 1),
        TweenSequenceItem(tween: Tween(begin: -22, end: -8), weight: 1),
        TweenSequenceItem(tween: Tween(begin: -8, end: -18), weight: 1),
        TweenSequenceItem(tween: Tween(begin: -18, end: 0), weight: 1),
      ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

      _rotateAnimation = TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 0, end: -0.03), weight: 1),
        TweenSequenceItem(tween: Tween(begin: -0.03, end: 0.05), weight: 1),
        TweenSequenceItem(tween: Tween(begin: 0.05, end: -0.05), weight: 1),
        TweenSequenceItem(tween: Tween(begin: -0.05, end: 0), weight: 1),
      ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    } else {
      _yAnimation = TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 1),
        TweenSequenceItem(tween: Tween(begin: -10, end: 0), weight: 1),
      ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

      _rotateAnimation = TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: -0.026, end: 0.026), weight: 1),
        TweenSequenceItem(tween: Tween(begin: 0.026, end: -0.026), weight: 1),
      ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    }

    _controller.repeat();
  }

  @override
  void didUpdateWidget(PetAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _controller.dispose();
      _controller = AnimationController(
        vsync: this,
        duration: Duration(
          milliseconds: widget.state == PetState.happy ? 1800 : 3500,
        ),
      );
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _yAnimation.value),
          child: Transform.rotate(
            angle: _rotateAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: AppShadows.petGlow,
              ),
              child: Image.asset(
                'assets/images/bird_default.png',
                width: widget.size,
                height: widget.size,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      color: AppColors.indigo200,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('🐦', style: TextStyle(fontSize: 64)),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
```

**Step 2: 验证文件创建**

Run: `flutter analyze lib/features/confide/widgets/pet_avatar.dart`
Expected: No issues found

---

### Task 3.5: 创建倾诉室页面

**Files:**
- Create: `lib/features/confide/pages/confide_page.dart`

**Step 1: 创建倾诉室页面**

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../widgets/pet_avatar.dart';
import '../widgets/response_bubble.dart';
import '../widgets/input_area.dart';
import '../services/response_service.dart';

class ConfidePage extends StatefulWidget {
  const ConfidePage({super.key});

  @override
  State<ConfidePage> createState() => _ConfidePageState();
}

class _ConfidePageState extends State<ConfidePage>
    with TickerProviderStateMixin {
  final _responseService = ResponseService();
  String _response = '';
  bool _showResponse = false;
  PetState _petState = PetState.idle;
  int _messageCount = 0;
  late AnimationController _responseController;

  @override
  void initState() {
    super.initState();
    _responseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  void _handleSubmit(String input) {
    setState(() {
      _response = _responseService.getResponse(input);
      _showResponse = true;
      _petState = PetState.happy;
      _messageCount++;
    });
    _responseController.forward(from: 0);

    Future.delayed(const Duration(milliseconds: 5500), () {
      if (mounted) {
        setState(() {
          _showResponse = false;
          _petState = PetState.idle;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.confideBackground),
      child: Stack(
        children: [
          ..._buildStars(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _buildContent(),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: InputArea(onSubmit: _handleSubmit),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 8),
      child: Center(
        child: Text(
          '职宠小窝',
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.mutedForeground,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_showResponse)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: ResponseBubble(
              text: _response,
              animation: _responseController,
            ),
          ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            PetAvatar(state: _petState),
            Positioned(
              right: -18,
              top: 28,
              child: _buildSideBubble(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (!_showResponse)
          Text(
            _messageCount == 0
                ? '咕咕在等你倾诉...'
                : '已倾诉 $_messageCount 次，咕咕一直在 ♡',
            style: AppTypography.caption.copyWith(
              color: const Color(0xFFBBB0D0),
            ),
          ),
      ],
    );
  }

  Widget _buildSideBubble() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.75),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.95), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6450C8).withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          _petState == PetState.happy ? '🥰' : '🫂',
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  List<Widget> _buildStars() {
    return const [
      AnimatedStar(left: 0.12, top: 0.08, delay: Duration.zero),
      AnimatedStar(left: 0.82, top: 0.06, delay: Duration(milliseconds: 500)),
      AnimatedStar(left: 0.88, top: 0.18, delay: Duration(seconds: 1)),
      AnimatedStar(left: 0.08, top: 0.22, delay: Duration(milliseconds: 1500)),
      AnimatedStar(left: 0.92, top: 0.30, delay: Duration(milliseconds: 800)),
      AnimatedStar(left: 0.05, top: 0.35, delay: Duration(milliseconds: 1200)),
    ].map((star) {
      return Positioned(
        left: star.left * MediaQuery.of(context).size.width,
        top: star.top * MediaQuery.of(context).size.height,
        child: AnimatedStar(
          left: 0,
          top: 0,
          delay: star.delay,
        ),
      );
    }).toList();
  }
}
```

**Step 2: 验证文件创建**

Run: `flutter analyze lib/features/confide/pages/confide_page.dart`
Expected: No issues found

---

## Phase 4: 主页面框架更新

### Task 4.1: 更新home_page.dart

**Files:**
- Modify: `app/lib/pages/home/home_page.dart`

**Step 1: 更新主页面**

```dart
import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';
import '../../features/confide/pages/confide_page.dart';
import '../../features/stats/pages/stats_page.dart';
import '../../features/park/pages/park_page.dart';
import '../../features/jobs/pages/jobs_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    ConfidePage(),
    StatsPage(),
    ParkPage(),
    JobsPage(),
    ProfilePage(),
  ];

  final List<NavItem> _navItems = const [
    NavItem(label: '倾诉室', icon: Icons.pets_outlined, activeIcon: Icons.pets),
    NavItem(label: '看板', icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart),
    NavItem(label: '公园', icon: Icons.park_outlined, activeIcon: Icons.park),
    NavItem(label: '岗位', icon: Icons.work_outline, activeIcon: Icons.work),
    NavItem(label: '我的', icon: Icons.person_outline, activeIcon: Icons.person),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: _navItems,
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('个人中心 - 开发中'),
    );
  }
}
```

**Step 2: 验证应用运行**

Run: `cd app && flutter run -d windows`
Expected: App shows confide page with navigation

---

## Phase 5: 看板页面

### Task 5.1: 创建统计卡片组件

**Files:**
- Create: `lib/features/stats/widgets/stat_card.dart`

**Step 1: 创建统计卡片**

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class StatCard extends StatelessWidget {
  final String label;
  final int value;
  final String unit;
  final Color backgroundColor;
  final Color borderColor;
  final Duration animationDuration;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.backgroundColor,
    required this.borderColor,
    this.animationDuration = const Duration(milliseconds: 1200),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        children: [
          _AnimatedNumber(
            target: value,
            duration: animationDuration,
            style: AppTypography.headingLarge.copyWith(
              color: Colors.white,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedNumber extends StatefulWidget {
  final int target;
  final Duration duration;
  final TextStyle? style;

  const _AnimatedNumber({
    required this.target,
    required this.duration,
    this.style,
  });

  @override
  State<_AnimatedNumber> createState() => _AnimatedNumberState();
}

class _AnimatedNumberState extends State<_AnimatedNumber> {
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _animate();
  }

  void _animate() {
    final start = DateTime.now();
    final tick = () {
      final elapsed = DateTime.now().difference(start).inMilliseconds;
      final progress = (elapsed / widget.duration.inMilliseconds).clamp(0.0, 1.0);
      final eased = 1 - (1 - progress) * (1 - progress) * (1 - progress);
      setState(() => _current = (eased * widget.target).round());
      if (progress < 1) {
        WidgetsBinding.instance.addPostFrameCallback((_) => tick());
      }
    };
    tick();
  }

  @override
  Widget build(BuildContext context) {
    return Text('$_current', style: widget.style);
  }
}
```

**Step 2: 验证文件创建**

Run: `flutter analyze lib/features/stats/widgets/stat_card.dart`
Expected: No issues found

---

### Task 5.2: 创建周图表组件

**Files:**
- Create: `lib/features/stats/widgets/weekly_chart.dart`

**Step 1: 创建周图表**

```dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class WeeklyChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const WeeklyChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2.5,
      child: AreaChart(
        AreaChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= data.length) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      data[value.toInt()]['day'],
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFFC0C0D0),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            AreaChartBarData(
              spots: data.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value['submissions'].toDouble());
              }).toList(),
              isCurved: true,
              color: AppColors.indigo500,
              barWidth: 2.5,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: AppColors.indigo500,
                    strokeWidth: 0,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.indigo500.withOpacity(0.35),
                    AppColors.indigo500.withOpacity(0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Step 2: 验证文件创建**

Run: `flutter analyze lib/features/stats/widgets/weekly_chart.dart`
Expected: No issues found

---

### Task 5.3: 创建看板页面

**Files:**
- Create: `lib/features/stats/pages/stats_page.dart`

**Step 1: 创建看板页面**

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../widgets/stat_card.dart';
import '../widgets/weekly_chart.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  static const _weekData = [
    {'day': '周一', 'submissions': 8, 'interviews': 1},
    {'day': '周二', 'submissions': 12, 'interviews': 2},
    {'day': '周三', 'submissions': 5, 'interviews': 0},
    {'day': '周四', 'submissions': 15, 'interviews': 3},
    {'day': '周五', 'submissions': 9, 'interviews': 1},
    {'day': '周六', 'submissions': 3, 'interviews': 0},
    {'day': '周日', 'submissions': 12, 'interviews': 2},
  ];

  static const _badges = [
    {'name': '百折不挠', 'desc': '累计投递100份', 'emoji': '💪', 'unlocked': true},
    {'name': '面试达人', 'desc': '完成10次面试', 'emoji': '🎯', 'unlocked': true},
    {'name': '社交蝴蝶', 'desc': '公园结交5位好友', 'emoji': '🦋', 'unlocked': false},
    {'name': 'Offer猎手', 'desc': '斩获3个Offer', 'emoji': '🏆', 'unlocked': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF7F8FC),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildChartCard(),
            const SizedBox(height: 16),
            _buildProgressCard(),
            const SizedBox(height: 16),
            _buildBadgeWall(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
      decoration: const BoxDecoration(gradient: AppColors.statsHeaderGradient),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '今日战报',
            style: AppTypography.labelSmall.copyWith(
              color: Colors.white70,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '坚持就是胜利 ✨',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: '投递数',
                  value: 128,
                  unit: '份',
                  backgroundColor: const Color(0xFFFFB478).withOpacity(0.25),
                  borderColor: const Color(0xFFFFA050).withOpacity(0.4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  label: '面试数',
                  value: 14,
                  unit: '次',
                  backgroundColor: const Color(0xFFA0D2F0).withOpacity(0.25),
                  borderColor: const Color(0xFF78BEE6).withOpacity(0.4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  label: 'Offer数',
                  value: 2,
                  unit: '个',
                  backgroundColor: const Color(0xFFA0DCA0).withOpacity(0.25),
                  borderColor: const Color(0xFF78C878).withOpacity(0.4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '本周行动轨迹',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '持续输出，好运自来',
                    style: AppTypography.caption.copyWith(color: AppColors.mutedForeground),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Text(
                  '近7天',
                  style: AppTypography.labelSmall.copyWith(color: AppColors.indigo500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          WeeklyChart(data: _weekData),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('阶段进度', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          _buildProgressBar('简历投递', 128, 200, const Color(0xFFF5A87A)),
          const SizedBox(height: 12),
          _buildProgressBar('面试通过', 14, 20, const Color(0xFF7AB8E8)),
          const SizedBox(height: 12),
          _buildProgressBar('Offer目标', 2, 3, const Color(0xFF7ACA7A)),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, int current, int target, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTypography.bodySmall),
            Text('$current / $target', style: AppTypography.caption.copyWith(color: AppColors.mutedForeground)),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F6),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: (current / target).clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeWall() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('我的勋章墙', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              Text('2/4 已解锁', style: AppTypography.caption.copyWith(color: AppColors.mutedForeground)),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
            ),
            itemCount: _badges.length,
            itemBuilder: (context, index) => _buildBadgeCard(_badges[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeCard(Map<String, dynamic> badge) {
    final unlocked = badge['unlocked'] as bool;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: unlocked ? const Color(0xFFF5C5A0).withOpacity(0.2) : const Color(0xFFF5F5F8),
        borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
        border: Border.all(
          color: unlocked ? const Color(0xFFF5C5A0) : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(badge['emoji'], style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            badge['name'],
            style: AppTypography.labelMedium.copyWith(
              color: unlocked ? const Color(0xFF3A3A5A) : AppColors.mutedForeground,
            ),
          ),
          Text(
            badge['desc'],
            style: AppTypography.caption.copyWith(color: AppColors.mutedForeground),
          ),
        ],
      ),
    );
  }
}
```

**Step 2: 验证文件创建**

Run: `flutter analyze lib/features/stats/pages/stats_page.dart`
Expected: No issues found

---

## Phase 6: 公园页面

### Task 6.1: 创建企鹅SVG组件

**Files:**
- Create: `lib/features/park/widgets/penguin_svg.dart`

**Step 1: 创建企鹅SVG**

```dart
import 'package:flutter/material.dart';

class PenguinSvg extends StatelessWidget {
  final Color color;
  final String accessory;
  final double size;

  const PenguinSvg({
    super.key,
    this.color = const Color(0xFF4A4A6A),
    this.accessory = 'none',
    this.size = 70,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 1.15),
      painter: _PenguinPainter(color: color, accessory: accessory),
    );
  }
}

class _PenguinPainter extends CustomPainter {
  final Color color;
  final String accessory;

  _PenguinPainter({required this.color, required this.accessory});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final scale = size.width / 60;

    canvas.save();
    canvas.scale(scale, scale);

    // Wings
    paint.color = color;
    canvas.save();
    canvas.translate(10, 42);
    canvas.rotate(-0.35);
    canvas.drawOval(const Rect.fromLTWH(-8, -13, 16, 26), paint);
    canvas.restore();

    canvas.save();
    canvas.translate(50, 42);
    canvas.rotate(0.35);
    canvas.drawOval(const Rect.fromLTWH(-8, -13, 16, 26), paint);
    canvas.restore();

    // Body
    canvas.drawOval(const Rect.fromLTWH(12, 26, 36, 40), paint);

    // Belly
    paint.color = const Color(0xFFF5F5F5);
    canvas.drawOval(const Rect.fromLTWH(19, 36, 22, 28), paint);

    // Head
    paint.color = color;
    canvas.drawCircle(const Offset(30, 21), 16, paint);

    // Eye whites
    paint.color = Colors.white;
    canvas.drawCircle(const Offset(23.5, 18), 5, paint);
    canvas.drawCircle(const Offset(36.5, 18), 5, paint);

    // Pupils
    paint.color = const Color(0xFF1A1A2E);
    canvas.drawCircle(const Offset(24.5, 19), 3, paint);
    canvas.drawCircle(const Offset(37.5, 19), 3, paint);

    // Eye shine
    paint.color = Colors.white;
    canvas.drawCircle(const Offset(25.5, 18), 1, paint);
    canvas.drawCircle(const Offset(38.5, 18), 1, paint);

    // Beak
    paint.color = const Color(0xFFF0A020);
    final beakPath = Path()
      ..moveTo(27, 24)
      ..lineTo(30, 30)
      ..lineTo(33, 24)
      ..close();
    canvas.drawPath(beakPath, paint);

    // Blush
    paint.color = const Color(0xFFFFB3C6).withOpacity(0.5);
    canvas.drawOval(const Rect.fromLTWH(16, 20.5, 8, 5), paint);
    canvas.drawOval(const Rect.fromLTWH(36, 20.5, 8, 5), paint);

    // Feet
    paint.color = const Color(0xFFF0A020);
    canvas.drawOval(const Rect.fromLTWH(17, 62, 14, 6), paint);
    canvas.drawOval(const Rect.fromLTWH(29, 62, 14, 6), paint);

    // Accessories
    _drawAccessory(canvas, paint);

    canvas.restore();
  }

  void _drawAccessory(Canvas canvas, Paint paint) {
    switch (accessory) {
      case 'tie':
        paint.color = const Color(0xFFC0392B);
        canvas.drawRect(const Rect.fromLTWH(27.5, 30, 5, 3), paint);
        final tiePath = Path()
          ..moveTo(27, 33)
          ..lineTo(30, 44)
          ..lineTo(33, 33)
          ..close();
        canvas.drawPath(tiePath, paint);
        break;
      case 'glasses':
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 1.5;
        paint.color = const Color(0xFF4A3728);
        canvas.drawCircle(const Offset(23.5, 18), 6, paint);
        canvas.drawCircle(const Offset(36.5, 18), 6, paint);
        canvas.drawLine(const Offset(29.5, 18), const Offset(30.5, 18), paint);
        canvas.drawLine(const Offset(5, 18), const Offset(17.5, 18), paint);
        canvas.drawLine(const Offset(42.5, 18), const Offset(55, 18), paint);
        break;
      case 'bow':
        paint.style = PaintingStyle.fill;
        paint.color = const Color(0xFFFF69B4);
        final bowPath = Path()
          ..moveTo(25, 6)
          ..lineTo(30, 12)
          ..lineTo(25, 18)
          ..close();
        canvas.drawPath(bowPath, paint);
        final bowPath2 = Path()
          ..moveTo(35, 6)
          ..lineTo(30, 12)
          ..lineTo(35, 18)
          ..close();
        canvas.drawPath(bowPath2, paint);
        paint.color = const Color(0xFFFF1493);
        canvas.drawCircle(const Offset(30, 12), 3.5, paint);
        break;
      case 'hardhat':
        paint.color = const Color(0xFFFF9500);
        canvas.drawOval(const Rect.fromLTWH(16, 0, 28, 16), paint);
        canvas.drawRect(const Rect.fromLTWH(15, 13, 30, 4), paint);
        break;
      case 'crown':
        paint.color = const Color(0xFFFFD700);
        final crownPath = Path()
          ..moveTo(18, 12)
          ..lineTo(22, 5)
          ..lineTo(30, 10)
          ..lineTo(38, 5)
          ..lineTo(42, 12)
          ..close();
        canvas.drawPath(crownPath, paint);
        canvas.drawRect(const Rect.fromLTWH(18, 12, 24, 5), paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _PenguinPainter oldDelegate) {
    return color != oldDelegate.color || accessory != oldDelegate.accessory;
  }
}
```

**Step 2: 验证文件创建**

Run: `flutter analyze lib/features/park/widgets/penguin_svg.dart`
Expected: No issues found

---

### Task 6.2: 创建公园页面

**Files:**
- Create: `lib/features/park/pages/park_page.dart`

**Step 1: 创建公园页面**

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../widgets/penguin_svg.dart';

class ParkPage extends StatefulWidget {
  const ParkPage({super.key});

  @override
  State<ParkPage> createState() => _ParkPageState();
}

class _ParkPageState extends State<ParkPage> {
  int _selectedZone = 0;
  bool _showZoneMenu = false;

  static const _zones = ['码农森林', '金币湖畔', '设计师草原', '产品家园'];

  static const _parkBirds = [
    {'id': 1, 'name': '码农阿贤', 'label': '全栈工程师', 'accessory': 'glasses', 'color': Color(0xFF4A78C8), 'x': 0.14, 'y': 0.28},
    {'id': 2, 'name': '设计师小美', 'label': 'UI/UX设计师', 'accessory': 'bow', 'color': Color(0xFFC87AB8), 'x': 0.60, 'y': 0.22},
    {'id': 3, 'name': '产品老王', 'label': '产品经理', 'accessory': 'tie', 'color': Color(0xFF4A9E5A), 'x': 0.35, 'y': 0.50},
    {'id': 4, 'name': '运营小李', 'label': '品牌运营', 'accessory': 'hardhat', 'color': Color(0xFFC89040), 'x': 0.68, 'y': 0.55},
    {'id': 5, 'name': 'HR阿珍', 'label': '人才招募', 'accessory': 'crown', 'color': Color(0xFF7A58C8), 'x': 0.18, 'y': 0.62},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE8F5E0),
      child: Stack(
        children: [
          _buildScene(),
          _buildZoneHeader(),
          if (_showZoneMenu) _buildZoneMenu(),
        ],
      ),
    );
  }

  Widget _buildZoneHeader() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 48, 20, 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.88),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '当前区域',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.mutedForeground,
                    letterSpacing: 0.1,
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _showZoneMenu = !_showZoneMenu),
                  child: Row(
                    children: [
                      Text(
                        '🌲 ${_zones[_selectedZone]}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2A4A2A),
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 18,
                        color: _showZoneMenu ? AppColors.indigo500 : AppColors.mutedForeground,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFD4EDD4),
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
              child: Text(
                '👥 ${12 + _selectedZone * 3} 只咕咕在逛',
                style: AppTypography.labelSmall.copyWith(color: const Color(0xFF3A7A3A)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoneMenu() {
    return Positioned(
      top: 100,
      left: 20,
      right: 20,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: AppShadows.modal,
        ),
        child: Column(
          children: List.generate(_zones.length, (index) {
            final isSelected = index == _selectedZone;
            return InkWell(
              onTap: () => setState(() {
                _selectedZone = index;
                _showZoneMenu = false;
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  border: index < _zones.length - 1
                      ? Border(bottom: BorderSide(color: Colors.grey.shade100))
                      : null,
                ),
                child: Row(
                  children: [
                    Text(
                      ['🌲', '💰', '🎨', '📱'][index],
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _zones[index],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? const Color(0xFF3A7A3A) : const Color(0xFF444444),
                      ),
                    ),
                    const Spacer(),
                    if (isSelected) const Text('✓', style: TextStyle(color: Colors.green)),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildScene() {
    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0, 0.45, 0.45, 1],
            colors: [Color(0xFFB8E8FF), Color(0xFFD4F0C0), Color(0xFF90D060), Color(0xFF70B840)],
          ),
        ),
        child: Stack(
          children: [
            ..._parkBirds.map((bird) => _buildBird(bird)),
          ],
        ),
      ),
    );
  }

  Widget _buildBird(Map<String, dynamic> bird) {
    return Positioned(
      left: bird['x'] as double,
      top: (bird['y'] as double) * 500 + 100,
      child: Column(
        children: [
          PenguinSvg(
            color: bird['color'] as Color,
            accessory: bird['accessory'] as String,
            size: 58,
          ),
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.35),
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
            child: Text(
              '${bird['name']} · ${bird['label']}',
              style: const TextStyle(fontSize: 9, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
```

**Step 2: 验证文件创建**

Run: `flutter analyze lib/features/park/pages/park_page.dart`
Expected: No issues found

---

## Phase 7: 岗位页面

### Task 7.1: 创建岗位卡片组件

**Files:**
- Create: `lib/features/jobs/widgets/job_card.dart`

**Step 1: 创建岗位卡片**

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class JobCard extends StatelessWidget {
  final Map<String, dynamic> job;
  final VoidCallback onTap;

  const JobCard({super.key, required this.job, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 4),
          _buildSalary(),
          const SizedBox(height: 8),
          _buildCompany(),
          const SizedBox(height: 12),
          _buildTags(),
          const SizedBox(height: 16),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            job['title'],
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ),
        if (job['isNew'] == true)
          _buildBadge('NEW', const Color(0xFF5ABE8A)),
        if (job['isUrgent'] == true)
          _buildBadge('急招', const Color(0xFFE8605A)),
      ],
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.white),
      ),
    );
  }

  Widget _buildSalary() {
    return Text(
      job['salary'],
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: job['salaryColor'] ?? AppColors.indigo500,
      ),
    );
  }

  Widget _buildCompany() {
    return Row(
      children: [
        Text(job['company'], style: AppTypography.bodySmall.copyWith(color: AppColors.mutedForeground)),
        const SizedBox(width: 8),
        const Icon(Icons.location_on_outlined, size: 12, color: Colors.grey),
        Text(job['location'], style: AppTypography.caption.copyWith(color: Colors.grey)),
        const SizedBox(width: 4),
        const Icon(Icons.access_time, size: 12, color: Colors.grey),
        Text(job['posted'], style: AppTypography.caption.copyWith(color: Colors.grey)),
      ],
    );
  }

  Widget _buildTags() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: (job['tags'] as List).map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5FA),
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          child: Text(tag, style: AppTypography.caption.copyWith(color: AppColors.mutedForeground)),
        );
      }).toList(),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.only(top: 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0x0F000000))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ...List.generate(4, (_) => const Icon(Icons.star, size: 12, color: Color(0xFFFFB840))),
              const Icon(Icons.star, size: 12, color: Color(0xFFE0E0E0)),
              const SizedBox(width: 4),
              Text('4.0 公司评分', style: AppTypography.caption.copyWith(color: Colors.grey)),
            ],
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
              child: const Text(
                '查看详情',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

**Step 2: 验证文件创建**

Run: `flutter analyze lib/features/jobs/widgets/job_card.dart`
Expected: No issues found

---

### Task 7.2: 创建岗位页面

**Files:**
- Create: `lib/features/jobs/pages/jobs_page.dart`

**Step 1: 创建岗位页面**

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../widgets/job_card.dart';

class JobsPage extends StatefulWidget {
  const JobsPage({super.key});

  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  final _searchController = TextEditingController();
  String _searchText = '';
  int _selectedCategory = 0;

  static const _categories = ['全部', '设计', '技术', '产品', '运营', '数据'];

  static const _jobs = [
    {
      'id': 1, 'title': 'UI设计师', 'salary': '15k-20k', 'company': '某创意科技有限公司',
      'location': '上海·静安区', 'tags': ['双休', '五险一金', '扁平管理'],
      'isNew': true, 'isUrgent': false, 'salaryColor': Color(0xFFE8805A), 'posted': '1小时前',
      'desc': '负责公司核心产品的视觉设计，包括移动端App、Web端界面设计，参与品牌视觉规范制定。',
    },
    {
      'id': 2, 'title': '产品经理', 'salary': '18k-25k', 'company': '某知名互联网大厂',
      'location': '北京·朝阳区', 'tags': ['六险一金', '期权激励', '免费三餐'],
      'isNew': false, 'isUrgent': true, 'salaryColor': Color(0xFF5A8AE8), 'posted': '3小时前',
      'desc': '主导2C产品从0到1的设计规划，深入分析用户需求，驱动产品功能迭代优化。',
    },
    {
      'id': 3, 'title': '前端工程师', 'salary': '20k-30k', 'company': '某头部电商平台',
      'location': '杭州·余杭区', 'tags': ['双休', '五险一金', '弹性工作'],
      'isNew': true, 'isUrgent': false, 'salaryColor': Color(0xFF5ABE8A), 'posted': '5小时前',
      'desc': '负责核心业务前端研发，技术栈React/TypeScript，参与架构设计。',
    },
    {
      'id': 4, 'title': '品牌运营专员', 'salary': '8k-12k', 'company': '某新消费品牌',
      'location': '广州·天河区', 'tags': ['双休', '五险一金', '餐补'],
      'isNew': false, 'isUrgent': false, 'salaryColor': Color(0xFFC87ACA), 'posted': '昨天',
      'desc': '负责品牌社媒运营，包括小红书、微博、微信公众号等平台内容策划与发布。',
    },
    {
      'id': 5, 'title': '数据分析师', 'salary': '15k-22k', 'company': '某头部本地生活平台',
      'location': '北京·海淀区', 'tags': ['双休', '年终奖', '补充医疗'],
      'isNew': false, 'isUrgent': true, 'salaryColor': Color(0xFFE8C03A), 'posted': '昨天',
      'desc': '负责业务数据的统计分析，搭建数据指标体系，输出数据报告。',
    },
  ];

  List<Map<String, dynamic>> get _filteredJobs {
    if (_searchText.isEmpty) return _jobs;
    return _jobs.where((job) {
      return job['title'].toString().contains(_searchText) ||
          job['company'].toString().contains(_searchText) ||
          (job['tags'] as List).any((tag) => tag.toString().contains(_searchText));
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F8),
      child: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          _buildCategories(),
          Expanded(child: _buildJobList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F8).withOpacity(0.92),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '为你精选',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.mutedForeground,
                  letterSpacing: 0.15,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                '岗位聚合馆 🔍',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E)),
              ),
            ],
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: AppShadows.button,
            ),
            child: const Icon(Icons.tune, color: AppColors.indigo500, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppShadows.input,
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchText = value),
              decoration: InputDecoration(
                hintText: '搜索岗位、公司或标签...',
                hintStyle: AppTypography.bodySmall.copyWith(color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = index == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = index),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected ? AppColors.primaryGradient : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                boxShadow: AppShadows.button,
              ),
              child: Text(
                _categories[index],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? Colors.white : AppColors.mutedForeground,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildJobList() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: _filteredJobs.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Text(
              '共找到 ${_filteredJobs.length} 个岗位',
              style: AppTypography.caption.copyWith(color: AppColors.mutedForeground),
            ),
          );
        }
        final job = _filteredJobs[index - 1];
        return JobCard(
          job: job,
          onTap: () => _showJobDetail(job),
        );
      },
    );
  }

  void _showJobDetail(Map<String, dynamic> job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(job['title'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(
                            job['salary'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: job['salaryColor'],
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F8FC),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(job['company'], style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(job['location'], style: AppTypography.caption),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('职位描述', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(
                    job['desc'],
                    style: AppTypography.bodySmall.copyWith(color: AppColors.mutedForeground, height: 1.8),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                    child: const Center(
                      child: Text('立即投递 🚀', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
```

**Step 2: 验证文件创建**

Run: `flutter analyze lib/features/jobs/pages/jobs_page.dart`
Expected: No issues found

---

## Phase 8: 最终验证

### Task 8.1: 运行完整应用

**Step 1: 运行应用**

Run: `cd app && flutter run -d windows`
Expected: All pages render correctly

**Step 2: 验证所有页面**

- [ ] 倾诉室页面显示正常，输入和回复功能正常
- [ ] 看板页面图表显示正常，数字动画正常
- [ ] 公园页面企鹅显示正常，区域切换正常
- [ ] 岗位页面搜索和详情弹窗正常
- [ ] 底部导航切换正常

---

**Plan complete and saved to `docs/plans/2026-03-16-flutter-ui-implementation.md`. Two execution options:**

**1. Subagent-Driven (this session)** - I dispatch fresh subagent per task, review between tasks, fast iteration

**2. Parallel Session (separate)** - Open new session with executing-plans, batch execution with checkpoints

**Which approach?**
