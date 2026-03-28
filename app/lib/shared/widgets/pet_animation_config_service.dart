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
      name: json['name'] as String? ?? '',
      startFrame: json['startFrame'] as int? ?? 0,
      endFrame: json['endFrame'] as int? ?? 0,
      frameCount: json['frameCount'] as int? ?? 0,
      loop: json['loop'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'startFrame': startFrame,
      'endFrame': endFrame,
      'frameCount': frameCount,
      'loop': loop,
    };
  }
}

/// 宠物动画配置
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
    required this.loop,
    required this.description,
    this.segments,
    this.variants = 1,
    this.framesPerVariant = 0,
  });

  /// 获取每帧时间（秒）
  double get stepTime => 1.0 / fps;

  /// 是否有片段配置
  bool get hasSegments => segments != null && segments!.isNotEmpty;
  
  /// 是否有多个变体
  bool get hasVariants => variants > 1;

  /// 获取指定片段
  AnimationSegment? getSegment(String segmentName) {
    return segments?[segmentName];
  }

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
      spritesheetPath: json['spritesheetPath'] as String? ?? '',
      frames: json['frames'] as int? ?? 1,
      frameWidth: json['frameWidth'] as int? ?? 256,
      frameHeight: json['frameHeight'] as int? ?? 256,
      columns: json['columns'] as int? ?? 1,
      rows: json['rows'] as int? ?? 1,
      fps: json['fps'] as int? ?? 12,
      loop: json['loop'] as bool? ?? true,
      description: json['description'] as String? ?? '',
      segments: segmentsMap,
      variants: json['variants'] as int? ?? 1,
      framesPerVariant: json['framesPerVariant'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'spritesheetPath': spritesheetPath,
      'frames': frames,
      'frameWidth': frameWidth,
      'frameHeight': frameHeight,
      'columns': columns,
      'rows': rows,
      'fps': fps,
      'loop': loop,
      'description': description,
      'segments': segments?.map((key, value) => MapEntry(key, value.toJson())),
      'variants': variants,
      'framesPerVariant': framesPerVariant,
    };
  }
}

/// 所有动画配置的容器
class AnimationsConfig {
  final Map<String, PetAnimationConfig> animations;

  const AnimationsConfig({required this.animations});

  /// 获取指定动画配置
  PetAnimationConfig? getAnimation(String animationKey) {
    return animations[animationKey];
  }

  factory AnimationsConfig.fromJson(Map<String, dynamic> json) {
    final animationsMap = <String, PetAnimationConfig>{};
    final animationsJson = json['animations'] as Map<String, dynamic>?;
    
    if (animationsJson != null) {
      animationsJson.forEach((key, value) {
        animationsMap[key] = PetAnimationConfig.fromJson(value as Map<String, dynamic>);
      });
    }

    return AnimationsConfig(animations: animationsMap);
  }

  Map<String, dynamic> toJson() {
    return {
      'animations': animations.map((key, value) => MapEntry(key, value.toJson())),
    };
  }
}

/// 动画配置服务 - 负责加载和管理动画配置
class PetAnimationConfigService {
  /// 缓存已加载的配置
  static final Map<String, AnimationsConfig> _configCache = {};

  /// 加载动画配置文件
  static Future<AnimationsConfig> loadConfig(String configPath) async {
    // 检查缓存
    if (_configCache.containsKey(configPath)) {
      return _configCache[configPath]!;
    }

    // 加载JSON文件
    final String jsonString = await rootBundle.loadString(configPath);
    final Map<String, dynamic> jsonData = json.decode(jsonString) as Map<String, dynamic>;
    
    final config = AnimationsConfig.fromJson(jsonData);
    
    // 缓存配置
    _configCache[configPath] = config;
    
    return config;
  }

  /// 清除缓存
  static void clearCache() {
    _configCache.clear();
  }

  /// 清除指定配置的缓存
  static void clearConfigCache(String configPath) {
    _configCache.remove(configPath);
  }

  /// 检查配置是否已缓存
  static bool isConfigCached(String configPath) {
    return _configCache.containsKey(configPath);
  }
}
