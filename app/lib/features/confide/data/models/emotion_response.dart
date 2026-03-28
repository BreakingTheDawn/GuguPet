/// AI回复情感类型枚举
/// 与宠物动画类型对应
enum AIEmotionType {
  happy,   // 开心
  sad,     // 难过
  angry,   // 生气
  excited, // 兴奋
  normal,  // 平静
}

/// AI情感响应模型
/// 用于解析AI回复中的情感标签并映射到动画
class EmotionResponse {
  /// 显示给用户的文本内容（已移除情感标签）
  final String content;
  
  /// 情感类型
  final AIEmotionType emotion;
  
  /// 原始回复内容（包含情感标签）
  final String rawContent;

  const EmotionResponse({
    required this.content,
    required this.emotion,
    required this.rawContent,
  });

  /// 情感标签正则表达式
  /// 匹配格式: [EMOTION:xxx]
  static final RegExp _emotionTagRegex = RegExp(
    r'\[EMOTION:(\w+)\]',
    caseSensitive: true,
  );

  /// 从AI原始回复解析情感响应
  /// 自动提取情感标签并移除
  factory EmotionResponse.fromRawResponse(String rawContent) {
    // 查找情感标签
    final match = _emotionTagRegex.firstMatch(rawContent);
    
    AIEmotionType emotion = AIEmotionType.normal; // 默认情感
    String content = rawContent;
    
    if (match != null) {
      // 提取情感类型
      final emotionStr = match.group(1)?.toLowerCase() ?? 'normal';
      emotion = _parseEmotionType(emotionStr);
      
      // 移除情感标签，得到纯净内容
      content = rawContent.replaceFirst(_emotionTagRegex, '').trim();
    }
    
    return EmotionResponse(
      content: content,
      emotion: emotion,
      rawContent: rawContent,
    );
  }

  /// 解析情感类型字符串
  static AIEmotionType _parseEmotionType(String emotionStr) {
    return switch (emotionStr) {
      'happy' => AIEmotionType.happy,
      'sad' => AIEmotionType.sad,
      'angry' => AIEmotionType.angry,
      'excited' => AIEmotionType.excited,
      'normal' => AIEmotionType.normal,
      _ => AIEmotionType.normal, // 未知情感默认为平静
    };
  }

  /// 获取情感类型的中文名称
  String get emotionName {
    return switch (emotion) {
      AIEmotionType.happy => '开心',
      AIEmotionType.sad => '难过',
      AIEmotionType.angry => '生气',
      AIEmotionType.excited => '兴奋',
      AIEmotionType.normal => '平静',
    };
  }

  /// 复制并修改
  EmotionResponse copyWith({
    String? content,
    AIEmotionType? emotion,
    String? rawContent,
  }) {
    return EmotionResponse(
      content: content ?? this.content,
      emotion: emotion ?? this.emotion,
      rawContent: rawContent ?? this.rawContent,
    );
  }

  @override
  String toString() {
    return 'EmotionResponse(content: $content, emotion: $emotionName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EmotionResponse &&
        other.content == content &&
        other.emotion == emotion &&
        other.rawContent == rawContent;
  }

  @override
  int get hashCode => Object.hash(content, emotion, rawContent);
}
