import 'package:flutter/material.dart';
import '../data/column_data.dart';
import '../widgets/column_card.dart';
import '../widgets/preview_modal.dart';
import '../widgets/bottom_cta.dart';

/// 付费专栏主页面
/// 展示咕咕档案馆的所有专栏内容
class ColumnsPage extends StatefulWidget {
  const ColumnsPage({super.key});

  @override
  State<ColumnsPage> createState() => _ColumnsPageState();
}

class _ColumnsPageState extends State<ColumnsPage>
    with TickerProviderStateMixin {
  ColumnItem? _previewColumn;
  int _selectedCategory = 0;

  late AnimationController _dotAnimationController;
  late List<Animation<double>> _dotAnimations;

  @override
  void initState() {
    super.initState();
    _initDotAnimations();
  }

  /// 初始化装饰点动画
  void _initDotAnimations() {
    _dotAnimationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    _dotAnimations = List.generate(12, (index) {
      return Tween<double>(begin: 0.2, end: 0.6).animate(
        CurvedAnimation(
          parent: _dotAnimationController,
          curve: Interval(
            index * 0.08,
            0.5 + index * 0.04,
            curve: Curves.easeInOut,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _dotAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: const Color(0xFFF7F4EF),
          child: Column(
            children: [
              _buildHeroBanner(),
              _buildSectionHeader(),
              _buildCategoryFilter(),
              Expanded(child: _buildColumnGrid()),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: const BottomCTA(),
        ),
        if (_previewColumn != null)
          Positioned.fill(
            child: PreviewModal(
              column: _previewColumn,
              onClose: () => setState(() => _previewColumn = null),
            ),
          ),
      ],
    );
  }

  /// Hero Banner 横幅区域
  Widget _buildHeroBanner() {
    return SizedBox(
      height: 188,
      child: Stack(
        children: [
          _buildBannerBackground(),
          _buildDecorativeDots(),
          _buildBannerContent(),
        ],
      ),
    );
  }

  /// Banner 背景（温暖渐变，无淡化效果）
  Widget _buildBannerBackground() {
    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-1, -1),
            end: Alignment(1, 1),
            colors: [
              Color(0xFF5A3318),
              Color(0xFF8B5A2A),
              Color(0xFF8B5A2A),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }

  /// 装饰性动画点
  Widget _buildDecorativeDots() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: List.generate(12, (index) {
            final size = 4.0 + (index % 3) * 2.0;
            final left = 8.0 + (index * 27) % 82;
            final top = 10.0 + (index * 19) % 70;

            return Positioned(
              left: left * (MediaQuery.of(context).size.width / 100),
              top: top * 1.88,
              child: AnimatedBuilder(
                animation: _dotAnimations[index],
                builder: (context, child) {
                  return Opacity(
                    opacity: _dotAnimations[index].value,
                    child: Transform.scale(
                      scale: 0.9 + _dotAnimations[index].value * 0.3,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFDCA0).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  /// Banner 文字内容
  Widget _buildBannerContent() {
    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 14 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBadge(),
                  const SizedBox(height: 8),
                  _buildTitle(),
                  const SizedBox(height: 6),
                  _buildSubtitle(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 标签徽章
  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFFDCA0).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFDCA0).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🎓', style: TextStyle(fontSize: 10)),
          SizedBox(width: 6),
          Text(
            '咕咕精选 · 毕业特辑',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFFDCA0),
            ),
          ),
        ],
      ),
    );
  }

  /// 主标题
  Widget _buildTitle() {
    return const Text(
      '毕业不迷茫：\n咕咕的避坑档案馆',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: Colors.white,
        height: 1.35,
        letterSpacing: 0.01,
      ),
    );
  }

  /// 副标题
  Widget _buildSubtitle() {
    return Text(
      '${ColumnData.columns.length} 份干货手册 · 陪你迈过每道坎',
      style: TextStyle(
        fontSize: 11,
        color: const Color(0xFFFFDCA0).withOpacity(0.8),
      ),
    );
  }

  /// 区域标题
  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '全套档案馆',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2A1A08),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '共 ${ColumnData.columns.length} 份专栏 · 持续更新中',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFFA08050),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEDD8A8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '🗂️ 档案馆',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF7A5030),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 分类筛选标签
  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: ColumnData.categories.length,
        itemBuilder: (context, index) {
          final isSelected = index == _selectedCategory;
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 200 + index * 50),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(-6 * (1 - value), 0),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategory = index),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF8B5A2A)
                      : const Color(0xFFB4823C).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  ColumnData.categories[index],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? Colors.white : const Color(0xFF8A6A40),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 专栏卡片网格
  Widget _buildColumnGrid() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 80),
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.82,
        ),
        itemCount: ColumnData.columns.length,
        itemBuilder: (context, index) {
          final column = ColumnData.columns[index];
          return ColumnCard(
            column: column,
            index: index,
            onPreview: () => _showPreview(column),
          );
        },
      ),
    );
  }

  /// 显示预览弹窗
  void _showPreview(ColumnItem column) {
    setState(() => _previewColumn = column);
  }
}
