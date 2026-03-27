import 'llm_service.dart';
import 'adapters/gemini_adapter.dart';
import 'adapters/gemini_sdk_adapter.dart';
import 'adapters/glm_adapter.dart';
import 'adapters/hunyuan_adapter.dart';
import 'llm_config.dart';

/// 支持的AI平台
/// 主用：GLM-4.7 (智谱)
/// 备用：混元 (腾讯)
/// 可选：Gemini (Google)
enum LLMProvider {
  glm('智谱GLM-4.7', 'glm-4.7-flash'),
  hunyuan('腾讯混元', 'hunyuan-lite'),
  gemini('Google Gemini (HTTP)', 'gemini-2.0-flash-exp'),
  geminiSDK('Google Gemini (SDK)', 'gemini-2.0-flash-exp');

  final String displayName;
  final String defaultModel;
  
  const LLMProvider(this.displayName, this.defaultModel);
}

/// LLM服务工厂
class LLMServiceFactory {
  /// 创建LLM服务实例
  static LLMService create(LLMProvider provider, LLMConfig config) {
    switch (provider) {
      case LLMProvider.glm:
        return GLMAdapter(config: config);
      case LLMProvider.hunyuan:
        return HunyuanAdapter(config: config);
      case LLMProvider.gemini:
        return GeminiAdapter(config: config);
      case LLMProvider.geminiSDK:
        return GeminiSDKAdapter(config: config);
    }
  }
}
