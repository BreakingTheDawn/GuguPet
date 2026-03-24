import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

/// 公司信息区块组件
/// 显示公司Logo、名称、标签和简介
class CompanyInfoSection extends StatelessWidget {
  /// 职位数据
  final Map<String, dynamic> job;

  const CompanyInfoSection({
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
          _buildTitle(),
          const SizedBox(height: 16),
          _buildCompanyInfo(),
        ],
      ),
    );
  }

  /// 构建标题
  Widget _buildTitle() {
    return Row(
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
          '公司信息',
          style: AppTypography.labelMedium.copyWith(
            color: const Color(0xFF3A3A5A),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// 构建公司信息
  /// 包含Logo、名称、标签和简介
  Widget _buildCompanyInfo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 公司Logo
        _buildCompanyLogo(),
        const SizedBox(width: 16),
        // 公司详细信息
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCompanyName(),
              const SizedBox(height: 8),
              _buildCompanyTags(),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建公司Logo
  Widget _buildCompanyLogo() {
    final logoUrl = job['companyLogo'] as String?;

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5FA),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: logoUrl != null && logoUrl.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              child: Image.network(
                logoUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildDefaultLogo(),
              ),
            )
          : _buildDefaultLogo(),
    );
  }

  /// 构建默认Logo图标
  Widget _buildDefaultLogo() {
    return Icon(
      Icons.business,
      size: 28,
      color: AppColors.mutedForeground,
    );
  }

  /// 构建公司名称
  Widget _buildCompanyName() {
    final companyName = job['company'] as String? ?? '未知公司';
    return Text(
      companyName,
      style: AppTypography.labelMedium.copyWith(
        color: const Color(0xFF1A1A2E),
        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// 构建公司标签
  /// 显示行业、融资阶段、规模等信息
  Widget _buildCompanyTags() {
    final tags = <String>[];

    // 添加行业标签
    if (job['companyIndustry'] != null) {
      tags.add(job['companyIndustry'] as String);
    }

    // 添加融资阶段标签
    if (job['companyFunding'] != null) {
      tags.add(job['companyFunding'] as String);
    }

    // 添加规模标签
    if (job['companySize'] != null) {
      tags.add(job['companySize'] as String);
    }

    // 如果没有标签，显示默认信息
    if (tags.isEmpty) {
      return Text(
        '暂无更多信息',
        style: AppTypography.caption.copyWith(
          color: AppColors.mutedForeground,
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5FA),
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          child: Text(
            tag,
            style: AppTypography.caption.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
        );
      }).toList(),
    );
  }
}
