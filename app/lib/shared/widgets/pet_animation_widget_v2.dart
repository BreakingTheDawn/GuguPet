import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'dart:ui' as ui;
import 'pet_animation_config_service.dart';

/// 宠物动画类型枚举
enum PetAnimationTypeV2 {
  idle,
  happy,
  move,
  angry,
  sad,
  excited,
}

/// 宠物动画组件 V2 - 支持帧范围播放和镜像翻转
class PetAnimationWidgetV2 extends StatefulWidget {
  final PetAnimationTypeV2 animationType;
  final double size;
  final VoidCallback? onAnimationComplete;
  final String? segmentName;
  final bool flipHorizontal;
  final bool autoPlay;
  final String? configPath;

  const PetAnimationWidgetV2({
    super.key,
    required this.animationType,
    this.size = 210,
    this.onAnimationComplete,
    this.segmentName,
    this.flipHorizontal = false,
    this.autoPlay = true,
    this.configPath,
  });

  @override
  State<PetAnimationWidgetV2> createState() => PetAnimationWidgetV2State();
}

class PetAnimationWidgetV2State extends State<PetAnimationWidgetV2> {
  /// 默认配置路径
  static const String _defaultConfigPath = 'assets/animations/pet_animations.json';

  /// 默认配置（当JSON加载失败时使用）
  static const Map<PetAnimationTypeV2, PetAnimationConfig> _defaultConfigs = {
    PetAnimationTypeV2.idle: PetAnimationConfig(
      spritesheetPath: 'assets/images/pet/pet_idle_spritesheet.png',
      frames: 18,
      frameWidth: 256,
      frameHeight: 256,
      columns: 18,
      rows: 1,
      fps: 12,
      loop: true,
      description: '宠物待机动画',
    ),
    PetAnimationTypeV2.happy: PetAnimationConfig(
      spritesheetPath: 'assets/images/pet/pet_happy_spritesheet.png',
      frames: 24,
      frameWidth: 256,
      frameHeight: 256,
      columns: 24,
      rows: 1,
      fps: 12,
      loop: true,
      description: '宠物高兴动画',
    ),
    PetAnimationTypeV2.move: PetAnimationConfig(
      spritesheetPath: 'assets/images/pet/pet_move_spritesheet.png',
      frames: 46,
      frameWidth: 256,
      frameHeight: 256,
      columns: 46,
      rows: 1,
      fps: 8,
      loop: false,
      description: '宠物移动动画',
      segments: {
        'turn_to_side': AnimationSegment(
          name: '转身到侧身',
          startFrame: 0,
          endFrame: 11,
          frameCount: 12,
          loop: false,
        ),
        'walk_to_side': AnimationSegment(
          name: '走到侧边',
          startFrame: 12,
          endFrame: 23,
          frameCount: 12,
          loop: false,
        ),
        'walk_back': AnimationSegment(
          name: '走回来',
          startFrame: 24,
          endFrame: 34,
          frameCount: 11,
          loop: false,
        ),
        'turn_to_front': AnimationSegment(
          name: '转回正身',
          startFrame: 35,
          endFrame: 45,
          frameCount: 11,
          loop: false,
        ),
        'move_to_side': AnimationSegment(
          name: '移动到侧边',
          startFrame: 0,
          endFrame: 23,
          frameCount: 24,
          loop: false,
        ),
        'return_to_center': AnimationSegment(
          name: '返回中心',
          startFrame: 24,
          endFrame: 45,
          frameCount: 22,
          loop: false,
        ),
        'full_cycle': AnimationSegment(
          name: '完整往返循环',
          startFrame: 0,
          endFrame: 45,
          frameCount: 46,
          loop: true,
        ),
      },
    ),
    PetAnimationTypeV2.angry: PetAnimationConfig(
      spritesheetPath: 'assets/images/pet/pet_angry_spritesheet.png',
      frames: 36,
      frameWidth: 256,
      frameHeight: 256,
      columns: 36,
      rows: 1,
      fps: 12,
      loop: true,
      description: '宠物生气动画',
    ),
    PetAnimationTypeV2.sad: PetAnimationConfig(
      spritesheetPath: 'assets/images/pet/pet_sad_spritesheet.png',
      frames: 24,
      frameWidth: 256,
      frameHeight: 256,
      columns: 24,
      rows: 1,
      fps: 10,
      loop: true,
      description: '宠物难过动画',
    ),
    PetAnimationTypeV2.excited: PetAnimationConfig(
      spritesheetPath: 'assets/images/pet/pet_excited_spritesheet.png',
      frames: 30,
      frameWidth: 256,
      frameHeight: 256,
      columns: 30,
      rows: 1,
      fps: 15,
      loop: true,
      description: '宠物兴奋动画',
    ),
  };

  ui.Image? _spritesheetImage;
  bool _isLoading = true;
  String? _error;
  _PetSpriteGameV2? _game;
  PetAnimationConfig? _currentConfig;

  @override
  void initState() {
    super.initState();
    _loadAnimation();
  }

  @override
  void didUpdateWidget(PetAnimationWidgetV2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animationType != widget.animationType ||
        oldWidget.segmentName != widget.segmentName ||
        oldWidget.flipHorizontal != widget.flipHorizontal) {
      _loadAnimation();
    }
  }

  /// 加载动画配置和图片
  Future<void> _loadAnimation() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 尝试从JSON加载配置
      final configPath = widget.configPath ?? _defaultConfigPath;
      PetAnimationConfig? config;

      try {
        final animationsConfig = await PetAnimationConfigService.loadConfig(configPath);
        final animationKey = widget.animationType.name;
        config = animationsConfig.getAnimation(animationKey);
      } catch (e) {
        // JSON加载失败，使用默认配置
        debugPrint('使用默认动画配置: $e');
      }

      // 使用默认配置作为后备
      config ??= _defaultConfigs[widget.animationType]!;
      _currentConfig = config;

      // 加载spritesheet图片
      final ByteData data = await rootBundle.load(config.spritesheetPath);
      final Uint8List bytes = data.buffer.asUint8List();
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image image = frameInfo.image;

      if (mounted) {
        setState(() {
          _spritesheetImage = image;
          _isLoading = false;
        });
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

  /// 播放指定片段
  void playSegment(String segmentName, {bool? flipHorizontal, VoidCallback? onComplete}) {
    _game?.playSegment(segmentName, flipHorizontal: flipHorizontal, onComplete: onComplete);
  }

  /// 停止动画
  void stopAnimation() {
    _game?.stopAnimation();
  }

  /// 暂停动画
  void pauseAnimation() {
    _game?.pauseAnimation();
  }

  /// 恢复动画
  void resumeAnimation() {
    _game?.resumeAnimation();
  }

  /// 获取当前配置
  PetAnimationConfig? get currentConfig => _currentConfig;

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

    if (_error != null || _spritesheetImage == null || _currentConfig == null) {
      return _buildErrorWidget();
    }

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: _PetAnimationGameV2(
        key: ValueKey('${widget.animationType}_${widget.segmentName}_${widget.flipHorizontal}'),
        spritesheetImage: _spritesheetImage!,
        config: _currentConfig!,
        size: widget.size,
        segmentName: widget.segmentName,
        flipHorizontal: widget.flipHorizontal,
        autoPlay: widget.autoPlay,
        onAnimationComplete: widget.onAnimationComplete,
        onGameCreated: (game) {
          _game = game;
        },
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

/// Flame 游戏组件 V2
class _PetAnimationGameV2 extends StatelessWidget {
  final ui.Image spritesheetImage;
  final PetAnimationConfig config;
  final double size;
  final String? segmentName;
  final bool flipHorizontal;
  final bool autoPlay;
  final VoidCallback? onAnimationComplete;
  final void Function(_PetSpriteGameV2 game)? onGameCreated;

  const _PetAnimationGameV2({
    super.key,
    required this.spritesheetImage,
    required this.config,
    required this.size,
    this.segmentName,
    this.flipHorizontal = false,
    this.autoPlay = true,
    this.onAnimationComplete,
    this.onGameCreated,
  });

  @override
  Widget build(BuildContext context) {
    final game = _PetSpriteGameV2(
      spritesheetImage: spritesheetImage,
      config: config,
      displaySize: size,
      segmentName: segmentName,
      flipHorizontal: flipHorizontal,
      autoPlay: autoPlay,
      onAnimationComplete: onAnimationComplete,
    );

    onGameCreated?.call(game);

    return GameWidget(game: game);
  }
}

/// Flame 游戏实例 V2
class _PetSpriteGameV2 extends FlameGame {
  final ui.Image spritesheetImage;
  final PetAnimationConfig config;
  final double displaySize;
  final String? segmentName;
  final bool flipHorizontal;
  final bool autoPlay;
  final VoidCallback? onAnimationComplete;

  late SpriteAnimationComponent _animationComponent;
  late SpriteSheet _spriteSheet;
  AnimationSegment? _currentSegment;
  bool _isPlaying = false;
  double _elapsedTime = 0;
  VoidCallback? _segmentCompleteCallback;

  _PetSpriteGameV2({
    required this.spritesheetImage,
    required this.config,
    required this.displaySize,
    this.segmentName,
    this.flipHorizontal = false,
    this.autoPlay = true,
    this.onAnimationComplete,
  });

  /// 设置透明背景
  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _spriteSheet = SpriteSheet(
      image: spritesheetImage,
      srcSize: Vector2(config.frameWidth.toDouble(), config.frameHeight.toDouble()),
    );

    // 初始化动画组件
    final scale = displaySize / config.frameWidth;

    _animationComponent = SpriteAnimationComponent(
      animation: _createAnimationForSegment(segmentName),
      size: Vector2(config.frameWidth.toDouble(), config.frameHeight.toDouble()),
      scale: Vector2(flipHorizontal ? -scale : scale, scale),
      anchor: Anchor.center,
      position: Vector2(displaySize / 2, displaySize / 2),
    );

    add(_animationComponent);

    if (autoPlay) {
      _isPlaying = true;
    }
  }

  /// 创建指定片段的动画
  SpriteAnimation _createAnimationForSegment(String? segmentName) {
    int startFrame = 0;
    int endFrame = config.frames - 1;
    bool loop = config.loop;

    if (segmentName != null && config.hasSegments) {
      final segment = config.getSegment(segmentName);
      if (segment != null) {
        startFrame = segment.startFrame;
        endFrame = segment.endFrame;
        loop = segment.loop;
        _currentSegment = segment;
      }
    }

    return _spriteSheet.createAnimation(
      row: 0,
      stepTime: config.stepTime,
      from: startFrame,
      to: endFrame + 1,
      loop: loop,
    );
  }

  /// 播放指定片段
  void playSegment(String segmentName, {bool? flipHorizontal, VoidCallback? onComplete}) {
    _segmentCompleteCallback = onComplete;
    _elapsedTime = 0;
    _isPlaying = true;

    final segment = config.getSegment(segmentName);
    if (segment != null) {
      _currentSegment = segment;

      // 更新翻转
      if (flipHorizontal != null) {
        final scale = displaySize / config.frameWidth;
        _animationComponent.scale = Vector2(flipHorizontal ? -scale : scale, scale);
      }

      // 创建新动画
      _animationComponent.animation = _spriteSheet.createAnimation(
        row: 0,
        stepTime: config.stepTime,
        from: segment.startFrame,
        to: segment.endFrame + 1,
        loop: segment.loop,
      );
    }
  }

  /// 停止动画
  void stopAnimation() {
    _isPlaying = false;
  }

  /// 暂停动画
  void pauseAnimation() {
    _isPlaying = false;
    paused = true;
  }

  /// 恢复动画
  void resumeAnimation() {
    _isPlaying = true;
    paused = false;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 检查动画是否完成
    if (_isPlaying && _currentSegment != null && !_currentSegment!.loop) {
      _elapsedTime += dt;
      final totalDuration = _currentSegment!.frameCount * config.stepTime;

      if (_elapsedTime >= totalDuration) {
        _isPlaying = false;
        _segmentCompleteCallback?.call();
        onAnimationComplete?.call();
      }
    }
  }
}

/// 移动动画控制器 - 封装常用的移动动画操作
class MovementAnimationController {
  final PetAnimationWidgetV2State _widgetState;
  final Function(bool) onFlipChanged;

  MovementAnimationController({
    required PetAnimationWidgetV2State widgetState,
    required this.onFlipChanged,
  }) : _widgetState = widgetState;

  /// 向左移动
  void moveToLeft({VoidCallback? onComplete}) {
    onFlipChanged(false);
    _widgetState.playSegment('move_to_side', onComplete: onComplete);
  }

  /// 向右移动
  void moveToRight({VoidCallback? onComplete}) {
    onFlipChanged(true);
    _widgetState.playSegment('move_to_side', flipHorizontal: true, onComplete: onComplete);
  }

  /// 返回中心
  void returnToCenter({bool fromLeft = true, VoidCallback? onComplete}) {
    onFlipChanged(!fromLeft);
    _widgetState.playSegment('return_to_center', flipHorizontal: !fromLeft, onComplete: onComplete);
  }

  /// 播放完整循环
  void playFullCycle({VoidCallback? onComplete}) {
    _widgetState.playSegment('full_cycle', onComplete: onComplete);
  }

  /// 停止
  void stop() {
    _widgetState.stopAnimation();
  }

  /// 暂停
  void pause() {
    _widgetState.pauseAnimation();
  }

  /// 恢复
  void resume() {
    _widgetState.resumeAnimation();
  }
}
