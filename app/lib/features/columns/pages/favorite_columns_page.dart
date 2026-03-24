import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/favorite_provider.dart';
import '../data/column_data.dart';
import '../data/models/favorite_column.dart';
import 'column_detail_page.dart';

// ═══════════════════════════════════════════════════════════════════════════════
/// 专栏收藏列表页面
/// 展示用户收藏的所有专栏，支持取消收藏和跳转到详情页
// ═══════════════════════════════════════════════════════════════════════════════
class FavoriteColumnsPage extends StatefulWidget {
  /// 用户ID（可选）
  final String? userId;

  const FavoriteColumnsPage({
    super.key,
    this.userId,
  });

  @override
  State<FavoriteColumnsPage> createState() => _FavoriteColumnsPageState();
}

class _FavoriteColumnsPageState extends State<FavoriteColumnsPage> {
  // ────────────────────────────────────────────────────────────────────────────
  // 生命周期方法
  // ────────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    // 页面加载时获取收藏列表
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFavorites();
    });
  }

  /// 加载收藏列表
  void _loadFavorites() {
    final provider = context.read<FavoriteProvider>();
    provider.loadFavorites(userId: widget.userId);
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 构建方法
  // ────────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 背景色
      backgroundColor: AppColors.archiveBackground,
      // 主体内容
      body: Consumer<FavoriteProvider>(
        builder: (context, provider, child) {
          // 构建页面结构
          return Column(
            children: [
              // 顶部导航栏
              _buildAppBar(provider),

              // 内容区域
              Expanded(
                child: _buildContent(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 顶部导航栏
  // ────────────────────────────────────────────────────────────────────────────

  /// 构建顶部导航栏
  Widget _buildAppBar(FavoriteProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.archiveModalBackground,
        boxShadow: [
          BoxShadow(
            color: AppColors.archiveTextMuted.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              // 返回按钮
              _buildBackButton(),

              // 标题
              Expanded(
                child: Text(
                  '我的收藏',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.archiveText,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // 占位，保持标题居中
              const SizedBox(width: 44),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建返回按钮
  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(
          Icons.arrow_back_ios_new,
          size: 20,
          color: AppColors.archiveText,
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 内容区域
  // ────────────────────────────────────────────────────────────────────────────

  /// 构建内容区域
  Widget _buildContent(FavoriteProvider provider) {
    // 加载状态
    if (provider.isLoading) {
      return _buildLoadingWidget();
    }

    // 错误状态
    if (provider.errorMessage != null) {
      return _buildErrorWidget(provider.errorMessage!);
    }

    // 空状态
    if (provider.favoriteCount == 0) {
      return _buildEmptyWidget();
    }

    // 正常状态：显示收藏列表
    return _buildFavoriteList(provider);
  }

  /// 构建收藏列表
  Widget _buildFavoriteList(FavoriteProvider provider) {
    return RefreshIndicator(
      // 下拉刷新
      onRefresh: () => provider.loadFavorites(),
      color: AppColors.archiveAccent,
      backgroundColor: AppColors.archiveModalBackground,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: provider.favoriteCount,
        itemBuilder: (context, index) {
          final favorite = provider.favorites[index];
          return _buildFavoriteCard(provider, favorite, index);
        },
      ),
    );
  }

  /// 构建收藏卡片
  Widget _buildFavoriteCard(
    FavoriteProvider provider,
    FavoriteColumn favorite,
    int index,
  ) {
    // 获取专栏基本信息
    final columnItem = _getColumnItem(favorite.columnId);

    // 如果专栏信息不存在，显示已删除的提示
    if (columnItem == null) {
      return _buildDeletedCard(favorite, index);
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + index * 50),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEDD8A8), Color(0xFFE3C47E)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF644614).withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.4),
              blurRadius: 0,
              offset: const Offset(0, 1),
            ),
          ],
          border: Border.all(
            color: const Color(0xFFB4823C).withValues(alpha: 0.22),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            // 点击跳转到详情页
            onTap: () => _navigateToDetail(favorite.columnId),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 左侧：emoji图标
                  _buildEmojiIcon(columnItem.emoji),

                  const SizedBox(width: 12),

                  // 中间：专栏信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 标题
                        _buildTitle(columnItem.title),

                        const SizedBox(height: 8),

                        // 分类和价格
                        _buildCategoryAndPrice(columnItem),

                        const SizedBox(height: 8),

                        // 收藏时间
                        _buildFavoriteTime(favorite.createdAt),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // 右侧：取消收藏按钮
                  _buildUnfavoriteButton(provider, favorite.columnId),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 构建emoji图标
  Widget _buildEmojiIcon(String emoji) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }

  /// 构建标题
  Widget _buildTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.archiveText,
        height: 1.4,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// 构建分类和价格
  Widget _buildCategoryAndPrice(ColumnItem columnItem) {
    return Row(
      children: [
        // 分类标签
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: columnItem.catBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            columnItem.category,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: columnItem.catColor,
            ),
          ),
        ),

        const SizedBox(width: 8),

        // 价格
        Text(
          columnItem.price,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.archiveAccentDark,
          ),
        ),
      ],
    );
  }

  /// 构建收藏时间
  Widget _buildFavoriteTime(DateTime createdAt) {
    return Row(
      children: [
        Icon(
          Icons.access_time,
          size: 12,
          color: AppColors.archiveTextMuted,
        ),
        const SizedBox(width: 4),
        Text(
          _formatDateTime(createdAt),
          style: TextStyle(
            fontSize: 11,
            color: AppColors.archiveTextMuted,
          ),
        ),
      ],
    );
  }

  /// 构建取消收藏按钮
  Widget _buildUnfavoriteButton(
    FavoriteProvider provider,
    String columnId,
  ) {
    return GestureDetector(
      onTap: provider.isOperating ? null : () => _handleUnfavorite(provider, columnId),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.archiveAccent.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite,
              size: 14,
              color: const Color(0xFFE74C3C),
            ),
            const SizedBox(width: 4),
            Text(
              '已收藏',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.archiveAccentDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建已删除专栏的卡片
  Widget _buildDeletedCard(FavoriteColumn favorite, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + index * 50),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.archiveTextMuted.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.archiveTextMuted.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.article_outlined,
              size: 48,
              color: AppColors.archiveTextMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    favorite.columnTitle ?? '专栏已下架',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.archiveTextMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '该专栏已下架或删除',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.archiveTextMuted.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 状态组件
  // ────────────────────────────────────────────────────────────────────────────

  /// 构建加载中组件
  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 3,
            color: AppColors.archiveAccent,
          ),
          const SizedBox(height: 16),
          Text(
            '加载中...',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.archiveTextMuted,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建错误组件
  Widget _buildErrorWidget(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.archiveTextMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.archiveTextMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadFavorites,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.archiveAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建空状态组件
  Widget _buildEmptyWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 图标
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.archiveCardStart.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_border,
                size: 40,
                color: AppColors.archiveAccent.withValues(alpha: 0.5),
              ),
            ),

            const SizedBox(height: 24),

            // 提示文字
            Text(
              '还没有收藏的专栏',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.archiveText,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              '去发现感兴趣的专栏吧',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.archiveTextMuted,
              ),
            ),

            const SizedBox(height: 24),

            // 去逛逛按钮
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                decoration: BoxDecoration(
                  gradient: AppColors.archiveBannerGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.archiveAccent.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Text(
                  '去逛逛',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 事件处理
  // ────────────────────────────────────────────────────────────────────────────

  /// 跳转到专栏详情页
  void _navigateToDetail(String columnId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ColumnDetailPage(
          columnId: columnId,
          userId: widget.userId,
        ),
      ),
    );
  }

  /// 处理取消收藏操作
  Future<void> _handleUnfavorite(
    FavoriteProvider provider,
    String columnId,
  ) async {
    // 显示确认对话框
    final confirmed = await _showUnfavoriteConfirmDialog();
    if (!confirmed) return;

    try {
      final success = await provider.removeFromFavorites(columnId);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('已取消收藏'),
            backgroundColor: AppColors.archiveAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('操作失败: $e'),
            backgroundColor: AppColors.destructive,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  /// 显示取消收藏确认对话框
  Future<bool> _showUnfavoriteConfirmDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.archiveModalBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              '取消收藏',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.archiveText,
              ),
            ),
            content: Text(
              '确定要取消收藏这个专栏吗？',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.archiveTextMuted,
              ),
            ),
            actions: [
              // 取消按钮
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  '取消',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.archiveTextMuted,
                  ),
                ),
              ),

              // 确认按钮
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  '确定',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.archiveAccent,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 辅助方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 根据专栏ID获取专栏基本信息
  /// [columnId] 专栏ID
  /// 返回专栏基本信息，不存在则返回null
  ColumnItem? _getColumnItem(String columnId) {
    try {
      final id = int.parse(columnId);
      return ColumnData.columns.firstWhere(
        (item) => item.id == id,
      );
    } catch (e) {
      return null;
    }
  }

  /// 格式化日期时间
  /// [dateTime] 日期时间对象
  /// 返回格式化后的字符串，如 "2024-03-24 15:30"
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    // 如果是今天
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes < 1) {
          return '刚刚';
        }
        return '${difference.inMinutes}分钟前';
      }
      return '${difference.inHours}小时前';
    }

    // 如果是昨天
    if (difference.inDays == 1) {
      return '昨天 ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }

    // 如果是今年
    if (dateTime.year == now.year) {
      return '${dateTime.month}-${dateTime.day} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }

    // 其他情况
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }
}
