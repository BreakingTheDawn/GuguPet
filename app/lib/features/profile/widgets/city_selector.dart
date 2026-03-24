import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

/// 城市选择器组件
/// 提供常用城市列表，支持多选和搜索功能
class CitySelector extends StatefulWidget {
  /// 当前选中的城市列表
  final List<String> selectedCities;
  
  /// 选择变化回调
  final ValueChanged<List<String>> onChanged;
  
  /// 最大可选数量
  final int maxSelection;

  const CitySelector({
    super.key,
    this.selectedCities = const [],
    required this.onChanged,
    this.maxSelection = 3,
  });

  @override
  State<CitySelector> createState() => _CitySelectorState();
}

class _CitySelectorState extends State<CitySelector> {
  /// 搜索关键词
  String _searchKeyword = '';
  
  /// 搜索控制器
  final TextEditingController _searchController = TextEditingController();

  /// 常用城市列表（按热门程度分组）
  /// 注意：某些城市可能同时出现在多个分组中（如杭州既是热门城市也是新一线城市）
  static const Map<String, List<String>> cityGroups = {
    '热门城市': [
      '北京',
      '上海',
      '广州',
      '深圳',
      '杭州',
      '成都',
      '武汉',
      '西安',
    ],
    '一线城市': [
      '北京',
      '上海',
      '广州',
      '深圳',
    ],
    '新一线城市': [
      '杭州',
      '成都',
      '武汉',
      '西安',
      '南京',
      '苏州',
      '天津',
      '重庆',
      '长沙',
      '郑州',
      '东莞',
      '青岛',
      '沈阳',
      '宁波',
      '昆明',
    ],
    '二线城市': [
      '合肥',
      '福州',
      '厦门',
      '哈尔滨',
      '济南',
      '大连',
      '长春',
      '石家庄',
      '南宁',
      '贵阳',
      '南昌',
      '太原',
      '珠海',
      '中山',
      '佛山',
      '无锡',
      '常州',
      '南通',
      '徐州',
      '温州',
    ],
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
          _buildHeader(),
          
          // 搜索框
          _buildSearchField(),
          
          // 已选城市标签
          if (widget.selectedCities.isNotEmpty) _buildSelectedTags(),
          
          // 城市列表
          _buildCityList(),
        ],
      ),
    );
  }

  /// 构建标题栏
  Widget _buildHeader() {
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
            Icons.location_city,
            size: AppSpacing.iconMd,
            color: AppColors.indigo500,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '选择期望城市',
            style: AppTypography.headingSmall.copyWith(
              color: AppColors.primary,
            ),
          ),
          const Spacer(),
          Text(
            '最多可选${widget.maxSelection}个',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建搜索框
  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchKeyword = value.trim();
          });
        },
        decoration: InputDecoration(
          hintText: '搜索城市',
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.mutedForeground,
          ),
          prefixIcon: Icon(
            Icons.search,
            size: AppSpacing.iconMd,
            color: AppColors.mutedForeground,
          ),
          filled: true,
          fillColor: AppColors.inputBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
        ),
      ),
    );
  }

  /// 构建已选城市标签
  Widget _buildSelectedTags() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: widget.selectedCities.map((city) {
          return _buildSelectedTag(city);
        }).toList(),
      ),
    );
  }

  /// 构建单个已选标签
  Widget _buildSelectedTag(String city) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.indigo500.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(
          color: AppColors.indigo500,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            city,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.indigo500,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          GestureDetector(
            onTap: () => _toggleCity(city),
            child: Icon(
              Icons.close,
              size: 14,
              color: AppColors.indigo500,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建城市列表
  Widget _buildCityList() {
    // 如果有搜索关键词，显示搜索结果
    if (_searchKeyword.isNotEmpty) {
      return _buildSearchResults();
    }
    
    // 否则显示分组列表
    return _buildGroupedList();
  }

  /// 构建搜索结果
  Widget _buildSearchResults() {
    final allCities = cityGroups.values.expand((list) => list).toSet().toList();
    final filteredCities = allCities
        .where((city) => city.toLowerCase().contains(_searchKeyword.toLowerCase()))
        .toList();

    if (filteredCities.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Center(
          child: Text(
            '未找到相关城市',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      itemCount: filteredCities.length,
      itemBuilder: (context, index) {
        return _buildCityTile(filteredCities[index]);
      },
    );
  }

  /// 构建分组列表
  Widget _buildGroupedList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      itemCount: cityGroups.length,
      itemBuilder: (context, groupIndex) {
        final groupName = cityGroups.keys.elementAt(groupIndex);
        final cities = cityGroups[groupName]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 分组标题
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Text(
                groupName,
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.mutedForeground,
                ),
              ),
            ),
            
            // 城市网格
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: cities.map((city) {
                  return _buildCityChip(city);
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  /// 构建城市选择项（列表形式）
  Widget _buildCityTile(String city) {
    final isSelected = widget.selectedCities.contains(city);
    
    return InkWell(
      onTap: () => _toggleCity(city),
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
            // 城市名称
            Text(
              city,
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

  /// 构建城市选择项（标签形式）
  Widget _buildCityChip(String city) {
    final isSelected = widget.selectedCities.contains(city);
    
    return GestureDetector(
      onTap: () => _toggleCity(city),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.indigo500 : AppColors.inputBackground,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isSelected ? AppColors.indigo500 : AppColors.border,
            width: 1,
          ),
        ),
        child: Text(
          city,
          style: AppTypography.bodyMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.primary,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  /// 切换城市选择状态
  void _toggleCity(String city) {
    final newSelection = List<String>.from(widget.selectedCities);
    
    if (newSelection.contains(city)) {
      // 取消选择
      newSelection.remove(city);
    } else {
      // 添加选择
      if (newSelection.length >= widget.maxSelection) {
        // 已达到最大选择数量
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('最多只能选择${widget.maxSelection}个城市'),
            backgroundColor: AppColors.warning,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      newSelection.add(city);
    }
    
    widget.onChanged(newSelection);
  }
}

/// 城市选择器底部弹窗
/// 用于在底部弹出城市选择器
class CitySelectorBottomSheet extends StatefulWidget {
  /// 当前选中的城市列表
  final List<String> selectedCities;
  
  /// 确认回调
  final ValueChanged<List<String>> onConfirmed;
  
  /// 最大可选数量
  final int maxSelection;

  const CitySelectorBottomSheet({
    super.key,
    this.selectedCities = const [],
    required this.onConfirmed,
    this.maxSelection = 3,
  });

  /// 显示城市选择器底部弹窗
  static Future<void> show(
    BuildContext context, {
    List<String> selectedCities = const [],
    required ValueChanged<List<String>> onConfirmed,
    int maxSelection = 3,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => CitySelectorBottomSheet(
        selectedCities: selectedCities,
        onConfirmed: onConfirmed,
        maxSelection: maxSelection,
      ),
    );
  }

  @override
  State<CitySelectorBottomSheet> createState() => _CitySelectorBottomSheetState();
}

class _CitySelectorBottomSheetState extends State<CitySelectorBottomSheet> {
  late List<String> _tempSelection;

  @override
  void initState() {
    super.initState();
    _tempSelection = List.from(widget.selectedCities);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.radiusLg),
          topRight: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      child: Column(
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
          
          // 城市选择器
          Expanded(
            child: CitySelector(
              selectedCities: _tempSelection,
              maxSelection: widget.maxSelection,
              onChanged: (cities) {
                setState(() {
                  _tempSelection = cities;
                });
              },
            ),
          ),
          
          // 底部操作栏
          _buildBottomBar(),
        ],
      ),
    );
  }

  /// 构建底部操作栏
  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(
          top: BorderSide(
            color: AppColors.divider,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // 已选数量提示
          Text(
            '已选 ${_tempSelection.length}/${widget.maxSelection}',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
          const Spacer(),
          // 取消按钮
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '取消',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.mutedForeground,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // 确认按钮
          ElevatedButton(
            onPressed: () {
              widget.onConfirmed(_tempSelection);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.indigo500,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }
}
