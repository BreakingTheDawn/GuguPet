import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../data/models/notification.dart' as model;

// ═══════════════════════════════════════════════════════════════════════════════
/// 通知列表项组件
/// 展示单条通知的详细信息，包括图标、标题、内容、时间和状态
// ═══════════════════════════════════════════════════════════════════════════════
class NotificationItem extends StatelessWidget {
  // ────────────────────────────────────────────────────────────────────────────
  // 属性定义
  // ────────────────────────────────────────────────────────────────────────────

  /// 通知数据
  final model.Notification notification;

  /// 点击回调
  final VoidCallback? onTap;

  const NotificationItem({
    super.key,
    required this.notification,
    this.onTap,
  });

  // ────────────────────────────────────────────────────────────────────────────
  // UI构建方法
  // ────────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Stack(
          children: [
            // 通知内容
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 通知图标
                  _buildIcon(),
                  const SizedBox(width: 12),
                  // 通知内容
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 标题行
                        _buildTitleRow(),
                        const SizedBox(height: 4),
                        // 内容
                        _buildContent(),
                        const SizedBox(height: 8),
                        // 时间和状态
                        _buildFooter(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // 未读标记（红色圆点）
            if (!notification.isRead) _buildUnreadIndicator(),
          ],
        ),
      ),
    );
  }

  /// 构建通知图标
  Widget _buildIcon() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: _getIconBackgroundColor(),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        _getIconData(),
        color: _getIconColor(),
        size: 24,
      ),
    );
  }

  /// 构建标题行
  Widget _buildTitleRow() {
    return Row(
      children: [
        // 标题
        Expanded(
          child: Text(
            notification.title,
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// 构建通知内容
  Widget _buildContent() {
    return Text(
      notification.content,
      style: AppTypography.bodySmall.copyWith(
        color: AppColors.mutedForeground,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// 构建底部信息（时间和状态）
  Widget _buildFooter() {
    return Row(
      children: [
        // 时间
        Text(
          _formatTime(notification.createdAt),
          style: AppTypography.caption.copyWith(
            color: AppColors.mutedForeground,
          ),
        ),
        const Spacer(),
        // 已读/未读状态
        _buildStatusChip(),
      ],
    );
  }

  /// 构建状态标签
  Widget _buildStatusChip() {
    if (notification.isRead) {
      // 已读状态
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.muted.withOpacity(0.3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check,
              size: 12,
              color: AppColors.mutedForeground,
            ),
            const SizedBox(width: 2),
            Text(
              '已读',
              style: AppTypography.caption.copyWith(
                color: AppColors.mutedForeground,
              ),
            ),
          ],
        ),
      );
    } else {
      // 未读状态
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.destructive.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.destructive,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '未读',
              style: AppTypography.caption.copyWith(
                color: AppColors.destructive,
              ),
            ),
          ],
        ),
      );
    }
  }

  /// 构建未读标记
  Widget _buildUnreadIndicator() {
    return Positioned(
      top: 12,
      right: 12,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: AppColors.destructive,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 辅助方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 获取图标数据
  IconData _getIconData() {
    switch (notification.type) {
      case model.NotificationType.interview:
        return Icons.event_note;
      case model.NotificationType.jobStatus:
        return Icons.work_outline;
      case model.NotificationType.columnUpdate:
        return Icons.article_outlined;
      case model.NotificationType.vipExpire:
        return Icons.star_outline;
      case model.NotificationType.activity:
        return Icons.local_activity_outlined;
      case model.NotificationType.system:
        return Icons.info_outline;
    }
  }

  /// 获取图标背景颜色
  Color _getIconBackgroundColor() {
    switch (notification.type) {
      case model.NotificationType.interview:
        return AppColors.info.withOpacity(0.1);
      case model.NotificationType.jobStatus:
        return AppColors.indigo500.withOpacity(0.1);
      case model.NotificationType.columnUpdate:
        return AppColors.warning.withOpacity(0.1);
      case model.NotificationType.vipExpire:
        return AppColors.purple500.withOpacity(0.1);
      case model.NotificationType.activity:
        return AppColors.success.withOpacity(0.1);
      case model.NotificationType.system:
        return AppColors.muted.withOpacity(0.3);
    }
  }

  /// 获取图标颜色
  Color _getIconColor() {
    switch (notification.type) {
      case model.NotificationType.interview:
        return AppColors.info;
      case model.NotificationType.jobStatus:
        return AppColors.indigo500;
      case model.NotificationType.columnUpdate:
        return AppColors.warning;
      case model.NotificationType.vipExpire:
        return AppColors.purple500;
      case model.NotificationType.activity:
        return AppColors.success;
      case model.NotificationType.system:
        return AppColors.mutedForeground;
    }
  }

  /// 格式化时间显示
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    // 1分钟内
    if (difference.inMinutes < 1) {
      return '刚刚';
    }
    // 1小时内
    if (difference.inHours < 1) {
      return '${difference.inMinutes}分钟前';
    }
    // 24小时内
    if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    }
    // 7天内
    if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    }
    // 超过7天，显示具体日期
    if (time.year == now.year) {
      return '${time.month}月${time.day}日';
    } else {
      return '${time.year}年${time.month}月${time.day}日';
    }
  }
}
