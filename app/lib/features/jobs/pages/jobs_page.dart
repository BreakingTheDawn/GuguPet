import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../widgets/job_card.dart';

class JobsPage extends StatefulWidget {
  const JobsPage({super.key});

  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  final _searchController = TextEditingController();
  String _searchText = '';
  int _selectedCategory = 0;

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
    if (_searchText.isEmpty) return _jobs;
    return _jobs.where((job) {
      return job['title'].toString().contains(_searchText) ||
          job['company'].toString().contains(_searchText) ||
          (job['tags'] as List).any((tag) => tag.toString().contains(_searchText));
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F8),
      child: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          _buildCategories(),
          Expanded(child: _buildJobList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F8).withOpacity(0.92),
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
              const SizedBox(height: 2),
              const Text(
                '岗位聚合馆 🔍',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E)),
              ),
            ],
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: AppShadows.button,
            ),
            child: const Icon(Icons.tune, color: AppColors.indigo500, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppShadows.input,
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchText = value),
              decoration: InputDecoration(
                hintText: '搜索岗位、公司或标签...',
                hintStyle: AppTypography.bodySmall.copyWith(color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = index == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = index),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected ? AppColors.primaryGradient : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                boxShadow: AppShadows.button,
              ),
              child: Text(
                _categories[index],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? Colors.white : AppColors.mutedForeground,
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
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: _filteredJobs.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Text(
              '共找到 ${_filteredJobs.length} 个岗位',
              style: AppTypography.caption.copyWith(color: AppColors.mutedForeground),
            ),
          );
        }
        final job = _filteredJobs[index - 1];
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
        maxChildSize: 0.9,
        minChildSize: 0.5,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(job['title'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(
                            job['salary'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: job['salaryColor'],
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F8FC),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(job['company'], style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(job['location'], style: AppTypography.caption),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('职位描述', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(
                    job['desc'],
                    style: AppTypography.bodySmall.copyWith(color: AppColors.mutedForeground, height: 1.8),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                    child: const Center(
                      child: Text('立即投递 🚀', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
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
