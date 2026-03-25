import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme.dart';
import '../../../data/models/job_event.dart';
import '../providers/submissions_provider.dart';

/// 投递记录页面
/// 展示用户的所有投递记录，支持按状态筛选
class SubmissionsPage extends StatefulWidget {
  const SubmissionsPage({super.key});

  @override
  State<SubmissionsPage> createState() => _SubmissionsPageState();
}

class _SubmissionsPageState extends State<SubmissionsPage>
    with SingleTickerProviderStateMixin {
  // Tab控制器
  late TabController _tabController;
  
  // Tab选项
  final List<String> _tabs = ['全部', '已投递', '已查看', '面试中', '已拒绝'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_handleTabChange);

    // 页面加载后获取数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSubmissions();
    });
  }

  /// 加载投递记录
  void _loadSubmissions() {
    // TODO: 从用户状态获取真实用户ID
    const userId = 'default_user';
    context.read<SubmissionsProvider>().loadSubmissions(userId);
  }

  /// 处理Tab切换
  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      context.read<SubmissionsProvider>().filterByStatus(_tabs[_tabController.index]);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: _buildAppBar(),
      body: Consumer<SubmissionsProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              _buildTabBar(),
              _buildStatsBar(provider),
              Expanded(child: _buildList(provider)),
            ],
          );
        },
      ),
    );
  }

  /// 构建AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('投递记录'),
      backgroundColor: Colors.white,
      elevation: 0,
      foregroundColor: const Color(0xFF3A3A5A),
    );
  }

  /// 构建TabBar
  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.indigo500,
        unselectedLabelColor: AppColors.mutedForeground,
        indicatorColor: AppColors.indigo500,
        labelStyle: AppTypography.labelSmall,
        tabs: _tabs.map((t) => Tab(text: t)).toList(),
      ),
    );
  }

  /// 构建统计栏
  Widget _buildStatsBar(SubmissionsProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('总计', provider.totalCount, const Color(0xFF6450C8)),
          _buildStatItem('已投递', provider.submittedCount, const Color(0xFF50A0C8)),
          _buildStatItem('面试', provider.interviewCount, const Color(0xFF50C880)),
        ],
      ),
    );
  }

  /// 构建统计项
  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          '$count',
          style: AppTypography.headingSmall.copyWith(color: color),
        ),
        Text(label, style: AppTypography.caption),
      ],
    );
  }

  /// 构建列表
  Widget _buildList(SubmissionsProvider provider) {
    // 加载中状态
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 错误状态
    if (provider.error != null) {
      return _buildErrorState(provider.error!);
    }

    // 空状态
    if (provider.submissions.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.submissions.length,
      itemBuilder: (context, index) {
        final submission = provider.submissions[index];
        return _buildSubmissionCard(submission, provider);
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
          Text('加载失败', style: AppTypography.bodyMedium.copyWith(color: AppColors.mutedForeground)),
          const SizedBox(height: 8),
          TextButton(onPressed: _loadSubmissions, child: const Text('重试')),
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
          Icon(Icons.inbox_outlined, size: 64, color: AppColors.mutedForeground),
          const SizedBox(height: 16),
          Text('暂无投递记录', style: AppTypography.bodyMedium.copyWith(color: AppColors.mutedForeground)),
          const SizedBox(height: 8),
          Text('去求职看板投递吧~', style: AppTypography.caption.copyWith(color: AppColors.mutedForeground)),
        ],
      ),
    );
  }

  /// 构建投递记录卡片
  Widget _buildSubmissionCard(JobEvent submission, SubmissionsProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  submission.positionName ?? '未知职位',
                  style: AppTypography.labelMedium,
                ),
              ),
              _buildStatusBadge(submission.eventType),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            submission.companyName ?? '未知公司',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.mutedForeground),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatTime(submission.eventTime),
                style: AppTypography.caption.copyWith(color: AppColors.mutedForeground),
              ),
              // 删除按钮
              GestureDetector(
                onTap: () => _handleDelete(submission, provider),
                child: Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: AppColors.mutedForeground,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建状态徽章
  Widget _buildStatusBadge(String type) {
    final statusConfig = {
      'submit': {'label': '已投递', 'color': const Color(0xFF6450C8)},
      'viewed': {'label': '已查看', 'color': const Color(0xFF50A0C8)},
      'interview': {'label': '面试中', 'color': const Color(0xFF50C880)},
      'rejected': {'label': '已拒绝', 'color': const Color(0xFFC85078)},
    };

    final config = statusConfig[type] ?? {'label': '未知', 'color': Colors.grey};

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (config['color'] as Color).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        config['label'] as String,
        style: AppTypography.caption.copyWith(color: config['color'] as Color),
      ),
    );
  }

  /// 格式化时间
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays == 0) {
      return '今天 ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return '昨天';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}天前';
    } else {
      return '${time.month}月${time.day}日';
    }
  }

  /// 处理删除
  void _handleDelete(JobEvent submission, SubmissionsProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除记录'),
        content: Text('确定删除 ${submission.positionName ?? "该"} 投递记录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确定', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // TODO: 从用户状态获取真实用户ID
      const userId = 'default_user';
      await provider.deleteSubmission(submission.id, userId);
    }
  }
}
