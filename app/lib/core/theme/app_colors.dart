import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Core semantic tokens approved for the companion workbench direction.
  static const Color backgroundDefault = Color(0xFFF8F7FC);
  static const Color backgroundSubtle = Color(0xFFF1F3FA);
  static const Color textDefault = Color(0xFF202136);
  static const Color textSecondary = Color(0xFF71758A);
  static const Color textTertiary = Color(0xFFA1A4B5);
  static const Color textInverse = Color(0xFFFFFFFF);
  static const Color textFill = Color(0xFFEEF1FF);
  static const Color iconDefault = Color(0xFF5F6FEB);
  static const Color iconSecondary = Color(0xFF7B7E91);
  static const Color iconFill = Color(0xFFEEF1FF);
  static const Color surfaceDefault = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = Color(0xFFF4F5FB);
  static const Color surfaceFill = Color(0xCCFFFFFF);
  static const Color brandPrimary = Color(0xFF5F6FEB);
  static const Color brandSoft = Color(0xFFDDE3FF);
  static const Color accentWarm = Color(0xFFF5B84B);
  static const Color accentGrowth = Color(0xFF59C783);
  static const Color borderDefault = Color(0xFFE4E6EF);
  static const Color dividerDefault = Color(0xFFECEEF5);

  static const Color background = backgroundDefault;
  static const Color foreground = textDefault;

  static const Color primary = brandPrimary;
  static const Color primaryForeground = textInverse;

  static const Color secondary = surfaceSecondary;
  static const Color secondaryForeground = textDefault;

  static const Color muted = backgroundSubtle;
  static const Color mutedForeground = textSecondary;

  static const Color accent = brandSoft;
  static const Color accentForeground = brandPrimary;

  static const Color destructive = Color(0xFFD4183D);
  static const Color destructiveForeground = Color(0xFFFFFFFF);

  static const Color border = borderDefault;
  static const Color input = Colors.transparent;
  static const Color inputBackground = surfaceSecondary;

  static const Color success = accentGrowth;
  static const Color warning = accentWarm;
  static const Color info = Color(0xFF5A8AE8);

  static const Color cardBackground = surfaceDefault;
  static const Color divider = dividerDefault;

  static const Color indigo50 = brandSoft;
  static const Color indigo200 = Color(0xFFBFC8FF);
  static const Color indigo400 = Color(0xFF8390F3);
  static const Color indigo500 = brandPrimary;
  static const Color purple200 = Color(0xFFC8C0E8);
  static const Color purple500 = Color(0xFF764BA2);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brandPrimary, accentGrowth],
  );

  static const LinearGradient confideBackground = LinearGradient(
    begin: Alignment(-1, -1),
    end: Alignment(1, 1),
    stops: [0.0, 0.45, 1.0],
    colors: [backgroundDefault, brandSoft, Color(0xFFFFF7E4)],
  );

  static const LinearGradient statsHeaderGradient = LinearGradient(
    begin: Alignment(-0.5, -1),
    end: Alignment(0.5, 1),
    colors: [brandPrimary, accentGrowth],
  );

  // ═══════════════════════════════════════════════════════════
  // 档案馆专栏配色（牛皮纸温暖风格）
  // ═══════════════════════════════════════════════════════════

  /// 档案馆主背景色
  static const Color archiveBackground = backgroundDefault;

  /// 档案馆卡片渐变起始色
  static const Color archiveCardStart = Color(0xFFFFF2CC);

  /// 档案馆卡片渐变结束色
  static const Color archiveCardEnd = brandSoft;

  /// 档案馆强调色（深棕色）
  static const Color archiveAccent = brandPrimary;

  /// 档案馆深色强调
  static const Color archiveAccentDark = textDefault;

  /// 档案馆文字颜色
  static const Color archiveText = textDefault;

  /// 档案馆次要文字颜色
  static const Color archiveTextMuted = textSecondary;

  /// 档案馆弹窗背景
  static const Color archiveModalBackground = surfaceDefault;

  /// 档案馆按钮渐变起始色
  static const Color archiveButtonStart = Color(0xFFFFE7A3);

  /// 档案馆按钮渐变结束色
  static const Color archiveButtonEnd = accentWarm;

  /// 档案馆按钮阴影色
  static const Color archiveButtonShadow = accentWarm;

  /// 档案馆购买按钮主文字色
  static const Color archiveButtonText = Color(0xFF3A2B12);

  /// 档案馆购买按钮辅助文字色
  static const Color archiveButtonTextMuted = Color(0xFF6D4B10);

  /// 档案馆高亮色
  static const Color archiveHighlight = Color(0xFFFFFFFF);

  /// 档案馆装饰色
  static const Color archiveDecorative = Color(0xFFFFE5A8);

  /// 档案馆边框色
  static const Color archiveBorder = borderDefault;

  /// 档案馆深色文字
  static const Color archiveTextDark = textDefault;

  /// 档案馆中等文字色
  static const Color archiveTextMedium = textSecondary;

  /// 档案馆图标色
  static const Color archiveIcon = iconSecondary;

  /// 档案馆内容文字色
  static const Color archiveContentText = textDefault;

  /// 档案馆详情按钮起始色
  static const Color archiveDetailButtonStart = brandPrimary;

  /// 档案馆详情按钮结束色
  static const Color archiveDetailButtonEnd = Color(0xFF4658D8);

  /// 离线状态背景色
  static const Color offlineBackground = Color(0xFFF5F5F5);

  /// 档案馆卡片阴影色
  static const Color archiveCardShadow = brandPrimary;

  /// 档案馆卡片边框色
  static const Color archiveCardBorder = borderDefault;

  /// 收藏红色
  static const Color favoriteRed = Color(0xFFE53935);

  /// 未收藏灰色
  static const Color unfavoriteGray = Color(0xFF9E9E9E);

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
  static const Color pageGradientEnd = backgroundSubtle;

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
    colors: [Color(0xFFF5B84B), Color(0xFFD99016)],
  );

  /// 成功状态渐变
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
  );
}
