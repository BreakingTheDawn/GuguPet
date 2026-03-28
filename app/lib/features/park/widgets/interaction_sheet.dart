import 'package:flutter/material.dart';
import '../data/models/models.dart';
import 'interaction_animations.dart';

// ═══════════════════════════════════════════════════════════════════════════════
/// 互动操作面板组件
/// 底部弹出的互动选项面板
/// 支持抚摸、打招呼、送礼、加好友等操作
// ═══════════════════════════════════════════════════════════════════════════════
class InteractionSheet extends StatelessWidget {
  // ────────────────────────────────────────────────────────────────────────────
  // 属性定义
  // ────────────────────────────────────────────────────────────────────────────

  /// 目标用户
  final ParkUser targetUser;
  
  /// 是否已是好友
  final bool isFriend;
  
  /// 抚摸宠物回调
  final VoidCallback? onPet;
  
  /// 打招呼回调
  final VoidCallback? onGreet;
  
  /// 送礼物回调
  final VoidCallback? onGift;
  
  /// 添加好友回调
  final VoidCallback? onAddFriend;
  
  /// 查看动态回调
  final VoidCallback? onViewPosts;

  // ────────────────────────────────────────────────────────────────────────────
  // 构造函数
  // ────────────────────────────────────────────────────────────────────────────

  const InteractionSheet({
    super.key,
    required this.targetUser,
    this.isFriend = false,
    this.onPet,
    this.onGreet,
    this.onGift,
    this.onAddFriend,
    this.onViewPosts,
  });

  // ────────────────────────────────────────────────────────────────────────────
  // 静态方法 - 显示面板
  // ────────────────────────────────────────────────────────────────────────────

  /// 显示互动面板
  static Future<void> show({
    required BuildContext context,
    required ParkUser targetUser,
    bool isFriend = false,
    VoidCallback? onPet,
    VoidCallback? onGreet,
    VoidCallback? onGift,
    VoidCallback? onAddFriend,
    VoidCallback? onViewPosts,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => InteractionSheet(
        targetUser: targetUser,
        isFriend: isFriend,
        onPet: onPet,
        onGreet: onGreet,
        onGift: onGift,
        onAddFriend: onAddFriend,
        onViewPosts: onViewPosts,
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
          mainAxisSize: MainAxisSize.min,
          children: [
            // 顶部拖动条
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // 用户信息头部
            _buildUserHeader(),
            
            const Divider(height: 1),
            
            // 互动选项列表
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  // 抚摸宠物
                  _buildInteractionOption(
                    context: context,
                    icon: '🐾',
                    title: '抚摸宠物',
                    subtitle: '摸摸${targetUser.name}的宠物',
                    animationType: 'pet',
                    onTap: onPet,
                  ),
                  
                  // 打招呼
                  _buildInteractionOption(
                    context: context,
                    icon: '👋',
                    title: '打个招呼',
                    subtitle: '向${targetUser.name}问好',
                    animationType: 'greet',
                    onTap: onGreet,
                  ),
                  
                  // 送礼物
                  _buildInteractionOption(
                    context: context,
                    icon: '🎁',
                    title: '送份礼物',
                    subtitle: '送给${targetUser.name}一份礼物',
                    animationType: 'gift',
                    onTap: onGift,
                  ),
                  
                  // 添加好友（如果还不是好友）
                  if (!isFriend)
                    _buildInteractionOption(
                      context: context,
                      icon: '❤️',
                      title: '添加好友',
                      subtitle: '和${targetUser.name}成为好友',
                      onTap: onAddFriend,
                    ),
                  
                  // 查看动态
                  _buildInteractionOption(
                    context: context,
                    icon: '📝',
                    title: '查看动态',
                    subtitle: '看看${targetUser.name}的分享',
                    onTap: onViewPosts,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// 构建用户信息头部
  Widget _buildUserHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 宠物头像
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: targetUser.petColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: targetUser.petColor,
                width: 2,
              ),
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
                  targetUser.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (targetUser.title != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    targetUser.title!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // 好友标识
          if (isFriend)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.pink.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite,
                    size: 14,
                    color: Colors.pink.shade400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '好友',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.pink.shade400,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// 构建互动选项
  Widget _buildInteractionOption({
    required BuildContext context,
    required String icon,
    required String title,
    required String subtitle,
    String? animationType,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(icon, style: const TextStyle(fontSize: 20)),
        ),
      ),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: () {
        Navigator.pop(context);
        
        // 播放动画
        if (animationType != null) {
          _playInteractionAnimation(context, animationType);
        }
        
        // 延迟执行回调，让动画先播放
        Future.delayed(const Duration(milliseconds: 300), () {
          onTap?.call();
        });
      },
    );
  }

  /// 播放互动动画
  void _playInteractionAnimation(BuildContext context, String type) {
    try {
      // 获取屏幕中心位置
      final screenSize = MediaQuery.of(context).size;
      final position = Offset(
        screenSize.width / 2,
        screenSize.height / 2,
      );
      
      InteractionAnimationManager.showAnimation(
        context: context,
        type: type,
        position: position,
      );
    } catch (e) {
      debugPrint('播放动画失败: $e');
    }
  }
}
