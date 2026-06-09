import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobpet/core/platform/platform_capabilities.dart';

void main() {
  group('PlatformCapabilities', () {
    test('current exposes web-safe platform capability flags', () {
      final capabilities = PlatformCapabilities.current;

      expect(capabilities.isWeb, kIsWeb);
      expect(capabilities.supportsLocalSqlite, isA<bool>());
      expect(capabilities.supportsDeviceSecurityChecks, isA<bool>());
      expect(capabilities.supportsLocalNotifications, isA<bool>());
    });
  });
}
