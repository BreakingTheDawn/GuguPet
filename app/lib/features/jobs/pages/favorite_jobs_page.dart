import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme.dart';
import '../../../core/services/app_strings.dart';
import '../../../data/models/favorite_job.dart';
import '../providers/favorite_provider.dart';
import '../pages/job_detail_page.dart';

/// 收藏职位列表页面
/// 展示用户收藏的职位列表，支持取消收藏和查看详情
class FavoriteJobsPage extends StatefulWidget {
  const FavoriteJobsPage({super.key});

  @override
  State<FavoriteJobsPage> createState() => _FavoriteJobsPageState();
}

class _FavoriteJobsPageState extends State<FavoriteJobsPage> {
  @override
  void initState() {
    super.initState();
    // 页面初始化时加载收藏列表
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoriteProvider>().loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F8),
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  /// 构建AppBar
  PreferredSizeWidget _buildAppBar() {
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
        AppStrings().favorites.title,
        style: AppTypography.labelMedium.copyWith(
          color: const Color(0xFF3A3A5A),
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }

  /// 构建页面主体
  Widget _buildBody() {
    return Consumer<FavoriteProvider>(
      builder: (context, provider, child) {
        // 加载状态
        if (provider.isLoading && provider.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.indigo500),
            ),
          );
        }

        // 错误状态
        if (provider.errorMessage != null) {
          return _buildErrorState(provider.errorMessage!);
        }

        // 空状态
        if (provider.isEmpty) {
          return _buildEmptyState();
        }

        // 收藏列表
        return RefreshIndicator(
          onRefresh: () => provider.refresh(),
          color: AppColors.indigo500,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            itemCount: provider.favoriteCount,
            itemBuilder: (context, index) {
              final favorite = provider.favorites[index];
              return _buildFavoriteCard(favorite);
            },
          ),
        );
      },
    );
  }

  /// 构建错误状态
  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.mutedForeground,
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings().common.loadFailed,
            style: AppTypography.labelMedium.copyWith(
              color: const Color(0xFF3A3A5A),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.mutedForeground,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.read<FavoriteProvider>().loadFavorites(),
            icon: const Icon(Icons.refresh, size: 18),
            label: Text(AppStrings().favorites.reload),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.indigo500,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 图标
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F8),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.favorite_border,
              size: 64,
              color: Color(0xFFC0C0D0),
            ),
          ),
          const SizedBox(height: 24),
          // 提示文本
          Text(
            AppStrings().favorites.noFavorites,
            style: AppTypography.labelMedium.copyWith(
              color: const Color(0xFF3A3A5A),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings().favorites.goDiscover,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 32),
          // 去发现按钮
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.explore_outlined, size: 18),
            label: Text(AppStrings().favorites.goDiscoverButton),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.indigo500,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建收藏卡片
  Widget _buildFavoriteCard(FavoriteJob favorite) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
        boxShadow: AppShadows.card,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToJobDetail(favorite),
          borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题和取消按钮
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 职位标题
                          Text(
                            favorite.jobTitle ?? AppStrings().favorites.unknownJob,
                            style: AppTypography.labelMedium.copyWith(
                              color: const Color(0xFF1A1A2E),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // 薪资
                          if (favorite.salaryRange != null)
                            Text(
                              favorite.salaryRange!,
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.indigo500,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // 取消收藏按钮
                    _buildRemoveButton(favorite),
                  ],
                ),
                const SizedBox(height: 12),
                // 公司和地点
                Row(
                  children: [
                    if (favorite.companyName != null) ...[
                      Icon(
                        Icons.business_outlined,
                        size: 14,
                        color: AppColors.mutedForeground,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        favorite.companyName!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.mutedForeground,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (favorite.jobLocation != null) ...[
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppColors.mutedForeground,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        favorite.jobLocation!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                // 标签
                if (favorite.jobTags != null && favorite.jobTags!.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: favorite.jobTags!.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
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
                  ),
                const SizedBox(height: 12),
                // 收藏时间
                if (favorite.createdAt != null)
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        AppStrings().getStringWithParams(AppStrings().favorites.favoriteTime, {'time': _formatDate(favorite.createdAt!)}),
                        style: AppTypography.caption.copyWith(
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建取消收藏按钮
  Widget _buildRemoveButton(FavoriteJob favorite) {
    return GestureDetector(
      onTap: () => _handleRemoveFavorite(favorite),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F8),
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite,
              size: 14,
              color: const Color(0xFFE8605A),
            ),
            const SizedBox(width: 4),
            Text(
              AppStrings().favorites.removeFavorite,
              style: AppTypography.caption.copyWith(
                color: const Color(0xFFE8605A),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 事件处理方法
  // ═══════════════════════════════════════════════════════════

  /// 跳转到职位详情
  void _navigateToJobDetail(FavoriteJob favorite) {
    // 构造职位数据Map
    final jobData = {
      'id': favorite.jobId,
      'title': favorite.jobTitle,
      'company': favorite.companyName,
      'salary': favorite.salaryRange,
      'location': favorite.jobLocation,
      'tags': favorite.jobTags,
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JobDetailPage(job: jobData),
      ),
    );
  }

  /// 处理取消收藏
  Future<void> _handleRemoveFavorite(FavoriteJob favorite) async {
    final confirmed = await _showRemoveConfirmDialog(favorite);

    if (confirmed == true && mounted) {
      final success = await context.read<FavoriteProvider>().removeFavorite(
            favorite.jobId,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? AppStrings().favorites.removed : AppStrings().favorites.operationFailed,
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: success ? AppColors.success : AppColors.destructive,
          ),
        );
      }
    }
  }

  /// 显示取消收藏确认对话框
  Future<bool?> _showRemoveConfirmDialog(FavoriteJob favorite) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        title: Text(
          AppStrings().favorites.removeConfirm,
          style: AppTypography.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          AppStrings().getStringWithParams(AppStrings().favorites.removeConfirmMessage, {'title': favorite.jobTitle ?? AppStrings().favorites.unknownJob}),
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              AppStrings().common.cancel,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.mutedForeground,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.destructive,
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

  /// 格式化日期
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}分钟前';
      }
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${date.month}月${date.day}日';
    }
  }
}
