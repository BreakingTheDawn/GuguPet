import 'package:flutter/material.dart';
import '../data/models/models.dart';

// ═══════════════════════════════════════════════════════════════════════════════
/// 用户资料弹窗组件
/// 展示用户的详细资料信息
// ═══════════════════════════════════════════════════════════════════════════════
class UserProfileSheet extends StatelessWidget {
  // ────────────────────────────────────────────────────────────────────────────
  // 属性定义
  // ────────────────────────────────────────────────────────────────────────────

  /// 用户数据
  final ParkUser user;
  
  /// 是否已是好友
  final bool isFriend;
  
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
    VoidCallback? onInteract,
    VoidCallback? onAddFriend,
    VoidCallback? onViewPosts,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        builder: (context, scrollController) => UserProfileSheet(
          user: user,
          isFriend: isFriend,
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
            
            const SizedBox(height: 24),
            
            // 操作按钮
            _buildActionButtons(),
            
            const SizedBox(height: 24),
            
            // 用户简介区域（预留）
            Expanded(
              child: _buildUserInfoSection(),
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

  /// 构建用户信息区域
  Widget _buildUserInfoSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 简介
          const Text(
            '简介',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            '这是一位正在求职的小伙伴，正在使用职宠小窝APP陪伴求职之旅。',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 统计信息（预留）
          const Text(
            '动态统计',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              _buildStatItem('动态', '0'),
              const SizedBox(width: 24),
              _buildStatItem('好友', '0'),
              const SizedBox(width: 24),
              _buildStatItem('互动', '0'),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // 最近活跃
          const Text(
            '最近活跃',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            user.lastActiveAt != null
                ? _formatLastActive(user.lastActiveAt!)
                : '刚刚在线',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建统计项
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  /// 格式化最后活跃时间
  String _formatLastActive(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    
    if (diff.inMinutes < 5) {
      return '刚刚在线';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}分钟前在线';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}小时前在线';
    } else {
      return '${diff.inDays}天前在线';
    }
  }
}
