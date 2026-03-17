import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

enum PetState { idle, happy }

class PetAvatar extends StatefulWidget {
  final PetState state;
  final double size;

  const PetAvatar({
    super.key,
    this.state = PetState.idle,
    this.size = 210,
  });

  @override
  State<PetAvatar> createState() => _PetAvatarState();
}

class _PetAvatarState extends State<PetAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _yAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: widget.state == PetState.happy ? 1800 : 3500,
      ),
    );

    if (widget.state == PetState.happy) {
      _yAnimation = TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 0, end: -22), weight: 1),
        TweenSequenceItem(tween: Tween(begin: -22, end: -8), weight: 1),
        TweenSequenceItem(tween: Tween(begin: -8, end: -18), weight: 1),
        TweenSequenceItem(tween: Tween(begin: -18, end: 0), weight: 1),
      ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

      _rotateAnimation = TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 0, end: -0.03), weight: 1),
        TweenSequenceItem(tween: Tween(begin: -0.03, end: 0.05), weight: 1),
        TweenSequenceItem(tween: Tween(begin: 0.05, end: -0.05), weight: 1),
        TweenSequenceItem(tween: Tween(begin: -0.05, end: 0), weight: 1),
      ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    } else {
      _yAnimation = TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 1),
        TweenSequenceItem(tween: Tween(begin: -10, end: 0), weight: 1),
      ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

      _rotateAnimation = TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: -0.026, end: 0.026), weight: 1),
        TweenSequenceItem(tween: Tween(begin: 0.026, end: -0.026), weight: 1),
      ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    }

    _controller.repeat();
  }

  @override
  void didUpdateWidget(PetAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _controller.dispose();
      _controller = AnimationController(
        vsync: this,
        duration: Duration(
          milliseconds: widget.state == PetState.happy ? 1800 : 3500,
        ),
      );
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _yAnimation.value),
          child: Transform.rotate(
            angle: _rotateAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: AppShadows.petGlow,
              ),
              child: Image.asset(
                'assets/images/bird_default.png',
                width: widget.size,
                height: widget.size,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      color: AppColors.indigo200,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('🐦', style: TextStyle(fontSize: 64)),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
