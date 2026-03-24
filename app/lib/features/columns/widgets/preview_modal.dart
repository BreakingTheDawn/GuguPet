import 'package:flutter/material.dart';
import '../data/column_data.dart';

/// 预览弹窗组件
/// 底部弹出式模态框，展示专栏的前20%预览内容
class PreviewModal extends StatelessWidget {
  final ColumnItem? column;
  final VoidCallback onClose;

  const PreviewModal({
    super.key,
    required this.column,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    if (column == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onClose,
      child: Material(
        color: Colors.transparent,
        child: Container(
          color: Colors.black.withValues(alpha: 0.45),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {},
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 400 * (1 - value)),
                    child: child,
                  );
                },
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.72,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFDFAF4),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildDragHandle(),
                      _buildHeader(),
                      _buildContent(),
                      _buildUnlockButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 拖拽指示条
  Widget _buildDragHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  /// 弹窗头部：分类标签、标题和关闭按钮
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFA0783C).withValues(alpha: 0.15),
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                  decoration: BoxDecoration(
                    color: column!.catBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    column!.category,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: column!.catColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  column!.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2A1A0A),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '前 20% 内容免费预览',
                  style: TextStyle(
                    fontSize: 11,
                    color: const Color(0xFFA08050),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onClose,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Icon(
                Icons.close,
                size: 20,
                color: const Color(0xFFC0A880),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 预览内容区域
  Widget _buildContent() {
    return Flexible(
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: column!.previewContent.asMap().entries.map((entry) {
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 250 + entry.key * 60),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(-8 * (1 - value), 0),
                      child: Opacity(
                        opacity: value,
                        child: child,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      entry.value,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF4A3A2A),
                        height: 1.8,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // 底部渐变遮罩
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFFFDFAF4).withValues(alpha: 0),
                      const Color(0xFFFDFAF4),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 解锁购买按钮
  Widget _buildUnlockButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: _ShimmerButton(
        text: '解锁完整内容 · ${column!.price}',
        onTap: () {
          // TODO: 实现购买逻辑
        },
      ),
    );
  }
}

/// 带闪光效果的按钮组件
class _ShimmerButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const _ShimmerButton({
    required this.text,
    required this.onTap,
  });

  @override
  State<_ShimmerButton> createState() => _ShimmerButtonState();
}

class _ShimmerButtonState extends State<_ShimmerButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment(-1, -1),
            end: Alignment(1, 1),
            colors: [Color(0xFF8B6040), Color(0xFF6A4020)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 闪光效果
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: Stack(
                      children: [
                        Positioned(
                          left: _animation.value * 200,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            width: 64,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.white.withValues(alpha: 0.22),
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
            ),
            // 按钮文字
            Text(
              widget.text,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
