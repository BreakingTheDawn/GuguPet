import 'dart:convert';
import 'package:flutter/services.dart';

/// 动画片段配置
class AnimationSegment {
  final String name;
  final int startFrame;
  final int endFrame;
  final int frameCount;
  final bool loop;

  const AnimationSegment({
    required this.name,
    required this.startFrame,
    required this.endFrame,
    required this.frameCount,
    this.loop = false,
  });

  factory AnimationSegment.fromJson(Map<String, dynamic> json) {
    return AnimationSegment(
      name: json['name'] as String,
      startFrame: json['startFrame'] as int,
      endFrame: json['endFrame'] as int,
      frameCount: json['frameCount'] as int,
      loop: json['loop'] as bool? ?? false,
    );
  }
}

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
  final String description;
  final Map<String, AnimationSegment>? segments;

  const PetAnimationConfig({
    required this.spritesheetPath,
    required this.frames,
    required this.frameWidth,
    required this.frameHeight,
    required this.columns,
    required this.rows,
    required this.fps,
    this.loop = true,
    this.description = '',
    this.segments,
  });

  /// 从 JSON 创建配置
  factory PetAnimationConfig.fromJson(Map<String, dynamic> json) {
    Map<String, AnimationSegment>? segmentsMap;
    if (json['segments'] != null) {
      segmentsMap = {};
      final segmentsJson = json['segments'] as Map<String, dynamic>;
      segmentsJson.forEach((key, value) {
        segmentsMap![key] = AnimationSegment.fromJson(value as Map<String, dynamic>);
      });
    }

    return PetAnimationConfig(
      spritesheetPath: json['spritesheet'] as String,
      frames: json['frames'] as int,
      frameWidth: json['frameWidth'] as int,
      frameHeight: json['frameHeight'] as int,
      columns: json['columns'] as int,
      rows: json['rows'] as int,
      fps: json['fps'] as int,
      loop: json['loop'] as bool? ?? true,
      description: json['description'] as String? ?? '',
      segments: segmentsMap,
    );
  }

  /// 获取每帧的时间间隔（秒）
  double get stepTime => 1.0 / fps;

  /// 获取指定片段的帧范围
  AnimationSegment? getSegment(String segmentName) {
    return segments?[segmentName];
  }

  /// 检查是否有片段
  bool get hasSegments => segments != null && segments!.isNotEmpty;
}

/// 动画配置集合
class PetAnimationsConfig {
  final String version;
  final String format;
  final Map<String, PetAnimationConfig> animations;

  const PetAnimationsConfig({
    required this.version,
    required this.format,
    required this.animations,
  });

  /// 从 JSON 创建配置集合
  factory PetAnimationsConfig.fromJson(Map<String, dynamic> json) {
    final animationsMap = <String, PetAnimationConfig>{};
    final animationsJson = json['animations'] as Map<String, dynamic>;
    animationsJson.forEach((key, value) {
      animationsMap[key] = PetAnimationConfig.fromJson(value as Map<String, dynamic>);
    });

    return PetAnimationsConfig(
      version: json['version'] as String? ?? '1.0',
      format: json['format'] as String? ?? 'RGBA8888',
      animations: animationsMap,
    );
  }

  /// 获取指定动画配置
  PetAnimationConfig? getAnimation(String animationName) {
    return animations[animationName];
  }
}

/// 动画配置加载服务
class PetAnimationConfigService {
  static PetAnimationsConfig? _cachedConfig;

  /// 加载动画配置
  static Future<PetAnimationsConfig> loadConfig(String configPath) async {
    if (_cachedConfig != null) {
      return _cachedConfig!;
    }

    try {
      final String jsonString = await rootBundle.loadString(configPath);
      final Map<String, dynamic> jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      _cachedConfig = PetAnimationsConfig.fromJson(jsonMap);
      return _cachedConfig!;
    } catch (e) {
      throw Exception('Failed to load animation config: $e');
    }
  }

  /// 获取缓存的配置
  static PetAnimationsConfig? get cachedConfig => _cachedConfig;

  /// 清除缓存
  static void clearCache() {
    _cachedConfig = null;
  }

  /// 预加载配置
  static Future<void> preloadConfig(String configPath) async {
    await loadConfig(configPath);
  }
}
