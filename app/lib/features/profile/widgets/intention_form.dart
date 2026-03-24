import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/widgets/widgets.dart';
import 'city_selector.dart';
import 'salary_selector.dart';

/// 求职意向表单数据模型
class JobIntentionFormData {
  /// 期望职位
  final String? jobIntention;
  
  /// 期望城市列表
  final List<String> cities;
  
  /// 期望薪资
  final String? salaryExpect;
  
  /// 行业偏好标签
  final String? industryTag;

  const JobIntentionFormData({
    this.jobIntention,
    this.cities = const [],
    this.salaryExpect,
    this.industryTag,
  });

  /// 复制并修改
  JobIntentionFormData copyWith({
    String? jobIntention,
    List<String>? cities,
    String? salaryExpect,
    String? industryTag,
  }) {
    return JobIntentionFormData(
      jobIntention: jobIntention ?? this.jobIntention,
      cities: cities ?? this.cities,
      salaryExpect: salaryExpect ?? this.salaryExpect,
      industryTag: industryTag ?? this.industryTag,
    );
  }
}

/// 求职意向表单组件
/// 包含期望职位、城市、薪资、行业偏好的输入和选择
class IntentionForm extends StatefulWidget {
  /// 初始表单数据
  final JobIntentionFormData initialData;
  
  /// 表单数据变化回调
  final ValueChanged<JobIntentionFormData>? onChanged;

  const IntentionForm({
    super.key,
    this.initialData = const JobIntentionFormData(),
    this.onChanged,
  });

  @override
  State<IntentionForm> createState() => IntentionFormState();
}

/// 求职意向表单状态类
/// 公开此类以便外部可以访问验证方法
class IntentionFormState extends State<IntentionForm> {
  /// 期望职位控制器
  late TextEditingController _jobIntentionController;
  
  /// 选中的城市列表
  late List<String> _selectedCities;
  
  /// 选中的薪资范围
  String? _selectedSalary;
  
  /// 行业偏好控制器
  late TextEditingController _industryTagController;

  @override
  void initState() {
    super.initState();
    _jobIntentionController = TextEditingController(
      text: widget.initialData.jobIntention,
    );
    _selectedCities = List.from(widget.initialData.cities);
    _selectedSalary = widget.initialData.salaryExpect;
    _industryTagController = TextEditingController(
      text: widget.initialData.industryTag,
    );
  }

  @override
  void dispose() {
    _jobIntentionController.dispose();
    _industryTagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 期望职位输入
        _buildJobIntentionField(),
        
        const SizedBox(height: AppSpacing.lg),
        
        // 期望城市选择
        _buildCityField(),
        
        const SizedBox(height: AppSpacing.lg),
        
        // 期望薪资选择
        _buildSalaryField(),
        
        const SizedBox(height: AppSpacing.lg),
        
        // 行业偏好输入
        _buildIndustryField(),
      ],
    );
  }

  /// 构建期望职位输入框
  Widget _buildJobIntentionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标签
        _buildFieldLabel(
          '期望职位',
          icon: Icons.work_outline,
          required: true,
        ),
        const SizedBox(height: AppSpacing.sm),
        
        // 输入框
        GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: TextField(
            controller: _jobIntentionController,
            onChanged: (value) => _notifyChange(),
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.primary,
            ),
            decoration: InputDecoration(
              hintText: '请输入期望职位，如：产品经理',
              hintStyle: AppTypography.bodyMedium.copyWith(
                color: AppColors.mutedForeground,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: AppSpacing.md,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建期望城市选择框
  Widget _buildCityField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标签
        _buildFieldLabel(
          '期望城市',
          icon: Icons.location_city,
          required: true,
        ),
        const SizedBox(height: AppSpacing.sm),
        
        // 选择框
        GestureDetector(
          onTap: () => _showCitySelector(),
          child: GlassContainer(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedCities.isEmpty
                        ? '请选择期望城市（最多3个）'
                        : _selectedCities.join('、'),
                    style: AppTypography.bodyLarge.copyWith(
                      color: _selectedCities.isEmpty
                          ? AppColors.mutedForeground
                          : AppColors.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: AppSpacing.iconMd,
                  color: AppColors.mutedForeground,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 构建期望薪资选择框
  Widget _buildSalaryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标签
        _buildFieldLabel(
          '期望薪资',
          icon: Icons.attach_money,
          required: true,
        ),
        const SizedBox(height: AppSpacing.sm),
        
        // 选择框
        GestureDetector(
          onTap: () => _showSalarySelector(),
          child: GlassContainer(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedSalary ?? '请选择期望薪资范围',
                    style: AppTypography.bodyLarge.copyWith(
                      color: _selectedSalary == null
                          ? AppColors.mutedForeground
                          : AppColors.primary,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: AppSpacing.iconMd,
                  color: AppColors.mutedForeground,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 构建行业偏好输入框
  Widget _buildIndustryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标签
        _buildFieldLabel(
          '行业偏好',
          icon: Icons.business_outlined,
          required: false,
        ),
        const SizedBox(height: AppSpacing.sm),
        
        // 输入框
        GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: TextField(
            controller: _industryTagController,
            onChanged: (value) => _notifyChange(),
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.primary,
            ),
            decoration: InputDecoration(
              hintText: '请输入行业偏好，如：互联网、金融科技',
              hintStyle: AppTypography.bodyMedium.copyWith(
                color: AppColors.mutedForeground,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: AppSpacing.md,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建字段标签
  Widget _buildFieldLabel(
    String label, {
    required IconData icon,
    bool required = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: AppSpacing.iconSm,
          color: AppColors.indigo500,
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.primary,
          ),
        ),
        if (required) ...[
          const SizedBox(width: AppSpacing.xs),
          Text(
            '*',
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.destructive,
            ),
          ),
        ],
      ],
    );
  }

  /// 显示城市选择器
  Future<void> _showCitySelector() async {
    await CitySelectorBottomSheet.show(
      context,
      selectedCities: _selectedCities,
      maxSelection: 3,
      onConfirmed: (cities) {
        setState(() {
          _selectedCities = cities;
        });
        _notifyChange();
      },
    );
  }

  /// 显示薪资选择器
  Future<void> _showSalarySelector() async {
    await SalarySelectorBottomSheet.show(
      context,
      selectedSalary: _selectedSalary,
      onSelected: (salary) {
        setState(() {
          _selectedSalary = salary;
        });
        _notifyChange();
      },
    );
  }

  /// 通知表单数据变化
  void _notifyChange() {
    widget.onChanged?.call(JobIntentionFormData(
      jobIntention: _jobIntentionController.text.trim().isEmpty
          ? null
          : _jobIntentionController.text.trim(),
      cities: _selectedCities,
      salaryExpect: _selectedSalary,
      industryTag: _industryTagController.text.trim().isEmpty
          ? null
          : _industryTagController.text.trim(),
    ));
  }

  /// 获取当前表单数据
  JobIntentionFormData get formData => JobIntentionFormData(
    jobIntention: _jobIntentionController.text.trim().isEmpty
        ? null
        : _jobIntentionController.text.trim(),
    cities: _selectedCities,
    salaryExpect: _selectedSalary,
    industryTag: _industryTagController.text.trim().isEmpty
        ? null
        : _industryTagController.text.trim(),
  );

  /// 验证表单
  /// 返回错误信息，如果验证通过则返回 null
  String? validate() {
    if (_jobIntentionController.text.trim().isEmpty) {
      return '请输入期望职位';
    }
    if (_selectedCities.isEmpty) {
      return '请选择期望城市';
    }
    if (_selectedSalary == null) {
      return '请选择期望薪资';
    }
    return null;
  }
}
