import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/theme.dart';
import '../../../core/services/app_strings.dart';
import '../../../data/models/job.dart';
import '../widgets/job_card.dart';
import '../widgets/job_filter_bottom_sheet.dart';
import '../providers/job_filter_provider.dart';
import '../providers/jobs_provider.dart';

/// 求职看板页面
/// 展示职位列表，支持搜索、筛选、投递和收藏功能
class JobsPage extends StatefulWidget {
  const JobsPage({super.key});

  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  // 搜索控制器
  final _searchController = TextEditingController();
  
  // 筛选状态Provider
  late final JobFilterProvider _filterProvider;

  // 分类选项
  static const _categories = ['全部', '设计', '技术', '产品', '运营', '数据'];

  @override
  void initState() {
    super.initState();
    _filterProvider = JobFilterProvider();
    
    // 页面加载后获取职位数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadJobs();
    });
  }

  /// 加载职位列表
  void _loadJobs() {
    // TODO: 从用户状态获取真实用户ID
    const userId = 'default_user';
    context.read<JobsProvider>().loadJobs(userId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _filterProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _filterProvider,
      child: Consumer2<JobsProvider, JobFilterProvider>(
        builder: (context, jobsProvider, filterProvider, child) {
          return Container(
            color: const Color(0xFFF5F5F8),
            child: Column(
              children: [
                _buildHeader(jobsProvider),
                _buildSearchBar(filterProvider),
                _buildCategories(jobsProvider),
                // 显示筛选标签
                if (filterProvider.hasAnyFilter) _buildFilterTags(filterProvider),
                Expanded(child: _buildJobList(jobsProvider, filterProvider)),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 构建页面标题
  Widget _buildHeader(JobsProvider provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F8).withValues(alpha: 0.92),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings().jobs.selectedForYou,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.mutedForeground,
                  letterSpacing: 0.15,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    AppStrings().jobs.newToday,
                    style: AppTypography.headingSmall.copyWith(
                      color: const Color(0xFF3A3A5A),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6450C8).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    ),
                    child: Text(
                      AppStrings().getStringWithParams(AppStrings().jobs.jobsCount, {'count': '${provider.newJobsCount}'}),
                      style: AppTypography.caption.copyWith(
                        color: const Color(0xFF6450C8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              boxShadow: AppShadows.button,
            ),
            child: const Icon(
              Icons.notifications_outlined,
              size: 20,
              color: Color(0xFF5A5A7A),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建搜索栏（带筛选按钮）
  Widget _buildSearchBar(JobFilterProvider filterProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          // 搜索输入框
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                boxShadow: AppShadows.input,
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  context.read<JobsProvider>().search(value);
                },
                decoration: InputDecoration(
                  hintText: AppStrings().jobs.searchPlaceholder,
                  hintStyle: AppTypography.bodyMedium.copyWith(
                    color: const Color(0xFFC0C0D0),
                  ),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFFC0C0D0)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 筛选按钮
          GestureDetector(
            onTap: () => _showFilterSheet(filterProvider),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: filterProvider.hasAnyFilter 
                    ? AppColors.indigo500 
                    : Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                boxShadow: AppShadows.button,
              ),
              child: Stack(
                children: [
                  Icon(
                    Icons.tune,
                    size: 20,
                    color: filterProvider.hasAnyFilter 
                        ? Colors.white 
                        : const Color(0xFF5A5A7A),
                  ),
                  // 筛选数量指示器
                  if (filterProvider.filterCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: filterProvider.hasAnyFilter 
                              ? Colors.white 
                              : AppColors.indigo500,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${filterProvider.filterCount}',
                          style: AppTypography.caption.copyWith(
                            color: filterProvider.hasAnyFilter 
                                ? AppColors.indigo500 
                                : Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建筛选标签区域
  Widget _buildFilterTags(JobFilterProvider filterProvider) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filterProvider.activeFilterTags.length + 1, // +1 为清除全部按钮
        itemBuilder: (context, index) {
          // 清除全部按钮
          if (index == filterProvider.activeFilterTags.length) {
            return GestureDetector(
              onTap: () => setState(() => filterProvider.resetAll()),
              child: Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.muted,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.close,
                      size: 14,
                      color: AppColors.mutedForeground,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      AppStrings().jobs.clearAll,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          
          // 筛选标签
          final tag = filterProvider.activeFilterTags[index];
          return GestureDetector(
            onTap: () => setState(() => filterProvider.removeFilterTag(tag)),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.indigo500.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                border: Border.all(
                  color: AppColors.indigo500.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tag,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.indigo500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.close,
                    size: 14,
                    color: AppColors.indigo500,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 显示筛选弹窗
  void _showFilterSheet(JobFilterProvider filterProvider) {
    JobFilterBottomSheet.show(
      context: context,
      filterProvider: filterProvider,
      onConfirm: () {
        setState(() {});
      },
    );
  }

  /// 构建分类选择器
  Widget _buildCategories(JobsProvider provider) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = _categories[index] == provider.selectedCategory;
          return GestureDetector(
            onTap: () => provider.selectCategory(_categories[index]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF6450C8) : Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                boxShadow: isSelected ? AppShadows.button : null,
              ),
              child: Text(
                _categories[index],
                style: AppTypography.labelSmall.copyWith(
                  color: isSelected ? Colors.white : const Color(0xFF5A5A7A),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 构建职位列表
  Widget _buildJobList(JobsProvider provider, JobFilterProvider filterProvider) {
    // 加载中状态
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    // 错误状态
    if (provider.error != null) {
      return _buildErrorState(provider.error!);
    }
    
    // 空状态
    if (provider.jobs.isEmpty) {
      return _buildEmptyState();
    }

    // 应用高级筛选
    var filteredJobs = provider.jobs.where((job) {
      return filterProvider.matchesFilter(job.toCardMap());
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      itemCount: filteredJobs.length,
      itemBuilder: (context, index) {
        final job = filteredJobs[index];
        return JobCard(
          job: job.toCardMap(),
          onTap: () => _showJobDetail(job, provider),
        );
      },
    );
  }

  /// 构建错误状态
  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.mutedForeground),
          const SizedBox(height: 16),
          Text(AppStrings().common.loadFailed, style: AppTypography.bodyMedium.copyWith(color: AppColors.mutedForeground)),
          const SizedBox(height: 8),
          TextButton(onPressed: _loadJobs, child: Text(AppStrings().common.retry)),
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
          Icon(Icons.work_off_outlined, size: 64, color: AppColors.mutedForeground),
          const SizedBox(height: 16),
          Text(AppStrings().jobs.noJobs, style: AppTypography.bodyMedium.copyWith(color: AppColors.mutedForeground)),
        ],
      ),
    );
  }

  /// 显示职位详情
  void _showJobDetail(Job job, JobsProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 拖动指示器
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 职位标题和薪资
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          job.title,
                          style: AppTypography.headingSmall,
                        ),
                      ),
                      Text(
                        job.salary,
                        style: AppTypography.headingSmall.copyWith(
                          color: const Color(0xFFE8805A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 公司名称
                  Text(
                    job.company,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 工作地点
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 16, color: AppColors.mutedForeground),
                      const SizedBox(width: 4),
                      Text(
                        job.location,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 标签
                  if (job.tags != null && job.tags!.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: job.tags!.map<Widget>((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F8),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                          ),
                          child: Text(
                            tag,
                            style: AppTypography.caption,
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 24),
                  // 职位描述
                  Text(
                    AppStrings().jobs.jobDescription,
                    style: AppTypography.labelMedium.copyWith(
                      color: const Color(0xFF3A3A5A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    job.description ?? AppStrings().jobs.noDescription,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.mutedForeground,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // 操作按钮
                  Row(
                    children: [
                      // 收藏按钮
                      GestureDetector(
                        onTap: () => _handleToggleFavorite(job, provider),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: provider.isFavorited(job.id) 
                                ? const Color(0xFFE8805A).withValues(alpha: 0.1)
                                : const Color(0xFFF5F5F8),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                          ),
                          child: Icon(
                            provider.isFavorited(job.id) ? Icons.favorite : Icons.favorite_border,
                            color: provider.isFavorited(job.id) 
                                ? const Color(0xFFE8805A)
                                : AppColors.mutedForeground,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // 投递按钮
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _handleSubmit(job, provider),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6450C8),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                            ),
                          ),
                          child: Text(AppStrings().jobs.applyNow),
                        ),
                      ),
                    ],
                  ),
                  // 查看原链接按钮
                  if (job.sourceUrl != null && job.sourceUrl!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _openSourceUrl(job.sourceUrl!),
                          icon: const Icon(Icons.open_in_new, size: 18),
                          label: Text(AppStrings().jobs.viewOnBoss),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF6450C8),
                            side: const BorderSide(color: Color(0xFF6450C8)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 处理投递
  void _handleSubmit(Job job, JobsProvider provider) async {
    // TODO: 从用户状态获取真实用户ID
    const userId = 'default_user';
    
    final success = await provider.submitJob(userId, job);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings().getStringWithParams(AppStrings().jobs.submitted, {'title': job.title})),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// 处理收藏切换
  void _handleToggleFavorite(Job job, JobsProvider provider) async {
    // TODO: 从用户状态获取真实用户ID
    const userId = 'default_user';
    
    await provider.toggleFavorite(userId, job);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.isFavorited(job.id) ? AppStrings().jobs.addedToFavorite : AppStrings().jobs.removedFromFavorite),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  /// 打开职位原链接
  Future<void> _openSourceUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings().jobs.cannotOpenLink)),
        );
      }
    }
  }
}
