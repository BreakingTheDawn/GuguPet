/// 内容图片模型
/// 用于存储专栏章节中的图片信息
class ContentImage {
  /// 图片URL地址
  final String url;

  /// 图片说明文字（可选）
  final String? caption;

  /// 图片宽度（像素）
  final int width;

  /// 图片高度（像素）
  final int height;

  ContentImage({
    required this.url,
    this.caption,
    required this.width,
    required this.height,
  });

  /// 将模型转换为JSON格式
  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'caption': caption,
      'width': width,
      'height': height,
    };
  }

  /// 从JSON数据创建模型实例
  factory ContentImage.fromJson(Map<String, dynamic> json) {
    return ContentImage(
      url: json['url'] as String,
      caption: json['caption'] as String?,
      width: json['width'] as int,
      height: json['height'] as int,
    );
  }

  /// 复制并修改模型属性
  ContentImage copyWith({
    String? url,
    String? caption,
    int? width,
    int? height,
  }) {
    return ContentImage(
      url: url ?? this.url,
      caption: caption ?? this.caption,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }
}
