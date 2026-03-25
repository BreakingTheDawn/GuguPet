import 'package:flutter/material.dart';
import '../data/models/models.dart';

// ═══════════════════════════════════════════════════════════════════════════════
/// 公园用户卡片组件
/// 展示公园内其他用户的卡片信息
/// 点击可触发用户资料弹窗
// ═══════════════════════════════════════════════════════════════════════════════
class ParkUserCard extends StatelessWidget {
  // ────────────────────────────────────────────────────────────────────────────
  // 属性定义
  // ────────────────────────────────────────────────────────────────────────────

  /// 用户数据
  final ParkUser user;
  
  /// 点击回调
  final VoidCallback? onTap;
  
  /// 是否显示在线状态
  final bool showOnlineStatus;

  // ────────────────────────────────────────────────────────────────────────────
  // 构造函数
  // ────────────────────────────────────────────────────────────────────────────

  const ParkUserCard({
    super.key,
    required this.user,
    this.onTap,
    this.showOnlineStatus = true,
  });

  // ────────────────────────────────────────────────────────────────────────────
  // 构建方法
  // ────────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 宠物头像区域
            _buildPetAvatar(),
            
            const SizedBox(height: 8),
            
            // 用户昵称
            Text(
              user.name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            
            // 职位标签
            if (user.title != null) ...[
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  user.title!,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建宠物头像
  Widget _buildPetAvatar() {
    return Stack(
      children: [
        // 宠物圆形头像
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: user.petColor.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: user.petColor,
              width: 2,
            ),
          ),
          child: Center(
            child: _buildPetIcon(),
          ),
        ),
        
        // 在线状态指示器
        if (showOnlineStatus)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),
        
        // 配饰图标
        if (user.petAccessory != 'none')
          Positioned(
            right: 0,
            top: 0,
            child: _buildAccessoryIcon(),
          ),
      ],
    );
  }

  /// 构建宠物图标
  Widget _buildPetIcon() {
    return Text(
      '🐧',
      style: const TextStyle(fontSize: 28),
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
    
    return Container(
      width: 18,
      height: 18,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          accessoryIcon,
          style: const TextStyle(fontSize: 10),
        ),
      ),
    );
  }
}
