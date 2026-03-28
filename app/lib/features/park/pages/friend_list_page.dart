import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/friend_provider.dart';
import '../data/models/models.dart';

// ═══════════════════════════════════════════════════════════════════════════════
/// 好友列表页面
/// 展示用户的好友列表和待处理的好友申请
// ═══════════════════════════════════════════════════════════════════════════════
class FriendListPage extends StatefulWidget {
  const FriendListPage({super.key});

  @override
  State<FriendListPage> createState() => _FriendListPageState();
}

class _FriendListPageState extends State<FriendListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // 加载好友列表
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FriendProvider>().loadFriends();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('好友列表'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: '好友'),
            Tab(text: '申请'),
          ],
        ),
      ),
      body: Consumer<FriendProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              // 好友列表
              _buildFriendsList(provider),
              // 好友申请列表
              _buildPendingList(provider),
            ],
          );
        },
      ),
    );
  }

  /// 构建好友列表
  Widget _buildFriendsList(FriendProvider provider) {
    if (provider.friends.isEmpty) {
      return _buildEmptyState(
        icon: Icons.people_outline,
        title: '暂无好友',
        subtitle: '去公园逛逛，认识新朋友吧！',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.friends.length,
      itemBuilder: (context, index) {
        final friend = provider.friends[index];
        return _buildFriendItem(friend, provider);
      },
    );
  }

  /// 构建好友项
  Widget _buildFriendItem(Friend friend, FriendProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Stack(
          children: [
            // 头像
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🐧', style: TextStyle(fontSize: 24)),
              ),
            ),
            
            // 在线状态指示器
            Positioned(
              right: 0,
              bottom: 0,
              child: _buildOnlineIndicator(friend),
            ),
          ],
        ),
        title: Row(
          children: [
            Text(friend.friendName),
            const SizedBox(width: 8),
            _buildOnlineBadge(friend),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (friend.friendTitle != null)
              Text(
                friend.friendTitle!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            const SizedBox(height: 2),
            Text(
              friend.onlineStatusText,
              style: TextStyle(
                fontSize: 11,
                color: friend.isOnline ? Colors.green : Colors.grey.shade500,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') {
              _showDeleteConfirmDialog(context, friend, provider);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'delete',
              child: Text('删除好友'),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建在线状态指示器（小圆点）
  Widget _buildOnlineIndicator(Friend friend) {
    Color color;
    switch (friend.onlineStatus) {
      case OnlineStatus.online:
        color = Colors.green;
        break;
      case OnlineStatus.busy:
        color = Colors.orange;
        break;
      case OnlineStatus.away:
        color = Colors.yellow;
        break;
      case OnlineStatus.offline:
        color = Colors.grey;
        break;
    }

    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
    );
  }

  /// 构建在线状态标签
  Widget _buildOnlineBadge(Friend friend) {
    if (friend.onlineStatus == OnlineStatus.offline) {
      return const SizedBox.shrink();
    }

    Color bgColor;
    String text;
    
    switch (friend.onlineStatus) {
      case OnlineStatus.online:
        bgColor = Colors.green.shade100;
        text = '在线';
        break;
      case OnlineStatus.busy:
        bgColor = Colors.orange.shade100;
        text = '忙碌';
        break;
      case OnlineStatus.away:
        bgColor = Colors.yellow.shade100;
        text = '离开';
        break;
      case OnlineStatus.offline:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  /// 构建待处理申请列表
  Widget _buildPendingList(FriendProvider provider) {
    if (provider.pendingRequests.isEmpty) {
      return _buildEmptyState(
        icon: Icons.inbox_outlined,
        title: '暂无好友申请',
        subtitle: '有新好友申请时会显示在这里',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.pendingRequests.length,
      itemBuilder: (context, index) {
        final request = provider.pendingRequests[index];
        return _buildPendingItem(request, provider);
      },
    );
  }

  /// 构建待处理申请项
  Widget _buildPendingItem(Friend request, FriendProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // 头像
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🐧', style: TextStyle(fontSize: 24)),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // 用户信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.friendName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (request.friendTitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      request.friendTitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // 操作按钮
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 接受按钮
                IconButton(
                  onPressed: () => provider.acceptRequest(request.id),
                  icon: const Icon(Icons.check_circle),
                  color: Colors.green,
                  iconSize: 28,
                ),
                
                // 拒绝按钮
                IconButton(
                  onPressed: () => provider.rejectRequest(request.id),
                  icon: const Icon(Icons.cancel),
                  color: Colors.red,
                  iconSize: 28,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  /// 显示删除确认对话框
  void _showDeleteConfirmDialog(
    BuildContext context,
    Friend friend,
    FriendProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除好友'),
        content: Text('确定要删除好友"${friend.friendName}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.removeFriend(friend.id);
            },
            child: const Text(
              '删除',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
