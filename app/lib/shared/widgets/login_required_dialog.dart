import 'package:flutter/material.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import 'package:provider/provider.dart';

/// 登录提醒弹窗
/// 当用户尝试访问需要登录的功能时弹出
class LoginRequiredDialog extends StatelessWidget {
  /// 功能名称（用于提示文案）
  final String? featureName;
  
  const LoginRequiredDialog({
    super.key,
    this.featureName,
  });
  
  /// 显示登录提醒弹窗
  /// [context] 上下文
  /// [featureName] 功能名称（可选）
  static Future<bool?> show(BuildContext context, {String? featureName}) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => LoginRequiredDialog(featureName: featureName),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(
            Icons.lock_outline,
            color: theme.colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          const Text('需要登录'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            featureName != null
                ? '使用「$featureName」功能需要先登录账号'
                : '该功能需要登录后才能使用',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '登录后即可享受完整功能体验',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            '稍后再说',
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(true);
            _navigateToLogin(context);
          },
          child: const Text('去登录'),
        ),
      ],
    );
  }
  
  /// 跳转到登录页面
  void _navigateToLogin(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.login);
  }
}

/// 登录守卫工具类
/// 提供便捷的登录检查方法
class LoginGuard {
  /// 检查登录状态并执行操作
  /// [context] 上下文
  /// [featureName] 功能名称
  /// [onAuthenticated] 登录后要执行的操作
  static Future<void> check(
    BuildContext context, {
    String? featureName,
    required VoidCallback onAuthenticated,
  }) async {
    final authProvider = context.read<AuthProvider>();
    
    if (authProvider.isAuthenticated) {
      onAuthenticated();
      return;
    }
    
    final shouldLogin = await LoginRequiredDialog.show(
      context,
      featureName: featureName,
    );
    
    if (shouldLogin == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (authProvider.isAuthenticated) {
          onAuthenticated();
        }
      });
    }
  }
  
  /// 简单的登录状态检查
  /// 返回是否已登录，未登录时弹出提示
  static Future<bool> checkSimple(
    BuildContext context, {
    String? featureName,
  }) async {
    final authProvider = context.read<AuthProvider>();
    
    if (authProvider.isAuthenticated) {
      return true;
    }
    
    await LoginRequiredDialog.show(context, featureName: featureName);
    return false;
  }
}
