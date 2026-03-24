import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorite_provider.dart';
import '../widgets/favorite_button.dart';
import '../services/column_service.dart';

// ═══════════════════════════════════════════════════════════════════════════════
/// 收藏按钮使用示例
/// 展示如何在页面中集成收藏按钮和状态管理
// ═══════════════════════════════════════════════════════════════════════════════

/// 示例1：基础用法 - 在详情页中使用
class DetailPageExample extends StatelessWidget {
  final String columnId;
  final String columnTitle;

  const DetailPageExample({
    super.key,
    required this.columnId,
    required this.columnTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('专栏详情'),
        actions: [
          // 使用收藏按钮
          Consumer<FavoriteProvider>(
            builder: (context, provider, child) {
              return FavoriteButton(
                isFavorited: provider.isFavorited(columnId),
                onTap: () => _handleFavoriteTap(context, provider),
                size: 28.0,
                showText: true,
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Center(
        child: Text('专栏内容: $columnTitle'),
      ),
    );
  }

  /// 处理收藏点击
  Future<void> _handleFavoriteTap(
    BuildContext context,
    FavoriteProvider provider,
  ) async {
    try {
      await provider.toggleFavorite(
        columnId,
        columnTitle: columnTitle,
      );

      // 显示提示
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.isFavorited(columnId) ? '已添加到收藏' : '已取消收藏',
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('操作失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// 示例2：使用样式配置 - 在列表项中使用
class ListItemExample extends StatelessWidget {
  final String columnId;
  final String columnTitle;

  const ListItemExample({
    super.key,
    required this.columnId,
    required this.columnTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(columnTitle),
        trailing: Consumer<FavoriteProvider>(
          builder: (context, provider, child) {
            // 使用小号样式
            return FavoriteButtonStyle.smallStyle.apply(
              isFavorited: provider.isFavorited(columnId),
              onTap: () => provider.toggleFavorite(
                columnId,
                columnTitle: columnTitle,
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 示例3：自定义样式 - 使用自定义颜色和图标
class CustomStyleExample extends StatelessWidget {
  final String columnId;

  const CustomStyleExample({
    super.key,
    required this.columnId,
  });

  @override
  Widget build(BuildContext context) {
    // 自定义样式配置
    const customStyle = FavoriteButtonStyle(
      size: 32.0,
      showText: true,
      favoriteIcon: Icons.bookmark,
      unfavoriteIcon: Icons.bookmark_border,
      favoriteColor: Color(0xFFFFB300), // 琥珀色
      unfavoriteColor: Color(0xFFBDBDBD), // 灰色
      animationDuration: Duration(milliseconds: 400),
    );

    return Consumer<FavoriteProvider>(
      builder: (context, provider, child) {
        return customStyle.apply(
          isFavorited: provider.isFavorited(columnId),
          onTap: () => provider.toggleFavorite(columnId),
        );
      },
    );
  }
}

/// 示例4：完整页面 - 收藏列表页面
class FavoriteListPageExample extends StatelessWidget {
  const FavoriteListPageExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的收藏'),
        actions: [
          // 刷新按钮
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<FavoriteProvider>().loadFavorites();
            },
          ),
        ],
      ),
      body: Consumer<FavoriteProvider>(
        builder: (context, provider, child) {
          // 加载状态
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 空状态
          if (provider.favorites.isEmpty) {
            return const Center(
              child: Text('暂无收藏'),
            );
          }

          // 收藏列表
          return ListView.builder(
            itemCount: provider.favoriteCount,
            itemBuilder: (context, index) {
              final favorite = provider.favorites[index];
              return ListTile(
                title: Text(favorite.columnTitle ?? '未知专栏'),
                subtitle: Text('收藏时间: ${_formatDate(favorite.createdAt)}'),
                trailing: FavoriteButton(
                  isFavorited: true,
                  onTap: () => _removeFavorite(context, provider, favorite.columnId),
                  size: 24.0,
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// 移除收藏
  Future<void> _removeFavorite(
    BuildContext context,
    FavoriteProvider provider,
    String columnId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认取消收藏'),
        content: const Text('确定要取消收藏这个专栏吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await provider.removeFromFavorites(columnId);
    }
  }

  /// 格式化日期
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

/// 示例5：Provider配置 - 在应用启动时配置
class ProviderSetupExample extends StatelessWidget {
  final Widget child;

  const ProviderSetupExample({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 其他Provider...

        // 收藏状态管理
        ChangeNotifierProvider<FavoriteProvider>(
          create: (context) => FavoriteProvider(
            columnService: context.read<ColumnService>(),
          )..loadFavorites(), // 初始化时加载收藏列表
        ),
      ],
      child: child,
    );
  }
}

/// 示例6：与详情页联动 - 在详情页中同步收藏状态
class DetailPageWithSyncExample extends StatefulWidget {
  final String columnId;

  const DetailPageWithSyncExample({
    super.key,
    required this.columnId,
  });

  @override
  State<DetailPageWithSyncExample> createState() =>
      _DetailPageWithSyncExampleState();
}

class _DetailPageWithSyncExampleState extends State<DetailPageWithSyncExample> {
  @override
  void initState() {
    super.initState();
    // 页面加载时刷新收藏状态
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<FavoriteProvider>()
          .refreshFavoriteStatus(widget.columnId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('专栏详情'),
        actions: [
          Consumer<FavoriteProvider>(
            builder: (context, provider, child) {
              return FavoriteButton(
                isFavorited: provider.isFavorited(widget.columnId),
                onTap: () => _toggleFavorite(provider),
                size: 28.0,
                showText: true,
                isDisabled: provider.isOperating,
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: const Center(
        child: Text('专栏内容'),
      ),
    );
  }

  /// 切换收藏状态
  Future<void> _toggleFavorite(FavoriteProvider provider) async {
    try {
      await provider.toggleFavorite(widget.columnId);

      // 显示成功提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.isFavorited(widget.columnId) ? '已添加到收藏' : '已取消收藏',
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      // 显示错误提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('操作失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
