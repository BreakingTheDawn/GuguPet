import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../platform/platform_capabilities.dart';

/// Initializes the FFI database factory for desktop platforms.
void initializeSqliteForPlatform(PlatformCapabilities capabilities) {
  if (capabilities.isWindows || capabilities.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
}
