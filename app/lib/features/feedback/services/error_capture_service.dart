import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../data/models/error_record.dart';

/// 全局错误捕获服务
/// 自动捕获Flutter框架错误和Dart未处理异常
class ErrorCaptureService {
  /// 单例实例
  static final ErrorCaptureService _instance = ErrorCaptureService._internal();
  factory ErrorCaptureService() => _instance;
  ErrorCaptureService._internal();

  /// 错误缓存队列
  final List<ErrorRecord> _errorCache = [];

  /// 最大缓存数量
  static const int _maxCacheSize = 10;

  /// 运行日志缓存
  final List<String> _logCache = [];

  /// 最大日志数量
  static const int _maxLogCount = 50;

  /// 设备信息插件
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// 是否已初始化
  bool _initialized = false;

  /// 错误回调
  Function(ErrorRecord error)? onError;

  /// 初始化错误捕获
  void initialize() {
    if (_initialized) return;
    _initialized = true;

    // 捕获Flutter框架错误
    FlutterError.onError = (details) {
      _captureError(
        type: ErrorType.flutter,
        message: details.toStringShort(),
        stackTrace: details.stack,
      );
      
      // 调用原始处理（在debug模式下显示红屏）
      FlutterError.presentError(details);
    };

    // 捕获Dart未处理异常
    PlatformDispatcher.instance.onError = (error, stack) {
      _captureError(
        type: ErrorType.dart,
        message: error.toString(),
        stackTrace: stack,
      );
      return true;
    };

    debugPrint('✅ ErrorCaptureService 已初始化');
  }

  /// 手动捕获错误
  void captureError({
    required ErrorType type,
    required String message,
    StackTrace? stackTrace,
    String? screenshot,
  }) {
    _captureError(
      type: type,
      message: message,
      stackTrace: stackTrace,
      screenshot: screenshot,
    );
  }

  /// 捕获网络错误
  void captureNetworkError(String message, {StackTrace? stackTrace}) {
    _captureError(
      type: ErrorType.network,
      message: message,
      stackTrace: stackTrace,
    );
  }

  /// 捕获自定义错误
  void captureCustomError(String message, {StackTrace? stackTrace, String? screenshot}) {
    _captureError(
      type: ErrorType.custom,
      message: message,
      stackTrace: stackTrace,
      screenshot: screenshot,
    );
  }

  /// 内部捕获错误
  Future<void> _captureError({
    required ErrorType type,
    required String message,
    StackTrace? stackTrace,
    String? screenshot,
  }) async {
    try {
      // 收集设备信息
      final deviceInfo = await _collectDeviceInfo();

      // 创建错误记录
      final record = ErrorRecord(
        id: _generateId(),
        type: type,
        message: message,
        stackTrace: stackTrace?.toString(),
        screenshot: screenshot,
        logs: List.from(_logCache),
        deviceInfo: deviceInfo,
        timestamp: DateTime.now(),
      );

      // 添加到缓存
      _errorCache.add(record);
      if (_errorCache.length > _maxCacheSize) {
        _errorCache.removeAt(0);
      }

      // 记录日志
      addLog('[ERROR] ${type.name}: $message');

      // 触发回调
      onError?.call(record);

      debugPrint('🔴 捕获错误: ${type.name} - $message');
    } catch (e) {
      debugPrint('❌ 捕获错误失败: $e');
    }
  }

  /// 获取最近的错误记录
  ErrorRecord? getLastError() {
    return _errorCache.isNotEmpty ? _errorCache.last : null;
  }

  /// 获取所有错误记录
  List<ErrorRecord> getAllErrors() {
    return List.unmodifiable(_errorCache);
  }

  /// 清除错误记录
  void clearErrors() {
    _errorCache.clear();
  }

  /// 添加运行日志
  void addLog(String log) {
    _logCache.add('[${DateTime.now().toIso8601String()}] $log');
    if (_logCache.length > _maxLogCount) {
      _logCache.removeAt(0);
    }
  }

  /// 获取所有日志
  List<String> getAllLogs() {
    return List.unmodifiable(_logCache);
  }

  /// 清除日志
  void clearLogs() {
    _logCache.clear();
  }

  /// 收集设备信息
  Future<Map<String, dynamic>> _collectDeviceInfo() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final info = await _deviceInfo.androidInfo;
        return {
          'platform': 'android',
          'os_version': info.version.release,
          'device_model': '${info.brand} ${info.model}',
          'sdk_version': info.version.sdkInt,
          'manufacturer': info.manufacturer,
        };
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final info = await _deviceInfo.iosInfo;
        return {
          'platform': 'ios',
          'os_version': info.systemVersion,
          'device_model': info.model,
          'name': info.name,
        };
      }
    } catch (e) {
      debugPrint('收集设备信息失败: $e');
    }
    return {'platform': 'unknown'};
  }

  /// 生成错误ID
  String _generateId() {
    return 'err_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// 获取错误统计
  Map<ErrorType, int> getErrorStats() {
    final stats = <ErrorType, int>{};
    for (final error in _errorCache) {
      stats[error.type] = (stats[error.type] ?? 0) + 1;
    }
    return stats;
  }

  /// 是否有错误
  bool get hasErrors => _errorCache.isNotEmpty;

  /// 错误数量
  int get errorCount => _errorCache.length;
}
