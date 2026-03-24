import 'content_section.dart';

/// 专栏完整内容模型
/// 用于存储专栏的详细信息，包括基本信息、内容章节、购买和收藏状态
class ColumnContent {
  /// 专栏唯一标识ID
  final String id;

  /// 专栏标题
  final String title;

  /// 分类标签名称
  final String category;

  /// 分类标签背景色（十六进制颜色值）
  final String catBg;

  /// 分类标签文字颜色（十六进制颜色值）
  final String catColor;

  /// 专栏价格
  final double price;

  /// 专栏图标（emoji表情）
  final String emoji;

  /// 预览内容列表（购买前可见的内容片段）
  final List<String> previewContent;

  /// 完整富文本内容（HTML格式，购买后可见）
  final String fullContent;

  /// 章节列表（结构化的内容分段）
  final List<ContentSection> sections;

  /// 是否已购买
  final bool isPurchased;

  /// 是否已收藏
  final bool isFavorite;

  ColumnContent({
    required this.id,
    required this.title,
    required this.category,
    required this.catBg,
    required this.catColor,
    required this.price,
    required this.emoji,
    this.previewContent = const [],
    this.fullContent = '',
    this.sections = const [],
    this.isPurchased = false,
    this.isFavorite = false,
  });

  /// 将模型转换为JSON格式
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'catBg': catBg,
      'catColor': catColor,
      'price': price,
      'emoji': emoji,
      'previewContent': previewContent,
      'fullContent': fullContent,
      'sections': sections.map((s) => s.toJson()).toList(),
      'isPurchased': isPurchased,
      'isFavorite': isFavorite,
    };
  }

  /// 从JSON数据创建模型实例
  factory ColumnContent.fromJson(Map<String, dynamic> json) {
    return ColumnContent(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      catBg: json['catBg'] as String,
      catColor: json['catColor'] as String,
      price: (json['price'] as num).toDouble(),
      emoji: json['emoji'] as String,
      previewContent: (json['previewContent'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      fullContent: json['fullContent'] as String? ?? '',
      sections: (json['sections'] as List<dynamic>?)
              ?.map((s) => ContentSection.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      isPurchased: json['isPurchased'] as bool? ?? false,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  /// 复制并修改模型属性
  ColumnContent copyWith({
    String? id,
    String? title,
    String? category,
    String? catBg,
    String? catColor,
    double? price,
    String? emoji,
    List<String>? previewContent,
    String? fullContent,
    List<ContentSection>? sections,
    bool? isPurchased,
    bool? isFavorite,
  }) {
    return ColumnContent(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      catBg: catBg ?? this.catBg,
      catColor: catColor ?? this.catColor,
      price: price ?? this.price,
      emoji: emoji ?? this.emoji,
      previewContent: previewContent ?? this.previewContent,
      fullContent: fullContent ?? this.fullContent,
      sections: sections ?? this.sections,
      isPurchased: isPurchased ?? this.isPurchased,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
