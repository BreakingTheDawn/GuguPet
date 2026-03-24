import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Border? border;
  final List<BoxShadow>? boxShadow;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 24.0,
    this.backgroundColor,
    this.borderRadius,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.border,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppSpacing.radiusXl);

    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: (backgroundColor ?? Colors.white).withValues(alpha: 0.65),
              borderRadius: radius,
              border: border ??
                  Border.all(
                    color: Colors.white.withValues(alpha: 0.88),
                    width: 1.5,
                  ),
              boxShadow: boxShadow ?? AppShadows.bubble,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
