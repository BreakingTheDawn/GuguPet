import 'dart:convert';
import 'package:flutter/services.dart';

/// 配置服务抽象基类
/// 提供JSON配置文件的加载、缓存和访问功能
abstract class ConfigService<T> {
  /// 配置文件路径
  final String configPath;
  
  /// 缓存的配置数据
  T? _cachedConfig;
  
  /// 构造函数
  ConfigService({required this.configPath});
  
  /// 加载配置文件
  /// 从assets中读取JSON配置文件并解析
  Future<T> loadConfig() async {
    // 如果已缓存,直接返回
    if (_cachedConfig != null) {
      return _cachedConfig!;
    }
    
    try {
      // 从assets加载JSON字符串
      final jsonString = await rootBundle.loadString(configPath);
      
      // 解析JSON
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      
      // 转换为配置对象
      _cachedConfig = fromJson(jsonMap);
      
      return _cachedConfig!;
    } catch (e) {
      throw ConfigLoadException(
        'Failed to load config from $configPath: $e',
      );
    }
  }
  
  /// 获取配置数据
  /// 如果未加载,会自动加载
  Future<T> get config async {
    if (_cachedConfig != null) {
      return _cachedConfig!;
    }
    return await loadConfig();
  }
  
  /// 同步获取已缓存的配置
  /// 如果未加载会抛出异常
  T get cachedConfig {
    if (_cachedConfig == null) {
      throw StateError('Config not loaded. Call loadConfig() first.');
    }
    return _cachedConfig!;
  }
  
  /// 清除缓存
  /// 用于热重载或强制重新加载配置
  void clearCache() {
    _cachedConfig = null;
  }
  
  /// 重新加载配置
  /// 清除缓存并重新加载
  Future<T> reload() async {
    clearCache();
    return await loadConfig();
  }
  
  /// 从JSON Map转换为配置对象
  /// 子类需要实现此方法
  T fromJson(Map<String, dynamic> json);
}

/// 配置加载异常
class ConfigLoadException implements Exception {
  final String message;
  
  ConfigLoadException(this.message);
  
  @override
  String toString() => 'ConfigLoadException: $message';
}
