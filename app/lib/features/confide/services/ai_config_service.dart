import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/llm_provider.dart';

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
    try {
      _prefs = await SharedPreferences.getInstance();
      
      // 如果用户ID变化，需要重新加载对应用户的配置
      if (_currentUserId != userId) {
        _currentUserId = userId;
        await _loadConfig();
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('初始化AI配置服务失败: $e');
    }
  }

  /// 加载配置
  Future<void> _loadConfig() async {
    // 加载配置
    final configJson = _prefs?.getString(_getConfigKey());
    if (configJson != null && configJson.isNotEmpty) {
      try {
        final decoded = jsonDecode(configJson) as Map<String, dynamic>;
        _config = AIConfig.fromJson(decoded);
      } catch (e) {
        debugPrint('解析AI配置失败: $e');
      }
    } else {
      // 如果没有保存的配置，使用默认配置
      _config = const AIConfig();
    }
    
    // 加载弹窗显示状态
    _hasShownUnlockDialog = _prefs?.getBool(_getUnlockDialogKey()) ?? false;
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
      await _prefs?.setString(_getConfigKey(), jsonEncode(config.toJson()));
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
    
    notifyListeners();
  }
}
