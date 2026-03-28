import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'dart:async';
import 'dart:math';
import '../../core/constants/app_constants.dart';

/// 宠物动画配置数据类
class PetAnimationConfig {
  final String spritesheetPath;
  final int frames;
  final int frameWidth;
  final int frameHeight;
  final int columns;
  final int rows;
  final int fps;
  final bool loop;
  final int variants; // 动画变体数量（用于idle动画随机选择）
  final int framesPerVariant; // 每个变体的帧数

  const PetAnimationConfig({
    required this.spritesheetPath,
    required this.frames,
    required this.frameWidth,
    required this.frameHeight,
    required this.columns,
    required this.rows,
    required this.fps,
    this.loop = true,
    this.variants = 1,
    this.framesPerVariant = 0,
  });

  /// 获取每帧的时间间隔（毫秒）
  int get frameDuration => (1000 / fps).round();
}

/// 宠物动画类型枚举
enum PetAnimationType {
  idle,
  happy,
  teasing,
  angry,
  move,
}

/// 宠物动画组件 - 使用 CustomPainter 渲染 spritesheet 动画
class PetAnimationWidget extends StatefulWidget {
  final PetAnimationType animationType;
  final double size;
  final VoidCallback? onAnimationComplete;

  const PetAnimationWidget({
    super.key,
    required this.animationType,
    this.size = 210,
    this.onAnimationComplete,
  });

  @override
  State<PetAnimationWidget> createState() => _PetAnimationWidgetState();
}

class _PetAnimationWidgetState extends State<PetAnimationWidget>
    with SingleTickerProviderStateMixin {
  /// 预定义的动画配置
  static const Map<PetAnimationType, PetAnimationConfig> _animationConfigs = {
    PetAnimationType.idle: PetAnimationConfig(
      spritesheetPath: AssetPaths.petIdleSpritesheet,
      frames: 36,
      frameWidth: 256,
      frameHeight: 256,
      columns: 36,
      rows: 3,
      fps: 12,
      loop: true,
      variants: 3,
      framesPerVariant: 36,
    ),
    PetAnimationType.happy: PetAnimationConfig(
      spritesheetPath: AssetPaths.petHappySpritesheet,
      frames: 24,
      frameWidth: 256,
      frameHeight: 256,
      columns: 24,
      rows: 1,
      fps: 12,
      loop: true,
    ),
    PetAnimationType.teasing: PetAnimationConfig(
      spritesheetPath: AssetPaths.petTeasingSpritesheet,
      frames: 36,
      frameWidth: 256,
      frameHeight: 256,
      columns: 36,
      rows: 1,
      fps: 12,
      loop: false,
    ),
    PetAnimationType.angry: PetAnimationConfig(
      spritesheetPath: AssetPaths.petAngrySpritesheet,
      frames: 36,
      frameWidth: 256,
      frameHeight: 256,
      columns: 36,
      rows: 1,
      fps: 12,
      loop: false,
    ),
    PetAnimationType.move: PetAnimationConfig(
      spritesheetPath: AssetPaths.petMoveSpritesheet,
      frames: 46,
      frameWidth: 256,
      frameHeight: 256,
      columns: 46,
      rows: 1,
      fps: 8,
      loop: false,
    ),
  };

  /// 预加载的图片缓存
  static final Map<PetAnimationType, ui.Image> _imageCache = {};
  
  ui.Image? _spritesheetImage;
  bool _isLoading = true;
  String? _error;
  
  int _currentFrame = 0;
  
  /// 动画计时器
  Timer? _animationTimer;
  
  /// 当前动画类型（用于检测变化）
  PetAnimationType? _currentAnimationType;
  
  /// 当前idle动画变体索引（0-2，对应三行）
  int _currentIdleVariant = 0;
  
  /// 随机数生成器
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _currentAnimationType = widget.animationType;
    _loadSpritesheet();
  }

  @override
  void didUpdateWidget(PetAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animationType != widget.animationType) {
      _animationTimer?.cancel();
      _animationTimer = null;
      
      _currentAnimationType = widget.animationType;
      _currentFrame = 0;
      _loadSpritesheet();
    }
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }

  /// 加载 spritesheet 图片（优先使用缓存）
  Future<void> _loadSpritesheet() async {
    if (_imageCache.containsKey(widget.animationType)) {
      _spritesheetImage = _imageCache[widget.animationType];
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _startAnimation();
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final config = _animationConfigs[widget.animationType]!;
      final ByteData data = await rootBundle.load(config.spritesheetPath);
      final Uint8List bytes = data.buffer.asUint8List();
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image image = frameInfo.image;
      
      _imageCache[widget.animationType] = image;
      
      if (mounted && _currentAnimationType == widget.animationType) {
        setState(() {
          _spritesheetImage = image;
          _isLoading = false;
        });
        _startAnimation();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  /// 开始动画循环
  void _startAnimation() {
    final config = _animationConfigs[widget.animationType]!;
    
    // 如果是idle动画且有多个变体，随机选择一个
    if (widget.animationType == PetAnimationType.idle && config.variants > 1) {
      _currentIdleVariant = _random.nextInt(config.variants);
    }
    
    _animationTimer?.cancel();
    
    _animationTimer = Timer.periodic(
      Duration(milliseconds: config.frameDuration),
      (timer) {
        if (!mounted || _currentAnimationType != widget.animationType) {
          timer.cancel();
          return;
        }
        
        setState(() {
          _currentFrame++;
          // 对于有变体的动画，帧数是每个变体的帧数
          final effectiveFrames = config.framesPerVariant > 0 
              ? config.framesPerVariant 
              : config.frames;
          
          if (_currentFrame >= effectiveFrames) {
            if (config.loop) {
              _currentFrame = 0;
              // idle动画循环完成后，随机选择新的变体
              if (widget.animationType == PetAnimationType.idle && config.variants > 1) {
                _currentIdleVariant = _random.nextInt(config.variants);
              }
            } else {
              _currentFrame = effectiveFrames - 1;
              timer.cancel();
              widget.onAnimationComplete?.call();
            }
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (_error != null || _spritesheetImage == null) {
      return _buildErrorWidget();
    }

    final config = _animationConfigs[widget.animationType]!;
    
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _SpritesheetPainter(
          image: _spritesheetImage!,
          config: config,
          currentFrame: _currentFrame,
          variantIndex: _currentIdleVariant,
        ),
      ),
    );
  }

  /// 构建错误占位组件
  Widget _buildErrorWidget() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '🐦',
          style: TextStyle(fontSize: widget.size * 0.3),
        ),
      ),
    );
  }
}

/// Spritesheet 绘制器
class _SpritesheetPainter extends CustomPainter {
  final ui.Image image;
  final PetAnimationConfig config;
  final int currentFrame;
  final int variantIndex; // 动画变体索引（用于多行spritesheet）

  _SpritesheetPainter({
    required this.image,
    required this.config,
    required this.currentFrame,
    this.variantIndex = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 对于有变体的动画，行号由变体索引决定
    // 对于无变体的动画，按原有逻辑计算行号
    final row = config.variants > 1 
        ? variantIndex 
        : currentFrame ~/ config.columns;
    final col = currentFrame % config.columns;
    
    final srcRect = Rect.fromLTWH(
      col * config.frameWidth.toDouble(),
      row * config.frameHeight.toDouble(),
      config.frameWidth.toDouble(),
      config.frameHeight.toDouble(),
    );
    
    final dstRect = Rect.fromLTWH(
      0,
      0,
      size.width,
      size.height,
    );
    
    canvas.drawImageRect(
      image,
      srcRect,
      dstRect,
      Paint()..filterQuality = FilterQuality.medium,
    );
  }

  @override
  bool shouldRepaint(covariant _SpritesheetPainter oldDelegate) {
    return oldDelegate.currentFrame != currentFrame || 
           oldDelegate.variantIndex != variantIndex;
  }
}

/// 宠物随机动画控制器 - 管理移动动画的随机触发
class PetRandomAnimationController extends ChangeNotifier {
  Timer? _randomMoveTimer;
  final Random _random = Random();
  
  PetAnimationType _currentAnimation = PetAnimationType.idle;
  PetAnimationType get currentAnimation => _currentAnimation;
  
  /// 最小触发间隔（秒）
  final int minIntervalSeconds;
  /// 最大触发间隔（秒）
  final int maxIntervalSeconds;
  
  PetRandomAnimationController({
    this.minIntervalSeconds = 5,
    this.maxIntervalSeconds = 15,
  });
  
  /// 开始随机动画调度
  void startRandomAnimation() {
    _scheduleNextMove();
  }
  
  /// 停止随机动画调度
  void stopRandomAnimation() {
    _randomMoveTimer?.cancel();
    _randomMoveTimer = null;
  }
  
  /// 手动触发动画
  void triggerAnimation(PetAnimationType type) {
    _randomMoveTimer?.cancel();
    _currentAnimation = type;
    notifyListeners();
  }
  
  /// 动画播放完成回调
  void onAnimationComplete() {
    if (_currentAnimation != PetAnimationType.idle) {
      _currentAnimation = PetAnimationType.idle;
      notifyListeners();
      _scheduleNextMove();
    }
  }
  
  /// 调度下一次移动动画
  void _scheduleNextMove() {
    final nextDelay = minIntervalSeconds + 
        _random.nextInt(maxIntervalSeconds - minIntervalSeconds + 1);
    
    _randomMoveTimer?.cancel();
    _randomMoveTimer = Timer(Duration(seconds: nextDelay), () {
      _currentAnimation = PetAnimationType.move;
      notifyListeners();
    });
  }
  
  @override
  void dispose() {
    stopRandomAnimation();
    super.dispose();
  }
}
