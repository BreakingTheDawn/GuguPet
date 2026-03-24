import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

/// 薪资选择器组件
/// 提供预设薪资范围选项和自定义输入功能
class SalarySelector extends StatelessWidget {
  /// 当前选中的薪资范围
  final String? selectedSalary;
  
  /// 选择回调
  final ValueChanged<String> onSelected;

  const SalarySelector({
    super.key,
    this.selectedSalary,
    required this.onSelected,
  });

  /// 预设薪资范围选项
  static const List<String> salaryOptions = [
    '5k以下',
    '5k-10k',
    '10k-15k',
    '15k-20k',
    '20k-30k',
    '30k-50k',
    '50k以上',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题栏
          _buildHeader(context),
          
          // 薪资选项列表
          _buildOptionsList(),
        ],
      ),
    );
  }

  /// 构建标题栏
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.divider,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.attach_money,
            size: AppSpacing.iconMd,
            color: AppColors.indigo500,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '选择期望薪资',
            style: AppTypography.headingSmall.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建薪资选项列表
  Widget _buildOptionsList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      itemCount: salaryOptions.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        thickness: 0.5,
        color: AppColors.divider,
        indent: AppSpacing.md,
        endIndent: AppSpacing.md,
      ),
      itemBuilder: (context, index) {
        final option = salaryOptions[index];
        final isSelected = option == selectedSalary;
        
        return _buildOptionTile(option, isSelected);
      },
    );
  }

  /// 构建单个选项
  Widget _buildOptionTile(String option, bool isSelected) {
    return InkWell(
      onTap: () => onSelected(option),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            // 选中图标
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.indigo500 : AppColors.mutedForeground,
                  width: 2,
                ),
                color: isSelected ? AppColors.indigo500 : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacing.md),
            // 薪资文本
            Text(
              option,
              style: AppTypography.bodyLarge.copyWith(
                color: isSelected ? AppColors.indigo500 : AppColors.primary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 薪资选择器底部弹窗
/// 用于在底部弹出薪资选择器
class SalarySelectorBottomSheet extends StatelessWidget {
  /// 当前选中的薪资范围
  final String? selectedSalary;
  
  /// 选择回调
  final ValueChanged<String> onSelected;

  const SalarySelectorBottomSheet({
    super.key,
    this.selectedSalary,
    required this.onSelected,
  });

  /// 显示薪资选择器底部弹窗
  static Future<void> show(
    BuildContext context, {
    String? selectedSalary,
    required ValueChanged<String> onSelected,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SalarySelectorBottomSheet(
        selectedSalary: selectedSalary,
        onSelected: onSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.radiusLg),
          topRight: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 顶部拖动条
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.sm),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.muted,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
          ),
          
          // 薪资选择器
          SalarySelector(
            selectedSalary: selectedSalary,
            onSelected: (value) {
              onSelected(value);
              Navigator.pop(context);
            },
          ),
          
          // 底部安全区域
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
