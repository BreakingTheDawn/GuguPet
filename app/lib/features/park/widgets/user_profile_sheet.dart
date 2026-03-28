import 'package:flutter/material.dart';
import '../data/models/models.dart';

// ═══════════════════════════════════════════════════════════════════════════════
/// 用户资料弹窗组件
/// 展示用户的详细资料信息，包括：
/// - 用户基本信息
/// - 宠物形象和配饰
/// - 求职进度摘要
/// - 最近动态列表
/// - 操作按钮
// ═══════════════════════════════════════════════════════════════════════════════
class UserProfileSheet extends StatelessWidget {
  // ────────────────────────────────────────────────────────────────────────────
  // 属性定义
  // ────────────────────────────────────────────────────────────────────────────

  /// 用户数据
  final ParkUser user;
  
  /// 是否已是好友
  final bool isFriend;
  
  /// 求职进度数据（投递数、面试数、Offer数）
  final Map<String, int>? jobStats;
  
  /// 最近动态列表
  final List<UserPost>? recentPosts;
  
  /// 互动按钮回调
  final VoidCallback? onInteract;
  
  /// 添加好友回调
  final VoidCallback? onAddFriend;
  
  /// 查看动态回调
  final VoidCallback? onViewPosts;

  // ────────────────────────────────────────────────────────────────────────────
  // 构造函数
  // ────────────────────────────────────────────────────────────────────────────

  const UserProfileSheet({
    super.key,
    required this.user,
    this.isFriend = false,
    this.jobStats,
    this.recentPosts,
    this.onInteract,
    this.onAddFriend,
    this.onViewPosts,
  });

  // ────────────────────────────────────────────────────────────────────────────
  // 静态方法 - 显示弹窗
  // ────────────────────────────────────────────────────────────────────────────

  /// 显示用户资料弹窗
  static Future<void> show({
    required BuildContext context,
    required ParkUser user,
    bool isFriend = false,
    Map<String, int>? jobStats,
    List<UserPost>? recentPosts,
    VoidCallback? onInteract,
    VoidCallback? onAddFriend,
    VoidCallback? onViewPosts,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => UserProfileSheet(
          user: user,
          isFriend: isFriend,
          jobStats: jobStats,
          recentPosts: recentPosts,
          onInteract: onInteract,
          onAddFriend: onAddFriend,
          onViewPosts: onViewPosts,
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 构建方法
  // ────────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // 顶部拖动条
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // 用户头像和信息
            _buildUserHeader(),
            
            const SizedBox(height: 16),
            
            // 求职进度摘要
            _buildJobProgressSection(),
            
            const SizedBox(height: 16),
            
            // 操作按钮
            _buildActionButtons(),
            
            const SizedBox(height: 16),
            
            // 最近动态列表
            Expanded(
              child: _buildRecentPostsSection(),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建用户头部
  Widget _buildUserHeader() {
    return Column(
      children: [
        // 宠物头像
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: user.petColor.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: user.petColor,
              width: 3,
            ),
          ),
          child: Center(
            child: Stack(
              children: [
                const Text('🐧', style: TextStyle(fontSize: 40)),
                
                // 配饰
                if (user.petAccessory != 'none')
                  Positioned(
                    right: 0,
                    top: 0,
                    child: _buildAccessoryIcon(),
                  ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // 用户昵称
        Text(
          user.name,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        // 职位标签
        if (user.title != null) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              user.title!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
        
        // 好友标识
        if (isFriend) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.favorite,
                size: 16,
                color: Colors.pink.shade400,
              ),
              const SizedBox(width: 4),
              Text(
                '已是好友',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.pink.shade400,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// 构建配饰图标
  Widget _buildAccessoryIcon() {
    String accessoryIcon;
    switch (user.petAccessory) {
      case 'glasses':
        accessoryIcon = '👓';
        break;
      case 'bow':
        accessoryIcon = '🎀';
        break;
      case 'tie':
        accessoryIcon = '👔';
        break;
      case 'hardhat':
        accessoryIcon = '⛑️';
        break;
      case 'crown':
        accessoryIcon = '👑';
        break;
      default:
        accessoryIcon = '';
    }
    
    return Text(accessoryIcon, style: const TextStyle(fontSize: 16));
  }

  /// 构建操作按钮
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // 互动按钮
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onInteract,
              icon: const Icon(Icons.pets, size: 18),
              label: const Text('互动'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // 添加好友/查看动态按钮
          Expanded(
            child: isFriend
                ? OutlinedButton.icon(
                    onPressed: onViewPosts,
                    icon: const Icon(Icons.article, size: 18),
                    label: const Text('动态'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: onAddFriend,
                    icon: const Icon(Icons.person_add, size: 18),
                    label: const Text('加好友'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  /// 构建求职进度摘要区域
  Widget _buildJobProgressSection() {
    final stats = jobStats ?? {'submitted': 0, 'interview': 0, 'offer': 0};
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Row(
            children: [
              Icon(
                Icons.work_outline,
                size: 18,
                color: Colors.grey.shade700,
              ),
              const SizedBox(width: 8),
              const Text(
                '求职进度',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // 进度条
          Row(
            children: [
              _buildProgressItem(
                label: '投递',
                count: stats['submitted'] ?? 0,
                color: Colors.blue,
              ),
              _buildProgressConnector(),
              _buildProgressItem(
                label: '面试',
                count: stats['interview'] ?? 0,
                color: Colors.orange,
              ),
              _buildProgressConnector(),
              _buildProgressItem(
                label: 'Offer',
                count: stats['offer'] ?? 0,
                color: Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建进度项
  Widget _buildProgressItem({
    required String label,
    required int count,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: Center(
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建进度连接线
  Widget _buildProgressConnector() {
    return Container(
      width: 20,
      height: 2,
      color: Colors.grey.shade300,
    );
  }

  /// 构建最近动态区域
  Widget _buildRecentPostsSection() {
    final posts = recentPosts ?? [];
    
    if (posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 48,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 12),
            Text(
              '暂无动态',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '最近动态',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (posts.length > 3)
                TextButton(
                  onPressed: onViewPosts,
                  child: const Text('查看全部'),
                ),
            ],
          ),
        ),
        
        const SizedBox(height: 8),
        
        // 动态列表
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: posts.length > 3 ? 3 : posts.length,
            itemBuilder: (context, index) {
              return _buildPostItem(posts[index]);
            },
          ),
        ),
      ],
    );
  }

  /// 构建动态项
  Widget _buildPostItem(UserPost post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 动态类型标签
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _getPostTypeColor(post.type).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _getPostTypeLabel(post.type),
              style: TextStyle(
                fontSize: 11,
                color: _getPostTypeColor(post.type),
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // 动态内容
          Text(
            post.content,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // 时间和互动
          Row(
            children: [
              Text(
                _formatPostTime(post.createdAt),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.favorite_border,
                size: 14,
                color: Colors.grey.shade400,
              ),
              const SizedBox(width: 4),
              Text(
                post.likeCount.toString(),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 获取动态类型颜色
  Color _getPostTypeColor(PostType type) {
    switch (type) {
      case PostType.experience:
        return Colors.blue;
      case PostType.interview:
        return Colors.orange;
      case PostType.offer:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  /// 获取动态类型标签
  String _getPostTypeLabel(PostType type) {
    switch (type) {
      case PostType.experience:
        return '求职经验';
      case PostType.interview:
        return '面试分享';
      case PostType.offer:
        return 'Offer庆祝';
      default:
        return '日常动态';
    }
  }

  /// 格式化动态时间
  String _formatPostTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}分钟前';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}小时前';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}天前';
    } else {
      return '${time.month}月${time.day}日';
    }
  }
}
