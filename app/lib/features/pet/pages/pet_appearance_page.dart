import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../data/models/pet_model.dart';
import '../data/models/pet_appearance.dart';
import '../services/pet_appearance_service.dart';

/// 宠物外观选择页面
/// 允许用户选择宠物皮肤和配饰
class PetAppearancePage extends StatefulWidget {
  /// 当前宠物数据
  final PetModel pet;

  /// 是否为VIP用户
  final bool isVip;

  /// 外观变更回调
  final Function(PetModel updatedPet)? onAppearanceChanged;

  /// 开通VIP回调
  final VoidCallback? onOpenVip;

  const PetAppearancePage({
    super.key,
    required this.pet,
    required this.isVip,
    this.onAppearanceChanged,
    this.onOpenVip,
  });

  @override
  State<PetAppearancePage> createState() => _PetAppearancePageState();
}

class _PetAppearancePageState extends State<PetAppearancePage>
    with SingleTickerProviderStateMixin {
  /// 外观服务
  final PetAppearanceService _appearanceService = PetAppearanceService();

  /// Tab控制器
  late TabController _tabController;

  /// 当前选中的皮肤ID
  late String _selectedSkinId;

  /// 当前选中的配饰ID
  late String _selectedAccessoryId;

  /// 是否正在保存
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedSkinId = widget.pet.skinId;
    _selectedAccessoryId = widget.pet.accessoryId;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // 宠物预览区域
          _buildPetPreview(),

          // Tab栏
          _buildTabBar(),

          // Tab内容
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSkinGrid(),
                _buildAccessoryGrid(),
              ],
            ),
          ),

          // 底部保存按钮
          _buildSaveButton(),
        ],
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
        '宠物外观',
        style: AppTypography.headingSmall.copyWith(
          color: AppColors.primary,
        ),
      ),
      centerTitle: true,
      actions: [
        // VIP标识
        if (widget.isVip)
          Container(
            margin: const EdgeInsets.only(right: AppSpacing.md),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.warning.withValues(alpha: 0.2),
                  AppColors.warning.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.workspace_premium,
                  size: AppSpacing.iconSm,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 4),
                Text(
                  'VIP',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// 构建宠物预览区域
  Widget _buildPetPreview() {
    final skin = PetAppearanceConfig.getSkinById(_selectedSkinId);
    final accessory = PetAppearanceConfig.getAccessoryById(_selectedAccessoryId);

    return Container(
      height: 200,
      margin: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (skin?.primaryColor ?? AppColors.muted).withValues(alpha: 0.1),
            (skin?.secondaryColor ?? AppColors.secondary).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 宠物主体
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 配饰（头部位置）
              if (accessory != null && accessory.position == 'head')
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    accessory.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),

              // 宠物图标
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      skin?.primaryColor ?? AppColors.muted,
                      skin?.secondaryColor ?? AppColors.secondary,
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (skin?.primaryColor ?? AppColors.muted).withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '🐦',
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
              ),

              // 配饰（颈部位置）
              if (accessory != null && accessory.position == 'neck')
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    accessory.icon,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),

              // 宠物名称
              const SizedBox(height: AppSpacing.sm),
              Text(
                widget.pet.name,
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.primary,
                ),
              ),
              Text(
                skin?.name ?? '经典咕咕',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.mutedForeground,
                ),
              ),
            ],
          ),

          // 配饰（背部位置）- 显示在宠物后面
          if (accessory != null && accessory.position == 'back')
            Positioned(
              child: Transform.translate(
                offset: const Offset(-60, 0),
                child: Text(
                  accessory.icon,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 构建Tab栏
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.muted.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.mutedForeground,
        labelStyle: AppTypography.labelMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(text: '皮肤'),
          Tab(text: '配饰'),
        ],
      ),
    );
  }

  /// 构建皮肤选择网格
  Widget _buildSkinGrid() {
    final skins = _appearanceService.getAvailableSkins(widget.isVip);

    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.85,
      ),
      itemCount: skins.length,
      itemBuilder: (context, index) {
        final skin = skins[index];
        final isSelected = _selectedSkinId == skin.id;
        final isLocked = skin.isVipOnly && !widget.isVip;

        return _buildSkinCard(skin, isSelected, isLocked);
      },
    );
  }

  /// 构建皮肤卡片
  Widget _buildSkinCard(PetSkin skin, bool isSelected, bool isLocked) {
    return GestureDetector(
      onTap: isLocked
          ? () => _showVipLockDialog()
          : () => _selectSkin(skin.id),
      child: GlassContainer(
        padding: EdgeInsets.zero,
        border: Border.all(
          color: isSelected ? AppColors.indigo500 : Colors.white.withValues(alpha: 0.88),
          width: isSelected ? 2 : 1,
        ),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.indigo500.withValues(alpha: 0.1),
                      AppColors.indigo500.withValues(alpha: 0.05),
                    ],
                  )
                : null,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          ),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 皮肤预览
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          skin.primaryColor,
                          skin.secondaryColor,
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: skin.primaryColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: isLocked
                        ? Icon(
                            Icons.lock,
                            color: Colors.white.withValues(alpha: 0.8),
                            size: AppSpacing.iconSm,
                          )
                        : Center(
                            child: Text(
                              '🐦',
                              style: TextStyle(
                                fontSize: 24,
                                color: _getContrastColor(skin.primaryColor),
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // 皮肤名称
                  Text(
                    skin.name,
                    style: AppTypography.labelSmall.copyWith(
                      color: isSelected ? AppColors.indigo500 : AppColors.primary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),

              // VIP标识
              if (skin.isVipOnly)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'VIP',
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white,
                        fontSize: 8,
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

  /// 构建配饰选择网格
  Widget _buildAccessoryGrid() {
    final accessories = _appearanceService.getAvailableAccessories(widget.isVip);

    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.85,
      ),
      itemCount: accessories.length,
      itemBuilder: (context, index) {
        final accessory = accessories[index];
        final isSelected = _selectedAccessoryId == accessory.id;
        final isLocked = accessory.isVipOnly && !widget.isVip;

        return _buildAccessoryCard(accessory, isSelected, isLocked);
      },
    );
  }

  /// 构建配饰卡片
  Widget _buildAccessoryCard(PetAccessory accessory, bool isSelected, bool isLocked) {
    return GestureDetector(
      onTap: isLocked
          ? () => _showVipLockDialog()
          : () => _selectAccessory(accessory.id),
      child: GlassContainer(
        padding: EdgeInsets.zero,
        border: Border.all(
          color: isSelected ? AppColors.indigo500 : Colors.white.withValues(alpha: 0.88),
          width: isSelected ? 2 : 1,
        ),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.indigo500.withValues(alpha: 0.1),
                      AppColors.indigo500.withValues(alpha: 0.05),
                    ],
                  )
                : null,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          ),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 配饰预览
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.muted.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        accessory.icon.isEmpty ? '❌' : accessory.icon,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // 配饰名称
                  Text(
                    accessory.name,
                    style: AppTypography.labelSmall.copyWith(
                      color: isSelected ? AppColors.indigo500 : AppColors.primary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),

              // VIP标识
              if (accessory.isVipOnly)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'VIP',
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white,
                        fontSize: 8,
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

  /// 构建保存按钮
  Widget _buildSaveButton() {
    final hasChanges = _selectedSkinId != widget.pet.skinId ||
        _selectedAccessoryId != widget.pet.accessoryId;

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
        child: SizedBox(
          width: double.infinity,
          height: AppSpacing.buttonHeightLg,
          child: ElevatedButton(
            onPressed: hasChanges && !_isSaving ? _saveAppearance : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.indigo500,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.muted.withValues(alpha: 0.3),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
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
                    '保存外观',
                    style: AppTypography.labelLarge.copyWith(
                      color: hasChanges ? Colors.white : AppColors.mutedForeground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  /// 选择皮肤
  void _selectSkin(String skinId) {
    setState(() {
      _selectedSkinId = skinId;
    });
  }

  /// 选择配饰
  void _selectAccessory(String accessoryId) {
    setState(() {
      _selectedAccessoryId = accessoryId;
    });
  }

  /// 保存外观
  Future<void> _saveAppearance() async {
    setState(() {
      _isSaving = true;
    });

    try {
      PetModel? updatedPet = widget.pet;

      // 更新皮肤
      if (_selectedSkinId != widget.pet.skinId) {
        updatedPet = await _appearanceService.updateSkin(
          updatedPet,
          _selectedSkinId,
          widget.isVip,
        );
      }

      // 更新配饰
      if (_selectedAccessoryId != widget.pet.accessoryId && updatedPet != null) {
        updatedPet = await _appearanceService.updateAccessory(
          updatedPet,
          _selectedAccessoryId,
          widget.isVip,
        );
      }

      if (updatedPet != null && mounted) {
        widget.onAppearanceChanged?.call(updatedPet);
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('外观已保存'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存失败: $e'),
            backgroundColor: AppColors.destructive,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  /// 显示VIP锁定提示
  void _showVipLockDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        title: Row(
          children: [
            Icon(
              Icons.workspace_premium,
              color: AppColors.warning,
            ),
            const SizedBox(width: AppSpacing.sm),
            const Text('VIP专属'),
          ],
        ),
        content: const Text('该外观为VIP专属，开通VIP会员后即可解锁使用。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '取消',
              style: TextStyle(color: AppColors.mutedForeground),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onOpenVip?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: Colors.white,
            ),
            child: const Text('开通VIP'),
          ),
        ],
      ),
    );
  }

  /// 获取对比色（用于在彩色背景上显示文字）
  Color _getContrastColor(Color backgroundColor) {
    // 计算亮度
    final luminance = (0.299 * (backgroundColor.r * 255.0).round() +
            0.587 * (backgroundColor.g * 255.0).round() +
            0.114 * (backgroundColor.b * 255.0).round()) /
        255;
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }
}
