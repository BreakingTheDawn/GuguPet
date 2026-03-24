import 'package:flutter/material.dart';
import 'dart:async';

/// 宠物互动按钮组件
/// 支持冷却状态显示
class PetActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isReady;
  final Duration remainingTime;
  final VoidCallback? onTap;
  final Color? activeColor;
  final Color? inactiveColor;

  const PetActionButton({
    super.key,
    required this.icon,
    required this.label,
    this.isReady = true,
    this.remainingTime = Duration.zero,
    this.onTap,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  State<PetActionButton> createState() => _PetActionButtonState();
}

class _PetActionButtonState extends State<PetActionButton> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _remaining = widget.remainingTime;
    _startTimer();
  }

  @override
  void didUpdateWidget(PetActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.remainingTime != widget.remainingTime) {
      _remaining = widget.remainingTime;
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    if (!widget.isReady && _remaining.inSeconds > 0) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remaining.inSeconds <= 0) {
          timer.cancel();
          return;
        }
        setState(() {
          _remaining = _remaining - const Duration(seconds: 1);
        });
      });
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}';
    }
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = widget.activeColor ?? theme.colorScheme.primary;
    final inactiveColor = widget.inactiveColor ?? theme.disabledColor;

    return GestureDetector(
      onTap: widget.isReady ? widget.onTap : null,
      onLongPress: () => _showTooltip(context),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: widget.isReady
              ? activeColor.withValues(alpha: 0.1)
              : inactiveColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.isReady ? activeColor : inactiveColor,
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(
                widget.icon,
                size: 28,
                color: widget.isReady ? activeColor : inactiveColor,
              ),
            ),
            if (!widget.isReady)
              Positioned(
                bottom: 4,
                left: 0,
                right: 0,
                child: Text(
                  _formatDuration(_remaining),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: inactiveColor,
                    fontSize: 10,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showTooltip(BuildContext context) {
    final tooltip = widget.isReady
        ? '${widget.label}\n点击互动'
        : '${widget.label}\n冷却中: ${_formatDuration(_remaining)}';
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tooltip),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        width: 150,
      ),
    );
  }
}
