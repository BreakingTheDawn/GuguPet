import 'package:flutter/material.dart';
import '../data/column_data.dart';

/// 专栏卡片组件
/// 展示单个付费专栏的信息，包括分类标签、标题、福利描述和价格
class ColumnCard extends StatelessWidget {
  final ColumnItem column;
  final int index;
  final VoidCallback onPreview;

  const ColumnCard({
    super.key,
    required this.column,
    required this.index,
    required this.onPreview,
  });

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
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEDD8A8), Color(0xFFE3C47E)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF644614).withValues(alpha: 0.15),
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
            color: const Color(0xFFB4823C).withValues(alpha: 0.22),
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
    );
  }

  /// 左侧牛皮纸纹理条
  Widget _buildLeftStrip() {
    return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      child: Container(
        width: 6,
        decoration: BoxDecoration(
          color: const Color(0xFF785014).withValues(alpha: 0.12),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          ),
        ),
      ),
    );
  }

  /// 右上角折角效果
  Widget _buildFoldCorner() {
    return Positioned(
      top: 0,
      right: 0,
      child: CustomPaint(
        size: const Size(18, 18),
        painter: _FoldCornerPainter(),
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

  /// 卡片头部：分类标签和emoji
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
        Text(
          column.emoji,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  /// 专栏标题
  Widget _buildTitle() {
    return Text(
      column.title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Color(0xFF2A1A08),
        height: 1.5,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// 福利描述
  Widget _buildBenefits() {
    return Text(
      column.benefits,
      style: TextStyle(
        fontSize: 9.5,
        color: const Color(0xFF8A6A40),
        height: 1.5,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// 底部操作栏：试读按钮和价格
  Widget _buildBottomBar() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF785014).withValues(alpha: 0.07),
          border: Border(
            top: BorderSide(
              color: const Color(0xFF785014).withValues(alpha: 0.1),
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildPreviewButton(),
            _buildPrice(),
          ],
        ),
      ),
    );
  }

  /// 试读按钮
  Widget _buildPreviewButton() {
    return GestureDetector(
      onTap: onPreview,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF785014).withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.visibility_outlined,
              size: 10,
              color: const Color(0xFF8A6A40),
            ),
            const SizedBox(width: 4),
            Text(
              '试读',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF8A6A40),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 价格标签
  Widget _buildPrice() {
    return Text(
      column.price,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF3A2A18),
      ),
    );
  }
}

/// 折角效果绘制器
class _FoldCornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF785014).withValues(alpha: 0.18)
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
        colors: [
          const Color(0xFFD4A860),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, 14, 14));

    final highlightPath = Path()
      ..moveTo(size.width - 4, 0)
      ..lineTo(size.width - 4, size.height - 4)
      ..lineTo(4, 0)
      ..close();

    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
