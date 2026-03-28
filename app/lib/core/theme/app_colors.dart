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

  static const Color indigo50 = Color(0xFFE8E8F8);
  static const Color indigo200 = Color(0xFFB8B8E8);
  static const Color indigo400 = Color(0xFF7C8AE8);
  static const Color indigo500 = Color(0xFF667EEA);
  static const Color purple200 = Color(0xFFC8C0E8);
  static const Color purple500 = Color(0xFF764BA2);

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

  // ═══════════════════════════════════════════════════════════
  // 档案馆专栏配色（牛皮纸温暖风格）
  // ═══════════════════════════════════════════════════════════

  /// 档案馆主背景色
  static const Color archiveBackground = Color(0xFFF7F4EF);

  /// 档案馆卡片渐变起始色
  static const Color archiveCardStart = Color(0xFFEDD8A8);

  /// 档案馆卡片渐变结束色
  static const Color archiveCardEnd = Color(0xFFE3C47E);

  /// 档案馆强调色（深棕色）
  static const Color archiveAccent = Color(0xFF8B5A2A);

  /// 档案馆深色强调
  static const Color archiveAccentDark = Color(0xFF5A3318);

  /// 档案馆文字颜色
  static const Color archiveText = Color(0xFF2A1A08);

  /// 档案馆次要文字颜色
  static const Color archiveTextMuted = Color(0xFF8A6A40);

  /// 档案馆弹窗背景
  static const Color archiveModalBackground = Color(0xFFFDFAF4);

  /// 档案馆卡片渐变
  static const LinearGradient archiveCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [archiveCardStart, archiveCardEnd],
  );

  /// 档案馆Banner渐变
  static const LinearGradient archiveBannerGradient = LinearGradient(
    begin: Alignment(-1, -1),
    end: Alignment(1, 1),
    colors: [archiveAccentDark, archiveAccent, archiveAccent],
    stops: [0.0, 0.5, 1.0],
  );

  // ═══════════════════════════════════════════════════════════
  // 错误状态颜色
  // ═══════════════════════════════════════════════════════════

  /// 错误状态颜色
  static const Color error = Color(0xFFE74C3C);

  // ═══════════════════════════════════════════════════════════
  // 情绪颜色
  // ═══════════════════════════════════════════════════════════

  /// 开心情绪颜色
  static const Color emotionHappy = Color(0xFF4CAF50);

  /// 难过情绪颜色
  static const Color emotionSad = Color(0xFF5A5A7A);

  /// 生气情绪颜色
  static const Color emotionAngry = Color(0xFFE74C3C);

  /// 兴奋情绪颜色
  static const Color emotionExcited = Color(0xFFFFB300);

  // ═══════════════════════════════════════════════════════════
  // 宠物颜色预设
  // ═══════════════════════════════════════════════════════════

  /// 宠物灰色
  static const Color petGray = Color(0xFF6B7280);

  /// 宠物灰色次要
  static const Color petGraySecondary = Color(0xFF9CA3AF);

  /// 宠物橙色
  static const Color petOrange = Color(0xFFF59E0B);

  /// 宠物橙色次要
  static const Color petOrangeSecondary = Color(0xFFFBBF24);

  /// 宠物粉色
  static const Color petPink = Color(0xFFEC4899);

  /// 宠物粉色次要
  static const Color petPinkSecondary = Color(0xFFF472B6);

  /// 宠物蓝色
  static const Color petBlue = Color(0xFF3B82F6);

  /// 宠物蓝色次要
  static const Color petBlueSecondary = Color(0xFF60A5FA);

  // ═══════════════════════════════════════════════════════════
  // 专栏分类颜色
  // ═══════════════════════════════════════════════════════════

  /// 职场入门分类背景色
  static const Color categoryCareerBg = Color(0xFFC8F0D4);

  /// 职场入门分类文字色
  static const Color categoryCareerText = Color(0xFF1E6640);

  /// 求职技巧分类背景色
  static const Color categoryJobHuntBg = Color(0xFFC2D9FF);

  /// 求职技巧分类文字色
  static const Color categoryJobHuntText = Color(0xFF1A3E7A);

  /// 面试攻略分类背景色
  static const Color categoryInterviewBg = Color(0xFFE8D4FF);

  /// 面试攻略分类文字色
  static const Color categoryInterviewText = Color(0xFF4A1A7A);

  /// 职场生存分类背景色
  static const Color categoryWorkplaceBg = Color(0xFFC8F0F8);

  /// 职场生存分类文字色
  static const Color categoryWorkplaceText = Color(0xFF0A4A5A);

  /// 权益保障分类背景色
  static const Color categoryRightsBg = Color(0xFFFFE2CC);

  /// 权益保障分类文字色
  static const Color categoryRightsText = Color(0xFF7A3A10);

  /// 心态调节分类背景色
  static const Color categoryMindsetBg = Color(0xFFFFD4E4);

  /// 心态调节分类文字色
  static const Color categoryMindsetText = Color(0xFF7A1A3A);

  /// 成长进阶分类背景色
  static const Color categoryGrowthBg = Color(0xFFD4F0C0);

  /// 成长进阶分类文字色
  static const Color categoryGrowthText = Color(0xFF1A5A2A);

  // ═══════════════════════════════════════════════════════════
  // 倾诉模块颜色
  // ═══════════════════════════════════════════════════════════

  /// 倾诉气泡背景色
  static const Color confideBubbleBg = Color(0xFFBBB0D0);

  /// 倾诉气泡文字色
  static const Color confideBubbleText = Color(0xFF5A5A7A);

  /// 倾诉输入区边框色
  static const Color confideInputBorder = Color(0xFFB8B0D0);

  /// 倾诉输入区文字色
  static const Color confideInputText = Color(0xFF5A5A7A);

  // ═══════════════════════════════════════════════════════════
  // 页面背景色
  // ═══════════════════════════════════════════════════════════

  /// 页面浅灰背景色
  static const Color pageBackgroundLight = Color(0xFFF8F7FC);

  /// 页面渐变起始色
  static const Color pageGradientStart = Color(0xFFF8F7FC);

  /// 页面渐变结束色
  static const Color pageGradientEnd = Color(0xFFEEE8F5);

  /// 加载指示器颜色
  static const Color loadingIndicator = Color(0xFF6366F1);

  // ═══════════════════════════════════════════════════════════
  // 渐变
  // ═══════════════════════════════════════════════════════════

  /// 页面背景渐变
  static const LinearGradient pageBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [pageGradientStart, pageGradientEnd],
  );

  /// 购买对话框渐变
  static const LinearGradient purchaseDialogGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFB300), Color(0xFFFF8F00)],
  );

  /// 成功状态渐变
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
  );
}
