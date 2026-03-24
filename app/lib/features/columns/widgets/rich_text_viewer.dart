import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../../core/theme/app_colors.dart';

/// 富文本查看器组件
/// 支持HTML富文本渲染，包括图片加载和自定义样式
class RichTextViewer extends StatelessWidget {
  /// HTML内容字符串
  final String htmlContent;

  /// 自定义样式映射（可选）
  /// 键为HTML标签名，值为对应的Style对象
  final Map<String, Style>? customStyles;

  /// 图片点击回调（可选）
  /// 参数为图片的URL地址
  final void Function(String url)? onImageTap;

  /// 文本最大行数（可选）
  /// 超出时显示省略号
  final int? maxLines;

  /// 文本溢出处理方式
  final TextOverflow textOverflow;

  /// 是否启用图片点击预览
  /// 默认为true，点击图片时会调用onImageTap
  final bool enableImagePreview;

  const RichTextViewer({
    super.key,
    required this.htmlContent,
    this.customStyles,
    this.onImageTap,
    this.maxLines,
    this.textOverflow = TextOverflow.ellipsis,
    this.enableImagePreview = true,
  });

  @override
  Widget build(BuildContext context) {
    // 如果内容为空，显示占位符
    if (htmlContent.isEmpty) {
      return _buildEmptyPlaceholder();
    }

    return Html(
      // HTML数据源
      data: htmlContent,

      // 默认样式配置
      style: _buildDefaultStyles(),

      // 自定义渲染器（用于图片等特殊元素）
      extensions: _buildExtensions(),

      // 文本溢出处理
      shrinkWrap: true,

      // 图片加载失败时的回调
      onLinkTap: (url, attributes, element) {
        // 处理链接点击
        if (url != null) {
          debugPrint('链接被点击: $url');
        }
      },
    );
  }

  /// 构建空内容占位符
  Widget _buildEmptyPlaceholder() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 空内容图标
            Icon(
              Icons.article_outlined,
              size: 48,
              color: AppColors.archiveTextMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            // 提示文字
            Text(
              '暂无内容',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.archiveTextMuted.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建默认样式
  /// 为各种HTML标签定义档案馆风格的样式
  /// 注意：flutter_html 3.0 版本使用新的 Style API
  Map<String, Style> _buildDefaultStyles() {
    // 默认样式映射
    final defaultStyles = <String, Style>{
      // ═══════════════════════════════════════════════════════════
      // 标题样式 (h1 - h6)
      // ═══════════════════════════════════════════════════════════
      'h1': Style(
        color: AppColors.archiveText,
        fontSize: FontSize(24),
        fontWeight: FontWeight.bold,
        margin: Margins.only(bottom: 16, top: 16),
        lineHeight: const LineHeight(1.4),
      ),
      'h2': Style(
        color: AppColors.archiveText,
        fontSize: FontSize(22),
        fontWeight: FontWeight.bold,
        margin: Margins.only(bottom: 14, top: 14),
        lineHeight: const LineHeight(1.4),
      ),
      'h3': Style(
        color: AppColors.archiveText,
        fontSize: FontSize(20),
        fontWeight: FontWeight.bold,
        margin: Margins.only(bottom: 12, top: 12),
        lineHeight: const LineHeight(1.4),
      ),
      'h4': Style(
        color: AppColors.archiveText,
        fontSize: FontSize(18),
        fontWeight: FontWeight.w600,
        margin: Margins.only(bottom: 10, top: 10),
        lineHeight: const LineHeight(1.4),
      ),
      'h5': Style(
        color: AppColors.archiveText,
        fontSize: FontSize(16),
        fontWeight: FontWeight.w600,
        margin: Margins.only(bottom: 8, top: 8),
        lineHeight: const LineHeight(1.4),
      ),
      'h6': Style(
        color: AppColors.archiveText,
        fontSize: FontSize(14),
        fontWeight: FontWeight.w600,
        margin: Margins.only(bottom: 6, top: 6),
        lineHeight: const LineHeight(1.4),
      ),

      // ═══════════════════════════════════════════════════════════
      // 段落和文本样式
      // ═══════════════════════════════════════════════════════════
      'p': Style(
        color: AppColors.archiveText,
        fontSize: FontSize(15),
        margin: Margins.only(bottom: 12),
        lineHeight: const LineHeight(1.6),
        textOverflow: textOverflow,
        maxLines: maxLines,
      ),
      'span': Style(
        color: AppColors.archiveText,
        fontSize: FontSize(15),
        lineHeight: const LineHeight(1.6),
      ),

      // ═══════════════════════════════════════════════════════════
      // 强调样式
      // ═══════════════════════════════════════════════════════════
      'strong': Style(
        color: AppColors.archiveText,
        fontWeight: FontWeight.bold,
      ),
      'b': Style(
        color: AppColors.archiveText,
        fontWeight: FontWeight.bold,
      ),
      'em': Style(
        color: AppColors.archiveText,
        fontStyle: FontStyle.italic,
      ),
      'i': Style(
        color: AppColors.archiveText,
        fontStyle: FontStyle.italic,
      ),

      // ═══════════════════════════════════════════════════════════
      // 列表样式
      // ═══════════════════════════════════════════════════════════
      'ul': Style(
        margin: Margins.only(bottom: 12, left: 16),
        padding: HtmlPaddings.only(left: 8),
      ),
      'ol': Style(
        margin: Margins.only(bottom: 12, left: 16),
        padding: HtmlPaddings.only(left: 8),
      ),
      'li': Style(
        color: AppColors.archiveText,
        fontSize: FontSize(15),
        margin: Margins.only(bottom: 4),
        lineHeight: const LineHeight(1.5),
      ),

      // ═══════════════════════════════════════════════════════════
      // 引用块样式
      // ═══════════════════════════════════════════════════════════
      'blockquote': Style(
        color: AppColors.archiveTextMuted,
        fontSize: FontSize(14),
        fontStyle: FontStyle.italic,
        margin: Margins.only(bottom: 12, left: 16, right: 16),
        padding: HtmlPaddings.only(left: 12, top: 8, bottom: 8),
        border: Border(
          left: BorderSide(
            color: AppColors.archiveAccent,
            width: 3,
          ),
        ),
        backgroundColor: AppColors.archiveBackground,
        lineHeight: const LineHeight(1.5),
      ),

      // ═══════════════════════════════════════════════════════════
      // 代码块样式
      // ═══════════════════════════════════════════════════════════
      'code': Style(
        color: AppColors.archiveAccentDark,
        fontSize: FontSize(13),
        backgroundColor: AppColors.muted,
        padding: HtmlPaddings.symmetric(horizontal: 4, vertical: 2),
      ),
      'pre': Style(
        color: AppColors.archiveText,
        fontSize: FontSize(13),
        backgroundColor: AppColors.muted,
        margin: Margins.only(bottom: 12),
        padding: HtmlPaddings.all(12),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
        whiteSpace: WhiteSpace.pre,
      ),

      // ═══════════════════════════════════════════════════════════
      // 图片样式
      // ═══════════════════════════════════════════════════════════
      'img': Style(
        margin: Margins.symmetric(vertical: 12),
        width: Width(double.infinity),
      ),

      // ═══════════════════════════════════════════════════════════
      // 链接样式
      // ═══════════════════════════════════════════════════════════
      'a': Style(
        color: AppColors.archiveAccent,
        textDecoration: TextDecoration.underline,
      ),

      // ═══════════════════════════════════════════════════════════
      // 分隔线样式
      // ═══════════════════════════════════════════════════════════
      'hr': Style(
        margin: Margins.symmetric(vertical: 16),
        border: Border(
          bottom: BorderSide(
            color: AppColors.archiveTextMuted.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),

      // ═══════════════════════════════════════════════════════════
      // 表格样式
      // ═══════════════════════════════════════════════════════════
      'table': Style(
        margin: Margins.only(bottom: 12),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      'th': Style(
        color: AppColors.archiveText,
        fontWeight: FontWeight.bold,
        fontSize: FontSize(14),
        padding: HtmlPaddings.all(8),
        backgroundColor: AppColors.archiveBackground,
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      'td': Style(
        color: AppColors.archiveText,
        fontSize: FontSize(14),
        padding: HtmlPaddings.all(8),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
    };

    // 合并自定义样式（自定义样式优先级更高）
    if (customStyles != null) {
      defaultStyles.addAll(customStyles!);
    }

    return defaultStyles;
  }

  /// 构建HTML扩展
  /// 用于自定义渲染器（如图片加载、特殊标签处理等）
  List<HtmlExtension> _buildExtensions() {
    return [
      // 图片自定义渲染器
      TagExtension(
        tagsToExtend: {'img'},
        builder: (extensionContext) {
          return _buildImageWidget(extensionContext);
        },
      ),
    ];
  }

  /// 构建图片组件
  /// 支持加载占位符、错误处理和点击预览
  Widget _buildImageWidget(ExtensionContext extensionContext) {
    // 获取图片属性
    final attributes = extensionContext.attributes;
    final src = attributes['src'] ?? '';
    final alt = attributes['alt'] ?? '图片';

    // 如果没有图片地址，显示错误占位符
    if (src.isEmpty) {
      return _buildImageErrorWidget('图片地址为空');
    }

    // 构建图片组件
    Widget imageWidget = _buildNetworkImage(src, alt);

    // 如果启用图片预览，添加点击手势
    if (enableImagePreview && onImageTap != null) {
      imageWidget = GestureDetector(
        onTap: () => onImageTap!(src),
        child: imageWidget,
      );
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: imageWidget,
    );
  }

  /// 构建网络图片组件
  /// 支持加载占位符和错误处理
  Widget _buildNetworkImage(String url, String alt) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        fit: BoxFit.cover,
        // 加载中占位符
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return _buildImageLoadingWidget(loadingProgress);
        },
        // 加载错误占位符
        errorBuilder: (context, error, stackTrace) {
          return _buildImageErrorWidget(alt);
        },
      ),
    );
  }

  /// 构建图片加载中占位符
  Widget _buildImageLoadingWidget(ImageChunkEvent loadingProgress) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.archiveBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 加载进度指示器
            CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
              color: AppColors.archiveAccent,
            ),
            const SizedBox(height: 12),
            // 加载提示文字
            Text(
              '图片加载中...',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.archiveTextMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建图片加载错误占位符
  Widget _buildImageErrorWidget(String alt) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.muted,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 错误图标
            Icon(
              Icons.broken_image_outlined,
              size: 32,
              color: AppColors.archiveTextMuted.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 8),
            // 错误提示文字
            Text(
              alt.isNotEmpty ? alt : '图片加载失败',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.archiveTextMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
