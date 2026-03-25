import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme.dart';
import '../../../core/services/app_strings.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../shared/widgets/login_required_dialog.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/weekly_chart.dart';
import '../widgets/stat_card.dart';
import '../providers/stats_provider.dart';

/// 统计看板页面
/// 展示用户的求职统计数据和成就徽章
class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage>
    with SingleTickerProviderStateMixin {
  // 动画控制器
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // 初始化动画控制器
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    
    // 页面加载后获取统计数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStats();
    });
    
    _controller.forward();
  }

  /// 加载统计数据
  void _loadStats() async {
    // 检查登录状态
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAuthenticated) {
      final shouldLogin = await LoginRequiredDialog.show(
        context,
        featureName: AppStrings().stats.featureName,
      );
      if (shouldLogin != true && mounted) {
        // 用户选择不登录，返回上一页
        Navigator.of(context).pop();
      }
      return;
    }
    
    // 使用登录用户的ID
    final userId = authProvider.currentUser?.userId ?? 'default_user';
    context.read<StatsProvider>().loadStats(userId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: AppBar(
        title: Text(
          AppStrings().stats.title,
          style: AppTypography.headingSmall.copyWith(
            color: AppColors.primary,
          ),
        ),
        backgroundColor: const Color(0xFFF8F7FC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Consumer<StatsProvider>(
          builder: (context, provider, child) {
            // 加载中状态
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            
            // 错误状态
            if (provider.error != null) {
              return _buildErrorState(provider.error!);
            }
            
            // 正常显示
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(provider.stats),
                  const SizedBox(height: 24),
                  _buildStatsGrid(provider.stats),
                  const SizedBox(height: 24),
                  _buildWeeklyChart(provider.stats),
                  const SizedBox(height: 24),
                  _buildBadgesSection(provider.stats),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// 构建错误状态
  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.mutedForeground,
          ),
          const SizedBox(height: 16),
          Text(
              AppStrings().stats.loadFailed,
              style: AppTypography.bodyMedium.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _loadStats,
            child: Text(AppStrings().common.retry),
          ),
        ],
      ),
    );
  }

  /// 构建页面标题
  Widget _buildHeader(dynamic stats) {
    final weeklySubmissions = stats?.weeklySubmissions ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings().stats.weeklyTitle,
          style: AppTypography.headingSmall.copyWith(
            color: const Color(0xFF3A3A5A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          AppStrings().getStringWithParams(
            AppStrings().stats.weeklySubtitle,
            {'count': weeklySubmissions.toString()}
          ),
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.mutedForeground,
          ),
        ),
      ],
    );
  }

  /// 构建统计卡片网格
  Widget _buildStatsGrid(dynamic stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.35,
      children: [
        StatCard(
          icon: Icons.send_outlined,
          label: AppStrings().stats.weeklySubmissions,
          value: stats?.weeklySubmissions ?? 0,
          change: _calculateChange(stats?.weeklySubmissions ?? 0),
          color: const Color(0xFF6450C8),
        ),
        StatCard(
          icon: Icons.visibility_outlined,
          label: AppStrings().stats.viewed,
          value: stats?.weeklyViews ?? 0,
          change: _calculateChange(stats?.weeklyViews ?? 0),
          color: const Color(0xFF50A0C8),
        ),
        StatCard(
          icon: Icons.favorite_outline,
          label: AppStrings().stats.interested,
          value: stats?.weeklyInterests ?? 0,
          change: AppStrings().stats.unchanged,
          color: const Color(0xFFC85078),
        ),
        StatCard(
          icon: Icons.chat_bubble_outline,
          label: AppStrings().stats.interviewInvites,
          value: stats?.weeklyInterviews ?? 0,
          change: (stats?.weeklyInterviews ?? 0) > 0 ? AppStrings().stats.newAdd : AppStrings().stats.none,
          color: const Color(0xFF50C880),
        ),
      ],
    );
  }

  /// 计算变化百分比
  String _calculateChange(int value) {
    if (value == 0) return AppStrings().stats.none;
    if (value > 10) return '+${(value * 0.1).toStringAsFixed(0)}%';
    return '+$value';
  }

  /// 构建周投递趋势图表
  Widget _buildWeeklyChart(dynamic stats) {
    final trend = stats?.weeklyTrend as List<dynamic>? ?? [];
    final List<Map<String, dynamic>> chartData = trend
        .map((e) => (e as dynamic).toMap() as Map<String, dynamic>)
        .toList();
    
    // 如果没有数据，显示默认数据
    if (chartData.isEmpty) {
      final statsStrings = AppStrings().stats;
      chartData.addAll([
        {'day': statsStrings.dayMon, 'submissions': 0},
        {'day': statsStrings.dayTue, 'submissions': 0},
        {'day': statsStrings.dayWed, 'submissions': 0},
        {'day': statsStrings.dayThu, 'submissions': 0},
        {'day': statsStrings.dayFri, 'submissions': 0},
        {'day': statsStrings.daySat, 'submissions': 0},
        {'day': statsStrings.daySun, 'submissions': 0},
      ]);
    }
    
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings().stats.weeklyTrend,
            style: AppTypography.labelMedium.copyWith(
              color: const Color(0xFF3A3A5A),
            ),
          ),
          const SizedBox(height: 16),
          WeeklyChart(data: chartData),
        ],
      ),
    );
  }

  /// 构建成就徽章区域
  Widget _buildBadgesSection(dynamic stats) {
    final badges = stats?.badges as List<dynamic>? ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings().stats.achievementBadges,
          style: AppTypography.labelMedium.copyWith(
            color: const Color(0xFF3A3A5A),
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.9,
          ),
          itemCount: badges.length,
          itemBuilder: (context, index) {
            return _buildBadgeCard(badges[index]);
          },
        ),
      ],
    );
  }

  /// 构建徽章卡片
  Widget _buildBadgeCard(dynamic badge) {
    final unlocked = badge.unlocked as bool;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: unlocked ? const Color(0xFFF5C5A0).withValues(alpha: 0.2) : const Color(0xFFF5F5F8),
        borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
        border: Border.all(
          color: unlocked ? const Color(0xFFF5C5A0) : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(badge.emoji as String, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 4),
          Text(
            badge.name as String,
            style: AppTypography.labelMedium.copyWith(
              color: unlocked ? const Color(0xFF3A3A5A) : AppColors.mutedForeground,
            ),
          ),
          Text(
            badge.desc as String,
            style: AppTypography.caption.copyWith(color: AppColors.mutedForeground),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
