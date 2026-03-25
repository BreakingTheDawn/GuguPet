import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme.dart';
import '../providers/profile_provider.dart';
import '../widgets/user_info_card.dart';
import '../widgets/stat_summary_card.dart';
import '../widgets/vip_status_card.dart';
import '../widgets/menu_list.dart';
import '../../jobs/pages/submissions_page.dart';
import '../../jobs/pages/favorite_jobs_page.dart';
import '../../jobs/providers/submissions_provider.dart';
import '../../jobs/providers/favorite_provider.dart';
import '../../stats/pages/stats_page.dart';
import '../../stats/providers/stats_provider.dart';
import 'job_intention_page.dart';
import 'settings_page.dart';
import 'vip_upgrade_page.dart';
import 'edit_profile_page.dart';

/// 个人中心主页面
/// 整合用户信息、统计数据、VIP状态和功能菜单
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  /// 刷新控制器
  final RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    // 页面初始化时加载数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadUserData();
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          return CustomScrollView(
            slivers: [
              // 自定义AppBar
              _buildSliverAppBar(),
              // 下拉刷新区域
              SliverToBoxAdapter(
                child: _buildRefreshableContent(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 构建SliverAppBar
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFFF8F7FC),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          '个人中心',
          style: AppTypography.headingSmall.copyWith(
            color: AppColors.primary,
          ),
        ),
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
      ),
    );
  }

  /// 构建可刷新的内容区域
  Widget _buildRefreshableContent(ProfileProvider provider) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: _buildContent(provider),
    );
  }

  /// 构建主要内容
  Widget _buildContent(ProfileProvider provider) {
    // 显示加载状态
    if (provider.isLoading && provider.userProfile == null) {
      return _buildLoadingState();
    }

    // 显示错误状态
    if (provider.errorMessage != null && provider.userProfile == null) {
      return _buildErrorState(provider);
    }

    // 显示正常内容
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 用户信息卡片
            UserInfoCard(
              userName: provider.userName,
              jobStatusTag: provider.jobStatusTag,
              onAvatarTap: () => _handleEditProfile(provider),
            ),
            const SizedBox(height: AppSpacing.md),

            // 统计摘要卡片
            StatSummaryCard(
              submissionCount: provider.submissionCount,
              interviewCount: provider.interviewCount,
              offerCount: provider.offerCount,
              onTap: () => _handleNavigateToStats(),
            ),
            const SizedBox(height: AppSpacing.md),

            // VIP状态卡片
            VipStatusCard(
              isVip: provider.isVip,
              vipExpireTime: provider.vipExpireTime,
              onUpgradeTap: () => _handleUpgradeVip(),
            ),
            const SizedBox(height: AppSpacing.lg),

            // 功能菜单标题
            Text(
              '功能入口',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // 功能菜单列表
            MenuList(items: _buildMenuItems(provider)),
          ],
        ),
      ),
    );
  }

  /// 构建菜单项列表
  List<MenuItem> _buildMenuItems(ProfileProvider provider) {
    return [
      MenuItem(
        icon: Icons.work_outline,
        title: '求职意向',
        subtitle: provider.jobStatusTag,
        onTap: () => _handleNavigateToJobIntention(),
      ),
      MenuItem(
        icon: Icons.send_outlined,
        title: '投递记录',
        badgeCount: provider.submissionCount > 0 ? provider.submissionCount : null,
        onTap: () => _handleNavigateToSubmissions(),
      ),
      MenuItem(
        icon: Icons.favorite_outline,
        title: '收藏职位',
        onTap: () => _handleNavigateToFavorites(),
      ),
      MenuItem(
        icon: Icons.settings_outlined,
        title: '设置',
        onTap: () => _handleNavigateToSettings(),
      ),
    ];
  }

  /// 构建加载状态
  Widget _buildLoadingState() {
    return Container(
      height: 400,
      alignment: Alignment.center,
      child: const CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.indigo500),
      ),
    );
  }

  /// 构建错误状态
  Widget _buildErrorState(ProfileProvider provider) {
    return Container(
      height: 400,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.mutedForeground,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            provider.errorMessage ?? '加载失败',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton(
            onPressed: () => provider.loadUserData(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.indigo500,
              foregroundColor: Colors.white,
            ),
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 事件处理方法
  // ═══════════════════════════════════════════════════════════

  /// 下拉刷新
  Future<void> _onRefresh() async {
    await context.read<ProfileProvider>().refresh();
    _refreshController.refreshCompleted();
  }

  /// 编辑个人资料
  Future<void> _handleEditProfile(ProfileProvider provider) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        // 使用 ChangeNotifierProvider.value 提供现有的 Provider
        builder: (context) => ChangeNotifierProvider<ProfileProvider>.value(
          value: provider,
          child: const EditProfilePage(),
        ),
      ),
    );
    
    // 如果保存成功，刷新数据
    if (result == true && mounted) {
      provider.refresh();
    }
  }

  /// 导航到统计页面
  void _handleNavigateToStats() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (_) => StatsProvider(),
          child: const StatsPage(),
        ),
      ),
    );
  }

  /// 升级VIP
  void _handleUpgradeVip() {
    // 先获取数据，避免在新页面的builder中使用context读取Provider
    final provider = context.read<ProfileProvider>();
    final isVip = provider.isVip;
    final vipExpireTime = provider.vipExpireTime;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VipUpgradePage(
          isVip: isVip,
          vipExpireTime: vipExpireTime,
        ),
      ),
    );
  }

  /// 导航到求职意向页面
  Future<void> _handleNavigateToJobIntention() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const JobIntentionPage(),
      ),
    );
    
    // 如果保存成功，刷新数据
    if (result == true && mounted) {
      context.read<ProfileProvider>().refresh();
    }
  }

  /// 导航到投递记录页面
  void _handleNavigateToSubmissions() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (_) => SubmissionsProvider(),
          child: const SubmissionsPage(),
        ),
      ),
    );
  }

  /// 导航到收藏职位页面
  void _handleNavigateToFavorites() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (_) => FavoriteProvider(),
          child: const FavoriteJobsPage(),
        ),
      ),
    );
  }

  /// 导航到设置页面
  void _handleNavigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsPage(),
      ),
    );
  }
}

/// 简单的刷新控制器（用于管理刷新状态）
class RefreshController {
  bool _isRefreshing = false;

  bool get isRefreshing => _isRefreshing;

  void refreshCompleted() {
    _isRefreshing = false;
  }

  void dispose() {
    // 清理资源
  }
}
