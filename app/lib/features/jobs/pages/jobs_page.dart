import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme.dart';
import '../widgets/job_card.dart';
import '../widgets/job_filter_bottom_sheet.dart';
import '../providers/job_filter_provider.dart';

class JobsPage extends StatefulWidget {
  const JobsPage({super.key});

  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  final _searchController = TextEditingController();
  String _searchText = '';
  int _selectedCategory = 0;

  /// 筛选状态Provider
  late final JobFilterProvider _filterProvider;

  static const _categories = ['全部', '设计', '技术', '产品', '运营', '数据'];

  static const _jobs = [
    {
      'id': 1, 'title': 'UI设计师', 'salary': '15k-20k', 'company': '某创意科技有限公司',
      'location': '上海·静安区', 'tags': ['双休', '五险一金', '扁平管理'],
      'isNew': true, 'isUrgent': false, 'salaryColor': Color(0xFFE8805A), 'posted': '1小时前',
      'desc': '负责公司核心产品的视觉设计，包括移动端App、Web端界面设计，参与品牌视觉规范制定。',
    },
    {
      'id': 2, 'title': '产品经理', 'salary': '18k-25k', 'company': '某知名互联网大厂',
      'location': '北京·朝阳区', 'tags': ['六险一金', '期权激励', '免费三餐'],
      'isNew': false, 'isUrgent': true, 'salaryColor': Color(0xFF5A8AE8), 'posted': '3小时前',
      'desc': '主导2C产品从0到1的设计规划，深入分析用户需求，驱动产品功能迭代优化。',
    },
    {
      'id': 3, 'title': '前端工程师', 'salary': '20k-30k', 'company': '某头部电商平台',
      'location': '杭州·余杭区', 'tags': ['双休', '五险一金', '弹性工作'],
      'isNew': true, 'isUrgent': false, 'salaryColor': Color(0xFF5ABE8A), 'posted': '5小时前',
      'desc': '负责核心业务前端研发，技术栈React/TypeScript，参与架构设计。',
    },
    {
      'id': 4, 'title': '品牌运营专员', 'salary': '8k-12k', 'company': '某新消费品牌',
      'location': '广州·天河区', 'tags': ['双休', '五险一金', '餐补'],
      'isNew': false, 'isUrgent': false, 'salaryColor': Color(0xFFC87ACA), 'posted': '昨天',
      'desc': '负责品牌社媒运营，包括小红书、微博、微信公众号等平台内容策划与发布。',
    },
    {
      'id': 5, 'title': '数据分析师', 'salary': '15k-22k', 'company': '某头部本地生活平台',
      'location': '北京·海淀区', 'tags': ['双休', '年终奖', '补充医疗'],
      'isNew': false, 'isUrgent': true, 'salaryColor': Color(0xFFE8C03A), 'posted': '昨天',
      'desc': '负责业务数据的统计分析，搭建数据指标体系，输出数据报告。',
    },
  ];

  List<Map<String, dynamic>> get _filteredJobs {
    var jobs = _jobs;
    
    // 应用搜索过滤
    if (_searchText.isNotEmpty) {
      jobs = jobs.where((job) {
        return job['title'].toString().contains(_searchText) ||
            job['company'].toString().contains(_searchText) ||
            (job['tags'] as List).any((tag) => tag.toString().contains(_searchText));
      }).toList();
    }
    
    // 应用高级筛选
    jobs = jobs.where((job) => _filterProvider.matchesFilter(job)).toList();
    
    return jobs;
  }

  @override
  void initState() {
    super.initState();
    _filterProvider = JobFilterProvider();
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
      child: Consumer<JobFilterProvider>(
        builder: (context, filter, child) {
          return Container(
            color: const Color(0xFFF5F5F8),
            child: Column(
              children: [
                _buildHeader(),
                _buildSearchBar(),
                _buildCategories(),
                // 显示筛选标签
                if (filter.hasAnyFilter) _buildFilterTags(filter),
                Expanded(child: _buildJobList()),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
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
                '为你精选',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.mutedForeground,
                  letterSpacing: 0.15,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '今日新上',
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
                      '${_jobs.where((j) => j['isNew'] == true).length} 个',
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
  Widget _buildSearchBar() {
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
                onChanged: (value) => setState(() => _searchText = value),
                decoration: InputDecoration(
                  hintText: '搜索职位、公司、标签...',
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
            onTap: _showFilterSheet,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _filterProvider.hasAnyFilter 
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
                    color: _filterProvider.hasAnyFilter 
                        ? Colors.white 
                        : const Color(0xFF5A5A7A),
                  ),
                  // 筛选数量指示器
                  if (_filterProvider.filterCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: _filterProvider.hasAnyFilter 
                              ? Colors.white 
                              : AppColors.indigo500,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${_filterProvider.filterCount}',
                          style: AppTypography.caption.copyWith(
                            color: _filterProvider.hasAnyFilter 
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
  Widget _buildFilterTags(JobFilterProvider filter) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filter.activeFilterTags.length + 1, // +1 为清除全部按钮
        itemBuilder: (context, index) {
          // 清除全部按钮
          if (index == filter.activeFilterTags.length) {
            return GestureDetector(
              onTap: () => setState(() => filter.resetAll()),
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
                      '清除全部',
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
          final tag = filter.activeFilterTags[index];
          return GestureDetector(
            onTap: () => setState(() => filter.removeFilterTag(tag)),
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
  void _showFilterSheet() {
    JobFilterBottomSheet.show(
      context: context,
      filterProvider: _filterProvider,
      onConfirm: () {
        setState(() {});
      },
    );
  }

  Widget _buildCategories() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = index == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = index),
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

  Widget _buildJobList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      itemCount: _filteredJobs.length,
      itemBuilder: (context, index) {
        final job = _filteredJobs[index];
        return JobCard(
          job: job,
          onTap: () => _showJobDetail(job),
        );
      },
    );
  }

  void _showJobDetail(Map<String, dynamic> job) {
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          job['title'] as String,
                          style: AppTypography.headingSmall,
                        ),
                      ),
                      Text(
                        job['salary'] as String,
                        style: AppTypography.headingSmall.copyWith(
                          color: job['salaryColor'] as Color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    job['company'] as String,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (job['tags'] as List).map<Widget>((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F8),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                        ),
                        child: Text(
                          tag as String,
                          style: AppTypography.caption,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '职位描述',
                    style: AppTypography.labelMedium.copyWith(
                      color: const Color(0xFF3A3A5A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    job['desc'] as String,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.mutedForeground,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('已投递 ${job['title']}'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6450C8),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                        ),
                      ),
                      child: const Text('立即投递'),
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
}
