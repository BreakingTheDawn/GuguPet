import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/widgets/widgets.dart';

/// 菜单项数据模型
class MenuItem {
  /// 图标
  final IconData icon;

  /// 标题
  final String title;

  /// 副标题（可选）
  final String? subtitle;

  /// 徽章数量（可选）
  final int? badgeCount;

  /// 点击回调
  final VoidCallback? onTap;

  const MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.badgeCount,
    this.onTap,
  });
}

/// 功能菜单列表组件
/// 显示个人中心的功能入口列表
class MenuList extends StatelessWidget {
  /// 菜单项列表
  final List<MenuItem> items;

  const MenuList({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _MenuItemTile(item: items[i]),
            // 除最后一项外，添加分隔线
            if (i < items.length - 1)
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.xl + AppSpacing.md + AppSpacing.md),
                child: Divider(
                  height: 1,
                  thickness: 0.5,
                  color: AppColors.divider,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// 菜单项组件
class _MenuItemTile extends StatelessWidget {
  final MenuItem item;

  const _MenuItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
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
                color: AppColors.indigo500.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Icon(
                item.icon,
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
                    item.title,
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  if (item.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle!,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // 徽章（如果有）
            if (item.badgeCount != null && item.badgeCount! > 0) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.destructive,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                constraints: const BoxConstraints(minWidth: 20),
                child: Text(
                  item.badgeCount! > 99 ? '99+' : '${item.badgeCount}',
                  style: AppTypography.labelSmall.copyWith(
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
            // 箭头图标（始终显示）
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
}
