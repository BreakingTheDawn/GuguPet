import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

/// 流式响应气泡组件
/// 支持逐字显示文本效果
class ResponseBubble extends StatefulWidget {
  final String text;
  final Animation<double> animation;
  /// 是否启用流式效果
  final bool enableStreaming;
  /// 流式显示速度（毫秒/字符）
  final int streamingSpeed;

  const ResponseBubble({
    super.key,
    required this.text,
    required this.animation,
    this.enableStreaming = false,
    this.streamingSpeed = 30,
  });

  @override
  State<ResponseBubble> createState() => ResponseBubbleState();
}

/// 暴露State以便外部可以更新文本
class ResponseBubbleState extends State<ResponseBubble> {
  String _displayText = '';
  bool _isStreaming = false;
  
  /// 获取当前显示的文本
  String get displayText => _displayText;
  
  /// 是否正在流式显示
  bool get isStreaming => _isStreaming;

  @override
  void initState() {
    super.initState();
    if (widget.enableStreaming) {
      _displayText = '';
    } else {
      _displayText = widget.text;
    }
  }

  @override
  void didUpdateWidget(ResponseBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 当文本变化时，更新显示
    if (oldWidget.text != widget.text) {
      if (widget.enableStreaming) {
        // 流式模式下，追加新文本
        _appendText(widget.text.substring(_displayText.length));
      } else {
        // 非流式模式，直接更新
        _displayText = widget.text;
      }
    }
  }

  /// 追加文本（用于流式显示）
  void _appendText(String newText) {
    if (newText.isEmpty) return;
    
    setState(() {
      _isStreaming = true;
    });
    
    // 逐字显示
    for (int i = 0; i < newText.length; i++) {
      Future.delayed(Duration(milliseconds: i * widget.streamingSpeed), () {
        if (mounted && _displayText.length < widget.text.length) {
          setState(() {
            _displayText = widget.text.substring(0, _displayText.length + 1);
          });
        }
      });
    }
    
    // 完成后更新状态
    Future.delayed(Duration(milliseconds: newText.length * widget.streamingSpeed + 100), () {
      if (mounted) {
        setState(() {
          _isStreaming = false;
        });
      }
    });
  }

  /// 直接更新文本（用于流式回调）
  void updateText(String text, {bool isDone = false}) {
    if (!mounted) return;
    
    setState(() {
      _displayText = text;
      _isStreaming = !isDone;
    });
  }

  /// 重置文本
  void reset() {
    setState(() {
      _displayText = '';
      _isStreaming = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.85, end: 1.0).animate(
        CurvedAnimation(parent: widget.animation, curve: Curves.elasticOut),
      ),
      child: FadeTransition(
        opacity: widget.animation,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 280),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
            border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 1),
            boxShadow: AppShadows.bubble,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  _displayText,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.confideBubbleText,
                    height: 1.7,
                  ),
                ),
              ),
              // 流式显示时的光标动画
              if (_isStreaming) ...[
                const SizedBox(width: 2),
                _buildCursor(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 构建闪烁光标
  Widget _buildCursor() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Opacity(
          opacity: value < 0.5 ? value * 2 : (1 - value) * 2,
          child: Container(
            width: 2,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.confideBubbleText,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        );
      },
      onEnd: () {
        // 循环动画
        if (_isStreaming && mounted) {
          setState(() {});
        }
      },
    );
  }
}
