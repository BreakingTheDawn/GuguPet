class ResponsePattern {
  final RegExp pattern;
  final String text;

  const ResponsePattern({required this.pattern, required this.text});
}

class ResponseService {
  static final List<ResponsePattern> _patterns = [
    ResponsePattern(
      pattern: RegExp(r'累|疲|倦|撑|崩|烦|难|苦|压力'),
      text: '累了就歇歇,你已经很努力了 🤍 轻轻抱抱你~',
    ),
    ResponsePattern(
      pattern: RegExp(r'面试|hr|HR|笔试|offer|Offer|OFFER'),
      text: '面试官看到你一定会心动的!咕咕为你加油 ✨',
    ),
    ResponsePattern(
      pattern: RegExp(r'拒|没过|挂|凉|凉凉|拒绝|失败'),
      text: '他们眼光有问题!你是最棒的,咕咕最喜欢你 🫂',
    ),
    ResponsePattern(
      pattern: RegExp(r'开心|高兴|棒|好消息|发|拿到|通过|过了'),
      text: '太好了!咕咕也为你感到超级开心~ 🎉🎊',
    ),
    ResponsePattern(
      pattern: RegExp(r'不知道|迷茫|迷失|找不到|方向'),
      text: '迷茫也没关系,每一步都算数的,我一直陪着你 🌟',
    ),
  ];

  static final List<String> _defaultResponses = [
    '嗯嗯,我都听到了,说出来感觉好一点了吗? 🐧',
    '你已经很棒了,不管怎样咕咕都支持你 ✨',
    '今天的委屈,明天变成铠甲,加油!',
    '咕咕在这里,轻轻抱抱你 🤍',
  ];

  String getResponse(String input) {
    for (final pattern in _patterns) {
      if (pattern.pattern.hasMatch(input)) {
        return pattern.text;
      }
    }
    return _defaultResponses[DateTime.now().millisecondsSinceEpoch % _defaultResponses.length];
  }
}
