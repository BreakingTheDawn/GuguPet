import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

// ═══════════════════════════════════════════════════════════════════════════════
/// 未读消息角标组件
/// 用于显示未读通知数量，支持不同大小和样式
// ═══════════════════════════════════════════════════════════════════════════════
class NotificationBadge extends StatelessWidget {
  // ────────────────────────────────────────────────────────────────────────────
  // 属性定义
  // ────────────────────────────────────────────────────────────────────────────

  /// 未读数量
  final int count;

  /// 最大显示数量（超过显示为 count+）
  final int maxCount;

  /// 角标大小
  final double size;

  /// 是否显示数字
  final bool showNumber;

  const NotificationBadge({
    super.key,
    required this.count,
    this.maxCount = 99,
    this.size = 18,
    this.showNumber = true,
  });

  // ────────────────────────────────────────────────────────────────────────────
  // UI构建方法
  // ────────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // 如果数量为0，不显示角标
    if (count <= 0) {
      return const SizedBox.shrink();
    }

    return Container(
      constraints: BoxConstraints(
        minWidth: size,
        minHeight: size,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: showNumber ? 6 : 0,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.destructive,
        borderRadius: BorderRadius.circular(size / 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.destructive.withOpacity(0.3),
            offset: const Offset(0, 1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Center(
        child: Text(
          _getDisplayText(),
          style: AppTypography.caption.copyWith(
            color: Colors.white,
            fontSize: size * 0.6,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 辅助方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 获取显示文本
  String _getDisplayText() {
    if (!showNumber) {
      return '';
    }
    
    if (count > maxCount) {
      return '$maxCount+';
    }
    
    return count.toString();
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
/// 图标角标组件
/// 将角标显示在图标的右上角
// ═══════════════════════════════════════════════════════════════════════════════
class IconWithBadge extends StatelessWidget {
  // ────────────────────────────────────────────────────────────────────────────
  // 属性定义
  // ────────────────────────────────────────────────────────────────────────────

  /// 图标
  final IconData icon;

  /// 图标大小
  final double iconSize;

  /// 图标颜色
  final Color iconColor;

  /// 未读数量
  final int badgeCount;

  /// 角标大小
  final double badgeSize;

  /// 点击回调
  final VoidCallback? onTap;

  const IconWithBadge({
    super.key,
    required this.icon,
    this.iconSize = 24,
    this.iconColor = AppColors.primary,
    required this.badgeCount,
    this.badgeSize = 16,
    this.onTap,
  });

  // ────────────────────────────────────────────────────────────────────────────
  // UI构建方法
  // ────────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 图标
          Icon(
            icon,
            size: iconSize,
            color: iconColor,
          ),
          // 角标
          if (badgeCount > 0)
            Positioned(
              top: -badgeSize * 0.3,
              right: -badgeSize * 0.3,
              child: NotificationBadge(
                count: badgeCount,
                size: badgeSize,
              ),
            ),
        ],
      ),
    );
  }
}
