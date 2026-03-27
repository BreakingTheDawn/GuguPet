import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/llm_provider.dart';
import '../../../core/services/security_service.dart';

/// AI对话配置模型
class AIConfig {
  /// AI平台
  final LLMProvider provider;
  
  /// API密钥
  final String apiKey;
  
  /// API端点
  final String endpoint;
  
  /// 模型名称
  final String model;
  
  /// 是否启用AI对话
  final bool isEnabled;

  const AIConfig({
    this.provider = LLMProvider.gemini,
    this.apiKey = '',
    this.endpoint = '',
    this.model = '',
    this.isEnabled = false,
  });

  /// 是否已配置
  bool get isConfigured => apiKey.isNotEmpty && endpoint.isNotEmpty && model.isNotEmpty;

  /// 从JSON创建
  factory AIConfig.fromJson(Map<String, dynamic> json) {
    final providerIndex = json['provider'] as int? ?? 0;
    // 确保索引在有效范围内
    final provider = providerIndex < LLMProvider.values.length
        ? LLMProvider.values[providerIndex]
        : LLMProvider.gemini;
    
    return AIConfig(
      provider: provider,
      apiKey: json['api_key'] as String? ?? '',
      endpoint: json['endpoint'] as String? ?? '',
      model: json['model'] as String? ?? '',
      isEnabled: json['is_enabled'] as bool? ?? false,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'provider': provider.index,
      'api_key': apiKey,
      'endpoint': endpoint,
      'model': model,
      'is_enabled': isEnabled,
    };
  }

  /// 复制并修改
  AIConfig copyWith({
    LLMProvider? provider,
    String? apiKey,
    String? endpoint,
    String? model,
    bool? isEnabled,
  }) {
    return AIConfig(
      provider: provider ?? this.provider,
      apiKey: apiKey ?? this.apiKey,
      endpoint: endpoint ?? this.endpoint,
      model: model ?? this.model,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}

/// AI配置服务
/// 管理用户的AI对话配置，按用户隔离
class AIConfigService extends ChangeNotifier {
  String? _currentUserId;
  AIConfig _config = const AIConfig();
  bool _hasShownUnlockDialog = false;
  SharedPreferences? _prefs;

  AIConfig get config => _config;
  bool get isConfigured => _config.isConfigured && _config.isEnabled;
  bool get hasShownUnlockDialog => _hasShownUnlockDialog;

  /// 获取配置键名（包含用户ID）
  String _getConfigKey() => 'ai_config_${_currentUserId ?? "guest"}';
  String _getUnlockDialogKey() => 'ai_unlock_dialog_shown_${_currentUserId ?? "guest"}';

  /// 初始化配置
  /// 从本地存储加载配置
  Future<void> initialize({String? userId}) async {
    debugPrint('=== AIConfigService初始化开始 ===');
    debugPrint('传入用户ID: $userId');
    debugPrint('当前用户ID: $_currentUserId');
    
    try {
      _prefs = await SharedPreferences.getInstance();
      debugPrint('SharedPreferences初始化成功');
      
      // 如果用户ID变化，需要重新加载对应用户的配置
      if (_currentUserId != userId) {
        _currentUserId = userId;
        await _loadConfig();
      }
      
      debugPrint('最终配置状态:');
      debugPrint('  isConfigured: $isConfigured');
      debugPrint('  config.isEnabled: ${_config.isEnabled}');
      debugPrint('  config.apiKey长度: ${_config.apiKey.length}');
      debugPrint('  config.endpoint: ${_config.endpoint}');
      debugPrint('  config.model: ${_config.model}');
      
      notifyListeners();
    } catch (e) {
      debugPrint('初始化AI配置服务失败: $e');
    }
  }

  /// 加载配置
  Future<void> _loadConfig() async {
    debugPrint('=== 加载AI配置 ===');
    debugPrint('配置键名: ${_getConfigKey()}');
    
    // 加载配置
    final configJson = _prefs?.getString(_getConfigKey());
    debugPrint('配置JSON是否存在: ${configJson != null}');
    
    if (configJson != null && configJson.isNotEmpty) {
      try {
        final decoded = jsonDecode(configJson) as Map<String, dynamic>;
        debugPrint('解析的配置: $decoded');
        _config = AIConfig.fromJson(decoded);
        
        debugPrint('从SharedPreferences加载的配置:');
        debugPrint('  provider: ${_config.provider}');
        debugPrint('  apiKey长度: ${_config.apiKey.length}');
        debugPrint('  endpoint: ${_config.endpoint}');
        debugPrint('  model: ${_config.model}');
        debugPrint('  isEnabled: ${_config.isEnabled}');
        
        // 从安全存储加载API密钥
        await loadApiKeyFromSecureStorage();
        
        debugPrint('从安全存储加载API密钥后:');
        debugPrint('  apiKey长度: ${_config.apiKey.length}');
      } catch (e) {
        debugPrint('解析AI配置失败: $e');
      }
    } else {
      // 如果没有保存的配置，使用默认配置
      debugPrint('未找到保存的配置，使用默认配置');
      _config = const AIConfig();
    }
    
    // 加载弹窗显示状态
    _hasShownUnlockDialog = _prefs?.getBool(_getUnlockDialogKey()) ?? false;
    debugPrint('解锁弹窗已显示: $_hasShownUnlockDialog');
  }

  /// 切换用户
  Future<void> switchUser(String userId) async {
    if (_currentUserId != userId) {
      _currentUserId = userId;
      await _loadConfig();
      notifyListeners();
    }
  }

  /// 从JSON字符串加载配置
  void loadFromJson(String? jsonStr) {
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
        _config = AIConfig.fromJson(decoded);
      } catch (e) {
        debugPrint('解析AI配置失败: $e');
      }
    }
    notifyListeners();
  }

  /// 保存配置
  Future<void> saveConfig(AIConfig config) async {
    _config = config;
    
    // 持久化到本地存储（使用用户特定的键名）
    try {
      // 保存API密钥到安全存储
      await saveApiKeyToSecureStorage(config.apiKey);
      
      // 保存其他配置到SharedPreferences（不包含API密钥）
      final configWithoutApiKey = AIConfig(
        provider: config.provider,
        apiKey: '', // 不保存API密钥到SharedPreferences
        endpoint: config.endpoint,
        model: config.model,
        isEnabled: config.isEnabled,
      );
      await _prefs?.setString(_getConfigKey(), jsonEncode(configWithoutApiKey.toJson()));
      notifyListeners();
    } catch (e) {
      debugPrint('保存AI配置失败: $e');
      rethrow;
    }
  }

  /// 标记解锁弹窗已显示
  Future<void> markUnlockDialogShown() async {
    _hasShownUnlockDialog = true;
    try {
      await _prefs?.setBool(_getUnlockDialogKey(), true);
      notifyListeners();
    } catch (e) {
      debugPrint('保存解锁弹窗状态失败: $e');
    }
  }

  /// 清除配置
  Future<void> clearConfig() async {
    _config = const AIConfig();
    
    try {
      await _prefs?.remove(_getConfigKey());
      // 同时清除安全存储的API密钥
      await clearApiKeyFromSecureStorage();
      notifyListeners();
    } catch (e) {
      debugPrint('清除AI配置失败: $e');
    }
  }
  
  /// 重置弹窗显示状态（用于测试）
  Future<void> resetUnlockDialogShown() async {
    _hasShownUnlockDialog = false;
    
    try {
      await _prefs?.setBool(_getUnlockDialogKey(), false);
    } catch (e) {
      debugPrint('重置弹窗状态失败: $e');
    }
  }

  // ==================== 安全存储API密钥 ====================

  /// 安全存储键名
  static const String _apiKeySecureKey = 'ai_api_key_secure';

  /// 从安全存储加载API密钥
  Future<void> loadApiKeyFromSecureStorage() async {
    debugPrint('=== 从安全存储加载API密钥 ===');
    try {
      final securityService = SecurityService();
      final encryptedKey = await securityService.secureRead(_apiKeySecureKey);
      debugPrint('加密密钥是否存在: ${encryptedKey != null}');
      debugPrint('加密密钥长度: ${encryptedKey?.length ?? 0}');
      
      if (encryptedKey != null && encryptedKey.isNotEmpty) {
        final decryptedKey = securityService.decryptData(encryptedKey);
        debugPrint('解密后的API密钥长度: ${decryptedKey.length}');
        _config = _config.copyWith(apiKey: decryptedKey);
      } else {
        debugPrint('安全存储中未找到API密钥');
      }
    } catch (e) {
      debugPrint('从安全存储加载API密钥失败: $e');
    }
  }

  /// 保存API密钥到安全存储
  Future<void> saveApiKeyToSecureStorage(String apiKey) async {
    try {
      final securityService = SecurityService();
      final encryptedKey = securityService.encryptData(apiKey);
      await securityService.secureWrite(_apiKeySecureKey, encryptedKey);
    } catch (e) {
      debugPrint('保存API密钥到安全存储失败: $e');
      rethrow;
    }
  }

  /// 清除安全存储的API密钥
  Future<void> clearApiKeyFromSecureStorage() async {
    try {
      final securityService = SecurityService();
      await securityService.secureDelete(_apiKeySecureKey);
    } catch (e) {
      debugPrint('清除安全存储的API密钥失败: $e');
    }
  }
}
