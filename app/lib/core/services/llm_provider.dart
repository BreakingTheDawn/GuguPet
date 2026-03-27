import 'llm_service.dart';
import 'adapters/gemini_adapter.dart';
import 'llm_config.dart';

/// 支持的AI平台
/// 当前仅支持Google Gemini
enum LLMProvider {
  gemini('Google Gemini', 'gemini-1.5-flash');

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
    }
  }
}
