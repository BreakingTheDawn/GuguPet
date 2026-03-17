class IntentResult {
  final String actionType;
  final String emotionType;
  final List<String> keywords;
  final double confidence;

  IntentResult({
    required this.actionType,
    required this.emotionType,
    required this.keywords,
    required this.confidence,
  });
}

class NegationContext {
  final bool hasNegation;
  final String? negationWord;
  final String? affectedPart;

  NegationContext({
    required this.hasNegation,
    this.negationWord,
    this.affectedPart,
  });
}

class IntentEngine {
  final Map<String, List<String>> _keywordRules;
  final List<String> _negationWords;
  final Map<String, String> _emotionMapping;
  final Map<String, String> _negationMapping;

  IntentEngine({
    Map<String, List<String>>? keywordRules,
    List<String>? negationWords,
    Map<String, String>? emotionMapping,
    Map<String, String>? negationMapping,
  })  : _keywordRules = keywordRules ?? _defaultKeywordRules,
        _negationWords = negationWords ?? _defaultNegationWords,
        _emotionMapping = emotionMapping ?? _defaultEmotionMapping,
        _negationMapping = negationMapping ?? _defaultNegationMapping;

  static const Map<String, List<String>> _defaultKeywordRules = {
    'resume_submit': [
      '投了',
      '投递',
      '发简历',
      '海投',
      '投了几份',
      '投完',
      '简历发',
      '发了简历',
      '投出去'
    ],
    'interview_received': [
      '面试',
      '邀约',
      '叫我去面试',
      '进面',
      '收到面试',
      '面试邀请',
      '约面试',
      '面试通知'
    ],
    'job_rejected': [
      '拒了',
      '没通过',
      '不合适',
      '拒信',
      '挂了',
      '被拒',
      '没过',
      '刷了',
      '凉凉'
    ],
    'offer_received': [
      'offer',
      '录用',
      '录取',
      '通过了',
      '上班',
      '入职',
      'offer了',
      '拿到offer',
      '定下来了'
    ],
    'slacking': [
      '没投',
      '躺平',
      '摆烂',
      '没看',
      '不想动',
      '休息',
      '摸鱼',
      '懒得'
    ],
    'anxiety': [
      '烦',
      '难过',
      '崩溃',
      '焦虑',
      '迷茫',
      '没用',
      '压力大',
      '心累',
      '绝望',
      '想哭'
    ],
  };

  static const List<String> _defaultNegationWords = [
    '没',
    '没有',
    '不',
    '还没',
    '不是',
    '别'
  ];

  static const Map<String, String> _defaultEmotionMapping = {
    'resume_submit': 'positive',
    'interview_received': 'positive',
    'job_rejected': 'negative',
    'offer_received': 'positive',
    'slacking': 'neutral',
    'anxiety': 'negative',
    'unknown': 'neutral',
  };

  static const Map<String, String> _defaultNegationMapping = {
    'resume_submit': 'slacking',
    'interview_received': 'slacking',
    'offer_received': 'slacking',
  };

  Future<IntentResult> analyze(String content) async {
    final cleanedContent = _preprocess(content);
    final negationContext = _detectNegation(cleanedContent);
    final keywords = _extractKeywords(cleanedContent);
    final actionType = _classifyAction(keywords, negationContext);
    final emotionType = _classifyEmotion(actionType);
    final confidence = _calculateConfidence(keywords, actionType);

    return IntentResult(
      actionType: actionType,
      emotionType: emotionType,
      keywords: keywords,
      confidence: confidence,
    );
  }

  String _preprocess(String content) {
    return content
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s\u4e00-\u9fa5]'), '');
  }

  NegationContext _detectNegation(String content) {
    for (final word in _negationWords) {
      if (content.contains(word)) {
        final parts = content.split(word);
        return NegationContext(
          hasNegation: true,
          negationWord: word,
          affectedPart: parts.isNotEmpty ? parts.last : '',
        );
      }
    }
    return NegationContext(hasNegation: false);
  }

  List<String> _extractKeywords(String content) {
    final matchedKeywords = <String>[];
    for (final entry in _keywordRules.entries) {
      for (final keyword in entry.value) {
        if (content.contains(keyword)) {
          matchedKeywords.add(keyword);
        }
      }
    }
    return matchedKeywords;
  }

  String _classifyAction(List<String> keywords, NegationContext negation) {
    if (keywords.isEmpty) return 'unknown';

    for (final entry in _keywordRules.entries) {
      for (final keyword in keywords) {
        if (entry.value.contains(keyword)) {
          if (negation.hasNegation && _isNegationApplicable(keyword, negation)) {
            return _getNegatedAction(entry.key);
          }
          return entry.key;
        }
      }
    }
    return 'unknown';
  }

  bool _isNegationApplicable(String keyword, NegationContext negation) {
    return negation.affectedPart?.contains(keyword) ?? false;
  }

  String _getNegatedAction(String actionType) {
    return _negationMapping[actionType] ?? 'unknown';
  }

  String _classifyEmotion(String actionType) {
    return _emotionMapping[actionType] ?? 'neutral';
  }

  double _calculateConfidence(List<String> keywords, String actionType) {
    if (actionType == 'unknown') return 0.0;
    final ruleKeywords = _keywordRules[actionType] ?? [];
    final matchCount = keywords.where((k) => ruleKeywords.contains(k)).length;
    return (matchCount / ruleKeywords.length).clamp(0.0, 1.0);
  }
}
