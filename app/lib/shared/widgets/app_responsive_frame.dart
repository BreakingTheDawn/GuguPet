import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';

/// Centers the mobile-first app surface on larger screens.
class AppResponsiveFrame extends StatelessWidget {
  const AppResponsiveFrame({
    super.key,
    required this.child,
    this.maxWidth = 560,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;

        // Mobile keeps the native full-width experience.
        if (!isWide) return child;

        return DecoratedBox(
          decoration: const BoxDecoration(
            gradient: AppColors.pageBackgroundGradient,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surfaceDefault,
                  border: Border.symmetric(
                    vertical: BorderSide(color: AppColors.borderDefault),
                  ),
                  boxShadow: AppShadows.floating,
                ),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}
