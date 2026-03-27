import 'llm_service.dart';
import 'adapters/gemini_adapter.dart';
import 'adapters/gemini_sdk_adapter.dart';
import 'llm_config.dart';

/// 支持的AI平台
/// 当前支持Google Gemini（HTTP和SDK两种实现）
enum LLMProvider {
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
      case LLMProvider.gemini:
        return GeminiAdapter(config: config);
      case LLMProvider.geminiSDK:
        return GeminiSDKAdapter(config: config);
    }
  }
}
