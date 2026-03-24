import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/widgets/widgets.dart';

/// VIP状态卡片组件
/// 显示VIP会员状态和有效期，非VIP用户显示升级入口
class VipStatusCard extends StatelessWidget {
  /// 是否为VIP用户
  final bool isVip;

  /// VIP过期时间
  final DateTime? vipExpireTime;

  /// 升级按钮点击回调
  final VoidCallback? onUpgradeTap;

  const VipStatusCard({
    super.key,
    required this.isVip,
    this.vipExpireTime,
    this.onUpgradeTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: isVip ? _buildVipContent() : _buildNonVipContent(),
    );
  }

  /// 构建VIP用户内容
  Widget _buildVipContent() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.warning.withValues(alpha: 0.15),
            AppColors.indigo500.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          // VIP图标
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: const Text(
              '🔥',
              style: TextStyle(fontSize: 24),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // VIP信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'VIP会员',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Text(
                        '已激活',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _formatExpireTime(),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建非VIP用户内容
  Widget _buildNonVipContent() {
    return InkWell(
      onTap: onUpgradeTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.muted.withValues(alpha: 0.3),
              AppColors.secondary.withValues(alpha: 0.5),
            ],
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            // 升级图标
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.indigo500.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Icon(
                Icons.workspace_premium_outlined,
                size: AppSpacing.iconLg,
                color: AppColors.indigo500,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // 升级信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '升级VIP会员',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '解锁更多求职特权，加速找到心仪工作',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            // 箭头图标
            Icon(
              Icons.chevron_right,
              color: AppColors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }

  /// 格式化过期时间显示
  String _formatExpireTime() {
    if (vipExpireTime == null) {
      return '有效期: 未知';
    }

    final now = DateTime.now();
    final difference = vipExpireTime!.difference(now).inDays;

    if (difference <= 0) {
      return 'VIP已过期';
    } else if (difference <= 7) {
      return '有效期还剩 $difference 天，请及时续费';
    } else {
      final formatter = DateFormat('yyyy-MM-dd');
      return '有效期至: ${formatter.format(vipExpireTime!)}';
    }
  }
}
