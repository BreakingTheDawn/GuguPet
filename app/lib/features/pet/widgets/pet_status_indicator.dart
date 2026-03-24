import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pet_provider.dart';
import '../data/models/pet_emotion.dart';

/// 宠物状态指示器组件
/// 显示情感状态和羁绊进度，融入场景风格
class PetStatusIndicator extends StatelessWidget {
  const PetStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PetProvider>(
      builder: (context, petProvider, child) {
        final pet = petProvider.pet;
        if (pet == null) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 情感状态
              _EmotionBadge(
                emotion: pet.currentEmotion,
                emotionValue: pet.emotionValue,
              ),
              const SizedBox(width: 16),
              // 分隔线
              Container(
                width: 1,
                height: 32,
                color: const Color(0xFFB8A5D9).withValues(alpha: 0.3),  // 柔和分隔线
              ),
              const SizedBox(width: 16),
              // 羁绊等级
              _BondBadge(
                level: pet.bondLevel,
                title: petProvider.bondTitle,
                progress: petProvider.bondProgress,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 情感状态徽章
class _EmotionBadge extends StatelessWidget {
  final PetEmotionType emotion;
  final int emotionValue;

  const _EmotionBadge({
    required this.emotion,
    required this.emotionValue,
  });

  @override
  Widget build(BuildContext context) {
    final emotionInfo = _getEmotionInfo(emotion);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 情感图标
        Text(
          emotionInfo.emoji,
          style: const TextStyle(fontSize: 22),
        ),
        const SizedBox(width: 8),
        // 情感名称 - 使用柔和的淡紫色
        Text(
          emotionInfo.label,
          style: const TextStyle(
            color: Color(0xFFD4C5E8),  // 柔和淡紫色
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  _EmotionInfo _getEmotionInfo(PetEmotionType emotion) {
    switch (emotion) {
      case PetEmotionType.happy:
        return _EmotionInfo('开心', '😊');
      case PetEmotionType.normal:
        return _EmotionInfo('平静', '😐');
      case PetEmotionType.sad:
        return _EmotionInfo('难过', '😢');
      case PetEmotionType.angry:
        return _EmotionInfo('生气', '😠');
      case PetEmotionType.excited:
        return _EmotionInfo('兴奋', '🤩');
    }
  }
}

/// 羁绊等级徽章
class _BondBadge extends StatelessWidget {
  final int level;
  final String title;
  final double progress;

  const _BondBadge({
    required this.level,
    required this.title,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 等级徽章 - 显示完整等级
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFF8B7EC8).withValues(alpha: 0.35),  // 柔和紫色背景
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            'Lv.$level',  // 显示完整等级
            style: const TextStyle(
              color: Color(0xFFE8DFF5),  // 柔和淡紫色
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // 称号 - 使用柔和的淡紫色
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFD4C5E8),  // 柔和淡紫色
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 10),
        // 进度条 - 加宽并显示更明显
        SizedBox(
          width: 60,  // 加宽进度条
          height: 6,  // 加高进度条
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Stack(
              children: [
                // 背景条
                Container(
                  color: const Color(0xFF6B5B95).withValues(alpha: 0.3),  // 深紫色半透明背景
                ),
                // 进度条
                FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFB8A5D9),  // 柔和紫色
                          const Color(0xFFD4C5E8),  // 更淡的紫色
                        ],
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 情感信息数据类
class _EmotionInfo {
  final String label;
  final String emoji;

  const _EmotionInfo(this.label, this.emoji);
}