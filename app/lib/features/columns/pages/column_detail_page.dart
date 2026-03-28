import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/app_strings.dart';
import '../providers/column_provider.dart';
import '../widgets/rich_text_viewer.dart';

// ═══════════════════════════════════════════════════════════════════════════════
/// 专栏详情页面
/// 展示专栏的完整内容，包括标题、分类、价格、富文本内容等
/// 支持购买、收藏、分享等操作
// ═══════════════════════════════════════════════════════════════════════════════
class ColumnDetailPage extends StatefulWidget {
  /// 专栏ID
  final String columnId;

  /// 用户ID（可选）
  final String? userId;

  const ColumnDetailPage({
    super.key,
    required this.columnId,
    this.userId,
  });

  @override
  State<ColumnDetailPage> createState() => _ColumnDetailPageState();
}

class _ColumnDetailPageState extends State<ColumnDetailPage> {
  // ────────────────────────────────────────────────────────────────────────────
  // 生命周期方法
  // ────────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    // 页面加载时获取专栏详情
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadColumnDetail();
    });
  }

  /// 加载专栏详情
  void _loadColumnDetail() {
    final provider = context.read<ColumnProvider>();
    provider.loadColumnDetail(
      widget.columnId,
      userId: widget.userId,
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 构建方法
  // ────────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 背景色
      backgroundColor: AppColors.archiveBackground,
      // 主体内容
      body: Consumer<ColumnProvider>(
        builder: (context, provider, child) {
          // 加载状态
          if (provider.isLoading) {
            return _buildLoadingWidget();
          }

          // 错误状态
          if (provider.errorMessage != null) {
            return _buildErrorWidget(provider.errorMessage!);
          }

          // 正常状态
          if (provider.columnContent == null) {
            return _buildEmptyWidget();
          }

          // 构建页面内容
          return Column(
            children: [
              // 顶部导航栏
              _buildAppBar(provider),

              // 内容区域
              Expanded(
                child: _buildContent(provider),
              ),

              // 底部操作栏
              _buildBottomBar(provider),
            ],
          );
        },
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 顶部导航栏
  // ────────────────────────────────────────────────────────────────────────────

  /// 构建顶部导航栏
  Widget _buildAppBar(ColumnProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.archiveModalBackground,
        boxShadow: [
          BoxShadow(
            color: AppColors.archiveTextMuted.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              // 返回按钮
              _buildBackButton(),

              // 标题
              Expanded(
                child: Text(
                  AppStrings().columns.title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.archiveText,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // 收藏按钮
              _buildFavoriteButton(provider),

              // 分享按钮
              _buildShareButton(provider),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建返回按钮
  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(
          Icons.arrow_back_ios_new,
          size: 20,
          color: AppColors.archiveText,
        ),
      ),
    );
  }

  /// 构建收藏按钮
  Widget _buildFavoriteButton(ColumnProvider provider) {
    return GestureDetector(
      onTap: provider.isOperating ? null : () => _toggleFavorite(provider),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(
          provider.isFavorited
              ? Icons.favorite
              : Icons.favorite_border_outlined,
          size: 22,
          color: provider.isFavorited
              ? AppColors.error
              : AppColors.archiveTextMuted,
        ),
      ),
    );
  }

  /// 构建分享按钮
  Widget _buildShareButton(ColumnProvider provider) {
    return GestureDetector(
      onTap: () => _handleShare(provider),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(
          Icons.share_outlined,
          size: 22,
          color: AppColors.archiveTextMuted,
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 内容区域
  // ────────────────────────────────────────────────────────────────────────────

  /// 构建内容区域
  Widget _buildContent(ColumnProvider provider) {
    final content = provider.columnContent!;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 专栏标题区
          _buildHeader(content),

          // 分隔线
          _buildDivider(),

          // 富文本内容区
          _buildRichTextContent(provider),
        ],
      ),
    );
  }

  /// 构建专栏标题区
  Widget _buildHeader(dynamic content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.archiveModalBackground,
        boxShadow: [
          BoxShadow(
            color: AppColors.archiveTextMuted.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 分类标签和价格
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 分类标签
              _buildCategoryTag(content),

              // 价格
              _buildPriceTag(content),
            ],
          ),

          const SizedBox(height: 12),

          // 标题
          Text(
            content.title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.archiveText,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 8),

          // 图标
          Text(
            content.emoji,
            style: const TextStyle(fontSize: 28),
          ),
        ],
      ),
    );
  }

  /// 构建分类标签
  Widget _buildCategoryTag(dynamic content) {
    // 解析颜色
    Color catBg;
    Color catColor;

    try {
      // 尝试从十六进制字符串解析颜色
      catBg = _parseColor(content.catBg);
      catColor = _parseColor(content.catColor);
    } catch (e) {
      // 解析失败时使用默认颜色
      catBg = AppColors.archiveCardStart;
      catColor = AppColors.archiveAccentDark;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: catBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        content.category,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: catColor,
        ),
      ),
    );
  }

  /// 构建价格标签
  Widget _buildPriceTag(dynamic content) {
    final price = content.price;
    final priceText = price == 0 ? AppStrings().columns.free : '¥${price.toStringAsFixed(1)}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: AppColors.archiveBannerGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.archiveAccent.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        priceText,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  /// 构建分隔线
  Widget _buildDivider() {
    return Container(
      height: 8,
      color: AppColors.archiveBackground,
    );
  }

  /// 构建富文本内容区
  Widget _buildRichTextContent(ColumnProvider provider) {
    final content = provider.columnContent!;
    final canRead = provider.canReadFullContent;

    // 根据购买状态决定显示的内容
    String htmlContent;
    if (canRead) {
      // 已购买或免费，显示完整内容
      htmlContent = content.fullContent;
    } else {
      // 未购买，显示预览内容
      htmlContent = _buildPreviewHtml(content.previewContent);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 未购买提示
          if (!canRead) _buildPurchaseHint(),

          // 富文本内容
          RichTextViewer(
            htmlContent: htmlContent,
            onImageTap: (url) {
              // TODO: 实现图片预览功能
              debugPrint('图片被点击: $url');
            },
          ),

          // 未购买时的购买提示
          if (!canRead) ...[
            const SizedBox(height: 24),
            _buildPurchasePrompt(),
          ],
        ],
      ),
    );
  }

  /// 构建预览内容的HTML
  String _buildPreviewHtml(List<String> previewContent) {
    final buffer = StringBuffer();
    buffer.write('<h2>📌 ${AppStrings().columns.contentPreview}</h2>');

    for (final item in previewContent) {
      buffer.write('<p>$item</p>');
    }

    buffer.write(
        '<p style="color: #8A6A40; font-style: italic;">${AppStrings().columns.previewHint}</p>');

    return buffer.toString();
  }

  /// 构建购买提示
  Widget _buildPurchaseHint() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.archiveCardStart.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.archiveAccent.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lock_outline,
            size: 20,
            color: AppColors.archiveAccent,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppStrings().columns.purchaseHint,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.archiveAccentDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建购买提示区域
  Widget _buildPurchasePrompt() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.archiveCardStart.withValues(alpha: 0.5),
            AppColors.archiveCardEnd.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.archiveAccent.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.auto_stories_outlined,
            size: 48,
            color: AppColors.archiveAccent,
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings().columns.unlockContent,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.archiveText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings().columns.unlockHint,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.archiveTextMuted,
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 底部操作栏
  // ────────────────────────────────────────────────────────────────────────────

  /// 构建底部操作栏
  Widget _buildBottomBar(ColumnProvider provider) {
    final canRead = provider.canReadFullContent;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.archiveModalBackground,
        boxShadow: [
          BoxShadow(
            color: AppColors.archiveTextMuted.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: canRead
              ? _buildReadButton(provider)
              : _buildPurchaseButtons(provider),
        ),
      ),
    );
  }

  /// 构建阅读按钮（已购买或免费）
  Widget _buildReadButton(ColumnProvider provider) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: AppColors.archiveCardGradient,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: AppColors.archiveAccent.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // 已购买，可以滚动阅读
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppStrings().columns.continueReading),
                backgroundColor: AppColors.archiveAccent,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(25),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.menu_book_outlined,
                  size: 20,
                  color: AppColors.archiveText,
                ),
                const SizedBox(width: 8),
                Text(
                  AppStrings().columns.continueReading,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.archiveText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建购买按钮组（未购买）
  Widget _buildPurchaseButtons(ColumnProvider provider) {
    return Row(
      children: [
        // 价格显示
        Expanded(
          flex: 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                provider.formattedPrice,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.archiveAccentDark,
                ),
              ),
              Text(
                AppStrings().columns.singlePurchase,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.archiveTextMuted,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 16),

        // 立即购买按钮
        Expanded(
          flex: 3,
          child: _buildPurchaseButton(provider),
        ),
      ],
    );
  }

  /// 构建购买按钮
  Widget _buildPurchaseButton(ColumnProvider provider) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        gradient: AppColors.archiveBannerGradient,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: AppColors.archiveAccent.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: provider.isOperating ? null : () => _handlePurchase(provider),
          borderRadius: BorderRadius.circular(25),
          child: Center(
            child: provider.isOperating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 20,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppStrings().columns.buyNow,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 状态组件
  // ────────────────────────────────────────────────────────────────────────────

  /// 构建加载中组件
  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 3,
            color: AppColors.archiveAccent,
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings().common.loading,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.archiveTextMuted,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建错误组件
  Widget _buildErrorWidget(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.archiveTextMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.archiveTextMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadColumnDetail,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.archiveAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(AppStrings().common.retry),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建空状态组件
  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article_outlined,
            size: 64,
            color: AppColors.archiveTextMuted.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings().columns.columnNotFound,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.archiveTextMuted,
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 事件处理
  // ────────────────────────────────────────────────────────────────────────────

  /// 处理购买操作
  Future<void> _handlePurchase(ColumnProvider provider) async {
    try {
      final success = await provider.purchaseColumn();

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings().columns.purchaseSuccess),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings().getStringWithParams(
              AppStrings().columns.purchaseFailed, 
              {'reason': e.toString()}
            )),
            backgroundColor: AppColors.destructive,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  /// 切换收藏状态
  Future<void> _toggleFavorite(ColumnProvider provider) async {
    try {
      final isFavorited = await provider.toggleFavorite();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isFavorited 
              ? AppStrings().columns.favorited 
              : AppStrings().columns.unfavorited),
            backgroundColor: AppColors.archiveAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings().getStringWithParams(
              AppStrings().columns.operationFailed,
              {'reason': e.toString()}
            )),
            backgroundColor: AppColors.destructive,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  /// 处理分享操作
  void _handleShare(ColumnProvider provider) {
    final content = provider.columnContent;
    if (content == null) return;

    // TODO: 实现分享功能
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings().getStringWithParams(
          AppStrings().columns.sharePrefix,
          {'title': content.title}
        )),
        backgroundColor: AppColors.archiveAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 辅助方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 解析颜色字符串
  /// [colorString] 十六进制颜色字符串，如 '0xFFEDD8A8' 或 '#EDD8A8'
  Color _parseColor(String colorString) {
    // 移除可能的前缀
    String hexColor = colorString.replaceAll('#', '').replaceAll('0x', '');

    // 补全透明度
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }

    return Color(int.parse(hexColor, radix: 16));
  }
}
