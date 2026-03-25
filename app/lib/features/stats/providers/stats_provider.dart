import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../../../data/models/stats_model.dart';
import '../../../data/repositories/job_repository.dart';
import '../../../data/repositories/job_repository_impl.dart';
import '../../../data/datasources/local/database_helper.dart';
import '../../../core/services/app_strings.dart';

/// 统计数据状态管理
/// 负责加载和管理统计看板的数据
class StatsProvider extends ChangeNotifier {
  // ═══════════════════════════════════════════════════════════
  // 依赖注入
  // ═══════════════════════════════════════════════════════════
  final JobRepository _jobRepository;
  final DatabaseHelper _databaseHelper;

  // ═══════════════════════════════════════════════════════════
  // 状态变量
  // ═══════════════════════════════════════════════════════════
  bool _isLoading = false;
  String? _error;
  StatsModel? _stats;
  
  // ═══════════════════════════════════════════════════════════
  // Getters
  // ═══════════════════════════════════════════════════════════
  bool get isLoading => _isLoading;
  String? get error => _error;
  StatsModel? get stats => _stats;

  // ═══════════════════════════════════════════════════════════
  // 构造函数
  // ═══════════════════════════════════════════════════════════
  StatsProvider({
    JobRepository? jobRepository,
    DatabaseHelper? databaseHelper,
  })  : _jobRepository = jobRepository ?? JobRepositoryImpl(),
        _databaseHelper = databaseHelper ?? DatabaseHelper();

  // ═══════════════════════════════════════════════════════════
  // 公共方法
  // ═══════════════════════════════════════════════════════════

  /// 加载统计数据
  /// [userId] 用户ID
  Future<void> loadStats(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 获取本周统计
      final weeklyStats = await _jobRepository.getWeeklyStats(userId);
      
      // 获取总投递数
      final totalSubmissions = await _jobRepository.getTotalSubmissions(userId);
      
      // 获取每日趋势数据
      final weeklyTrend = await _getWeeklyTrend(userId);
      
      // 计算徽章解锁状态
      final badges = _calculateBadges(totalSubmissions, weeklyStats);

      _stats = StatsModel(
        weeklySubmissions: weeklyStats['submissions'] ?? 0,
        totalSubmissions: totalSubmissions,
        weeklyViews: weeklyStats['views'] ?? 0,
        weeklyInterests: weeklyStats['interests'] ?? 0,
        weeklyInterviews: weeklyStats['interviews'] ?? 0,
        weeklyTrend: weeklyTrend,
        badges: badges,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 刷新数据
  /// [userId] 用户ID
  Future<void> refresh(String userId) async {
    await loadStats(userId);
  }

  // ═══════════════════════════════════════════════════════════
  // 私有方法
  // ═══════════════════════════════════════════════════════════

  /// 获取本周每日趋势
  /// [userId] 用户ID
  Future<List<DailyStats>> _getWeeklyTrend(String userId) async {
    final db = await _databaseHelper.database;
    final now = DateTime.now();
    
    // 计算本周一（周一为一周的第一天）
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    
    final results = <DailyStats>[];
    final statsStrings = AppStrings().stats;
    final dayNames = [
      statsStrings.dayMon, 
      statsStrings.dayTue, 
      statsStrings.dayWed, 
      statsStrings.dayThu, 
      statsStrings.dayFri, 
      statsStrings.daySat, 
      statsStrings.daySun
    ];

    for (int i = 0; i < 7; i++) {
      final day = weekStart.add(Duration(days: i));
      final dayStart = DateTime(day.year, day.month, day.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      // 查询当天的投递数量
      final count = Sqflite.firstIntValue(
        await db.query(
          DatabaseHelper.tableJobEvents,
          columns: ['COUNT(*)'],
          where: 'user_id = ? AND event_type = ? AND event_time >= ? AND event_time < ?',
          whereArgs: [userId, 'submit', dayStart.toIso8601String(), dayEnd.toIso8601String()],
        ),
      ) ?? 0;

      results.add(DailyStats(day: dayNames[i], submissions: count));
    }

    return results;
  }

  /// 计算徽章解锁状态
  /// [total] 总投递数
  /// [weeklyStats] 周统计数据
  List<BadgeModel> _calculateBadges(int total, Map<String, int> weeklyStats) {
    final statsStrings = AppStrings().stats;
    return [
      // 初出茅庐：投递第1份简历
      BadgeModel(
        emoji: '🌱',
        name: statsStrings.badgeFirst,
        desc: statsStrings.badgeFirstDesc,
        unlocked: total >= 1,
      ),
      // 稳步成长：累计投递10份
      BadgeModel(
        emoji: '🌿',
        name: statsStrings.badgeGrowing,
        desc: statsStrings.badgeGrowingDesc,
        unlocked: total >= 10,
      ),
      // 枝繁叶茂：累计投递50份
      BadgeModel(
        emoji: '🌳',
        name: statsStrings.badgeFlourishing,
        desc: statsStrings.badgeFlourishingDesc,
        unlocked: total >= 50,
      ),
      // 投递达人：单日投递5份
      BadgeModel(
        emoji: '🔥',
        name: statsStrings.badgeDaily,
        desc: statsStrings.badgeDailyDesc,
        unlocked: weeklyStats['maxDaily'] != null && weeklyStats['maxDaily']! >= 5,
      ),
      // 坚持不懈：连续7天投递
      BadgeModel(
        emoji: '💎',
        name: statsStrings.badgePersistent,
        desc: statsStrings.badgePersistentDesc,
        unlocked: weeklyStats['consecutiveDays'] != null && weeklyStats['consecutiveDays']! >= 7,
      ),
      // 终获offer：拿到心仪offer
      BadgeModel(
        emoji: '🏆',
        name: statsStrings.badgeOffer,
        desc: statsStrings.badgeOfferDesc,
        unlocked: weeklyStats['hasOffer'] == 1,
      ),
    ];
  }
}
