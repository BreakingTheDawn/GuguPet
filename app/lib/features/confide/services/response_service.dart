import '../../../core/services/app_strings.dart';

/// 情感类型枚举
enum EmotionType {
  positive,   // 积极 - happy 动画
  negative,   // 消极 - angry 动画
  neutral,    // 中性 - idle 动画
}

/// 响应结果
class ResponseResult {
  final String text;
  final EmotionType emotion;

  const ResponseResult({
    required this.text,
    required this.emotion,
  });
}

/// 响应模式匹配类
class ResponsePattern {
  final RegExp pattern;
  final String Function() getText;
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
  /// 响应模式列表
  static List<ResponsePattern> get _patterns => [
    // 消极情感 - 触发生气/担忧动画
    ResponsePattern(
      pattern: RegExp(r'累|疲|倦|撑|崩|烦|难|苦|压力|生气|愤怒|气死|讨厌'),
      getText: () => AppStrings().confide.responseTired,
      emotion: EmotionType.negative,
    ),
    ResponsePattern(
      pattern: RegExp(r'拒|没过|挂|凉|凉凉|拒绝|失败|不行'),
      getText: () => AppStrings().confide.responseRejected,
      emotion: EmotionType.negative,
    ),
    ResponsePattern(
      pattern: RegExp(r'不知道|迷茫|迷失|找不到|方向'),
      getText: () => AppStrings().confide.responseLost,
      emotion: EmotionType.negative,
    ),
    // 积极情感 - 触发高兴动画
    ResponsePattern(
      pattern: RegExp(r'开心|高兴|棒|好消息|发|拿到|通过|过了|谢谢|感谢|喜欢'),
      getText: () => AppStrings().confide.responseHappy,
      emotion: EmotionType.positive,
    ),
    ResponsePattern(
      pattern: RegExp(r'面试|hr|HR|笔试|offer|Offer|OFFER'),
      getText: () => AppStrings().confide.responseInterview,
      emotion: EmotionType.positive,
    ),
  ];

  /// 默认响应列表
  static List<String> get _defaultResponses => [
    AppStrings().confide.responseDefault1,
    AppStrings().confide.responseDefault2,
    AppStrings().confide.responseDefault3,
    AppStrings().confide.responseDefault4,
  ];

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
