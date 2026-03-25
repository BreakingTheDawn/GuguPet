import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme.dart';
import '../../../core/services/app_strings.dart';
import '../providers/job_detail_provider.dart';
import '../widgets/job_info_section.dart';
import '../widgets/company_info_section.dart';

/// 职位详情页面
/// 展示职位详细信息、公司信息，提供收藏、分享、沟通和投递功能
/// 使用 ChangeNotifierProvider 管理 Provider 生命周期
class JobDetailPage extends StatelessWidget {
  /// 职位数据
  final Map<String, dynamic> job;

  const JobDetailPage({
    super.key,
    required this.job,
  });

  @override
  Widget build(BuildContext context) {
    // 使用 ChangeNotifierProvider 在 build 方法中创建 Provider
    // Provider 框架会自动管理生命周期，无需手动 dispose
    return ChangeNotifierProvider(
      create: (_) => JobDetailProvider()..loadJobDetail(job),
      child: _JobDetailPageContent(job: job),
    );
  }
}

/// 职位详情页面内容组件
/// 包含页面的实际 UI 实现
class _JobDetailPageContent extends StatelessWidget {
  /// 职位数据
  final Map<String, dynamic> job;

  const _JobDetailPageContent({required this.job});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F8),
      appBar: _buildAppBar(context),
      body: _buildBody(context),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  /// 构建AppBar
  /// 包含返回按钮、标题、收藏和分享按钮
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios,
          color: Color(0xFF3A3A5A),
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        AppStrings().jobs.jobDetail,
        style: AppTypography.labelMedium.copyWith(
          color: const Color(0xFF3A3A5A),
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: [
        // 收藏按钮
        Consumer<JobDetailProvider>(
          builder: (context, provider, child) {
            return IconButton(
              icon: Icon(
                provider.isFavorited
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: provider.isFavorited
                    ? const Color(0xFFE8605A)
                    : const Color(0xFF5A5A7A),
                size: 24,
              ),
              onPressed: () => _toggleFavorite(context, provider),
            );
          },
        ),
        // 分享按钮
        IconButton(
          icon: const Icon(
            Icons.share_outlined,
            color: Color(0xFF5A5A7A),
            size: 24,
          ),
          onPressed: () => _shareJob(context),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  /// 构建页面主体
  /// 包含职位信息、公司信息和工作地点
  Widget _buildBody(BuildContext context) {
    return Consumer<JobDetailProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.indigo500),
            ),
          );
        }

        if (provider.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AppColors.mutedForeground,
                ),
                const SizedBox(height: 16),
                Text(
                  provider.errorMessage!,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final jobData = provider.jobData;
        if (jobData == null) return const SizedBox.shrink();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 职位信息区块
              JobInfoSection(job: jobData),
              const SizedBox(height: 16),
              // 公司信息区块
              CompanyInfoSection(job: jobData),
              const SizedBox(height: 16),
              // 工作地点区块
              _buildLocationSection(jobData),
              const SizedBox(height: 100), // 为底部操作栏留出空间
            ],
          ),
        );
      },
    );
  }

  /// 构建工作地点区块
  Widget _buildLocationSection(Map<String, dynamic> jobData) {
    final location = jobData['location'] as String?;
    if (location == null || location.isEmpty) {
      return const SizedBox.shrink();
    }

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
                AppStrings().jobs.workLocation,
                style: AppTypography.labelMedium.copyWith(
                  color: const Color(0xFF3A3A5A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 地点信息
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 18,
                color: AppColors.mutedForeground,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  location,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建底部操作栏
  /// 包含沟通和投递简历按钮
  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 立即沟通按钮
          Expanded(
            child: _buildOutlineButton(
              label: AppStrings().jobs.communicateNow,
              icon: Icons.chat_bubble_outline,
              onPressed: () => _handleCommunicate(context),
            ),
          ),
          const SizedBox(width: 12),
          // 投递简历按钮
          Expanded(
            flex: 2,
            child: _buildPrimaryButton(
              label: AppStrings().jobs.submitResume,
              icon: Icons.send_outlined,
              onPressed: () => _handleApply(context),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建轮廓按钮
  Widget _buildOutlineButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.indigo500,
        side: const BorderSide(color: AppColors.indigo500, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
      ),
    );
  }

  /// 构建主要按钮
  Widget _buildPrimaryButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 事件处理方法
  // ═══════════════════════════════════════════════════════════

  /// 切换收藏状态
  Future<void> _toggleFavorite(
    BuildContext context,
    JobDetailProvider provider,
  ) async {
    try {
      await provider.toggleFavorite();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.isFavorited ? AppStrings().jobs.addedToFavorite : AppStrings().jobs.removedFromFavorite,
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: provider.isFavorited
                ? AppColors.success
                : AppColors.mutedForeground,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings().getStringWithParams(AppStrings().errors.operationFailedWithReason, {'reason': e.toString()})),
            duration: const Duration(seconds: 2),
            backgroundColor: AppColors.destructive,
          ),
        );
      }
    }
  }

  /// 分享职位
  void _shareJob(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings().jobs.shareDeveloping),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// 处理沟通
  void _handleCommunicate(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings().jobs.communicateDeveloping),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// 处理投递简历
  void _handleApply(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        title: Text(
          AppStrings().jobs.submitConfirm,
          style: AppTypography.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          AppStrings().jobs.submitConfirmMessage,
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              AppStrings().common.cancel,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.mutedForeground,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppStrings().getStringWithParams(AppStrings().jobs.submitSuccess, {'title': job['title']})),
                  duration: const Duration(seconds: 2),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.indigo500,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
            child: Text(AppStrings().common.confirm),
          ),
        ],
      ),
    );
  }
}
