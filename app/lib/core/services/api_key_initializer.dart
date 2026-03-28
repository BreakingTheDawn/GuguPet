// API Key初始化器
// 用于在应用启动时配置预置的API Key
// ⚠️ 注意：这个文件不应该包含真实的API Key，只提供配置方法

import 'package:flutter/foundation.dart';
import 'multi_llm_service.dart';

/// API Key初始化器
/// 
/// 使用说明：
/// 1. 从安全的地方获取API Key（环境变量、后端接口等）
/// 2. 调用saveApiKey方法安全存储
/// 3. 永远不要硬编码API Key到代码中
class ApiKeyInitializer {
  final MultiLLMService _multiLLMService;

  ApiKeyInitializer(this._multiLLMService);

  /// 初始化所有API Key
  /// 
  /// 在实际应用中，应该从以下方式获取API Key：
  /// - 后端接口动态获取
  /// - 环境变量（仅开发环境）
  /// - 用户输入
  /// - 加密配置文件
  Future<void> initialize() async {
    debugPrint('=== API Key初始化 ===');
    
    // 当前实现：请手动调用saveApiKey方法配置
    debugPrint('请手动配置API Key，调用: _multiLLMService.saveApiKey(providerId, apiKey)');
  }

  /// 配置GLM API Key
  /// 
  /// 调用示例：
  /// ```dart
  /// await initializer.configureGLM('your-api-key-here');
  /// ```
  Future<void> configureGLM(String apiKey) async {
    if (apiKey.isEmpty) {
      throw ArgumentError('API Key不能为空');
    }
    
    await _multiLLMService.saveApiKey('glm', apiKey);
    debugPrint('GLM API Key已配置');
  }

  /// 配置混元API Key
  Future<void> configureHunyuan(String apiKey) async {
    if (apiKey.isEmpty) {
      throw ArgumentError('API Key不能为空');
    }
    
    await _multiLLMService.saveApiKey('hunyuan', apiKey);
    debugPrint('混元API Key已配置');
  }

  /// 配置Gemini API Key
  Future<void> configureGemini(String apiKey) async {
    if (apiKey.isEmpty) {
      throw ArgumentError('API Key不能为空');
    }
    
    await _multiLLMService.saveApiKey('gemini', apiKey);
    debugPrint('Gemini API Key已配置');
  }
}

/// API Key配置指南
/// 
/// ## 安全配置方式（按推荐程度排序）
/// 
/// ### 1. 后端接口动态获取（最推荐）
/// ```dart
/// // 应用启动时从后端获取
/// final response = await http.post(
///   Uri.parse('https://your-api.com/get-ai-keys'),
///   headers: {'Authorization': 'Bearer $userToken'},
/// );
/// final keys = jsonDecode(response.body);
/// await initializer.configureGLM(keys['glm']);
/// ```
/// 
/// ### 2. 用户手动输入
/// ```dart
/// // 在设置页面提供输入框
/// TextField(
///   onSubmitted: (value) async {
///     await initializer.configureGLM(value);
///   },
/// )
/// ```
/// 
/// ### 3. 环境变量（仅开发环境）
/// ```bash
/// # 编译时注入
/// flutter run --dart-define=GLM_API_KEY=your-key
/// ```
/// 
/// ## 安全注意事项
/// 
/// 1. ❌ 永远不要硬编码API Key到代码中
/// 2. ❌ 不要将API Key提交到Git仓库
/// 3. ❌ 不要在日志中打印API Key
/// 4. ❌ 不要通过网络明文传输API Key
/// 5. ✅ 使用flutter_secure_storage加密存储
/// 6. ✅ 定期轮换API Key
/// 7. ✅ 在后端控制API Key的访问权限
/// 
/// ## 当前配置
/// 
/// 请使用以下方式配置GLM API Key：
/// 
/// ```dart
/// final initializer = ApiKeyInitializer(multiLLMService);
/// await initializer.configureGLM('your-api-key-here');
/// ```
/// 
/// ⚠️ 注意：生产环境请使用更安全的方式获取API Key

