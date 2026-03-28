import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════════════════
/// 公园访问权限类型
/// 定义用户访问公园的不同权限级别
// ═══════════════════════════════════════════════════════════════════════════════
enum ParkAccessLevel {
  /// 无权限 - 未解锁公园
  none,
  
  /// 访客模式 - Pro用户但未上岸，可浏览但不可互动
  visitor,
  
  /// 完全权限 - 已上岸用户，可浏览和互动
  full,
}

// ═══════════════════════════════════════════════════════════════════════════════
/// 公园访问权限服务
/// 负责检查用户的公园访问权限
// ═══════════════════════════════════════════════════════════════════════════════
class ParkAccessService {
  // ────────────────────────────────────────────────────────────────────────────
  // 公开方法
  // ────────────────────────────────────────────────────────────────────────────

  /// 检查公园访问权限
  /// 
  /// [isParkUnlocked] 公园是否已解锁
  /// [isPro] 是否为Pro用户
  /// [hasLanded] 是否已上岸
  /// 
  /// 返回访问权限级别
  static ParkAccessLevel checkAccess({
    required bool isParkUnlocked,
    required bool isPro,
    required bool hasLanded,
  }) {
    // 如果公园已解锁，拥有完全权限
    if (isParkUnlocked || hasLanded) {
      return ParkAccessLevel.full;
    }
    
    // 如果是Pro用户但未上岸，可以访客模式访问
    if (isPro) {
      return ParkAccessLevel.visitor;
    }
    
    // 否则无权限
    return ParkAccessLevel.none;
  }

  /// 检查是否可以互动
  /// 
  /// [accessLevel] 访问权限级别
  static bool canInteract(ParkAccessLevel accessLevel) {
    return accessLevel == ParkAccessLevel.full;
  }

  /// 检查是否可以浏览
  /// 
  /// [accessLevel] 访问权限级别
  static bool canBrowse(ParkAccessLevel accessLevel) {
    return accessLevel != ParkAccessLevel.none;
  }

  /// 获取权限提示文本
  /// 
  /// [accessLevel] 访问权限级别
  static String getAccessHint(ParkAccessLevel accessLevel) {
    switch (accessLevel) {
      case ParkAccessLevel.none:
        return '需要获得Offer或升级Pro才能进入公园';
      case ParkAccessLevel.visitor:
        return '访客模式：可浏览公园内容，升级Pro后可互动';
      case ParkAccessLevel.full:
        return '欢迎来到公园！';
    }
  }

  /// 获取权限解锁说明
  /// 
  /// [accessLevel] 访问权限级别
  static String getUnlockDescription(ParkAccessLevel accessLevel) {
    switch (accessLevel) {
      case ParkAccessLevel.none:
        return '获得Offer后自动解锁公园，或升级Pro会员以访客身份进入';
      case ParkAccessLevel.visitor:
        return '获得Offer后即可解锁完整公园功能，与其他上岸小伙伴互动';
      case ParkAccessLevel.full:
        return '你已拥有公园完整权限';
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
/// 访客模式横幅组件
/// 在公园页面顶部显示访客模式提示
// ═══════════════════════════════════════════════════════════════════════════════
class VisitorModeBanner extends StatelessWidget {
  /// 升级Pro回调
  final VoidCallback? onUpgradePro;
  
  /// 关闭回调
  final VoidCallback? onClose;

  const VisitorModeBanner({
    super.key,
    this.onUpgradePro,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.shade100,
            Colors.orange.shade100,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          // 图标
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.amber.shade200,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('👀', style: TextStyle(fontSize: 20)),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // 文字说明
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '访客模式',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '可浏览公园内容，获得Offer后可互动',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          
          // 升级按钮
          if (onUpgradePro != null)
            TextButton(
              onPressed: onUpgradePro,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: const Text('升级Pro'),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
/// 访客模式锁定遮罩
/// 覆盖在互动功能上，提示用户升级
// ═══════════════════════════════════════════════════════════════════════════════
class VisitorLockOverlay extends StatelessWidget {
  /// 功能名称
  final String featureName;
  
  /// 升级Pro回调
  final VoidCallback? onUpgradePro;
  
  /// 获得Offer回调
  final VoidCallback? onGetOffer;

  const VisitorLockOverlay({
    super.key,
    required this.featureName,
    this.onUpgradePro,
    this.onGetOffer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 锁定图标
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('🔒', style: TextStyle(fontSize: 28)),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 提示文本
              Text(
                '访客模式下无法使用$featureName',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              Text(
                '获得Offer后即可解锁完整功能',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 20),
              
              // 操作按钮
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onGetOffer != null)
                    OutlinedButton(
                      onPressed: onGetOffer,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                      ),
                      child: const Text('去求职'),
                    ),
                  
                  if (onGetOffer != null && onUpgradePro != null)
                    const SizedBox(width: 12),
                  
                  if (onUpgradePro != null)
                    ElevatedButton(
                      onPressed: onUpgradePro,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('升级Pro'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
/// 访客模式提示对话框
/// 当访客尝试使用互动功能时显示
// ═══════════════════════════════════════════════════════════════════════════════
class VisitorModeDialog extends StatelessWidget {
  /// 功能名称
  final String featureName;
  
  /// 升级Pro回调
  final VoidCallback? onUpgradePro;

  const VisitorModeDialog({
    super.key,
    required this.featureName,
    this.onUpgradePro,
  });

  /// 显示对话框
  static Future<void> show(
    BuildContext context, {
    required String featureName,
    VoidCallback? onUpgradePro,
  }) {
    return showDialog(
      context: context,
      builder: (context) => VisitorModeDialog(
        featureName: featureName,
        onUpgradePro: onUpgradePro,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('👀', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(width: 8),
          const Text('访客模式'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '访客模式下无法使用「$featureName」功能',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('✅ ', style: TextStyle(fontSize: 12)),
                    Expanded(
                      child: Text(
                        '浏览公园动态',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Text('✅ ', style: TextStyle(fontSize: 12)),
                    Expanded(
                      child: Text(
                        '查看用户资料',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '🔒 ',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '互动功能需获得Offer',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('知道了'),
        ),
        if (onUpgradePro != null)
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onUpgradePro?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
            ),
            child: const Text('升级Pro'),
          ),
      ],
    );
  }
}
