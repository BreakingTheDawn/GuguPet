import '../models/config_models.dart';
import 'config_service.dart';

/// UI文本服务
/// 提供类型安全的UI文本访问接口
class AppStrings extends ConfigService<UIStringsConfig> {
  /// 单例实例
  static final AppStrings _instance = AppStrings._internal();
  
  /// 工厂构造函数
  factory AppStrings() => _instance;
  
  /// 私有构造函数
  AppStrings._internal() : super(configPath: 'assets/config/ui_strings.json');
  
  /// 从JSON转换为配置对象
  @override
  UIStringsConfig fromJson(Map<String, dynamic> json) {
    return UIStringsConfig.fromJson(json);
  }
  
  /// 获取通用文本
  CommonStrings get common => cachedConfig.common;
  
  /// 获取职位模块文本
  JobStrings get jobs => cachedConfig.jobs;
  
  /// 获取设置模块文本
  SettingsStrings get settings => cachedConfig.settings;
  
  /// 获取个人中心文本
  ProfileStrings get profile => cachedConfig.profile;
  
  /// 获取通知模块文本
  NotificationStrings get notifications => cachedConfig.notifications;
  
  /// 获取错误提示文本
  ErrorStrings get errors => cachedConfig.errors;
  
  /// 获取带参数的文本
  /// 用于需要动态替换参数的文本
  /// 例如: "你好,{name}!" -> "你好,张三!"
  String getStringWithParams(String text, Map<String, String> params) {
    String result = text;
    params.forEach((key, value) {
      result = result.replaceAll('{$key}', value);
    });
    return result;
  }
  
  /// 初始化服务
  /// 在应用启动时调用
  static Future<void> initialize() async {
    await _instance.loadConfig();
  }
  
  /// 检查服务是否已初始化
  static bool get isInitialized => _instance._cachedConfig != null;
}
