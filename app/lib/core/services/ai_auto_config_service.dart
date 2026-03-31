// AI自动配置服务
// 检查和管理AI API Key配置状态

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'security_service.dart';
import 'ai_config_loader_service.dart';

/// AI自动配置服务
/// 检查API Key配置状态，引导用户配置自己的API Key
class AIAutoConfigService {
  static final _secureStorage = const FlutterSecureStorage();
  static final _securityService = SecurityService();
  
  /// 初始化并检查AI服务配置状态
  static Future<void> initialize() async {
    debugPrint('=== AI配置服务初始化 ===');
    
    try {
      // 检查GLM API Key是否已配置
      final existingKey = await _getApiKey('ai_api_key_glm');
      
      if (existingKey == null || existingKey.isEmpty) {
        debugPrint('⚠️ GLM API Key未配置');
        debugPrint('💡 请在设置页面配置您的API Key');
      } else {
        debugPrint('✅ GLM API Key已配置');
      }
      
      // 清除AI配置缓存，确保使用最新配置
      AIConfigLoaderService.clearCache();
      
      debugPrint('AI配置检查完成');
    } catch (e) {
      debugPrint('AI配置检查失败: $e');
    }
  }
  
  /// 配置GLM API Key（用户手动配置）
  static Future<void> configureGLM(String apiKey) async {
    if (apiKey.isEmpty) {
      throw ArgumentError('API Key不能为空');
    }
    
    try {
      // 加密存储API Key
      final encryptedKey = _securityService.encryptData(apiKey);
      await _secureStorage.write(
        key: 'ai_api_key_glm',
        value: encryptedKey,
      );
      
      // 清除缓存，确保使用新配置
      AIConfigLoaderService.clearCache();
      
      debugPrint('✅ GLM API Key已配置');
    } catch (e) {
      debugPrint('配置GLM API Key失败: $e');
      rethrow;
    }
  }
  
  /// 从安全存储读取API Key
  static Future<String?> _getApiKey(String key) async {
    try {
      final encrypted = await _secureStorage.read(key: key);
      if (encrypted == null || encrypted.isEmpty) {
        return null;
      }
      return _securityService.decryptData(encrypted);
    } catch (e) {
      debugPrint('读取API Key失败: $e');
      return null;
    }
  }
  
  /// 清除所有API Key（用于测试）
  static Future<void> clearAllApiKeys() async {
    await _secureStorage.delete(key: 'ai_api_key_glm');
    await _secureStorage.delete(key: 'ai_api_key_hunyuan');
    await _secureStorage.delete(key: 'ai_api_key_gemini');
    debugPrint('所有API Key已清除');
  }
}
