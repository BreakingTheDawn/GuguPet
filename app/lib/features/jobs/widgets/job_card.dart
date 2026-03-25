import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class JobCard extends StatelessWidget {
  final Map<String, dynamic> job;
  final VoidCallback onTap;

  const JobCard({super.key, required this.job, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
          const SizedBox(height: 4),
          _buildSalary(),
          const SizedBox(height: 8),
          _buildCompany(),
          const SizedBox(height: 12),
          _buildTags(),
          const SizedBox(height: 16),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            job['title'] ?? '未知职位',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ),
        if (job['isNew'] == true)
          _buildBadge('NEW', const Color(0xFF5ABE8A)),
        if (job['isUrgent'] == true)
          _buildBadge('急招', const Color(0xFFE8605A)),
      ],
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.white),
      ),
    );
  }

  Widget _buildSalary() {
    return Text(
      job['salary'] ?? '薪资面议',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: job['salaryColor'] ?? AppColors.indigo500,
      ),
    );
  }

  Widget _buildCompany() {
    return Row(
      children: [
        Text(job['company'] ?? '未知公司', style: AppTypography.bodySmall.copyWith(color: AppColors.mutedForeground)),
        const SizedBox(width: 8),
        const Icon(Icons.location_on_outlined, size: 12, color: Colors.grey),
        Text(job['location'] ?? '', style: AppTypography.caption.copyWith(color: Colors.grey)),
        const SizedBox(width: 4),
        const Icon(Icons.access_time, size: 12, color: Colors.grey),
        Text(job['posted'] ?? '', style: AppTypography.caption.copyWith(color: Colors.grey)),
      ],
    );
  }

  Widget _buildTags() {
    final tags = job['tags'];
    if (tags == null || (tags is List && tags.isEmpty)) {
      return const SizedBox.shrink();
    }
    
    final tagList = tags is List ? tags : [];
    
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: tagList.map<Widget>((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5FA),
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          child: Text(tag.toString(), style: AppTypography.caption.copyWith(color: AppColors.mutedForeground)),
        );
      }).toList(),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.only(top: 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0x0F000000))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ...List.generate(4, (_) => const Icon(Icons.star, size: 12, color: Color(0xFFFFB840))),
              const Icon(Icons.star, size: 12, color: Color(0xFFE0E0E0)),
              const SizedBox(width: 4),
              Text('4.0 公司评分', style: AppTypography.caption.copyWith(color: Colors.grey)),
            ],
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
              child: const Text(
                '查看详情',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
