import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../data/models/notification.dart' as model;

// ═══════════════════════════════════════════════════════════════════════════════
/// 通知空状态组件
/// 当没有通知时显示的空状态页面
// ═══════════════════════════════════════════════════════════════════════════════
class NotificationEmpty extends StatelessWidget {
  // ────────────────────────────────────────────────────────────────────────────
  // 属性定义
  // ────────────────────────────────────────────────────────────────────────────

  /// 当前筛选的通知类型（null表示全部）
  final model.NotificationType? type;

  const NotificationEmpty({
    super.key,
    this.type,
  });

  // ────────────────────────────────────────────────────────────────────────────
  // UI构建方法
  // ────────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 空状态图标
              _buildEmptyIcon(),
              const SizedBox(height: 24),
              // 空状态标题
              _buildTitle(),
              const SizedBox(height: 8),
              // 空状态描述
              _buildDescription(),
              const SizedBox(height: 32),
              // 操作按钮（可选）
              if (type == null) _buildAction(),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建空状态图标
  Widget _buildEmptyIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.muted.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _getEmptyIcon(),
        size: 56,
        color: AppColors.mutedForeground,
      ),
    );
  }

  /// 构建标题
  Widget _buildTitle() {
    return Text(
      _getTitle(),
      style: AppTypography.headingSmall.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.w600,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// 构建描述文本
  Widget _buildDescription() {
    return Text(
      _getDescription(),
      style: AppTypography.bodyMedium.copyWith(
        color: AppColors.mutedForeground,
      ),
      textAlign: TextAlign.center,
      maxLines: 2,
    );
  }

  /// 构建操作按钮
  Widget _buildAction() {
    return TextButton.icon(
      onPressed: () {
        // TODO: 导航到发现页面或推荐页面
        debugPrint('去看看');
      },
      icon: Icon(
        Icons.explore_outlined,
        size: 20,
        color: AppColors.indigo500,
      ),
      label: Text(
        '去看看',
        style: AppTypography.labelMedium.copyWith(
          color: AppColors.indigo500,
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 辅助方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 获取空状态图标
  IconData _getEmptyIcon() {
    switch (type) {
      case model.NotificationType.interview:
        return Icons.event_busy_outlined;
      case model.NotificationType.jobStatus:
        return Icons.work_off_outlined;
      case model.NotificationType.columnUpdate:
        return Icons.article_outlined;
      case model.NotificationType.vipExpire:
        return Icons.star_border_outlined;
      case model.NotificationType.activity:
        return Icons.local_activity_outlined;
      case model.NotificationType.system:
        return Icons.notifications_none_outlined;
      case null:
        return Icons.notifications_none_outlined;
    }
  }

  /// 获取标题文本
  String _getTitle() {
    switch (type) {
      case model.NotificationType.interview:
        return '暂无面试通知';
      case model.NotificationType.jobStatus:
        return '暂无求职通知';
      case model.NotificationType.columnUpdate:
        return '暂无专栏更新';
      case model.NotificationType.vipExpire:
        return '暂无VIP提醒';
      case model.NotificationType.activity:
        return '暂无活动通知';
      case model.NotificationType.system:
        return '暂无系统公告';
      case null:
        return '暂无通知';
    }
  }

  /// 获取描述文本
  String _getDescription() {
    switch (type) {
      case model.NotificationType.interview:
        return '还没有收到面试邀请\n继续加油投递简历吧';
      case model.NotificationType.jobStatus:
        return '还没有投递状态更新\n去查看更多职位机会';
      case model.NotificationType.columnUpdate:
        return '关注的专栏暂无更新\n去发现更多优质内容';
      case model.NotificationType.vipExpire:
        return 'VIP会员状态良好\n享受专属权益中';
      case model.NotificationType.activity:
        return '暂无活动通知\n敬请期待精彩活动';
      case model.NotificationType.system:
        return '暂无系统公告\n系统运行正常';
      case null:
        return '这里空空如也\n有新消息时会第一时间通知您';
    }
  }
}
