import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

/// 职位信息区块组件
/// 显示职位标题、薪资、标签和职位描述
class JobInfoSection extends StatelessWidget {
  /// 职位数据
  final Map<String, dynamic> job;

  const JobInfoSection({
    super.key,
    required this.job,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 12),
          _buildTags(),
          const SizedBox(height: 20),
          _buildDivider(),
          const SizedBox(height: 20),
          _buildDescription(),
        ],
      ),
    );
  }

  /// 构建标题区域
  /// 包含职位名称和薪资信息
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 职位标题
        Text(
          job['title'] ?? '未知职位',
          style: AppTypography.headingSmall.copyWith(
            color: const Color(0xFF1A1A2E),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        // 薪资范围
        Row(
          children: [
            Text(
              job['salary'] ?? '面议',
              style: AppTypography.headingSmall.copyWith(
                color: job['salaryColor'] as Color? ?? AppColors.indigo500,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 12),
            // 工作地点
            if (job['location'] != null) ...[
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.mutedForeground,
              ),
              const SizedBox(width: 4),
              Text(
                job['location'] as String,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.mutedForeground,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  /// 构建标签区域
  /// 显示职位标签（经验、学历、工作类型等）
  Widget _buildTags() {
    final tags = job['tags'] as List<dynamic>? ?? [];
    if (tags.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5FA),
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          child: Text(
            tag.toString(),
            style: AppTypography.caption.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 构建分隔线
  Widget _buildDivider() {
    return Container(
      height: 1,
      color: AppColors.divider,
    );
  }

  /// 构建职位描述区域
  Widget _buildDescription() {
    final description = job['desc'] as String?;
    if (description == null || description.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        Row(
          children: [
            Container(
              width: 4,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.indigo500,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '职位描述',
              style: AppTypography.labelMedium.copyWith(
                color: const Color(0xFF3A3A5A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // 描述内容
        Text(
          description,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.mutedForeground,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}
