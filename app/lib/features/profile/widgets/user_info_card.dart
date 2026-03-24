import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/widgets/widgets.dart';

/// 用户信息卡片组件
/// 显示用户头像、用户名和求职状态标签
class UserInfoCard extends StatelessWidget {
  /// 用户名
  final String userName;

  /// 求职状态标签
  final String jobStatusTag;

  /// 头像点击回调
  final VoidCallback? onAvatarTap;

  const UserInfoCard({
    super.key,
    required this.userName,
    required this.jobStatusTag,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          // 头像区域
          _buildAvatar(),
          const SizedBox(width: AppSpacing.md),
          // 用户信息区域
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 用户名
                Text(
                  userName,
                  style: AppTypography.headingSmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                // 求职状态标签
                _buildStatusTag(),
              ],
            ),
          ),
          // 编辑按钮
          IconButton(
            icon: const Icon(Icons.chevron_right),
            color: AppColors.mutedForeground,
            onPressed: onAvatarTap,
          ),
        ],
      ),
    );
  }

  /// 构建头像组件
  Widget _buildAvatar() {
    return GestureDetector(
      onTap: onAvatarTap,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.indigo500.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            // 显示用户名首字符作为默认头像
            userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
            style: AppTypography.headingLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  /// 构建求职状态标签
  Widget _buildStatusTag() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.indigo500.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(
          color: AppColors.indigo500.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 状态图标
          Icon(
            Icons.work_outline,
            size: AppSpacing.iconSm,
            color: AppColors.indigo500,
          ),
          const SizedBox(width: AppSpacing.xs),
          // 状态文字
          Text(
            jobStatusTag,
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.indigo500,
            ),
          ),
        ],
      ),
    );
  }
}
