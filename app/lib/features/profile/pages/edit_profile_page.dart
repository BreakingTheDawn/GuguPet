import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme.dart';
import '../providers/profile_provider.dart';

/// 编辑个人资料页面
/// 允许用户修改用户名、求职意向、期望城市、期望薪资等信息
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // 表单控制器
  final _formKey = GlobalKey<FormState>();
  final _userNameController = TextEditingController();
  final _jobIntentionController = TextEditingController();
  final _cityController = TextEditingController();
  final _salaryExpectController = TextEditingController();
  
  // 是否正在保存
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // 初始化表单数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  /// 加载用户数据到表单
  void _loadUserData() {
    final provider = context.read<ProfileProvider>();
    final profile = provider.userProfile;
    
    if (profile != null) {
      _userNameController.text = profile.userName;
      _jobIntentionController.text = profile.jobIntention ?? '';
      _cityController.text = profile.city ?? '';
      _salaryExpectController.text = profile.salaryExpect ?? '';
    }
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _jobIntentionController.dispose();
    _cityController.dispose();
    _salaryExpectController.dispose();
    super.dispose();
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
      title: Text(
        '编辑个人资料',
        style: AppTypography.headingSmall.copyWith(
          color: AppColors.primary,
        ),
      ),
      backgroundColor: const Color(0xFFF8F7FC),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        // 保存按钮
        TextButton(
          onPressed: _isSaving ? null : _handleSave,
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.indigo500),
                  ),
                )
              : Text(
                  '保存',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.indigo500,
                  ),
                ),
        ),
      ],
    );
  }

  /// 构建页面主体
  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头像区域
            _buildAvatarSection(),
            const SizedBox(height: 32),
            
            // 基本信息
            _buildSectionTitle('基本信息'),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _userNameController,
              label: '用户名',
              hint: '请输入用户名',
              icon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入用户名';
                }
                if (value.trim().length > 20) {
                  return '用户名不能超过20个字符';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            
            // 求职意向
            _buildSectionTitle('求职意向'),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _jobIntentionController,
              label: '求职意向',
              hint: '如：产品经理、前端开发',
              icon: Icons.work_outline,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _cityController,
              label: '期望城市',
              hint: '如：北京、上海、深圳',
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _salaryExpectController,
              label: '期望薪资',
              hint: '如：15k-20k',
              icon: Icons.attach_money,
            ),
            const SizedBox(height: 40),
            
            // 提示信息
            _buildTipCard(),
          ],
        ),
      ),
    );
  }

  /// 构建头像区域
  Widget _buildAvatarSection() {
    return Center(
      child: Stack(
        children: [
          // 头像
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.indigo500.withValues(alpha: 0.1),
              border: Border.all(
                color: AppColors.indigo500.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                _userNameController.text.isNotEmpty
                    ? _userNameController.text[0].toUpperCase()
                    : 'U',
                style: AppTypography.headingLarge.copyWith(
                  color: AppColors.indigo500,
                ),
              ),
            ),
          ),
          // 编辑按钮
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.indigo500,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.camera_alt_outlined,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建章节标题
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.labelMedium.copyWith(
        color: const Color(0xFF3A3A5A),
      ),
    );
  }

  /// 构建文本输入框
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppShadows.input,
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.mutedForeground,
          ),
          hintText: hint,
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: const Color(0xFFC0C0D0),
          ),
          prefixIcon: Icon(icon, color: AppColors.mutedForeground, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  /// 构建提示卡片
  Widget _buildTipCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.indigo500.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: AppColors.indigo500.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.indigo500,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '完善个人资料可以帮助我们为您推荐更合适的职位',
              style: AppTypography.caption.copyWith(
                color: AppColors.indigo500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 处理保存
  Future<void> _handleSave() async {
    // 验证表单
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final provider = context.read<ProfileProvider>();
      final success = await provider.updateUserProfile(
        userName: _userNameController.text.trim(),
        jobIntention: _jobIntentionController.text.trim(),
        city: _cityController.text.trim(),
        salaryExpect: _salaryExpectController.text.trim(),
      );

      setState(() => _isSaving = false);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('保存成功'),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop(true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('保存失败，请重试'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存失败: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
