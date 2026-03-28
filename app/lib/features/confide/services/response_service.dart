import '../../../core/services/app_strings.dart';

/// 情感类型枚举
enum EmotionType {
  positive,   // 积极 - happy 动画
  negative,   // 消极 - angry 动画
  neutral,    // 中性 - idle 动画
}

/// 响应结果
class ResponseResult {
  /// 响应文本
  final String text;
  
  /// 情感类型
  final EmotionType emotion;

  const ResponseResult({
    required this.text,
    required this.emotion,
  });
}

/// 响应模式匹配类
class ResponsePattern {
  /// 正则表达式模式
  final RegExp pattern;
  
  /// 获取文本的回调函数
  final String Function() getText;
  
  /// 情感类型
  final EmotionType emotion;

  const ResponsePattern({
    required this.pattern,
    required this.getText,
    this.emotion = EmotionType.neutral,
  });
}

/// 响应服务
/// 根据用户输入匹配对应的响应文本和情感类型
class ResponseService {
  /// 获取响应模式列表（使用配置化的关键词）
  List<ResponsePattern> get _patterns {
    final keywords = AppStrings().confide.emotionKeywords;
    
    return [
      // 消极情感 - 触发生气/担忧动画
      ResponsePattern(
        pattern: RegExp(keywords.negative.join('|')),
        getText: () => AppStrings().confide.responseTired,
        emotion: EmotionType.negative,
      ),
      ResponsePattern(
        pattern: RegExp(keywords.rejected.join('|')),
        getText: () => AppStrings().confide.responseRejected,
        emotion: EmotionType.negative,
      ),
      ResponsePattern(
        pattern: RegExp(keywords.lost.join('|')),
        getText: () => AppStrings().confide.responseLost,
        emotion: EmotionType.negative,
      ),
      // 积极情感 - 触发高兴动画
      ResponsePattern(
        pattern: RegExp(keywords.positive.join('|')),
        getText: () => AppStrings().confide.responseHappy,
        emotion: EmotionType.positive,
      ),
      ResponsePattern(
        pattern: RegExp(keywords.interview.join('|')),
        getText: () => AppStrings().confide.responseInterview,
        emotion: EmotionType.positive,
      ),
    ];
  }
  
  /// 获取默认响应列表
  List<String> get _defaultResponses => AppStrings().confide.defaultResponses;

  /// 根据用户输入获取响应结果（包含文本和情感类型）
  ResponseResult getResponseWithEmotion(String input) {
    for (final pattern in _patterns) {
      if (pattern.pattern.hasMatch(input)) {
        return ResponseResult(
          text: pattern.getText(),
          emotion: pattern.emotion,
        );
      }
    }
    return ResponseResult(
      text: _defaultResponses[DateTime.now().millisecondsSinceEpoch % _defaultResponses.length],
      emotion: EmotionType.neutral,
    );
  }

  /// 根据用户输入获取响应文本（兼容旧接口）
  String getResponse(String input) {
    return getResponseWithEmotion(input).text;
  }
}
