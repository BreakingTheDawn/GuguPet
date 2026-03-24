import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme.dart';
import '../providers/notification_provider.dart';
import '../data/models/notification_settings.dart';

// ═══════════════════════════════════════════════════════════════════════════════
/// 通知设置页面
/// 用于管理用户的通知偏好设置，包括推送开关、通知类型开关和免打扰时段
// ═══════════════════════════════════════════════════════════════════════════════
class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  // ────────────────────────────────────────────────────────────────────────────
  // 状态变量
  // ────────────────────────────────────────────────────────────────────────────

  /// 推送总开关
  bool _pushEnabled = true;

  /// 面试提醒开关
  bool _interviewEnabled = true;

  /// 投递状态更新开关
  bool _jobStatusEnabled = true;

  /// 专栏更新开关
  bool _columnUpdateEnabled = true;

  /// VIP到期提醒开关
  bool _vipExpireEnabled = true;

  /// 活动通知开关
  bool _activityEnabled = true;

  /// 系统公告开关
  bool _systemEnabled = true;

  /// 免打扰开关
  bool _quietHoursEnabled = false;

  /// 免打扰开始时间
  TimeOfDay _quietHoursStart = const TimeOfDay(hour: 22, minute: 0);

  /// 免打扰结束时间
  TimeOfDay _quietHoursEnd = const TimeOfDay(hour: 8, minute: 0);

  /// 是否正在保存
  bool _isSaving = false;

  /// 设置是否已加载
  bool _isLoaded = false;

  // ────────────────────────────────────────────────────────────────────────────
  // 生命周期方法
  // ────────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    // 页面加载时获取设置数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSettings();
    });
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 数据加载方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 加载通知设置
  Future<void> _loadSettings() async {
    final provider = context.read<NotificationProvider>();
    await provider.loadSettings(provider.userId);

    // 如果有设置数据，更新本地状态
    final settings = provider.settings;
    if (settings != null) {
      setState(() {
        _pushEnabled = settings.pushEnabled;
        _interviewEnabled = settings.interviewEnabled;
        _jobStatusEnabled = settings.jobStatusEnabled;
        _columnUpdateEnabled = settings.columnUpdateEnabled;
        _vipExpireEnabled = settings.vipExpireEnabled;
        _activityEnabled = settings.activityEnabled;
        _systemEnabled = settings.systemEnabled;

        // 解析免打扰时间
        if (settings.quietHoursStart != null) {
          _quietHoursStart = _parseTimeString(settings.quietHoursStart!);
          _quietHoursEnabled = true;
        }
        if (settings.quietHoursEnd != null) {
          _quietHoursEnd = _parseTimeString(settings.quietHoursEnd!);
        }

        _isLoaded = true;
      });
    } else {
      setState(() {
        _isLoaded = true;
      });
    }
  }

  /// 解析时间字符串为TimeOfDay
  /// [timeString] 时间字符串，格式为 HH:mm
  TimeOfDay _parseTimeString(String timeString) {
    final parts = timeString.split(':');
    if (parts.length == 2) {
      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;
      return TimeOfDay(hour: hour, minute: minute);
    }
    return const TimeOfDay(hour: 0, minute: 0);
  }

  /// 将TimeOfDay转换为时间字符串
  /// [time] TimeOfDay对象
  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 保存设置方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 保存通知设置到数据库
  Future<void> _saveSettings() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final provider = context.read<NotificationProvider>();
      final settings = provider.settings;

      // 创建或更新设置对象
      final newSettings = NotificationSettings(
        id: settings?.id ?? 'settings_${provider.userId}',
        userId: provider.userId,
        pushEnabled: _pushEnabled,
        interviewEnabled: _interviewEnabled,
        jobStatusEnabled: _jobStatusEnabled,
        columnUpdateEnabled: _columnUpdateEnabled,
        vipExpireEnabled: _vipExpireEnabled,
        activityEnabled: _activityEnabled,
        systemEnabled: _systemEnabled,
        quietHoursStart: _quietHoursEnabled ? _formatTimeOfDay(_quietHoursStart) : null,
        quietHoursEnd: _quietHoursEnabled ? _formatTimeOfDay(_quietHoursEnd) : null,
        createdAt: settings?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 调用Provider保存设置
      await provider.updateSettings(newSettings);

      // 显示成功提示
      if (mounted) {
        _showSnackBar('设置已保存');
      }
    } catch (e) {
      debugPrint('保存设置失败: $e');
      if (mounted) {
        _showSnackBar('保存失败，请重试');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 事件处理方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 处理推送总开关变化
  void _handlePushEnabledChanged(bool value) {
    setState(() {
      _pushEnabled = value;
    });
    _saveSettings();
  }

  /// 处理通知类型开关变化
  void _handleNotificationTypeChanged(
    String type,
    bool value,
  ) {
    setState(() {
      switch (type) {
        case 'interview':
          _interviewEnabled = value;
          break;
        case 'jobStatus':
          _jobStatusEnabled = value;
          break;
        case 'columnUpdate':
          _columnUpdateEnabled = value;
          break;
        case 'vipExpire':
          _vipExpireEnabled = value;
          break;
        case 'activity':
          _activityEnabled = value;
          break;
        case 'system':
          _systemEnabled = value;
          break;
      }
    });
    _saveSettings();
  }

  /// 处理免打扰开关变化
  void _handleQuietHoursEnabledChanged(bool value) {
    setState(() {
      _quietHoursEnabled = value;
    });
    _saveSettings();
  }

  /// 选择免打扰开始时间
  Future<void> _selectQuietHoursStart() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _quietHoursStart,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteTextColor: AppColors.indigo500,
              dialHandColor: AppColors.indigo500,
              dialBackgroundColor: AppColors.indigo50,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      setState(() {
        _quietHoursStart = time;
      });
      _saveSettings();
    }
  }

  /// 选择免打扰结束时间
  Future<void> _selectQuietHoursEnd() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _quietHoursEnd,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteTextColor: AppColors.indigo500,
              dialHandColor: AppColors.indigo500,
              dialBackgroundColor: AppColors.indigo50,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      setState(() {
        _quietHoursEnd = time;
      });
      _saveSettings();
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
          // 显示加载状态
          if (!_isLoaded || provider.isLoading) {
            return _buildLoadingState();
          }

          return Column(
            children: [
              // 顶部标题栏
              _buildAppBar(),
              // 设置内容
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 推送通知总开关
                      _buildPushSwitch(),
                      const SizedBox(height: 24),
                      // 通知类型设置
                      _buildNotificationTypes(),
                      const SizedBox(height: 24),
                      // 免打扰时段设置
                      _buildQuietHours(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 构建顶部标题栏
  Widget _buildAppBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                child: Center(
                  child: Text(
                    '通知设置',
                    style: AppTypography.headingSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              // 占位，保持标题居中
              const SizedBox(width: 48),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建推送通知总开关
  Widget _buildPushSwitch() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // 图标
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.indigo50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.notifications_active_outlined,
                color: AppColors.indigo500,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // 文字说明
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '推送通知',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '接收应用推送通知',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            // 开关
            Switch(
              value: _pushEnabled,
              onChanged: _handlePushEnabledChanged,
              thumbColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColors.indigo500;
                }
                return null;
              }),
              trackColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColors.indigo200;
                }
                return null;
              }),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建通知类型设置
  Widget _buildNotificationTypes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            '通知类型',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.mutedForeground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // 设置卡片
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                offset: const Offset(0, 2),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            children: [
              _buildNotificationTypeItem(
                icon: Icons.work_outline,
                title: '面试提醒',
                value: _interviewEnabled,
                onChanged: (value) => _handleNotificationTypeChanged('interview', value),
                showDivider: true,
              ),
              _buildNotificationTypeItem(
                icon: Icons.send_outlined,
                title: '投递状态更新',
                value: _jobStatusEnabled,
                onChanged: (value) => _handleNotificationTypeChanged('jobStatus', value),
                showDivider: true,
              ),
              _buildNotificationTypeItem(
                icon: Icons.article_outlined,
                title: '专栏更新',
                value: _columnUpdateEnabled,
                onChanged: (value) => _handleNotificationTypeChanged('columnUpdate', value),
                showDivider: true,
              ),
              _buildNotificationTypeItem(
                icon: Icons.card_membership_outlined,
                title: 'VIP到期提醒',
                value: _vipExpireEnabled,
                onChanged: (value) => _handleNotificationTypeChanged('vipExpire', value),
                showDivider: true,
              ),
              _buildNotificationTypeItem(
                icon: Icons.event_outlined,
                title: '活动通知',
                value: _activityEnabled,
                onChanged: (value) => _handleNotificationTypeChanged('activity', value),
                showDivider: true,
              ),
              _buildNotificationTypeItem(
                icon: Icons.campaign_outlined,
                title: '系统公告',
                value: _systemEnabled,
                onChanged: (value) => _handleNotificationTypeChanged('system', value),
                showDivider: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建单个通知类型设置项
  Widget _buildNotificationTypeItem({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool showDivider,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              // 图标
              Icon(
                icon,
                color: AppColors.mutedForeground,
                size: 20,
              ),
              const SizedBox(width: 16),
              // 标题
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
              // 开关
              Switch(
                value: value,
                onChanged: _pushEnabled ? onChanged : null,
                thumbColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return AppColors.indigo500;
                  }
                  return null;
                }),
                trackColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return AppColors.indigo200;
                  }
                  return null;
                }),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 56,
            endIndent: 20,
            color: AppColors.border,
          ),
      ],
    );
  }

  /// 构建免打扰时段设置
  Widget _buildQuietHours() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            '免打扰时段',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.mutedForeground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // 设置卡片
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                offset: const Offset(0, 2),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            children: [
              // 免打扰开关
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.do_not_disturb_on_outlined,
                      color: AppColors.mutedForeground,
                      size: 20,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        '开启免打扰',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Switch(
                      value: _quietHoursEnabled,
                      onChanged: _pushEnabled ? _handleQuietHoursEnabledChanged : null,
                      thumbColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return AppColors.indigo500;
                        }
                        return null;
                      }),
                      trackColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return AppColors.indigo200;
                        }
                        return null;
                      }),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                indent: 56,
                endIndent: 20,
                color: AppColors.border,
              ),
              // 开始时间
              _buildTimeSelector(
                title: '开始时间',
                time: _quietHoursStart,
                onTap: _quietHoursEnabled && _pushEnabled ? _selectQuietHoursStart : null,
              ),
              Divider(
                height: 1,
                indent: 56,
                endIndent: 20,
                color: AppColors.border,
              ),
              // 结束时间
              _buildTimeSelector(
                title: '结束时间',
                time: _quietHoursEnd,
                onTap: _quietHoursEnabled && _pushEnabled ? _selectQuietHoursEnd : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建时间选择器
  Widget _buildTimeSelector({
    required String title,
    required TimeOfDay time,
    required VoidCallback? onTap,
  }) {
    final isEnabled = onTap != null;
    final timeString = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            const SizedBox(width: 36),
            Text(
              title,
              style: AppTypography.labelMedium.copyWith(
                color: isEnabled ? AppColors.primary : AppColors.mutedForeground,
              ),
            ),
            const Spacer(),
            Text(
              timeString,
              style: AppTypography.labelMedium.copyWith(
                color: isEnabled ? AppColors.indigo500 : AppColors.mutedForeground,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isEnabled) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.mutedForeground,
                size: 14,
              ),
            ],
          ],
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
}
