/// 主题配置数据模型
class ThemeConfig {
  /// 亮色主题配置
  final ThemeColors light;
  
  /// 暗色主题配置
  final ThemeColors dark;
  
  ThemeConfig({
    required this.light,
    required this.dark,
  });
  
  factory ThemeConfig.fromJson(Map<String, dynamic> json) {
    return ThemeConfig(
      light: ThemeColors.fromJson(json['light'] as Map<String, dynamic>),
      dark: ThemeColors.fromJson(json['dark'] as Map<String, dynamic>),
    );
  }
}

/// 主题颜色配置
class ThemeColors {
  /// 主要颜色
  final String primary;
  
  /// 背景颜色
  final String background;
  
  /// 卡片颜色
  final String card;
  
  /// 文本颜色
  final String text;
  
  /// 次要文本颜色
  final String textSecondary;
  
  /// 边框颜色
  final String border;
  
  /// 强调颜色
  final String accent;
  
  ThemeColors({
    required this.primary,
    required this.background,
    required this.card,
    required this.text,
    required this.textSecondary,
    required this.border,
    required this.accent,
  });
  
  factory ThemeColors.fromJson(Map<String, dynamic> json) {
    return ThemeColors(
      primary: json['primary'] as String,
      background: json['background'] as String,
      card: json['card'] as String,
      text: json['text'] as String,
      textSecondary: json['textSecondary'] as String,
      border: json['border'] as String,
      accent: json['accent'] as String,
    );
  }
}
