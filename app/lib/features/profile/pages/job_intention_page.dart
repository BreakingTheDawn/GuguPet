import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../core/di/repository_provider.dart';
import '../widgets/intention_form.dart';

/// 求职意向设置页面
/// 允许用户设置和修改求职意向信息
class JobIntentionPage extends StatefulWidget {
  const JobIntentionPage({super.key});

  @override
  State<JobIntentionPage> createState() => _JobIntentionPageState();
}

class _JobIntentionPageState extends State<JobIntentionPage> {
  /// 用户仓库
  final UserRepository _userRepository = repositoryProvider.userRepository;
  
  /// 表单全局键
  final GlobalKey<_IntentionFormWrapperState> _formKey = GlobalKey<_IntentionFormWrapperState>();
  
  /// 用户档案
  UserProfile? _userProfile;
  
  /// 是否正在加载
  bool _isLoading = true;
  
  /// 是否正在保存
  bool _isSaving = false;
  
  /// 错误信息
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// 加载用户数据
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final profile = await _userRepository.getUser('default_user');
      setState(() {
        _userProfile = profile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '加载用户数据失败: $e';
      });
      debugPrint('JobIntentionPage Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  /// 构建AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
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
        '求职意向',
        style: AppTypography.headingSmall.copyWith(
          color: AppColors.primary,
        ),
      ),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: AppColors.divider,
        ),
      ),
    );
  }

  /// 构建主体内容
  Widget _buildBody() {
    // 显示加载状态
    if (_isLoading) {
      return _buildLoadingState();
    }

    // 显示错误状态
    if (_errorMessage != null && _userProfile == null) {
      return _buildErrorState();
    }

    // 显示表单内容
    return _buildFormContent();
  }

  /// 构建加载状态
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.indigo500),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '加载中...',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建错误状态
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.mutedForeground,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _errorMessage ?? '加载失败',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.mutedForeground,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton(
            onPressed: _loadUserData,
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

  /// 构建表单内容
  Widget _buildFormContent() {
    return Column(
      children: [
        // 表单区域
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: _IntentionFormWrapper(
              key: _formKey,
              initialData: JobIntentionFormData(
                jobIntention: _userProfile?.jobIntention,
                cities: _userProfile?.city?.split('、') ?? [],
                salaryExpect: _userProfile?.salaryExpect,
                industryTag: _userProfile?.industryTag,
              ),
            ),
          ),
        ),
        
        // 底部保存按钮
        _buildSaveButton(),
      ],
    );
  }

  /// 构建保存按钮
  Widget _buildSaveButton() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: AppSpacing.buttonHeightLg,
        child: ElevatedButton(
          onPressed: _isSaving ? null : _handleSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.indigo500,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.muted,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            elevation: 0,
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  '保存修改',
                  style: AppTypography.labelLarge.copyWith(
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  /// 处理保存操作
  Future<void> _handleSave() async {
    // 验证表单
    final error = _formKey.currentState?.validate();
    if (error != null) {
      _showSnackBar(error, isError: true);
      return;
    }

    // 获取表单数据
    final formData = _formKey.currentState?.formData;
    if (formData == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // 构建更新后的用户档案
      final updatedProfile = UserProfile(
        userId: _userProfile?.userId ?? 'default_user',
        userName: _userProfile?.userName ?? '求职者',
        jobIntention: formData.jobIntention,
        city: formData.cities.isEmpty ? null : formData.cities.join('、'),
        salaryExpect: formData.salaryExpect,
        industryTag: formData.industryTag,
        petMemory: _userProfile?.petMemory ?? [],
        vipStatus: _userProfile?.vipStatus ?? false,
        vipExpireTime: _userProfile?.vipExpireTime,
        isOnboarded: _userProfile?.isOnboarded ?? false,
        onboardingReport: _userProfile?.onboardingReport,
      );

      // 保存到仓库
      await _userRepository.updateUser(updatedProfile);

      setState(() {
        _userProfile = updatedProfile;
        _isSaving = false;
      });

      // 显示成功提示
      _showSnackBar('保存成功', isError: false);

      // 延迟返回上一页
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.pop(context, true);
        }
      });
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      
      _showSnackBar('保存失败: $e', isError: true);
      debugPrint('Save Error: $e');
    }
  }

  /// 显示提示信息
  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.destructive : AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// 表单包装器组件
/// 用于暴露表单的验证和获取数据方法
class _IntentionFormWrapper extends StatefulWidget {
  /// 初始表单数据
  final JobIntentionFormData initialData;

  const _IntentionFormWrapper({
    super.key,
    required this.initialData,
  });

  @override
  State<_IntentionFormWrapper> createState() => _IntentionFormWrapperState();
}

class _IntentionFormWrapperState extends State<_IntentionFormWrapper> {
  /// 表单数据
  late JobIntentionFormData _formData;
  
  /// 内部表单的键，用于访问表单状态
  final GlobalKey<IntentionFormState> _formKey = GlobalKey<IntentionFormState>();

  @override
  void initState() {
    super.initState();
    _formData = widget.initialData;
  }

  @override
  Widget build(BuildContext context) {
    return IntentionForm(
      key: _formKey,
      initialData: widget.initialData,
      onChanged: (data) {
        _formData = data;
      },
    );
  }

  /// 验证表单
  /// 直接调用内部表单的验证方法，避免重复逻辑
  String? validate() {
    return _formKey.currentState?.validate();
  }

  /// 获取表单数据
  JobIntentionFormData get formData => _formData;
}
