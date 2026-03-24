import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme.dart';
import '../providers/notification_provider.dart';
import '../data/models/notification.dart' as model;
import '../widgets/notification_item.dart';
import '../widgets/notification_empty.dart';
import '../widgets/notification_badge.dart';
import 'notification_settings_page.dart';

// ═══════════════════════════════════════════════════════════════════════════════
/// 通知中心主页面
/// 展示用户的所有通知消息，支持分类筛选和批量操作
// ═══════════════════════════════════════════════════════════════════════════════
class NotificationCenterPage extends StatefulWidget {
  const NotificationCenterPage({super.key});

  @override
  State<NotificationCenterPage> createState() => _NotificationCenterPageState();
}

class _NotificationCenterPageState extends State<NotificationCenterPage>
    with SingleTickerProviderStateMixin {
  // ────────────────────────────────────────────────────────────────────────────
  // 状态变量
  // ────────────────────────────────────────────────────────────────────────────

  /// Tab控制器
  late TabController _tabController;

  /// 当前选中的Tab索引
  int _currentTabIndex = 0;

  /// Tab标签列表
  final List<String> _tabLabels = ['全部', '求职', '专栏', '系统'];

  /// Tab对应的通知类型（null表示全部）
  final List<model.NotificationType?> _tabTypes = [
    null,
    model.NotificationType.interview,
    model.NotificationType.columnUpdate,
    model.NotificationType.system,
  ];

  // ────────────────────────────────────────────────────────────────────────────
  // 生命周期方法
  // ────────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    // 初始化Tab控制器
    _tabController = TabController(
      length: _tabLabels.length,
      vsync: this,
    );
    _tabController.addListener(_handleTabChange);

    // 页面加载时获取通知数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotifications();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 数据加载方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 加载通知列表
  Future<void> _loadNotifications() async {
    final provider = context.read<NotificationProvider>();
    await provider.loadNotifications(
      provider.userId,
      type: _tabTypes[_currentTabIndex],
    );
  }

  /// 下拉刷新通知列表
  Future<void> _onRefresh() async {
    final provider = context.read<NotificationProvider>();
    await provider.refreshNotifications();
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 事件处理方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 处理Tab切换
  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      return;
    }
    
    setState(() {
      _currentTabIndex = _tabController.index;
    });

    // 根据选中的Tab筛选通知类型
    final provider = context.read<NotificationProvider>();
    provider.filterByType(_tabTypes[_currentTabIndex]);
  }

  /// 标记所有通知为已读
  Future<void> _handleMarkAllAsRead() async {
    final provider = context.read<NotificationProvider>();
    
    // 检查是否有未读通知
    if (provider.unreadCount == 0) {
      _showSnackBar('没有未读通知');
      return;
    }

    // 显示确认对话框
    final confirmed = await _showConfirmDialog(
      '标记已读',
      '确定将所有通知标记为已读吗？',
    );

    if (confirmed == true) {
      try {
        await provider.markAllAsRead();
        _showSnackBar('已全部标记为已读');
      } catch (e) {
        _showSnackBar('操作失败，请重试');
      }
    }
  }

  /// 导航到通知设置页面
  void _handleNavigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationSettingsPage(),
      ),
    );
  }

  /// 点击通知项
  void _handleNotificationTap(model.Notification notification) async {
    // 如果未读，标记为已读
    if (!notification.isRead) {
      final provider = context.read<NotificationProvider>();
      await provider.markAsRead(notification.id);
    }

    // 根据通知类型执行不同的操作
    _handleNotificationAction(notification);
  }

  /// 根据通知类型执行操作
  void _handleNotificationAction(model.Notification notification) {
    switch (notification.type) {
      case model.NotificationType.interview:
        // TODO: 导航到面试详情页面
        debugPrint('查看面试详情: ${notification.title}');
        break;
      case model.NotificationType.jobStatus:
        // TODO: 导航到投递记录页面
        debugPrint('查看投递状态: ${notification.title}');
        break;
      case model.NotificationType.columnUpdate:
        // TODO: 导航到专栏详情页面
        debugPrint('查看专栏更新: ${notification.title}');
        break;
      case model.NotificationType.vipExpire:
        // TODO: 导航到VIP续费页面
        debugPrint('VIP续费提醒: ${notification.title}');
        break;
      case model.NotificationType.activity:
        // TODO: 导航到活动详情页面
        debugPrint('查看活动: ${notification.title}');
        break;
      case model.NotificationType.system:
        // TODO: 显示系统公告详情
        debugPrint('系统公告: ${notification.title}');
        break;
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // UI构建方法
  // ────────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // 顶部标题栏
              _buildAppBar(provider),
              // Tab栏
              _buildTabBar(),
              // 通知列表
              Expanded(
                child: _buildNotificationList(provider),
              ),
              // 底部操作栏
              _buildBottomBar(provider),
            ],
          );
        },
      ),
    );
  }

  /// 构建顶部标题栏
  Widget _buildAppBar(NotificationProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // 返回按钮
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 20),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
              ),
              // 标题
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '通知中心',
                      style: AppTypography.headingSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    // 未读角标
                    if (provider.unreadCount > 0) ...[
                      const SizedBox(width: 8),
                      NotificationBadge(count: provider.unreadCount),
                    ],
                  ],
                ),
              ),
              // 设置按钮
              IconButton(
                icon: const Icon(Icons.settings_outlined, size: 24),
                onPressed: _handleNavigateToSettings,
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建Tab栏
  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.indigo500,
        unselectedLabelColor: AppColors.mutedForeground,
        labelStyle: AppTypography.labelMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTypography.labelMedium,
        indicatorColor: AppColors.indigo500,
        indicatorWeight: 2,
        indicatorSize: TabBarIndicatorSize.label,
        tabs: _tabLabels.map((label) => Tab(text: label)).toList(),
      ),
    );
  }

  /// 构建通知列表
  Widget _buildNotificationList(NotificationProvider provider) {
    // 显示加载状态
    if (provider.isLoading && provider.notifications.isEmpty) {
      return _buildLoadingState();
    }

    // 显示错误状态
    if (provider.errorMessage != null && provider.notifications.isEmpty) {
      return _buildErrorState(provider);
    }

    // 获取筛选后的通知列表
    final notifications = provider.filteredNotifications;

    // 显示空状态
    if (notifications.isEmpty) {
      return NotificationEmpty(
        type: _tabTypes[_currentTabIndex],
      );
    }

    // 显示通知列表
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.indigo500,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: NotificationItem(
              notification: notification,
              onTap: () => _handleNotificationTap(notification),
            ),
          );
        },
      ),
    );
  }

  /// 构建底部操作栏
  Widget _buildBottomBar(NotificationProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ElevatedButton(
            onPressed: provider.unreadCount > 0 ? _handleMarkAllAsRead : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.indigo500,
              disabledBackgroundColor: AppColors.muted,
              foregroundColor: Colors.white,
              disabledForegroundColor: AppColors.mutedForeground,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              '全部标记为已读',
              style: AppTypography.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 构建加载状态
  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.indigo500),
      ),
    );
  }

  /// 构建错误状态
  Widget _buildErrorState(NotificationProvider provider) {
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
            provider.errorMessage ?? '加载失败',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadNotifications,
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

  // ────────────────────────────────────────────────────────────────────────────
  // 辅助方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 显示提示消息
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// 显示确认对话框
  Future<bool?> _showConfirmDialog(String title, String content) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                '取消',
                style: TextStyle(color: AppColors.mutedForeground),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                '确定',
                style: TextStyle(color: AppColors.indigo500),
              ),
            ),
          ],
        );
      },
    );
  }
}
