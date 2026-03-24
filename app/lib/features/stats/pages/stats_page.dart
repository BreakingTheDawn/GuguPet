import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../widgets/weekly_chart.dart';
import '../widgets/stat_card.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  static const _weeklyData = [
    {'day': '周一', 'submissions': 3},
    {'day': '周二', 'submissions': 5},
    {'day': '周三', 'submissions': 2},
    {'day': '周四', 'submissions': 7},
    {'day': '周五', 'submissions': 4},
    {'day': '周六', 'submissions': 1},
    {'day': '周日', 'submissions': 2},
  ];

  static const _badges = [
    {'emoji': '🌱', 'name': '初出茅庐', 'desc': '投递第1份简历', 'unlocked': true},
    {'emoji': '🌿', 'name': '稳步成长', 'desc': '累计投递10份', 'unlocked': true},
    {'emoji': '🌳', 'name': '枝繁叶茂', 'desc': '累计投递50份', 'unlocked': false},
    {'emoji': '🔥', 'name': '投递达人', 'desc': '单日投递5份', 'unlocked': true},
    {'emoji': '💎', 'name': '坚持不懈', 'desc': '连续7天投递', 'unlocked': false},
    {'emoji': '🏆', 'name': '终获offer', 'desc': '拿到心仪offer', 'unlocked': false},
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F7FC),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 48, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildStatsGrid(),
              const SizedBox(height: 24),
              _buildWeeklyChart(),
              const SizedBox(height: 24),
              _buildBadgesSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '求职数据',
          style: AppTypography.headingSmall.copyWith(
            color: const Color(0xFF3A3A5A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '本周已投递 24 份简历',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.mutedForeground,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.35,
      children: const [
        StatCard(
          icon: Icons.send_outlined,
          label: '本周投递',
          value: 24,
          change: '+12%',
          color: Color(0xFF6450C8),
        ),
        StatCard(
          icon: Icons.visibility_outlined,
          label: '被查看',
          value: 8,
          change: '+25%',
          color: Color(0xFF50A0C8),
        ),
        StatCard(
          icon: Icons.favorite_outline,
          label: '感兴趣',
          value: 3,
          change: '持平',
          color: Color(0xFFC85078),
        ),
        StatCard(
          icon: Icons.chat_bubble_outline,
          label: '面试邀约',
          value: 1,
          change: '新增',
          color: Color(0xFF50C880),
        ),
      ],
    );
  }

  Widget _buildWeeklyChart() {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '本周投递趋势',
            style: AppTypography.labelMedium.copyWith(
              color: const Color(0xFF3A3A5A),
            ),
          ),
          const SizedBox(height: 16),
          WeeklyChart(data: _weeklyData),
        ],
      ),
    );
  }

  Widget _buildBadgesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '成就徽章',
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
          itemCount: _badges.length,
          itemBuilder: (context, index) {
            return _buildBadgeCard(_badges[index]);
          },
        ),
      ],
    );
  }

  Widget _buildBadgeCard(Map<String, dynamic> badge) {
    final unlocked = badge['unlocked'] as bool;
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
          Text(badge['emoji'], style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 4),
          Text(
            badge['name'],
            style: AppTypography.labelMedium.copyWith(
              color: unlocked ? const Color(0xFF3A3A5A) : AppColors.mutedForeground,
            ),
          ),
          Text(
            badge['desc'],
            style: AppTypography.caption.copyWith(color: AppColors.mutedForeground),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
