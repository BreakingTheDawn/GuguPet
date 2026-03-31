/// 错误类型枚举
enum ErrorType {
  /// Flutter框架错误
  flutter,
  /// Dart未处理异常
  dart,
  /// 网络错误
  network,
  /// 自定义错误
  custom,
}

/// 错误记录模型
class ErrorRecord {
  /// 唯一标识符
  final String id;
  
  /// 错误类型
  final ErrorType type;
  
  /// 错误消息
  final String message;
  
  /// 堆栈跟踪
  final String? stackTrace;
  
  /// Base64编码的截图
  final String? screenshot;
  
  /// 最近的运行日志
  final List<String> logs;
  
  /// 设备信息
  final Map<String, dynamic>? deviceInfo;
  
  /// 时间戳
  final DateTime timestamp;

  ErrorRecord({
    required this.id,
    required this.type,
    required this.message,
    this.stackTrace,
    this.screenshot,
    this.logs = const [],
    this.deviceInfo,
    required this.timestamp,
  });

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'message': message,
      'stack_trace': stackTrace,
      'screenshot': screenshot,
      'logs': logs,
      'device_info': deviceInfo,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// 从JSON创建
  factory ErrorRecord.fromJson(Map<String, dynamic> json) {
    return ErrorRecord(
      id: json['id'] as String,
      type: ErrorType.values.firstWhere((e) => e.name == json['type']),
      message: json['message'] as String,
      stackTrace: json['stack_trace'] as String?,
      screenshot: json['screenshot'] as String?,
      logs: (json['logs'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      deviceInfo: json['device_info'] as Map<String, dynamic>?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// 是否有截图
  bool get hasScreenshot => screenshot != null && screenshot!.isNotEmpty;

  /// 是否有堆栈跟踪
  bool get hasStackTrace => stackTrace != null && stackTrace!.isNotEmpty;

  /// 是否有日志
  bool get hasLogs => logs.isNotEmpty;

  /// 获取错误类型显示名称
  String get typeDisplayName {
    switch (type) {
      case ErrorType.flutter:
        return 'Flutter错误';
      case ErrorType.dart:
        return 'Dart异常';
      case ErrorType.network:
        return '网络错误';
      case ErrorType.custom:
        return '自定义错误';
    }
  }

  /// 获取截断的错误消息（用于显示）
  String get truncatedMessage {
    if (message.length > 100) {
      return '${message.substring(0, 100)}...';
    }
    return message;
  }

  /// 复制并更新
  ErrorRecord copyWith({
    String? id,
    ErrorType? type,
    String? message,
    String? stackTrace,
    String? screenshot,
    List<String>? logs,
    Map<String, dynamic>? deviceInfo,
    DateTime? timestamp,
  }) {
    return ErrorRecord(
      id: id ?? this.id,
      type: type ?? this.type,
      message: message ?? this.message,
      stackTrace: stackTrace ?? this.stackTrace,
      screenshot: screenshot ?? this.screenshot,
      logs: logs ?? this.logs,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
