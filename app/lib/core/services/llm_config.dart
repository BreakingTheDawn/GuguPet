/// 大模型服务配置
class LLMConfig {
  /// API密钥（从环境变量或安全存储获取）
  final String apiKey;
  
  /// API端点
  final String endpoint;
  
  /// 模型名称
  final String model;
  
  /// 最大Token数
  final int maxTokens;
  
  /// 温度参数
  final double temperature;
  
  /// 请求超时（毫秒）
  final int timeoutMs;

  const LLMConfig({
    required this.apiKey,
    this.endpoint = 'https://api.openai.com/v1/chat/completions',
    this.model = 'gpt-4o-mini',
    this.maxTokens = 500,
    this.temperature = 0.7,
    this.timeoutMs = 10000,
  });

  /// 创建空配置（禁用LLM）
  const LLMConfig.disabled()
      : apiKey = '',
        endpoint = '',
        model = '',
        maxTokens = 0,
        temperature = 0,
        timeoutMs = 0;

  /// 是否已配置
  bool get isConfigured => apiKey.isNotEmpty && endpoint.isNotEmpty;
}
