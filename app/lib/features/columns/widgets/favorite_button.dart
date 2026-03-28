import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

// ═══════════════════════════════════════════════════════════════════════════════
/// 收藏按钮组件
/// 提供收藏/取消收藏的可视化交互，支持动画效果和状态持久化
// ═══════════════════════════════════════════════════════════════════════════════
class FavoriteButton extends StatefulWidget {
  // ────────────────────────────────────────────────────────────────────────────
  // 参数定义
  // ────────────────────────────────────────────────────────────────────────────

  /// 是否已收藏
  final bool isFavorited;

  /// 点击回调
  final VoidCallback? onTap;

  /// 按钮大小
  final double size;

  /// 是否显示文字
  final bool showText;

  /// 是否禁用
  final bool isDisabled;

  /// 自定义收藏图标
  final IconData? favoriteIcon;

  /// 自定义未收藏图标
  final IconData? unfavoriteIcon;

  /// 自定义收藏颜色
  final Color? favoriteColor;

  /// 自定义未收藏颜色
  final Color? unfavoriteColor;

  /// 动画时长
  final Duration animationDuration;

  const FavoriteButton({
    super.key,
    required this.isFavorited,
    this.onTap,
    this.size = 24.0,
    this.showText = false,
    this.isDisabled = false,
    this.favoriteIcon,
    this.unfavoriteIcon,
    this.favoriteColor,
    this.unfavoriteColor,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton>
    with SingleTickerProviderStateMixin {
  // ────────────────────────────────────────────────────────────────────────────
  // 动画控制器
  // ────────────────────────────────────────────────────────────────────────────

  /// 动画控制器
  late AnimationController _controller;

  /// 缩放动画
  late Animation<double> _scaleAnimation;

  /// 旋转动画
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  /// 初始化动画
  void _initAnimations() {
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    // 缩放动画：从1.0到1.3再回到1.0
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.3)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.3, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    // 旋转动画：轻微旋转效果
    _rotationAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 0.15)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.15, end: 0.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(FavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 当收藏状态改变时，触发动画
    if (oldWidget.isFavorited != widget.isFavorited) {
      _triggerAnimation();
    }
  }

  /// 触发动画
  void _triggerAnimation() {
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 构建方法
  // ────────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isDisabled ? null : _handleTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: child,
            ),
          );
        },
        child: _buildButtonContent(),
      ),
    );
  }

  /// 构建按钮内容
  Widget _buildButtonContent() {
    // 默认颜色配置
    final defaultFavoriteColor = AppColors.favoriteRed;
    final defaultUnfavoriteColor = AppColors.unfavoriteGray;

    // 使用自定义颜色或默认颜色
    final favoriteColor = widget.favoriteColor ?? defaultFavoriteColor;
    final unfavoriteColor = widget.unfavoriteColor ?? defaultUnfavoriteColor;

    // 使用自定义图标或默认图标
    final favoriteIcon = widget.favoriteIcon ?? Icons.favorite;
    final unfavoriteIcon = widget.unfavoriteIcon ?? Icons.favorite_border;

    // 当前图标和颜色
    final currentIcon = widget.isFavorited ? favoriteIcon : unfavoriteIcon;
    final currentColor = widget.isFavorited ? favoriteColor : unfavoriteColor;

    return Container(
      padding: EdgeInsets.all(widget.size * 0.25),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 图标
          Icon(
            currentIcon,
            size: widget.size,
            color: widget.isDisabled
                ? currentColor.withValues(alpha: 0.5)
                : currentColor,
          ),
          // 文字标签
          if (widget.showText) ...[
            SizedBox(width: widget.size * 0.25),
            Text(
              widget.isFavorited ? '已收藏' : '收藏',
              style: TextStyle(
                fontSize: widget.size * 0.6,
                fontWeight: FontWeight.w600,
                color: widget.isDisabled
                    ? currentColor.withValues(alpha: 0.5)
                    : currentColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 事件处理
  // ────────────────────────────────────────────────────────────────────────────

  /// 处理点击事件
  void _handleTap() {
    if (widget.isDisabled) return;

    // 触发动画
    _triggerAnimation();

    // 调用回调
    widget.onTap?.call();
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
/// 收藏按钮样式配置
/// 用于统一配置收藏按钮的外观
// ═══════════════════════════════════════════════════════════════════════════════
class FavoriteButtonStyle {
  /// 按钮大小
  final double size;

  /// 是否显示文字
  final bool showText;

  /// 收藏图标
  final IconData favoriteIcon;

  /// 未收藏图标
  final IconData unfavoriteIcon;

  /// 收藏颜色
  final Color favoriteColor;

  /// 未收藏颜色
  final Color unfavoriteColor;

  /// 动画时长
  final Duration animationDuration;

  const FavoriteButtonStyle({
    this.size = 24.0,
    this.showText = false,
    this.favoriteIcon = Icons.favorite,
    this.unfavoriteIcon = Icons.favorite_border,
    this.favoriteColor = AppColors.favoriteRed,
    this.unfavoriteColor = AppColors.unfavoriteGray,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  /// 默认样式
  static const defaultStyle = FavoriteButtonStyle();

  /// 大号样式（用于详情页）
  static const largeStyle = FavoriteButtonStyle(
    size: 32.0,
    showText: true,
  );

  /// 小号样式（用于列表项）
  static const smallStyle = FavoriteButtonStyle(
    size: 20.0,
    showText: false,
  );

  /// 应用样式到按钮
  FavoriteButton apply({
    required bool isFavorited,
    VoidCallback? onTap,
    bool isDisabled = false,
  }) {
    return FavoriteButton(
      isFavorited: isFavorited,
      onTap: onTap,
      size: size,
      showText: showText,
      isDisabled: isDisabled,
      favoriteIcon: favoriteIcon,
      unfavoriteIcon: unfavoriteIcon,
      favoriteColor: favoriteColor,
      unfavoriteColor: unfavoriteColor,
      animationDuration: animationDuration,
    );
  }
}
