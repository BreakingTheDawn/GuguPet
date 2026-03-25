import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/services/app_strings.dart';
import '../../../shared/widgets/widgets.dart';

/// 设置页面
/// 包含通知设置、隐私设置、关于信息等功能
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // ═══════════════════════════════════════════════════════════
  // 通知设置状态
  // ═══════════════════════════════════════════════════════════

  /// 求职提醒开关
  bool _jobReminderEnabled = true;

  /// 面试提醒开关
  bool _interviewReminderEnabled = true;

  /// 宠物互动提醒开关
  bool _petInteractionEnabled = true;

  /// 系统通知开关
  bool _systemNotificationEnabled = false;

  // ═══════════════════════════════════════════════════════════
  // 隐私设置状态
  // ═══════════════════════════════════════════════════════════

  /// 简历公开状态
  bool _resumePublic = true;

  /// 联系方式可见性
  bool _contactVisible = false;

  /// 应用版本号
  static const String _appVersion = '1.0.0';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 通知设置区域
              _buildSectionTitle('通知设置'),
              _buildNotificationSettings(),

              const SizedBox(height: AppSpacing.lg),

              // 隐私设置区域
              _buildSectionTitle('隐私设置'),
              _buildPrivacySettings(),

              const SizedBox(height: AppSpacing.lg),

              // 关于区域
              _buildSectionTitle('关于'),
              _buildAboutSection(),

              const SizedBox(height: AppSpacing.xl),

              // 退出登录按钮
              _buildLogoutButton(),

              const SizedBox(height: AppSpacing.lg),

              // 账号注销按钮
              _buildDeleteAccountButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF8F7FC),
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: AppColors.primary,
          size: AppSpacing.iconMd,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        AppStrings().settings.title,
        style: AppTypography.headingSmall.copyWith(
          color: AppColors.primary,
        ),
      ),
      centerTitle: true,
    );
  }

  /// 构建区域标题
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        title,
        style: AppTypography.labelMedium.copyWith(
          color: AppColors.mutedForeground,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 通知设置区域
  // ═══════════════════════════════════════════════════════════

  /// 构建通知设置卡片
  Widget _buildNotificationSettings() {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        children: [
          _buildSwitchTile(
            icon: Icons.work_outline,
            title: '求职提醒',
            subtitle: '接收职位推荐和投递状态更新通知',
            value: _jobReminderEnabled,
            onChanged: (value) {
              setState(() {
                _jobReminderEnabled = value;
              });
            },
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.calendar_today_outlined,
            title: '面试提醒',
            subtitle: '面试前自动发送提醒通知',
            value: _interviewReminderEnabled,
            onChanged: (value) {
              setState(() {
                _interviewReminderEnabled = value;
              });
            },
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.pets_outlined,
            title: '宠物互动提醒',
            subtitle: '宠物状态变化时发送通知',
            value: _petInteractionEnabled,
            onChanged: (value) {
              setState(() {
                _petInteractionEnabled = value;
              });
            },
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.notifications_outlined,
            title: '系统通知',
            subtitle: '接收系统公告和活动通知',
            value: _systemNotificationEnabled,
            onChanged: (value) {
              setState(() {
                _systemNotificationEnabled = value;
              });
            },
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 隐私设置区域
  // ═══════════════════════════════════════════════════════════

  /// 构建隐私设置卡片
  Widget _buildPrivacySettings() {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        children: [
          _buildSwitchTile(
            icon: Icons.description_outlined,
            title: '简历公开',
            subtitle: '允许招聘方查看您的简历',
            value: _resumePublic,
            onChanged: (value) {
              setState(() {
                _resumePublic = value;
              });
            },
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.phone_outlined,
            title: '联系方式可见',
            subtitle: '允许招聘方获取您的联系方式',
            value: _contactVisible,
            onChanged: (value) {
              setState(() {
                _contactVisible = value;
              });
            },
          ),
          _buildDivider(),
          _buildActionTile(
            icon: Icons.delete_outline,
            title: '清除数据',
            subtitle: '清除本地缓存和浏览记录',
            onTap: _handleClearData,
            isDestructive: false,
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 关于区域
  // ═══════════════════════════════════════════════════════════

  /// 构建关于卡片
  Widget _buildAboutSection() {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        children: [
          _buildInfoTile(
            icon: Icons.info_outline,
            title: '版本信息',
            value: 'v$_appVersion',
          ),
          _buildDivider(),
          _buildActionTile(
            icon: Icons.article_outlined,
            title: '用户协议',
            onTap: _handleUserAgreement,
          ),
          _buildDivider(),
          _buildActionTile(
            icon: Icons.privacy_tip_outlined,
            title: '隐私政策',
            onTap: _handlePrivacyPolicy,
          ),
          _buildDivider(),
          _buildActionTile(
            icon: Icons.people_outline,
            title: '关于我们',
            onTap: _handleAboutUs,
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 通用组件
  // ═══════════════════════════════════════════════════════════

  /// 构建开关设置项
  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          // 图标容器
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.indigo500.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(
              icon,
              size: AppSpacing.iconMd,
              color: AppColors.indigo500,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // 标题和副标题
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // 开关组件
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.indigo500.withValues(alpha: 0.5),
            activeThumbColor: AppColors.indigo500,
          ),
        ],
      ),
    );
  }

  /// 构建操作项（带箭头）
  Widget _buildActionTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            // 图标容器
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDestructive
                    ? AppColors.destructive.withValues(alpha: 0.1)
                    : AppColors.indigo500.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Icon(
                icon,
                size: AppSpacing.iconMd,
                color: isDestructive ? AppColors.destructive : AppColors.indigo500,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // 标题和副标题
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyLarge.copyWith(
                      color: isDestructive ? AppColors.destructive : AppColors.primary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // 箭头图标
            Icon(
              Icons.chevron_right,
              color: AppColors.mutedForeground,
              size: AppSpacing.iconMd,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建信息展示项（带右侧值）
  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          // 图标容器
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.indigo500.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(
              icon,
              size: AppSpacing.iconMd,
              color: AppColors.indigo500,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // 标题
          Expanded(
            child: Text(
              title,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
          // 右侧值
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建分隔线
  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xl + AppSpacing.md + AppSpacing.md),
      child: Divider(
        height: 1,
        thickness: 0.5,
        color: AppColors.divider,
      ),
    );
  }

  /// 构建退出登录按钮
  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _handleLogout,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.indigo500,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          elevation: 0,
        ),
        child: Text(
          '退出登录',
          style: AppTypography.labelLarge.copyWith(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// 构建账号注销按钮
  Widget _buildDeleteAccountButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _handleDeleteAccount,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.destructive,
          side: BorderSide(
            color: AppColors.destructive.withValues(alpha: 0.5),
          ),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
        child: Text(
          '注销账号',
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.destructive,
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 事件处理方法
  // ═══════════════════════════════════════════════════════════

  /// 清除数据
  void _handleClearData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings().settings.clearData),
        content: Text(AppStrings().settings.clearDataConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppStrings().common.cancel,
              style: TextStyle(color: AppColors.mutedForeground),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 实际清除数据逻辑
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('数据已清除')),
              );
            },
            child: Text(
              AppStrings().common.confirm,
              style: TextStyle(color: AppColors.destructive),
            ),
          ),
        ],
      ),
    );
  }

  /// 用户协议
  void _handleUserAgreement() {
    // TODO: 导航到用户协议页面或打开网页
    debugPrint('打开用户协议');
  }

  /// 隐私政策
  void _handlePrivacyPolicy() {
    // TODO: 导航到隐私政策页面或打开网页
    debugPrint('打开隐私政策');
  }

  /// 关于我们
  void _handleAboutUs() {
    // TODO: 导航到关于我们页面
    debugPrint('打开关于我们');
  }

  /// 退出登录
  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings().settings.logout),
        content: Text(AppStrings().settings.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppStrings().common.cancel,
              style: TextStyle(color: AppColors.mutedForeground),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 实际退出登录逻辑
              // 退出后返回登录页面
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Text(
              AppStrings().common.confirm,
              style: TextStyle(color: AppColors.indigo500),
            ),
          ),
        ],
      ),
    );
  }

  /// 注销账号
  void _handleDeleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings().settings.deleteAccount),
        content: Text(AppStrings().settings.deleteAccountConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppStrings().common.cancel,
              style: TextStyle(color: AppColors.mutedForeground),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 实际注销账号逻辑
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Text(
              AppStrings().common.confirm,
              style: TextStyle(color: AppColors.destructive),
            ),
          ),
        ],
      ),
    );
  }
}
