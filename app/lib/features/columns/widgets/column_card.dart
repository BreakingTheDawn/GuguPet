import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../data/column_data.dart';

/// 专栏卡片组件
/// 展示单个付费专栏的信息，包括分类标签、标题、福利描述和价格
/// 支持下架状态显示：下架专栏显示灰色，用户无法点击进入
/// 支持已购买状态显示：已购买专栏显示"已购买"标签
/// 点击卡片整体可跳转到详情页
class ColumnCard extends StatelessWidget {
  /// 专栏数据
  final ColumnItem column;

  /// 卡片索引，用于动画延迟
  final int index;

  /// 试读按钮点击回调
  final VoidCallback onPreview;

  /// 卡片整体点击回调（跳转到详情页）
  final VoidCallback? onTap;

  /// 是否已购买（已购买用户显示不同UI）
  final bool isPurchased;

  const ColumnCard({
    super.key,
    required this.column,
    required this.index,
    required this.onPreview,
    this.onTap,
    this.isPurchased = false,
  });

  /// 是否为下架状态
  bool get isOffline => column.isOffline;

  /// 是否显示已购买状态
  bool get showPurchased => isPurchased && !isOffline;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + index * 50),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: isOffline ? null : onTap,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isOffline
                      ? [AppColors.muted, AppColors.mutedForeground]
                      : [AppColors.archiveCardStart, AppColors.archiveCardEnd],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: isOffline
                        ? Colors.black.withValues(alpha: 0.08)
                        : AppColors.archiveAccentDark.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.4),
                    blurRadius: 0,
                    offset: const Offset(0, 1),
                  ),
                ],
                border: Border.all(
                  color: isOffline
                      ? Colors.grey.withValues(alpha: 0.3)
                      : AppColors.archiveAccent.withValues(alpha: 0.22),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    _buildLeftStrip(),
                    _buildFoldCorner(),
                    _buildContent(),
                    _buildBottomBar(),
                  ],
                ),
              ),
            ),
            if (isOffline) _buildOfflineOverlay(),
          ],
        ),
      ),
    );
  }

  /// 下架状态遮罩层
  /// 显示"即将上线"标签，覆盖整个卡片
  Widget _buildOfflineOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.schedule,
                  size: 14,
                  color: Colors.white,
                ),
                SizedBox(width: 6),
                Text(
                  '即将上线',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 左侧牛皮纸纹理条
  /// 下架状态使用灰色
  Widget _buildLeftStrip() {
    return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      child: Container(
        width: 6,
        decoration: BoxDecoration(
          color: isOffline
              ? Colors.grey.withValues(alpha: 0.15)
              : AppColors.archiveTextMuted.withValues(alpha: 0.12),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          ),
        ),
      ),
    );
  }

  /// 右上角折角效果
  /// 下架状态使用灰色
  Widget _buildFoldCorner() {
    return Positioned(
      top: 0,
      right: 0,
      child: CustomPaint(
        size: const Size(18, 18),
        painter: _FoldCornerPainter(isOffline: isOffline),
      ),
    );
  }

  /// 卡片主要内容
  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 8),
          _buildTitle(),
          const SizedBox(height: 4),
          _buildBenefits(),
        ],
      ),
    );
  }

  /// 卡片头部：分类标签、emoji和已购买标签
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: column.catBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            column.category,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: column.catColor,
              letterSpacing: 0.03,
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showPurchased) _buildPurchasedBadge(),
            const SizedBox(width: 4),
            Text(
              column.emoji,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }

  /// 已购买标签
  Widget _buildPurchasedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.emotionHappy.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle,
            size: 10,
            color: Colors.white,
          ),
          SizedBox(width: 3),
          Text(
            '已购买',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// 专栏标题
  /// 下架状态使用灰色文字
  Widget _buildTitle() {
    return Text(
      column.title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: isOffline ? Colors.grey.withValues(alpha: 0.6) : AppColors.archiveText,
        height: 1.5,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// 福利描述
  /// 下架状态使用灰色文字
  Widget _buildBenefits() {
    return Text(
      column.benefits,
      style: TextStyle(
        fontSize: 9.5,
        color: isOffline ? Colors.grey.withValues(alpha: 0.5) : AppColors.archiveTextMuted,
        height: 1.5,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// 底部操作栏：试读按钮和价格/阅读按钮
  /// 下架状态使用灰色背景
  /// 已购买状态显示"立即阅读"，未购买显示"试读"和价格
  Widget _buildBottomBar() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isOffline
              ? Colors.grey.withValues(alpha: 0.08)
              : AppColors.archiveTextMuted.withValues(alpha: 0.07),
          border: Border(
            top: BorderSide(
              color: isOffline
                  ? Colors.grey.withValues(alpha: 0.15)
                  : AppColors.archiveTextMuted.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            showPurchased ? _buildReadButton() : _buildPreviewButton(),
            showPurchased ? const SizedBox() : _buildPrice(),
          ],
        ),
      ),
    );
  }

  /// 立即阅读按钮（已购买状态）
  Widget _buildReadButton() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.emotionHappy.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.emotionHappy.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_stories,
              size: 10,
              color: Colors.white,
            ),
            SizedBox(width: 4),
            Text(
              '立即阅读',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 试读按钮
  /// 下架状态禁用点击
  Widget _buildPreviewButton() {
    return GestureDetector(
      onTap: isOffline ? null : onPreview,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isOffline
                ? Colors.grey.withValues(alpha: 0.2)
                : AppColors.archiveTextMuted.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.visibility_outlined,
              size: 10,
              color: isOffline ? Colors.grey : AppColors.archiveTextMuted,
            ),
            const SizedBox(width: 4),
            Text(
              '试读',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: isOffline ? Colors.grey : AppColors.archiveTextMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 价格标签
  /// 下架状态使用灰色文字
  Widget _buildPrice() {
    return Text(
      column.price,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: isOffline ? Colors.grey.withValues(alpha: 0.5) : AppColors.archiveText,
      ),
    );
  }
}

/// 折角效果绘制器
/// 支持下架状态的灰色显示
class _FoldCornerPainter extends CustomPainter {
  /// 是否为下架状态
  final bool isOffline;

  _FoldCornerPainter({this.isOffline = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isOffline
          ? Colors.grey.withValues(alpha: 0.2)
          : AppColors.archiveTextMuted.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, 0)
      ..close();

    canvas.drawPath(path, paint);

    // 内部高光
    final highlightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isOffline
            ? [Colors.grey.withValues(alpha: 0.3), Colors.transparent]
            : [AppColors.archiveCardStart, Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, 14, 14));

    final highlightPath = Path()
      ..moveTo(size.width - 4, 0)
      ..lineTo(size.width - 4, size.height - 4)
      ..lineTo(4, 0)
      ..close();

    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant _FoldCornerPainter oldDelegate) =>
      oldDelegate.isOffline != isOffline;
}
