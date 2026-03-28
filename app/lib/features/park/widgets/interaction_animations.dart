import 'dart:math';
import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════════════════
/// 互动动画组件集合
/// 包含：爱心粒子动画、波浪动画、礼物盒动画
// ═══════════════════════════════════════════════════════════════════════════════

// ────────────────────────────────────────────────────────────────────────────────
/// 爱心粒子动画（抚摸宠物）
/// 显示多个爱心粒子从中心向外扩散
// ────────────────────────────────────────────────────────────────────────────────
class HeartParticleAnimation extends StatefulWidget {
  /// 动画位置
  final Offset position;
  
  /// 动画完成回调
  final VoidCallback? onComplete;

  const HeartParticleAnimation({
    super.key,
    required this.position,
    this.onComplete,
  });

  @override
  State<HeartParticleAnimation> createState() => _HeartParticleAnimationState();
}

class _HeartParticleAnimationState extends State<HeartParticleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _particles = _generateParticles();
    
    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  /// 生成粒子
  List<_Particle> _generateParticles() {
    final random = Random();
    return List.generate(8, (index) {
      final angle = (index * 45) * pi / 180;
      return _Particle(
        angle: angle,
        speed: 30 + random.nextDouble() * 20,
        size: 12 + random.nextDouble() * 8,
        delay: index * 0.05,
      );
    });
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
        return CustomPaint(
          painter: _HeartParticlePainter(
            particles: _particles,
            progress: _controller.value,
          ),
          size: const Size(120, 120),
        );
      },
    );
  }
}

/// 爱心粒子绘制器
class _HeartParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _HeartParticlePainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (final particle in particles) {
      // 计算粒子进度（考虑延迟）
      final particleProgress = (progress - particle.delay).clamp(0.0, 1.0);
      if (particleProgress <= 0) continue;

      // 计算位置
      final distance = particle.speed * particleProgress * 2;
      final x = center.dx + cos(particle.angle) * distance;
      final y = center.dy + sin(particle.angle) * distance - particleProgress * 20;

      // 计算透明度（渐隐效果）
      final opacity = 1.0 - particleProgress;

      // 绘制爱心
      _drawHeart(
        canvas,
        Offset(x, y),
        particle.size * (1 + particleProgress * 0.3),
        Color.lerp(
          const Color(0xFFFF6B6B),
          const Color(0xFFFF8E8E),
          particleProgress,
        )!.withValues(alpha: opacity),
      );
    }
  }

  /// 绘制爱心形状
  void _drawHeart(Canvas canvas, Offset center, double size, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final halfSize = size / 2;

    path.moveTo(center.dx, center.dy - halfSize * 0.3);
    
    // 左半边
    path.cubicTo(
      center.dx - halfSize, center.dy - halfSize,
      center.dx - halfSize, center.dy + halfSize * 0.3,
      center.dx, center.dy + halfSize,
    );
    
    // 右半边
    path.cubicTo(
      center.dx + halfSize, center.dy + halfSize * 0.3,
      center.dx + halfSize, center.dy - halfSize,
      center.dx, center.dy - halfSize * 0.3,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HeartParticlePainter oldDelegate) {
    return progress != oldDelegate.progress;
  }
}

// ────────────────────────────────────────────────────────────────────────────────
/// 波浪动画（打招呼）
/// 显示波浪形状的动画效果
// ────────────────────────────────────────────────────────────────────────────────
class WaveAnimation extends StatefulWidget {
  /// 动画位置
  final Offset position;
  
  /// 动画完成回调
  final VoidCallback? onComplete;

  const WaveAnimation({
    super.key,
    required this.position,
    this.onComplete,
  });

  @override
  State<WaveAnimation> createState() => _WaveAnimationState();
}

class _WaveAnimationState extends State<WaveAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
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
        return CustomPaint(
          painter: _WavePainter(progress: _controller.value),
          size: const Size(100, 60),
        );
      },
    );
  }
}

/// 波浪绘制器
class _WavePainter extends CustomPainter {
  final double progress;

  _WavePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4FC3F7).withValues(alpha: 1 - progress * 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final waveWidth = size.width * 0.8;
    final startX = size.width * 0.1;
    final centerY = size.height / 2;

    // 绘制三条波浪线
    for (var wave = 0; wave < 3; wave++) {
      final waveProgress = (progress - wave * 0.1).clamp(0.0, 1.0);
      if (waveProgress <= 0) continue;

      final opacity = 1 - waveProgress;
      paint.color = Color.lerp(
        const Color(0xFF4FC3F7),
        const Color(0xFF81D4FA),
        waveProgress,
      )!.withValues(alpha: opacity);

      path.reset();
      
      final amplitude = 10 * (1 - waveProgress * 0.5);
      final frequency = 2 + wave;
      
      for (var x = 0; x <= waveWidth; x++) {
        final y = centerY +
            sin((x / waveWidth * frequency * pi * 2) + waveProgress * pi * 2) * amplitude;
        
        if (x == 0) {
          path.moveTo(startX + x, y);
        } else {
          path.lineTo(startX + x, y);
        }
      }

      canvas.drawPath(path, paint);
    }

    // 绘制手形图标
    _drawHand(canvas, size, progress);
  }

  /// 绘制挥手的手形
  void _drawHand(Canvas canvas, Size size, double progress) {
    final paint = Paint()
      ..color = const Color(0xFFFFB74D)
      ..style = PaintingStyle.fill;

    final handCenter = Offset(
      size.width * 0.5 + sin(progress * pi * 4) * 10,
      size.height * 0.5 - progress * 20,
    );

    final handSize = 20.0 * (1 - progress * 0.3);
    
    // 简化的手掌形状
    canvas.drawCircle(handCenter, handSize, paint);
    
    // 手指
    for (var i = 0; i < 5; i++) {
      final fingerAngle = -pi / 2 + (i - 2) * pi / 8;
      final fingerX = handCenter.dx + cos(fingerAngle) * handSize * 1.5;
      final fingerY = handCenter.dy + sin(fingerAngle) * handSize * 1.5;
      
      canvas.drawCircle(
        Offset(fingerX, fingerY),
        handSize * 0.3,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return progress != oldDelegate.progress;
  }
}

// ────────────────────────────────────────────────────────────────────────────────
/// 礼物盒动画（送礼）
/// 显示礼物盒打开的动画效果
// ────────────────────────────────────────────────────────────────────────────────
class GiftBoxAnimation extends StatefulWidget {
  /// 动画位置
  final Offset position;
  
  /// 礼物类型
  final String giftType;
  
  /// 动画完成回调
  final VoidCallback? onComplete;

  const GiftBoxAnimation({
    super.key,
    required this.position,
    this.giftType = 'default',
    this.onComplete,
  });

  @override
  State<GiftBoxAnimation> createState() => _GiftBoxAnimationState();
}

class _GiftBoxAnimationState extends State<GiftBoxAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _rotateAnimation = Tween<double>(begin: 0, end: 0.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );

    _bounceAnimation = Tween<double>(begin: 1.2, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );
    
    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
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
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotateAnimation.value,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 礼物盒
                _buildGiftBox(),
                
                // 星星粒子
                if (_controller.value > 0.3)
                  ..._buildStarParticles(),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 构建礼物盒
  Widget _buildGiftBox() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: _getGiftColor(),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: _getGiftColor().withValues(alpha: 0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          // 丝带
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 8,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 8,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ),
          // 蝴蝶结
          Positioned(
            top: -10,
            left: 0,
            right: 0,
            child: Center(
              child: _buildBow(),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建蝴蝶结
  Widget _buildBow() {
    return SizedBox(
      width: 30,
      height: 20,
      child: CustomPaint(
        painter: _BowPainter(),
      ),
    );
  }

  /// 获取礼物颜色
  Color _getGiftColor() {
    switch (widget.giftType) {
      case 'premium':
        return const Color(0xFFFFD700);
      case 'special':
        return const Color(0xFFE91E63);
      default:
        return const Color(0xFF4CAF50);
    }
  }

  /// 构建星星粒子
  List<Widget> _buildStarParticles() {
    final particles = <Widget>[];
    final random = Random();
    
    for (var i = 0; i < 6; i++) {
      final angle = (i * 60) * pi / 180;
      final distance = 40 + _bounceAnimation.value * 30;
      final x = cos(angle) * distance;
      final y = sin(angle) * distance;
      
      particles.add(
        Positioned(
          left: 30 + x,
          top: 30 + y,
          child: Opacity(
            // 使用clamp确保opacity在有效范围[0.0, 1.0]内
            // _bounceAnimation从1.2开始，所以1 - 1.2 = -0.2会超出范围
            opacity: (1 - _bounceAnimation.value).clamp(0.0, 1.0),
            child: Text(
              ['⭐', '✨', '🌟', '💫', '✨', '⭐'][i],
              style: TextStyle(
                fontSize: 16 + random.nextDouble() * 8,
              ),
            ),
          ),
        ),
      );
    }
    
    return particles;
  }
}

/// 蝴蝶结绘制器
class _BowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    // 左边蝴蝶结
    final leftPath = Path();
    leftPath.moveTo(size.width / 2, size.height / 2);
    leftPath.cubicTo(
      size.width / 4, size.height / 4,
      0, size.height / 4,
      0, size.height / 2,
    );
    leftPath.cubicTo(
      0, size.height * 0.75,
      size.width / 4, size.height * 0.75,
      size.width / 2, size.height / 2,
    );
    canvas.drawPath(leftPath, paint);

    // 右边蝴蝶结
    final rightPath = Path();
    rightPath.moveTo(size.width / 2, size.height / 2);
    rightPath.cubicTo(
      size.width * 0.75, size.height / 4,
      size.width, size.height / 4,
      size.width, size.height / 2,
    );
    rightPath.cubicTo(
      size.width, size.height * 0.75,
      size.width * 0.75, size.height * 0.75,
      size.width / 2, size.height / 2,
    );
    canvas.drawPath(rightPath, paint);

    // 中心结
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      4,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ────────────────────────────────────────────────────────────────────────────────
/// 粒子数据类
// ────────────────────────────────────────────────────────────────────────────────
class _Particle {
  final double angle;
  final double speed;
  final double size;
  final double delay;

  _Particle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.delay,
  });
}

// ────────────────────────────────────────────────────────────────────────────────
/// 互动动画管理器
/// 用于统一管理动画的显示和隐藏
// ────────────────────────────────────────────────────────────────────────────────
class InteractionAnimationManager {
  static final InteractionAnimationManager _instance = 
      InteractionAnimationManager._internal();
  factory InteractionAnimationManager() => _instance;
  InteractionAnimationManager._internal();

  /// 显示互动动画
  /// [context] BuildContext
  /// [type] 动画类型：'pet', 'greet', 'gift'
  /// [position] 动画位置
  /// [giftType] 礼物类型（仅当type为'gift'时有效）
  static OverlayEntry? showAnimation({
    required BuildContext context,
    required String type,
    required Offset position,
    String giftType = 'default',
  }) {
    final overlay = Overlay.of(context);
    
    late Widget animation;
    switch (type) {
      case 'pet':
        animation = HeartParticleAnimation(position: position);
        break;
      case 'greet':
        animation = WaveAnimation(position: position);
        break;
      case 'gift':
        animation = GiftBoxAnimation(position: position, giftType: giftType);
        break;
      default:
        return null;
    }

    OverlayEntry? entry;
    entry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx - 60,
        top: position.dy - 60,
        child: Material(
          color: Colors.transparent,
          child: animation,
        ),
      ),
    );

    overlay.insert(entry);

    // 动画结束后移除
    Future.delayed(const Duration(milliseconds: 1600), () {
      entry?.remove();
    });

    return entry;
  }
}
