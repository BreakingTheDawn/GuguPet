import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../data/column_data.dart';

/// 预览弹窗组件
/// 底部弹出式模态框，展示专栏的前20%预览内容
/// 下架专栏显示"即将上线"提示，无法购买
class PreviewModal extends StatelessWidget {
  /// 专栏数据
  final ColumnItem? column;

  /// 关闭回调
  final VoidCallback onClose;

  const PreviewModal({
    super.key,
    required this.column,
    required this.onClose,
  });

  /// 是否为下架状态
  bool get isOffline => column?.isOffline ?? false;

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
                  decoration: BoxDecoration(
                    color: isOffline ? AppColors.offlineBackground : AppColors.archiveModalBackground,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildDragHandle(),
                      _buildHeader(),
                      if (isOffline) _buildOfflineNotice() else _buildContent(),
                      _buildBottomButton(),
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
            color: isOffline
                ? Colors.grey.withValues(alpha: 0.15)
                : AppColors.archiveBorder.withValues(alpha: 0.15),
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
                    color: isOffline ? Colors.grey.withValues(alpha: 0.2) : column!.catBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    column!.category,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isOffline ? Colors.grey : column!.catColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  column!.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isOffline ? Colors.grey : AppColors.archiveTextDark,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isOffline ? '内容正在准备中' : '前 20% 内容免费预览',
                  style: TextStyle(
                    fontSize: 11,
                    color: isOffline ? Colors.grey : AppColors.archiveTextMedium,
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
                color: isOffline ? Colors.grey : AppColors.archiveIcon,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 下架状态提示区域
  /// 显示"即将上线"的提示信息
  Widget _buildOfflineNotice() {
    return Flexible(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.schedule,
                size: 48,
                color: Colors.grey.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '内容正在准备中',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '该专栏即将上线，敬请期待',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
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
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.archiveContentText,
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
                      AppColors.archiveModalBackground.withValues(alpha: 0),
                      AppColors.archiveModalBackground,
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

  /// 底部按钮
  /// 下架状态显示"敬请期待"，正常状态显示"解锁完整内容"
  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: isOffline
          ? _buildComingSoonButton()
          : _ShimmerButton(
              text: '解锁完整内容 · ${column!.price}',
              onTap: () {
                // TODO: 实现购买逻辑
              },
            ),
    );
  }

  /// "敬请期待"按钮
  /// 下架状态显示，禁用点击
  Widget _buildComingSoonButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.schedule,
              size: 18,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Text(
              '敬请期待',
              style: TextStyle(
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
            colors: [AppColors.archiveDetailButtonStart, AppColors.archiveDetailButtonEnd],
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
