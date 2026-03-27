import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../core/di/repository_provider.dart';
import '../../../data/models/user_profile.dart';
import '../../pet/providers/pet_provider.dart';

/// VIP套餐类型枚举
enum VipPackageType {
  /// 月度会员
  monthly,
  /// 季度会员
  quarterly,
  /// 年度会员
  yearly,
}

/// VIP套餐数据模型
class VipPackage {
  /// 套餐类型
  final VipPackageType type;

  /// 套餐名称
  final String name;

  /// 价格
  final double price;

  /// 原价（用于显示划线价）
  final double? originalPrice;

  /// 单位描述
  final String unit;

  /// 标签文字（如"推荐"、"最划算"）
  final String? tag;

  /// 标签颜色
  final Color? tagColor;

  const VipPackage({
    required this.type,
    required this.name,
    required this.price,
    this.originalPrice,
    required this.unit,
    this.tag,
    this.tagColor,
  });
}

/// VIP特权数据模型
class VipPrivilege {
  /// 特权图标
  final IconData icon;

  /// 特权名称
  final String title;

  /// 特权描述
  final String description;

  const VipPrivilege({
    required this.icon,
    required this.title,
    required this.description,
  });
}

/// VIP升级页面
/// 展示VIP特权、套餐选择和支付功能
class VipUpgradePage extends StatefulWidget {
  /// 当前是否为VIP用户
  final bool isVip;

  /// VIP过期时间
  final DateTime? vipExpireTime;

  const VipUpgradePage({
    super.key,
    this.isVip = false,
    this.vipExpireTime,
  });

  @override
  State<VipUpgradePage> createState() => _VipUpgradePageState();
}

class _VipUpgradePageState extends State<VipUpgradePage> {
  /// 当前选中的套餐
  VipPackageType _selectedPackage = VipPackageType.quarterly;

  /// VIP套餐列表
  final List<VipPackage> _packages = const [
    VipPackage(
      type: VipPackageType.monthly,
      name: '月度会员',
      price: 19.9,
      unit: '月',
    ),
    VipPackage(
      type: VipPackageType.quarterly,
      name: '季度会员',
      price: 49.9,
      originalPrice: 59.7,
      unit: '季',
      tag: '推荐',
      tagColor: AppColors.indigo500,
    ),
    VipPackage(
      type: VipPackageType.yearly,
      name: '年度会员',
      price: 149.9,
      originalPrice: 238.8,
      unit: '年',
      tag: '最划算',
      tagColor: AppColors.warning,
    ),
  ];

  /// VIP特权列表
  /// 根据项目实际功能设计，提供宠物相关的增值服务
  final List<VipPrivilege> _privileges = const [
    VipPrivilege(
      icon: Icons.menu_book_outlined,
      title: '专栏免费阅读',
      description: '免费阅读所有付费专栏内容',
    ),
    VipPrivilege(
      icon: Icons.palette_outlined,
      title: '宠物外观',
      description: '解锁专属宠物皮肤和颜色',
    ),
    VipPrivilege(
      icon: Icons.card_giftcard_outlined,
      title: '宠物配饰',
      description: '获得可爱配饰装扮你的咕咕',
    ),
    VipPrivilege(
      icon: Icons.bolt_outlined,
      title: '羁绊加速',
      description: '羁绊值获取速度提升50%',
    ),
    VipPrivilege(
      icon: Icons.timer_outlined,
      title: '互动加速',
      description: '喂食、玩耍等互动冷却缩短50%',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // 顶部VIP状态区域（如果已是VIP）
            if (widget.isVip) _buildVipStatusHeader(),

            // VIP特权展示区域
            _buildPrivilegeSection(),

            const SizedBox(height: AppSpacing.lg),

            // 套餐选择区域
            _buildPackageSection(),

            const SizedBox(height: AppSpacing.xl),

            // 底部支付区域
            _buildPaymentSection(),
          ],
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
        icon: const Icon(
          Icons.arrow_back_ios,
          color: AppColors.primary,
          size: AppSpacing.iconMd,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'VIP会员',
        style: AppTypography.headingSmall.copyWith(
          color: AppColors.primary,
        ),
      ),
      centerTitle: true,
    );
  }

  /// 构建VIP状态头部（已开通VIP的用户显示）
  Widget _buildVipStatusHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.warning.withValues(alpha: 0.15),
            AppColors.indigo500.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // VIP图标
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: const Text(
              '🔥',
              style: TextStyle(fontSize: 24),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // VIP信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'VIP会员',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Text(
                        '已激活',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _formatExpireTime(),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建VIP特权展示区域
  Widget _buildPrivilegeSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Row(
            children: [
              Icon(
                Icons.workspace_premium_outlined,
                color: AppColors.warning,
                size: AppSpacing.iconMd,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'VIP专属特权',
                style: AppTypography.headingSmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // 特权列表
          GlassContainer(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: _privileges.asMap().entries.map((entry) {
                final index = entry.key;
                final privilege = entry.value;
                return Column(
                  children: [
                    _buildPrivilegeItem(privilege),
                    if (index < _privileges.length - 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sm,
                        ),
                        child: Divider(
                          color: AppColors.divider,
                          height: 1,
                        ),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建单个特权项
  Widget _buildPrivilegeItem(VipPrivilege privilege) {
    return Row(
      children: [
        // 图标容器
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Icon(
            privilege.icon,
            color: AppColors.warning,
            size: AppSpacing.iconMd,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        // 文字内容
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                privilege.title,
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                privilege.description,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
        // VIP标识
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Text(
            'VIP',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.warning,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  /// 构建套餐选择区域
  Widget _buildPackageSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Row(
            children: [
              Icon(
                Icons.card_giftcard_outlined,
                color: AppColors.indigo500,
                size: AppSpacing.iconMd,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '选择套餐',
                style: AppTypography.headingSmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // 套餐卡片列表
          Row(
            children: _packages.map((package) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: package.type == VipPackageType.yearly
                        ? 0
                        : AppSpacing.sm,
                  ),
                  child: _buildPackageCard(package),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// 构建套餐卡片
  Widget _buildPackageCard(VipPackage package) {
    final isSelected = _selectedPackage == package.type;

    return GestureDetector(
      onTap: () => _selectPackage(package.type),
      child: GlassContainer(
        padding: EdgeInsets.zero,
        border: Border.all(
          color: isSelected ? AppColors.warning : Colors.white.withValues(alpha: 0.88),
          width: isSelected ? 2 : 1.5,
        ),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.warning.withValues(alpha: 0.1),
                      AppColors.warning.withValues(alpha: 0.05),
                    ],
                  )
                : null,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                children: [
                  // 套餐名称
                  Text(
                    package.name,
                    style: AppTypography.labelMedium.copyWith(
                      color: isSelected ? AppColors.warning : AppColors.primary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // 价格
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '¥',
                        style: AppTypography.labelMedium.copyWith(
                          color: isSelected ? AppColors.warning : AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        package.price.toStringAsFixed(1),
                        style: AppTypography.headingLarge.copyWith(
                          color: isSelected ? AppColors.warning : AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),

                  // 原价（划线价）
                  if (package.originalPrice != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '¥${package.originalPrice!.toStringAsFixed(1)}',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.mutedForeground,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.xs),

                  // 单位
                  Text(
                    '/${package.unit}',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),

              // 标签（推荐/最划算）
              if (package.tag != null)
                Positioned(
                  top: -8,
                  right: -8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: package.tagColor ?? AppColors.indigo500,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Text(
                      package.tag!,
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建底部支付区域
  Widget _buildPaymentSection() {
    final selectedPackageData = _packages.firstWhere(
      (p) => p.type == _selectedPackage,
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
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
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 服务协议
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '开通即表示同意',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
                GestureDetector(
                  onTap: _handleServiceAgreement,
                  child: Text(
                    '《VIP服务协议》',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.indigo500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // 支付按钮
            SizedBox(
              width: double.infinity,
              height: AppSpacing.buttonHeightLg,
              child: ElevatedButton(
                onPressed: _handlePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.workspace_premium,
                      size: AppSpacing.iconMd,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      widget.isVip ? '立即续费' : '立即开通',
                      style: AppTypography.labelLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '¥${selectedPackageData.price.toStringAsFixed(1)}',
                      style: AppTypography.headingSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 事件处理方法
  // ═══════════════════════════════════════════════════════════

  /// 选择套餐
  void _selectPackage(VipPackageType type) {
    setState(() {
      _selectedPackage = type;
    });
  }

  /// 处理支付
  Future<void> _handlePayment() async {
    final selectedPackageData = _packages.firstWhere(
      (p) => p.type == _selectedPackage,
    );

    // TODO: 集成支付功能
    debugPrint('支付套餐: ${selectedPackageData.name}');
    debugPrint('支付金额: ¥${selectedPackageData.price}');

    // 计算VIP过期时间
    DateTime expireTime;
    final now = DateTime.now();
    switch (selectedPackageData.type) {
      case VipPackageType.monthly:
        expireTime = now.add(const Duration(days: 30));
        break;
      case VipPackageType.quarterly:
        expireTime = now.add(const Duration(days: 90));
        break;
      case VipPackageType.yearly:
        expireTime = now.add(const Duration(days: 365));
        break;
    }

    // 更新VIP状态到数据库
    try {
      // 获取当前用户资料
      final userProfile = await repositoryProvider.userRepository.getUser('default_user');
      
      if (userProfile != null) {
        // 创建更新后的用户资料
        final updatedProfile = UserProfile(
          userId: userProfile.userId,
          userName: userProfile.userName,
          jobIntention: userProfile.jobIntention,
          city: userProfile.city,
          salaryExpect: userProfile.salaryExpect,
          petMemory: userProfile.petMemory,
          vipStatus: true,
          vipExpireTime: expireTime,
          isOnboarded: userProfile.isOnboarded,
          industryTag: userProfile.industryTag,
          onboardingReport: userProfile.onboardingReport,
        );

        // 保存到数据库
        await repositoryProvider.userRepository.updateUser(updatedProfile);

        // 同步VIP状态到PetProvider
        if (mounted) {
          try {
            final petProvider = context.read<PetProvider>();
            petProvider.updateUserProfile(updatedProfile);
          } catch (e) {
            debugPrint('同步VIP状态到PetProvider失败: $e');
          }
        }

        // 显示支付成功提示
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${selectedPackageData.name}开通成功！'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );

          // 返回上一页
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      debugPrint('VIP开通失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('开通失败: $e'),
            backgroundColor: AppColors.destructive,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// 处理服务协议点击
  void _handleServiceAgreement() {
    // TODO: 导航到VIP服务协议页面
    debugPrint('查看VIP服务协议');
  }

  /// 格式化过期时间显示
  String _formatExpireTime() {
    if (widget.vipExpireTime == null) {
      return '有效期: 未知';
    }

    final now = DateTime.now();
    final difference = widget.vipExpireTime!.difference(now).inDays;

    if (difference <= 0) {
      return 'VIP已过期';
    } else if (difference <= 7) {
      return '有效期还剩 $difference 天，请及时续费';
    } else {
      return '有效期至: ${widget.vipExpireTime!.year}-${widget.vipExpireTime!.month.toString().padLeft(2, '0')}-${widget.vipExpireTime!.day.toString().padLeft(2, '0')}';
    }
  }
}
