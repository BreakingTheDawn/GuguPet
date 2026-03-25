import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../providers/job_filter_provider.dart';

/// 职位筛选底部弹窗组件
/// 支持多维度筛选：薪资、城市、经验、学历、公司规模、融资阶段
class JobFilterBottomSheet extends StatefulWidget {
  /// 当前筛选条件Provider
  final JobFilterProvider filterProvider;

  /// 确认筛选回调
  final VoidCallback onConfirm;

  const JobFilterBottomSheet({
    super.key,
    required this.filterProvider,
    required this.onConfirm,
  });

  /// 显示筛选弹窗的静态方法
  /// [context] BuildContext
  /// [filterProvider] 筛选状态Provider
  /// [onConfirm] 确认回调
  static Future<void> show({
    required BuildContext context,
    required JobFilterProvider filterProvider,
    required VoidCallback onConfirm,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => JobFilterBottomSheet(
        filterProvider: filterProvider,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  State<JobFilterBottomSheet> createState() => _JobFilterBottomSheetState();
}

class _JobFilterBottomSheetState extends State<JobFilterBottomSheet> {
  /// 临时筛选Provider，用于在确认前暂存选择
  late final JobFilterProvider _tempFilter;

  @override
  void initState() {
    super.initState();
    // 创建临时Provider并复制当前筛选条件
    _tempFilter = JobFilterProvider();
    _tempFilter.copyFrom(widget.filterProvider);
  }

  @override
  void dispose() {
    _tempFilter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // 顶部拖动指示器和标题
              _buildHeader(),
              // 筛选内容区域
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildSectionTitle('薪资范围'),
                    _buildSalaryOptions(),
                    const SizedBox(height: 20),
                    _buildSectionTitle('工作城市'),
                    _buildCityOptions(),
                    const SizedBox(height: 20),
                    _buildSectionTitle('工作经验'),
                    _buildExperienceOptions(),
                    const SizedBox(height: 20),
                    _buildSectionTitle('学历要求'),
                    _buildEducationOptions(),
                    const SizedBox(height: 20),
                    _buildSectionTitle('公司规模'),
                    _buildCompanySizeOptions(),
                    const SizedBox(height: 20),
                    _buildSectionTitle('融资阶段'),
                    _buildFundingStageOptions(),
                    const SizedBox(height: 100), // 底部留白
                  ],
                ),
              ),
              // 底部操作按钮
              _buildBottomButtons(),
            ],
          ),
        );
      },
    );
  }

  /// 构建顶部标题区域
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: AppColors.divider,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // 拖动指示器
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 标题行
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '高级筛选',
                style: AppTypography.headingSmall.copyWith(
                  color: const Color(0xFF3A3A5A),
                ),
              ),
              // 重置按钮
              TextButton(
                onPressed: _handleReset,
                child: Text(
                  '重置',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建筛选区域标题
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: AppTypography.labelMedium.copyWith(
          color: const Color(0xFF3A3A5A),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// 构建薪资范围选项(多选)
  Widget _buildSalaryOptions() {
    return _buildMultiSelectOptions(
      options: widget.filterProvider.salaryOptions,
      selectedOptions: _tempFilter.selectedSalaries,
      onToggle: (option) {
        setState(() {
          _tempFilter.toggleSalary(option);
        });
      },
    );
  }

  /// 构建工作城市选项(多选)
  Widget _buildCityOptions() {
    return _buildMultiSelectOptions(
      options: widget.filterProvider.cityOptions,
      selectedOptions: _tempFilter.selectedCities,
      onToggle: (option) {
        setState(() {
          _tempFilter.toggleCity(option);
        });
      },
    );
  }

  /// 构建工作经验选项(单选)
  Widget _buildExperienceOptions() {
    return _buildSingleSelectOptions(
      options: widget.filterProvider.experienceOptions,
      selectedOption: _tempFilter.selectedExperience,
      onSelect: (option) {
        setState(() {
          _tempFilter.setExperience(option);
        });
      },
    );
  }

  /// 构建学历要求选项(单选)
  Widget _buildEducationOptions() {
    return _buildSingleSelectOptions(
      options: widget.filterProvider.educationOptions,
      selectedOption: _tempFilter.selectedEducation,
      onSelect: (option) {
        setState(() {
          _tempFilter.setEducation(option);
        });
      },
    );
  }

  /// 构建公司规模选项(单选)
  Widget _buildCompanySizeOptions() {
    return _buildSingleSelectOptions(
      options: widget.filterProvider.companySizeOptions,
      selectedOption: _tempFilter.selectedCompanySize,
      onSelect: (option) {
        setState(() {
          _tempFilter.setCompanySize(option);
        });
      },
    );
  }

  /// 构建融资阶段选项(单选)
  Widget _buildFundingStageOptions() {
    return _buildSingleSelectOptions(
      options: widget.filterProvider.fundingStageOptions,
      selectedOption: _tempFilter.selectedFundingStage,
      onSelect: (option) {
        setState(() {
          _tempFilter.setFundingStage(option);
        });
      },
    );
  }

  /// 构建多选选项组件
  /// [options] 选项列表
  /// [selectedOptions] 已选中选项集合
  /// [onToggle] 切换选中状态回调
  Widget _buildMultiSelectOptions({
    required List<String> options,
    required Set<String> selectedOptions,
    required void Function(String) onToggle,
  }) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((option) {
        final isSelected = selectedOptions.contains(option);
        return GestureDetector(
          onTap: () => onToggle(option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.indigo500 : Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(
                color: isSelected ? AppColors.indigo500 : AppColors.border,
                width: 1,
              ),
              boxShadow: isSelected ? AppShadows.button : null,
            ),
            child: Text(
              option,
              style: AppTypography.labelSmall.copyWith(
                color: isSelected ? Colors.white : const Color(0xFF5A5A7A),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 构建单选选项组件
  /// [options] 选项列表
  /// [selectedOption] 已选中选项
  /// [onSelect] 选择回调
  Widget _buildSingleSelectOptions({
    required List<String> options,
    required String? selectedOption,
    required void Function(String) onSelect,
  }) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((option) {
        final isSelected = selectedOption == option;
        return GestureDetector(
          onTap: () => onSelect(option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.indigo500 : Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(
                color: isSelected ? AppColors.indigo500 : AppColors.border,
                width: 1,
              ),
              boxShadow: isSelected ? AppShadows.button : null,
            ),
            child: Text(
              option,
              style: AppTypography.labelSmall.copyWith(
                color: isSelected ? Colors.white : const Color(0xFF5A5A7A),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 构建底部操作按钮
  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.divider,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 重置按钮
          Expanded(
            child: OutlinedButton(
              onPressed: _handleReset,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.mutedForeground,
                side: BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
              ),
              child: const Text('重置'),
            ),
          ),
          const SizedBox(width: 12),
          // 确定按钮
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _handleConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.indigo500,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
              ),
              child: Text(
                '确定${_tempFilter.filterCount > 0 ? ' (${_tempFilter.filterCount})' : ''}',
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 处理重置操作
  void _handleReset() {
    setState(() {
      _tempFilter.resetAll();
    });
  }

  /// 处理确认操作
  void _handleConfirm() {
    // 将临时筛选条件复制到实际Provider
    widget.filterProvider.copyFrom(_tempFilter);
    // 调用确认回调
    widget.onConfirm();
    // 关闭弹窗
    Navigator.pop(context);
  }
}
