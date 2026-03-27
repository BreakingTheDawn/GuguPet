// AI自动配置服务
// 在应用启动时自动配置API Key，无需用户手动输入

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'security_service.dart';
import 'ai_config_loader_service.dart';

/// AI自动配置服务
/// 自动配置预设的API Key，用户无需手动输入
class AIAutoConfigService {
  static final _secureStorage = const FlutterSecureStorage();
  static final _securityService = SecurityService();
  
  // ⚠️ 安全警告：生产环境应该从后端接口获取，不要硬编码
  // 这里使用硬编码仅用于演示，实际应该通过后端接口动态获取
  static const String _glmApiKey = '8e4979fbaa514e27aa97bcd099ba27e2.VXYkauHvE388vBYr';
  
  /// 初始化并自动配置所有AI服务
  static Future<void> initialize() async {
    debugPrint('=== AI自动配置服务初始化 ===');
    
    try {
      // 检查GLM API Key是否已配置
      final existingKey = await _getApiKey('ai_api_key_glm');
      
      if (existingKey == null || existingKey.isEmpty) {
        debugPrint('GLM API Key未配置，正在自动配置...');
        await _configureGLM();
      } else {
        debugPrint('GLM API Key已配置');
      }
      
      // 清除AI配置缓存，确保使用最新配置
      AIConfigLoaderService.clearCache();
      
      debugPrint('AI自动配置完成');
    } catch (e) {
      debugPrint('AI自动配置失败: $e');
    }
  }
  
  /// 配置GLM API Key
  static Future<void> _configureGLM() async {
    try {
      // 加密存储API Key
      final encryptedKey = _securityService.encryptData(_glmApiKey);
      await _secureStorage.write(
        key: 'ai_api_key_glm',
        value: encryptedKey,
      );
      
      debugPrint('GLM API Key已安全存储');
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
