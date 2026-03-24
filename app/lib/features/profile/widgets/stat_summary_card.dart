import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/widgets/widgets.dart';

/// 统计摘要卡片组件
/// 显示投递、面试、Offer的统计数据
class StatSummaryCard extends StatelessWidget {
  /// 投递数量
  final int submissionCount;

  /// 面试数量
  final int interviewCount;

  /// Offer数量
  final int offerCount;

  /// 点击回调
  final VoidCallback? onTap;

  const StatSummaryCard({
    super.key,
    required this.submissionCount,
    required this.interviewCount,
    required this.offerCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        child: Row(
          children: [
            // 投递统计
            Expanded(
              child: _buildStatItem(
                icon: Icons.send_outlined,
                label: '投递',
                value: submissionCount,
                color: const Color(0xFF6450C8),
              ),
            ),
            // 分隔线
            _buildDivider(),
            // 面试统计
            Expanded(
              child: _buildStatItem(
                icon: Icons.calendar_today_outlined,
                label: '面试',
                value: interviewCount,
                color: const Color(0xFF50A0C8),
              ),
            ),
            // 分隔线
            _buildDivider(),
            // Offer统计
            Expanded(
              child: _buildStatItem(
                icon: Icons.card_giftcard_outlined,
                label: 'Offer',
                value: offerCount,
                color: const Color(0xFF50C880),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建统计项
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required int value,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 图标容器
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Icon(
            icon,
            size: AppSpacing.iconMd,
            color: color,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        // 数值
        Text(
          '$value',
          style: AppTypography.headingMedium.copyWith(
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        // 标签
        Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.mutedForeground,
          ),
        ),
      ],
    );
  }

  /// 构建分隔线
  Widget _buildDivider() {
    return Container(
      height: 48,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      color: AppColors.divider,
    );
  }
}
