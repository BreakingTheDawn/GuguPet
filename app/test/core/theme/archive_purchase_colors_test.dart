import 'package:flutter_test/flutter_test.dart';
import 'package:jobpet/core/theme/app_colors.dart';

void main() {
  test(
    'archive purchase CTA uses warm commerce colors instead of brand blue',
    () {
      expect(AppColors.archiveButtonStart, isNot(AppColors.brandPrimary));
      expect(AppColors.archiveButtonEnd, AppColors.accentWarm);
      expect(AppColors.archiveButtonShadow, AppColors.accentWarm);
      expect(AppColors.archiveButtonText, isNot(AppColors.textInverse));
    },
  );
}
