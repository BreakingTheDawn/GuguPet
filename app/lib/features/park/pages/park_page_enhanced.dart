import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../routes/app_routes.dart';
import '../providers/park_provider.dart';
import '../providers/friend_provider.dart';
import '../providers/post_provider.dart';
import '../widgets/park_user_card.dart';
import '../widgets/interaction_sheet.dart';
import '../data/models/models.dart';
import '../pages/friend_list_page.dart';
import '../pages/post_feed_page.dart';

// ═══════════════════════════════════════════════════════════════════════════════
/// 公园页面（增强版）
/// 集成社交功能的公园主页面
// ═══════════════════════════════════════════════════════════════════════════════
class ParkPageEnhanced extends StatefulWidget {
  const ParkPageEnhanced({super.key});

  @override
  State<ParkPageEnhanced> createState() => _ParkPageEnhancedState();
}

class _ParkPageEnhancedState extends State<ParkPageEnhanced> {
  // ────────────────────────────────────────────────────────────────────────────
  // 状态变量
  // ────────────────────────────────────────────────────────────────────────────

  int _selectedZone = 0;
  bool _showZoneMenu = false;

  // 区域配置
  static const List<Map<String, dynamic>> _zones = [
    {'name': '码农森林', 'icon': '🌲', 'color': Color(0xFF4CAF50)},
    {'name': '金币湖畔', 'icon': '💰', 'color': Color(0xFFFFC107)},
    {'name': '设计师草原', 'icon': '🎨', 'color': Color(0xFF9C27B0)},
    {'name': '产品家园', 'icon': '📱', 'color': Color(0xFF2196F3)},
  ];

  // ────────────────────────────────────────────────────────────────────────────
  // 生命周期方法
  // ────────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    
    // 初始化数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  /// 初始化数据
  void _initializeData() {
    final parkProvider = context.read<ParkProvider>();
    final friendProvider = context.read<FriendProvider>();
    final postProvider = context.read<PostProvider>();
    
    // 设置当前用户（Mock数据）
    friendProvider.setCurrentUserId('current_user');
    postProvider.setCurrentUser('current_user', '求职者');
    
    // 加载公园用户
    parkProvider.loadParkUsers();
    
    // 加载好友列表
    friendProvider.loadFriends();
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 构建方法
  // ────────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 背景渐变
          _buildBackground(),
          
          // 区域头部
          _buildZoneHeader(),
          
          // 主要内容区域
          _buildMainContent(),
        ],
      ),
    );
  }

  /// 构建背景
  Widget _buildBackground() {
    final zoneColor = _zones[_selectedZone]['color'] as Color;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0, 0.45, 0.45, 1],
          colors: [
            zoneColor.withOpacity(0.3),
            zoneColor.withOpacity(0.1),
            Colors.green.shade100,
            Colors.green.shade50,
          ],
        ),
      ),
    );
  }

  /// 构建区域头部
  Widget _buildZoneHeader() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 48, 20, 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 区域选择器
            GestureDetector(
              onTap: () => setState(() => _showZoneMenu = !_showZoneMenu),
              child: Row(
                children: [
                  Text(
                    '${_zones[_selectedZone]['icon']} ${_zones[_selectedZone]['name']}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _showZoneMenu ? Icons.expand_less : Icons.expand_more,
                    size: 24,
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            // 消息按钮
            _buildHeaderButton(
              icon: Icons.chat_bubble_outline,
              count: 3, // TODO: 从通知系统获取未读消息数
              onTap: () => _navigateToNotifications(),
            ),
            
            const SizedBox(width: 12),
            
            // 好友按钮
            _buildHeaderButton(
              icon: Icons.people_outline,
              count: context.watch<FriendProvider>().pendingCount,
              onTap: () => _navigateToFriendList(),
            ),
            
            const SizedBox(width: 12),
            
            // 动态按钮
            _buildHeaderButton(
              icon: Icons.article_outlined,
              onTap: () => _navigateToPostFeed(),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建头部按钮
  Widget _buildHeaderButton({
    required IconData icon,
    int? count,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 22),
          ),
          if (count != null && count > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  count > 9 ? '9+' : count.toString(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 构建主要内容区域
  Widget _buildMainContent() {
    return Positioned.fill(
      top: 120,
      child: Column(
        children: [
          // 用户数量提示
          Consumer<ParkProvider>(
            builder: (context, provider, child) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      '🚶 ${provider.parkUsers.length}只咕咕在逛',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // 用户列表
          Expanded(
            child: Consumer<ParkProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (provider.parkUsers.isEmpty) {
                  return _buildEmptyState();
                }
                
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: provider.parkUsers.length,
                  itemBuilder: (context, index) {
                    final user = provider.parkUsers[index];
                    return ParkUserCard(
                      user: user,
                      onTap: () => _showUserInteraction(user),
                    );
                  },
                );
              },
            ),
          ),
          
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pets,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            '这个区域暂时没有其他咕咕',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建底部导航栏
  Widget _buildBottomBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavItem(
              icon: Icons.park,
              label: '公园',
              isSelected: true,
            ),
            _buildBottomNavItem(
              icon: Icons.chat_bubble_outline,
              label: '消息',
              badge: 3,
            ),
            _buildBottomNavItem(
              icon: Icons.person_outline,
              label: '我的',
            ),
          ],
        ),
      ),
    );
  }

  /// 构建底部导航项
  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    bool isSelected = false,
    int? badge,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.grey,
              size: 24,
            ),
            if (badge != null && badge > 0)
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    badge > 9 ? '9+' : badge.toString(),
                    style: const TextStyle(
                      fontSize: 8,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isSelected ? Colors.blue : Colors.grey,
          ),
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 交互方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 显示用户互动面板
  Future<void> _showUserInteraction(ParkUser user) async {
    final friendProvider = context.read<FriendProvider>();
    final isFriend = await friendProvider.isFriend(user.id);
    
    if (!mounted) return;
    
    InteractionSheet.show(
      context: context,
      targetUser: user,
      isFriend: isFriend,
      onPet: () => _handleInteraction(user, InteractionType.pet),
      onGreet: () => _handleInteraction(user, InteractionType.greet),
      onGift: () => _handleInteraction(user, InteractionType.gift),
      onAddFriend: () => _handleAddFriend(user),
      onViewPosts: () => _handleViewPosts(user),
    );
  }

  /// 处理互动
  Future<void> _handleInteraction(ParkUser user, InteractionType type) async {
    final parkProvider = context.read<ParkProvider>();
    
    await parkProvider.sendInteraction(
      'current_user',
      user.id,
      type,
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('你${_getInteractionText(type)}${user.name}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// 获取互动文本
  String _getInteractionText(InteractionType type) {
    switch (type) {
      case InteractionType.pet:
        return '抚摸了';
      case InteractionType.greet:
        return '向';
      case InteractionType.gift:
        return '送给';
      case InteractionType.like:
        return '点赞了';
    }
  }

  /// 处理添加好友
  Future<void> _handleAddFriend(ParkUser user) async {
    final friendProvider = context.read<FriendProvider>();
    
    final success = await friendProvider.sendFriendRequest(
      user.id,
      user.name,
      targetUserTitle: user.title,
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '好友申请已发送' : '发送失败，请重试'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// 处理查看动态
  void _handleViewPosts(ParkUser user) {
    // TODO: 跳转到用户动态页面
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('查看${user.name}的动态'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// 跳转到好友列表
  void _navigateToFriendList() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FriendListPage()),
    );
  }

  /// 跳转到动态流
  void _navigateToPostFeed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PostFeedPage()),
    );
  }
  
  /// 跳转到消息通知页面
  void _navigateToNotifications() {
    Navigator.pushNamed(context, AppRoutes.notificationCenter);
  }
}
