import 'package:flutter/material.dart';
import '../data/column_data.dart';

/// 底部CTA按钮组件
/// 固定在页面底部，展示全套购买按钮
class BottomCTA extends StatefulWidget {
  const BottomCTA({super.key});

  @override
  State<BottomCTA> createState() => _BottomCTAState();
}

class _BottomCTAState extends State<BottomCTA>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;
  bool _isTapped = false;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2800),
      vsync: this,
    )..repeat();
    _shimmerAnimation = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFF7F4EF).withOpacity(0),
            const Color(0xFFF7F4EF),
          ],
          stops: const [0.0, 0.6],
        ),
      ),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isTapped = true),
        onTapUp: (_) {
          setState(() => _isTapped = false);
          _handlePurchase();
        },
        onTapCancel: () => setState(() => _isTapped = false),
        child: AnimatedScale(
          scale: _isTapped ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment(-1, -1),
                end: Alignment(1, 1),
                colors: [Color(0xFF7A5030), Color(0xFF5A3318)],
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5A3218).withOpacity(0.4),
                  blurRadius: 28,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: const Color(0xFF5A3218).withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 闪光扫过效果
                _buildShimmerEffect(),
                // 按钮内容
                _buildButtonContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 闪光扫过动画效果
  Widget _buildShimmerEffect() {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: Stack(
              children: [
                Positioned(
                  left: _shimmerAnimation.value * 200,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 96,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          const Color(0xFFFFF0D0).withOpacity(0.28),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 按钮内容：图标、文字和动画星星
  Widget _buildButtonContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('📦', style: TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '一键带走全套档案馆',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '8册合集 · 原价 ${ColumnData.originalPrice} · 现仅 ${ColumnData.bundlePrice}',
              style: TextStyle(
                fontSize: 11,
                color: const Color(0xFFFFDCB4).withOpacity(0.85),
              ),
            ),
          ],
        ),
        const SizedBox(width: 4),
        AnimatedScale(
          scale: _isTapped ? 1.4 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: AnimatedRotation(
            turns: _isTapped ? 0.04 : 0,
            duration: const Duration(milliseconds: 150),
            child: const Text('✨', style: TextStyle(fontSize: 18)),
          ),
        ),
      ],
    );
  }

  /// 处理购买逻辑
  void _handlePurchase() {
    // TODO: 实现全套购买逻辑
  }
}
