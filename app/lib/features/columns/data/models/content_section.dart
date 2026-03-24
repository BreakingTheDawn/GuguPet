import 'content_image.dart';

/// 内容章节模型
/// 用于存储专栏的章节内容，包含标题、正文和图片列表
class ContentSection {
  /// 章节标题
  final String title;

  /// 章节正文内容
  final String content;

  /// 章节包含的图片列表
  final List<ContentImage> images;

  ContentSection({
    required this.title,
    required this.content,
    this.images = const [],
  });

  /// 将模型转换为JSON格式
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'images': images.map((img) => img.toJson()).toList(),
    };
  }

  /// 从JSON数据创建模型实例
  factory ContentSection.fromJson(Map<String, dynamic> json) {
    return ContentSection(
      title: json['title'] as String,
      content: json['content'] as String,
      images: (json['images'] as List<dynamic>?)
              ?.map((img) => ContentImage.fromJson(img as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// 复制并修改模型属性
  ContentSection copyWith({
    String? title,
    String? content,
    List<ContentImage>? images,
  }) {
    return ContentSection(
      title: title ?? this.title,
      content: content ?? this.content,
      images: images ?? this.images,
    );
  }
}
