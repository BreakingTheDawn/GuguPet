import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class ResponseBubble extends StatelessWidget {
  final String text;
  final Animation<double> animation;

  const ResponseBubble({
    super.key,
    required this.text,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.85, end: 1.0).animate(
        CurvedAnimation(parent: animation, curve: Curves.elasticOut),
      ),
      child: FadeTransition(
        opacity: animation,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 280),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(AppSpacing.radius2xl),
            border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 1),
            boxShadow: AppShadows.bubble,
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: const Color(0xFF5A5A7A),
              height: 1.7,
            ),
          ),
        ),
      ),
    );
  }
}
