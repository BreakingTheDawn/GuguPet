import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class StatCard extends StatelessWidget {
  final String label;
  final int value;
  final String unit;
  final Color backgroundColor;
  final Color borderColor;
  final Duration animationDuration;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.backgroundColor,
    required this.borderColor,
    this.animationDuration = const Duration(milliseconds: 1200),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        children: [
          _AnimatedNumber(
            target: value,
            duration: animationDuration,
            style: AppTypography.headingLarge.copyWith(
              color: Colors.white,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedNumber extends StatefulWidget {
  final int target;
  final Duration duration;
  final TextStyle? style;

  const _AnimatedNumber({
    required this.target,
    required this.duration,
    this.style,
  });

  @override
  State<_AnimatedNumber> createState() => _AnimatedNumberState();
}

class _AnimatedNumberState extends State<_AnimatedNumber> {
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _animate();
  }

  void _animate() {
    final start = DateTime.now();
    void tick() {
      final elapsed = DateTime.now().difference(start).inMilliseconds;
      final progress = (elapsed / widget.duration.inMilliseconds).clamp(0.0, 1.0);
      final eased = 1 - (1 - progress) * (1 - progress) * (1 - progress);
      setState(() => _current = (eased * widget.target).round());
      if (progress < 1) {
        WidgetsBinding.instance.addPostFrameCallback((_) => tick());
      }
    }
    tick();
  }

  @override
  Widget build(BuildContext context) {
    return Text('$_current', style: widget.style);
  }
}
