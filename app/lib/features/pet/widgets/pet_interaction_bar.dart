import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pet_provider.dart';
import '../services/pet_interaction_service.dart';

/// 侧边互动栏组件
/// 提供喂食、玩耍两个互动按钮，支持展开/收起
class PetInteractionBar extends StatefulWidget {
  const PetInteractionBar({super.key});

  @override
  State<PetInteractionBar> createState() => _PetInteractionBarState();
}

class _PetInteractionBarState extends State<PetInteractionBar>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = true;
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.reverse();
      } else {
        _animationController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PetProvider>(
      builder: (context, petProvider, child) {
        final pet = petProvider.pet;
        if (pet == null) {
          return const SizedBox.shrink();
        }

        // 获取各互动的冷却信息
        final feedCooldown = petProvider.getCooldown('feed');
        final playCooldown = petProvider.getCooldown('play');

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 展开/收起按钮
            _buildToggleButton(),
            const SizedBox(height: 8),
            // 互动按钮区域
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _isExpanded
                  ? Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 喂食按钮
                          _InteractionButton(
                            icon: Icons.restaurant_rounded,
                            label: '喂食',
                            isReady: feedCooldown.isReady,
                            remainingTime: feedCooldown.remainingTime,
                            activeColor: const Color(0xFFFF9500),
                            onTap: feedCooldown.isReady
                                ? () => _handleInteraction(context, petProvider, 'feed')
                                : null,
                          ),
                          const SizedBox(height: 16),
                          // 玩耍按钮
                          _InteractionButton(
                            icon: Icons.sports_esports_rounded,
                            label: '玩耍',
                            isReady: playCooldown.isReady,
                            remainingTime: playCooldown.remainingTime,
                            activeColor: const Color(0xFF34C759),
                            onTap: playCooldown.isReady
                                ? () => _handleInteraction(context, petProvider, 'play')
                                : null,
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        );
      },
    );
  }

  /// 构建展开/收起按钮
  Widget _buildToggleButton() {
    return GestureDetector(
      onTap: _toggleExpand,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: RotationTransition(
          turns: _rotationAnimation,
          child: Icon(
            Icons.expand_more_rounded,
            color: Colors.white.withValues(alpha: 0.8),
            size: 22,
          ),
        ),
      ),
    );
  }

  /// 处理互动
  Future<void> _handleInteraction(
    BuildContext context,
    PetProvider petProvider,
    String interactionType,
  ) async {
    // 显示加载提示
    _showLoadingSnackBar(context, _getActionName(interactionType));

    InteractionResult? result;

    try {
      switch (interactionType) {
        case 'feed':
          result = await petProvider.feed();
          break;
        case 'play':
          result = await petProvider.play();
          break;
      }

      // 隐藏加载提示
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (result != null && context.mounted) {
        // 显示互动反馈
        _showInteractionFeedback(context, result, interactionType);
      }
    } catch (e) {
      // 隐藏加载提示
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (context.mounted) {
        _showErrorSnackBar(context, e.toString());
      }
    }
  }

  /// 获取动作中文名
  String _getActionName(String type) {
    switch (type) {
      case 'feed':
        return '喂食';
      case 'play':
        return '玩耍';
      default:
        return '互动';
    }
  }

  /// 显示加载提示
  void _showLoadingSnackBar(BuildContext context, String actionName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Text('正在$actionName...'),
          ],
        ),
        duration: const Duration(seconds: 10),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// 显示互动反馈
  void _showInteractionFeedback(
    BuildContext context,
    InteractionResult result,
    String interactionType,
  ) {
    final messages = <String>[];
    final actionName = _getActionName(interactionType);

    messages.add('$actionName成功！');

    if (result.emotionMessage != null && result.emotionMessage!.isNotEmpty) {
      messages.add(result.emotionMessage!);
    }

    if (result.levelUp) {
      messages.add('🎉 羁绊升级！达到 ${result.levelUpTitle} 等级！');
    }

    // 显示成功动画和提示
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 成功图标
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green.shade600,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              // 消息内容
              ...messages.map((msg) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      msg,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: msg.contains('升级') ? FontWeight.bold : FontWeight.normal,
                        color: msg.contains('升级') ? Colors.orange.shade700 : Colors.black87,
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );

    // 2秒后自动关闭弹窗
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    });
  }

  /// 显示错误提示
  void _showErrorSnackBar(BuildContext context, String error) {
    String message = error;
    if (error.contains('冷却中')) {
      message = '该互动正在冷却中，请稍后再试~';
    } else if (error.contains('database')) {
      message = '数据保存失败，请重试';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

/// 互动按钮组件（带触摸反馈效果）
class _InteractionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isReady;
  final Duration remainingTime;
  final VoidCallback? onTap;
  final Color activeColor;

  const _InteractionButton({
    required this.icon,
    required this.label,
    this.isReady = true,
    this.remainingTime = Duration.zero,
    this.onTap,
    required this.activeColor,
  });

  @override
  State<_InteractionButton> createState() => _InteractionButtonState();
}

class _InteractionButtonState extends State<_InteractionButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
    
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    
    if (widget.isReady) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_InteractionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isReady != oldWidget.isReady) {
      if (widget.isReady) {
        _glowController.repeat(reverse: true);
      } else {
        _glowController.stop();
      }
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _scaleController.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    _scaleController.reverse();
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}';
    }
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isReady ? _onTapDown : null,
      onTapUp: widget.isReady ? _onTapUp : null,
      onTapCancel: widget.isReady ? _onTapCancel : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: widget.isReady
                      ? widget.activeColor.withValues(alpha: 0.8)
                      : Colors.grey.withValues(alpha: 0.4),
                  width: 2,
                ),
                boxShadow: widget.isReady
                    ? [
                        BoxShadow(
                          color: widget.activeColor.withValues(alpha: _glowAnimation.value),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      widget.icon,
                      size: 26,
                      color: widget.isReady
                          ? widget.activeColor
                          : Colors.grey.withValues(alpha: 0.5),
                    ),
                  ),
                  if (!widget.isReady)
                    Positioned(
                      bottom: 4,
                      left: 0,
                      right: 0,
                      child: Text(
                        _formatDuration(widget.remainingTime),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.withValues(alpha: 0.7),
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}