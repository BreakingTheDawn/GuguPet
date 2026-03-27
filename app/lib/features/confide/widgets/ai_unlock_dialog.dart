import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../routes/app_routes.dart';

/// AI功能解锁弹窗
/// 当用户羁绊等级达标时显示，提示可以接入AI智能对话
class AIUnlockDialog extends StatelessWidget {
  const AIUnlockDialog({super.key});

  /// 显示解锁弹窗
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const AIUnlockDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.indigo500.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.auto_awesome,
              color: AppColors.indigo500,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Text('新功能解锁！'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '咕咕的智能对话功能已解锁！',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '接入AI大模型后，咕咕可以：',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 8),
          _buildFeatureItem('与你进行自然的多轮对话'),
          _buildFeatureItem('记住你们聊过的内容'),
          _buildFeatureItem('更好地理解和回应你的情绪'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.indigo500.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: AppColors.indigo500,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '不接入AI也可以使用简单倾诉功能',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.indigo500,
                    ),
                  ),
                ),
              ],
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
              color: AppColors.mutedForeground,
            ),
          ),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(true);
            _navigateToAISettings(context);
          },
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.indigo500,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('去配置'),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 18,
            color: AppColors.indigo500,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAISettings(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.aiSettings);
  }
}
