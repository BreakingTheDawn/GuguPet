import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../widgets/stat_card.dart';
import '../widgets/weekly_chart.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  static const _weekData = [
    {'day': '周一', 'submissions': 8, 'interviews': 1},
    {'day': '周二', 'submissions': 12, 'interviews': 2},
    {'day': '周三', 'submissions': 5, 'interviews': 0},
    {'day': '周四', 'submissions': 15, 'interviews': 3},
    {'day': '周五', 'submissions': 9, 'interviews': 1},
    {'day': '周六', 'submissions': 3, 'interviews': 0},
    {'day': '周日', 'submissions': 12, 'interviews': 2},
  ];

  static const _badges = [
    {'name': '百折不挠', 'desc': '累计投递100份', 'emoji': '💪', 'unlocked': true},
    {'name': '面试达人', 'desc': '完成10次面试', 'emoji': '🎯', 'unlocked': true},
    {'name': '社交蝴蝶', 'desc': '公园结交5位好友', 'emoji': '🦋', 'unlocked': false},
    {'name': 'Offer猎手', 'desc': '斩获3个Offer', 'emoji': '🏆', 'unlocked': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF7F8FC),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildChartCard(),
            const SizedBox(height: 16),
            _buildProgressCard(),
            const SizedBox(height: 16),
            _buildBadgeWall(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
      decoration: const BoxDecoration(gradient: AppColors.statsHeaderGradient),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '今日战报',
            style: AppTypography.labelSmall.copyWith(
              color: Colors.white70,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '坚持就是胜利 ✨',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: '投递数',
                  value: 128,
                  unit: '份',
                  backgroundColor: const Color(0xFFFFB478).withOpacity(0.25),
                  borderColor: const Color(0xFFFFA050).withOpacity(0.4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  label: '面试数',
                  value: 14,
                  unit: '次',
                  backgroundColor: const Color(0xFFA0D2F0).withOpacity(0.25),
                  borderColor: const Color(0xFF78BEE6).withOpacity(0.4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  label: 'Offer数',
                  value: 2,
                  unit: '个',
                  backgroundColor: const Color(0xFFA0DCA0).withOpacity(0.25),
                  borderColor: const Color(0xFF78C878).withOpacity(0.4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '本周行动轨迹',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '持续输出，好运自来',
                    style: AppTypography.caption.copyWith(color: AppColors.mutedForeground),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Text(
                  '近7天',
                  style: AppTypography.labelSmall.copyWith(color: AppColors.indigo500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          WeeklyChart(data: _weekData),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('阶段进度', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          _buildProgressBar('简历投递', 128, 200, const Color(0xFFF5A87A)),
          const SizedBox(height: 12),
          _buildProgressBar('面试通过', 14, 20, const Color(0xFF7AB8E8)),
          const SizedBox(height: 12),
          _buildProgressBar('Offer目标', 2, 3, const Color(0xFF7ACA7A)),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, int current, int target, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTypography.bodySmall),
            Text('$current / $target', style: AppTypography.caption.copyWith(color: AppColors.mutedForeground)),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F6),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: (current / target).clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeWall() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('我的勋章墙', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              Text('2/4 已解锁', style: AppTypography.caption.copyWith(color: AppColors.mutedForeground)),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
            ),
            itemCount: _badges.length,
            itemBuilder: (context, index) => _buildBadgeCard(_badges[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeCard(Map<String, dynamic> badge) {
    final unlocked = badge['unlocked'] as bool;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: unlocked ? const Color(0xFFF5C5A0).withOpacity(0.2) : const Color(0xFFF5F5F8),
        borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
        border: Border.all(
          color: unlocked ? const Color(0xFFF5C5A0) : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(badge['emoji'], style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            badge['name'],
            style: AppTypography.labelMedium.copyWith(
              color: unlocked ? const Color(0xFF3A3A5A) : AppColors.mutedForeground,
            ),
          ),
          Text(
            badge['desc'],
            style: AppTypography.caption.copyWith(color: AppColors.mutedForeground),
          ),
        ],
      ),
    );
  }
}
