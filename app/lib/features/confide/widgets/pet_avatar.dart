import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/widgets/pet_animation_widget.dart';

/// 宠物状态枚举
enum PetState { idle, happy, teasing, angry, move }

/// 宠物头像组件 - 支持 spritesheet 动画和点击互动
class PetAvatar extends StatelessWidget {
  final PetState state;
  final double size;
  final VoidCallback? onTap;
  final VoidCallback? onAnimationComplete;

  const PetAvatar({
    super.key,
    this.state = PetState.idle,
    this.size = 210,
    this.onTap,
    this.onAnimationComplete,
  });

  @override
  Widget build(BuildContext context) {
    final animationType = _getAnimationType(state);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: AppShadows.petGlow,
        ),
        child: PetAnimationWidget(
          animationType: animationType,
          size: size,
          onAnimationComplete: onAnimationComplete,
        ),
      ),
    );
  }

  /// 获取动画类型
  PetAnimationType _getAnimationType(PetState state) {
    switch (state) {
      case PetState.happy:
        return PetAnimationType.happy;
      case PetState.teasing:
        return PetAnimationType.teasing;
      case PetState.angry:
        return PetAnimationType.angry;
      case PetState.move:
        return PetAnimationType.move;
      default:
        return PetAnimationType.idle;
    }
  }
}
