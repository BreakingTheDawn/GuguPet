import 'package:flutter/widgets.dart';

import '../../features/feedback/services/error_capture_service.dart';
import '../platform/platform_capabilities.dart';
import '../services/ai_auto_config_service.dart';
import '../services/app_strings.dart';
import '../services/business_config_service.dart';
import '../services/security_service.dart';
import '../services/test_admin_initializer.dart';
import '../services/test_user_initializer.dart';
import '../services/theme_service.dart';
import 'sqlite_bootstrap.dart';

/// Coordinates process-wide startup before the widget tree is created.
class AppBootstrap {
  const AppBootstrap({PlatformCapabilities? capabilities})
    : _capabilities = capabilities;

  final PlatformCapabilities? _capabilities;

  /// Runs startup services behind platform capability gates.
  Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    final capabilities = _capabilities ?? PlatformCapabilities.current;

    // Desktop SQLite uses FFI; Web uses a no-op conditional import.
    initializeSqliteForPlatform(capabilities);

    // Error capture starts early so later startup failures are recorded.
    ErrorCaptureService().initialize();

    // Security checks rely on native-only plugins and dart:io implementation.
    if (capabilities.supportsDeviceSecurityChecks) {
      await _initializeSecurity();
    }

    // Configuration services provide strings, business rules, and themes.
    await AppStrings.initialize();
    await BusinessConfigService.initialize();
    await ThemeService.initialize();

    // Seed local test accounts only where SQLite storage is available.
    if (capabilities.supportsLocalSqlite) {
      await TestUserInitializer.initialize();
      await TestAdminInitializer.initialize();
      TestAdminInitializer.printAllTestAccountsInfo();
    }

    // AI configuration is last because it depends on app config being loaded.
    await AIAutoConfigService.initialize();
  }

  /// Initializes device security and logs non-fatal startup issues.
  Future<void> _initializeSecurity() async {
    try {
      final securityService = SecurityService();
      await securityService.initialize();

      final isSecure = await securityService.isDeviceSecure();
      if (!isSecure) {
        debugPrint('[Security] Device security check failed.');
      } else {
        debugPrint('[Security] Device security check passed.');
      }

      debugPrint('[Security] Security service initialized.');
    } catch (error, stackTrace) {
      debugPrint('[Security] Security service initialization failed: $error');
      debugPrint('$stackTrace');
    }
  }
}
