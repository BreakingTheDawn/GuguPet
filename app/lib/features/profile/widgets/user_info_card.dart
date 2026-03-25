import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/widgets/widgets.dart';

/// 用户信息卡片组件
/// 显示用户头像、用户名和求职状态标签
/// 支持已登录和未登录两种状态显示
class UserInfoCard extends StatelessWidget {
  /// 用户名
  final String userName;

  /// 求职状态标签
  final String? jobStatusTag;

  /// 头像点击回调
  final VoidCallback? onAvatarTap;

  /// 是否已登录
  final bool isLoggedIn;

  /// 登录按钮点击回调
  final VoidCallback? onLoginTap;

  const UserInfoCard({
    super.key,
    required this.userName,
    this.jobStatusTag,
    this.onAvatarTap,
    this.isLoggedIn = true,
    this.onLoginTap,
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
                  isLoggedIn ? userName : '未登录',
                  style: AppTypography.headingSmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                // 状态标签或登录提示
                isLoggedIn
                    ? _buildStatusTag()
                    : _buildLoginPrompt(),
              ],
            ),
          ),
          // 操作按钮
          isLoggedIn
              ? IconButton(
                  icon: const Icon(Icons.chevron_right),
                  color: AppColors.mutedForeground,
                  onPressed: onAvatarTap,
                )
              : _buildLoginButton(),
        ],
      ),
    );
  }

  /// 构建头像组件
  Widget _buildAvatar() {
    return GestureDetector(
      onTap: isLoggedIn ? onAvatarTap : onLoginTap,
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
          child: isLoggedIn
              ? Text(
                  // 显示用户名首字符作为默认头像
                  userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                  style: AppTypography.headingLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                )
              : const Icon(
                  Icons.person_outline,
                  size: 36,
                  color: Colors.white,
                ),
        ),
      ),
    );
  }

  /// 构建求职状态标签
  Widget _buildStatusTag() {
    if (jobStatusTag == null || jobStatusTag!.isEmpty) {
      return Text(
        '点击设置求职意向',
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.mutedForeground,
        ),
      );
    }
    
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
            jobStatusTag!,
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.indigo500,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建登录提示
  Widget _buildLoginPrompt() {
    return Text(
      '点击登录以使用完整功能',
      style: AppTypography.bodySmall.copyWith(
        color: AppColors.mutedForeground,
      ),
    );
  }

  /// 构建登录按钮
  Widget _buildLoginButton() {
    return FilledButton(
      onPressed: onLoginTap,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.indigo500,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
      child: const Text('登录'),
    );
  }
}
