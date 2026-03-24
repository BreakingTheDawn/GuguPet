import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/widgets/widgets.dart';

class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final String change;
  final Color color;

  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.change,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
            ],
          ),
          const Spacer(),
          _AnimatedNumber(target: value, style: AppTypography.headingSmall),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppTypography.caption),
              Text(
                change,
                style: AppTypography.caption.copyWith(
                  color: change.contains('+') ? const Color(0xFF50C880) : AppColors.mutedForeground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnimatedNumber extends StatefulWidget {
  final int target;
  final TextStyle style;

  const _AnimatedNumber({required this.target, required this.style});

  @override
  State<_AnimatedNumber> createState() => _AnimatedNumberState();
}

class _AnimatedNumberState extends State<_AnimatedNumber> {
  int _current = 0;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _animate();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _animate() {
    final start = DateTime.now();
    void tick() {
      if (_isDisposed) return;
      final elapsed = DateTime.now().difference(start).inMilliseconds;
      final progress = (elapsed / 800).clamp(0.0, 1.0);
      final eased = 1 - (1 - progress) * (1 - progress) * (1 - progress);
      if (mounted) {
        setState(() => _current = (eased * widget.target).round());
      }
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
