import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

/// 公园解锁弹窗
/// 当用户首次获得Offer解锁公园时显示
class ParkUnlockDialog extends StatefulWidget {
  /// 解锁来源
  final String source;
  
  /// 关闭回调
  final VoidCallback? onClose;

  const ParkUnlockDialog({
    super.key,
    this.source = 'offer',
    this.onClose,
  });

  /// 显示解锁弹窗
  static Future<void> show(BuildContext context, {String source = 'offer'}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ParkUnlockDialog(source: source),
    );
  }

  @override
  State<ParkUnlockDialog> createState() => _ParkUnlockDialogState();
}

class _ParkUnlockDialogState extends State<ParkUnlockDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF4CAF50).withValues(alpha: 0.1),
                      const Color(0xFF81C784).withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 庆祝动画
                    _buildCelebrationAnimation(),
                    
                    const SizedBox(height: 16),
                    
                    // 标题
                    Text(
                      '🎉 恭喜解锁！',
                      style: AppTypography.headingSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.foreground,
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // 描述
                    Text(
                      '恭喜你获得Offer！\n彼岸公园已为你开放',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.mutedForeground,
                        height: 1.5,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // 公园图标
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF4CAF50),
                          width: 2,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          '🌲',
                          style: TextStyle(fontSize: 40),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // 功能说明
                    AnimatedBuilder(
                      animation: _slideAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _slideAnimation.value),
                          child: Opacity(
                            opacity: _fadeAnimation.value,
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _buildFeatureItem('🚶', '认识更多上岸的小伙伴'),
                            const SizedBox(height: 8),
                            _buildFeatureItem('💬', '分享你的求职故事'),
                            const SizedBox(height: 8),
                            _buildFeatureItem('🎁', '给求职中的咕咕送祝福'),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // 按钮
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.onClose?.call();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '立即探索',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 构建庆祝动画
  Widget _buildCelebrationAnimation() {
    return SizedBox(
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: List.generate(5, (index) {
          final delay = index * 0.1;
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final progress = (_controller.value - delay).clamp(0.0, 1.0);
              final distance = 30 + progress * 20;
              
              return Positioned(
                left: 40 + distance * (index % 2 == 0 ? 1 : -1),
                top: 30 + distance * (index < 2 ? -1 : 1) * 0.5,
                child: Opacity(
                  opacity: progress,
                  child: Text(
                    ['🎉', '✨', '🌟', '🎊', '💫'][index],
                    style: TextStyle(fontSize: 20 + progress * 10),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  /// 构建功能项
  Widget _buildFeatureItem(String icon, String text) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
        ),
      ],
    );
  }
}
