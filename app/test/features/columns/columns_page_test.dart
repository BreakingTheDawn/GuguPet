import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobpet/core/platform/platform_capabilities.dart';
import 'package:jobpet/features/columns/pages/columns_page.dart';

void main() {
  testWidgets(
    'ColumnsPage skips local purchase loading without SQLite support',
    (tester) async {
      const webLikeCapabilities = PlatformCapabilities(
        isWeb: true,
        isWindows: false,
        isLinux: false,
        isAndroid: false,
        isIOS: false,
        supportsLocalSqlite: false,
        supportsDeviceSecurityChecks: false,
        supportsLocalNotifications: false,
      );

      await tester.pumpWidget(
        const MaterialApp(home: ColumnsPage(capabilities: webLikeCapabilities)),
      );

      expect(find.byType(CircularProgressIndicator), findsNothing);
    },
  );
}
