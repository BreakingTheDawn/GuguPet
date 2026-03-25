import '../models/business_config_models.dart';
import 'config_service.dart';

/// 业务配置服务
/// 提供业务数据的访问接口
class BusinessConfigService extends ConfigService<BusinessConfig> {
  /// 单例实例
  static final BusinessConfigService _instance = BusinessConfigService._internal();
  
  /// 工厂构造函数
  factory BusinessConfigService() => _instance;
  
  /// 私有构造函数
  BusinessConfigService._internal() : super(configPath: 'assets/config/business_config.json');
  
  /// 从JSON转换为配置对象
  @override
  BusinessConfig fromJson(Map<String, dynamic> json) {
    return BusinessConfig.fromJson(json);
  }
  
  /// 获取职位筛选选项
  JobFiltersConfig get jobFilters => cachedConfig.jobFilters;
  
  /// 获取宠物回复模板
  PetResponsesConfig get petResponses => cachedConfig.petResponses;
  
  /// 获取城市分组
  CityGroupsConfig get cityGroups => cachedConfig.cityGroups;
  
  /// 初始化服务
  /// 在应用启动时调用
  static Future<void> initialize() async {
    await _instance.loadConfig();
  }
  
  /// 检查服务是否已初始化
  static bool get isInitialized {
    try {
      _instance.cachedConfig;
      return true;
    } catch (e) {
      return false;
    }
  }
}
