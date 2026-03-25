import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/theme_config_models.dart';
import 'config_service.dart';

/// 主题服务
/// 提供主题配置的访问和切换功能
class ThemeService extends ConfigService<ThemeConfig> {
  /// 单例实例
  static final ThemeService _instance = ThemeService._internal();
  
  /// 工厂构造函数
  factory ThemeService() => _instance;
  
  /// 私有构造函数
  ThemeService._internal() : super(configPath: 'assets/config/theme_config.json');
  
  /// SharedPreferences实例
  SharedPreferences? _prefs;
  
  /// 主题模式键名
  static const String _themeModeKey = 'theme_mode';
  
  /// 从JSON转换为配置对象
  @override
  ThemeConfig fromJson(Map<String, dynamic> json) {
    return ThemeConfig.fromJson(json);
  }
  
  /// 获取亮色主题配置
  ThemeColors get lightTheme => cachedConfig.light;
  
  /// 获取暗色主题配置
  ThemeColors get darkTheme => cachedConfig.dark;
  
  /// 初始化服务
  /// 在应用启动时调用
  static Future<void> initialize() async {
    await _instance.loadConfig();
    _instance._prefs = await SharedPreferences.getInstance();
  }
  
  /// 检查服务是否已初始化
  static bool get isInitialized {
    try {
      _instance.cachedConfig;
      return _instance._prefs != null;
    } catch (StateError) {
      return false;
    }
  }
  
  /// 获取当前主题模式
  ThemeMode get themeMode {
    if (_prefs == null) return ThemeMode.system;
    
    final modeString = _prefs!.getString(_themeModeKey);
    switch (modeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
  
  /// 设置主题模式
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_prefs == null) return;
    
    String modeString;
    switch (mode) {
      case ThemeMode.light:
        modeString = 'light';
        break;
      case ThemeMode.dark:
        modeString = 'dark';
        break;
      default:
        modeString = 'system';
    }
    
    await _prefs!.setString(_themeModeKey, modeString);
  }
  
  /// 切换主题模式
  Future<ThemeMode> toggleThemeMode() async {
    ThemeMode newMode;
    switch (themeMode) {
      case ThemeMode.light:
        newMode = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        newMode = ThemeMode.system;
        break;
      default:
        newMode = ThemeMode.light;
    }
    
    await setThemeMode(newMode);
    return newMode;
  }
}
