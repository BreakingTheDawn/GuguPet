import 'package:flutter/foundation.dart';

/// Describes runtime platform features without importing dart:io.
class PlatformCapabilities {
  const PlatformCapabilities({
    required this.isWeb,
    required this.isWindows,
    required this.isLinux,
    required this.isAndroid,
    required this.isIOS,
    required this.supportsLocalSqlite,
    required this.supportsDeviceSecurityChecks,
    required this.supportsLocalNotifications,
  });

  /// Builds capability flags from Flutter's web-safe platform APIs.
  static PlatformCapabilities get current {
    final isWindows =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;
    final isLinux = !kIsWeb && defaultTargetPlatform == TargetPlatform.linux;
    final isAndroid =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
    final isIOS = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

    return PlatformCapabilities(
      isWeb: kIsWeb,
      isWindows: isWindows,
      isLinux: isLinux,
      isAndroid: isAndroid,
      isIOS: isIOS,
      supportsLocalSqlite: !kIsWeb,
      supportsDeviceSecurityChecks: isWindows || isLinux || isAndroid || isIOS,
      supportsLocalNotifications: isAndroid || isIOS,
    );
  }

  /// True when the app is running in a browser.
  final bool isWeb;

  /// True when the native target is Windows.
  final bool isWindows;

  /// True when the native target is Linux.
  final bool isLinux;

  /// True when the native target is Android.
  final bool isAndroid;

  /// True when the native target is iOS.
  final bool isIOS;

  /// True when local SQLite-backed services can safely start.
  final bool supportsLocalSqlite;

  /// True when native security checks can safely start.
  final bool supportsDeviceSecurityChecks;

  /// True when local notification APIs can safely start.
  final bool supportsLocalNotifications;
}
