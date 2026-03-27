import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';

/// 安全监控服务
/// 记录安全事件、检测异常行为、生成安全报告
class SecurityMonitorService {
  /// 单例实例
  static final SecurityMonitorService _instance = SecurityMonitorService._internal();
  factory SecurityMonitorService() => _instance;
  SecurityMonitorService._internal();

  /// 安全事件存储键
  static const String _securityEventsKey = 'security_events';
  static const int _maxEvents = 100; // 最多保留100条事件

  /// 记录安全事件
  /// [eventType] 事件类型
  /// [severity] 严重程度
  /// [details] 详细信息
  /// [userId] 用户ID（可选）
  Future<void> logSecurityEvent({
    required SecurityEventType eventType,
    required SecuritySeverity severity,
    required String details,
    String? userId,
  }) async {
    try {
      final event = SecurityEvent(
        id: _generateEventId(),
        eventType: eventType,
        severity: severity,
        details: details,
        userId: userId,
        timestamp: DateTime.now(),
      );

      final prefs = await SharedPreferences.getInstance();
      final eventsJson = prefs.getString(_securityEventsKey);
      
      List<dynamic> events = [];
      if (eventsJson != null) {
        events = jsonDecode(eventsJson) as List<dynamic>;
      }

      // 添加新事件
      events.add(event.toMap());

      // 保留最近的事件
      if (events.length > _maxEvents) {
        events = events.sublist(events.length - _maxEvents);
      }

      await prefs.setString(_securityEventsKey, jsonEncode(events));

      // 如果是严重事件，立即上报（生产环境）
      if (severity == SecuritySeverity.critical) {
        await _reportCriticalEvent(event);
      }
    } catch (e) {
      print('[SecurityMonitor] 记录安全事件失败: $e');
    }
  }

  /// 获取安全事件列表
  /// [limit] 返回的事件数量限制
  Future<List<SecurityEvent>> getSecurityEvents({int limit = 50}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = prefs.getString(_securityEventsKey);

      if (eventsJson == null) {
        return [];
      }

      final events = jsonDecode(eventsJson) as List<dynamic>;
      return events
          .map((e) => SecurityEvent.fromMap(e as Map<String, dynamic>))
          .toList()
          .sublist(0, events.length > limit ? limit : events.length);
    } catch (e) {
      return [];
    }
  }

  /// 清除安全事件日志
  Future<void> clearSecurityEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_securityEventsKey);
    } catch (e) {
      // 忽略清除失败
    }
  }

  /// 生成安全报告
  /// [userId] 用户ID
  Future<SecurityReport> generateSecurityReport(String userId) async {
    try {
      final events = await getSecurityEvents();
      final userEvents = events.where((e) => e.userId == userId).toList();

      return SecurityReport(
        userId: userId,
        generatedAt: DateTime.now(),
        totalEvents: userEvents.length,
        criticalEvents: userEvents.where((e) => e.severity == SecuritySeverity.critical).length,
        warningEvents: userEvents.where((e) => e.severity == SecuritySeverity.warning).length,
        infoEvents: userEvents.where((e) => e.severity == SecuritySeverity.info).length,
        events: userEvents,
      );
    } catch (e) {
      throw SecurityMonitorException('生成安全报告失败: $e');
    }
  }

  /// 上报严重安全事件（生产环境应发送到服务器）
  Future<void> _reportCriticalEvent(SecurityEvent event) async {
    try {
      // 生产环境：发送到服务器
      // await _apiClient.reportSecurityEvent(event);
      
      // 开发环境：打印日志
      print('[SecurityMonitor] ⚠️ 严重安全事件: ${event.eventType}');
      print('[SecurityMonitor] 详情: ${event.details}');
      print('[SecurityMonitor] 时间: ${event.timestamp}');
    } catch (e) {
      print('[SecurityMonitor] 上报安全事件失败: $e');
    }
  }

  /// 生成事件ID
  String _generateEventId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final random = DateTime.now().microsecond.toString();
    final bytes = utf8.encode('$timestamp$random');
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 16);
  }

  /// 检测异常行为模式
  /// [userId] 用户ID
  /// 返回检测到的异常列表
  Future<List<String>> detectAnomalousPatterns(String userId) async {
    try {
      final events = await getSecurityEvents();
      final userEvents = events.where((e) => e.userId == userId).toList();

      final anomalies = <String>[];

      // 1. 检测频繁的VIP状态变更
      final vipEvents = userEvents.where((e) => 
        e.eventType == SecurityEventType.vipStatusChanged
      ).toList();
      
      if (vipEvents.length > 3) {
        anomalies.add('检测到频繁的VIP状态变更（${vipEvents.length}次）');
      }

      // 2. 检测签名验证失败
      final signatureFailures = userEvents.where((e) => 
        e.eventType == SecurityEventType.signatureVerificationFailed
      ).toList();
      
      if (signatureFailures.isNotEmpty) {
        anomalies.add('检测到${signatureFailures.length}次签名验证失败');
      }

      // 3. 检测设备Root/越狱
      final rootEvents = userEvents.where((e) => 
        e.eventType == SecurityEventType.rootDetected
      ).toList();
      
      if (rootEvents.isNotEmpty) {
        anomalies.add('检测到设备已Root/越狱');
      }

      return anomalies;
    } catch (e) {
      return [];
    }
  }
}

/// 安全事件类型
enum SecurityEventType {
  rootDetected,                    // 检测到Root/越狱
  signatureVerificationFailed,     // 签名验证失败
  vipStatusChanged,                // VIP状态变更
  dataTamperingDetected,           // 数据篡改检测
  unauthorizedAccess,              // 未授权访问
  apiKeyCompromised,               // API密钥泄露
  deviceBindingFailed,             // 设备绑定失败
  suspiciousActivity,              // 可疑活动
}

/// 安全严重程度
enum SecuritySeverity {
  info,        // 信息
  warning,     // 警告
  critical,    // 严重
}

/// 安全事件模型
class SecurityEvent {
  final String id;
  final SecurityEventType eventType;
  final SecuritySeverity severity;
  final String details;
  final String? userId;
  final DateTime timestamp;

  SecurityEvent({
    required this.id,
    required this.eventType,
    required this.severity,
    required this.details,
    this.userId,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventType': eventType.name,
      'severity': severity.name,
      'details': details,
      'userId': userId,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory SecurityEvent.fromMap(Map<String, dynamic> map) {
    return SecurityEvent(
      id: map['id'] as String,
      eventType: SecurityEventType.values.firstWhere((e) => e.name == map['eventType']),
      severity: SecuritySeverity.values.firstWhere((e) => e.name == map['severity']),
      details: map['details'] as String,
      userId: map['userId'] as String?,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
}

/// 安全报告模型
class SecurityReport {
  final String userId;
  final DateTime generatedAt;
  final int totalEvents;
  final int criticalEvents;
  final int warningEvents;
  final int infoEvents;
  final List<SecurityEvent> events;

  SecurityReport({
    required this.userId,
    required this.generatedAt,
    required this.totalEvents,
    required this.criticalEvents,
    required this.warningEvents,
    required this.infoEvents,
    required this.events,
  });

  /// 获取安全评分（0-100）
  int get securityScore {
    if (totalEvents == 0) return 100;

    int score = 100;
    score -= criticalEvents * 20;
    score -= warningEvents * 5;
    score -= infoEvents * 1;

    return score.clamp(0, 100);
  }

  /// 获取安全等级描述
  String get securityLevel {
    final score = securityScore;
    if (score >= 90) return '优秀';
    if (score >= 70) return '良好';
    if (score >= 50) return '一般';
    if (score >= 30) return '较差';
    return '危险';
  }
}

/// 安全监控异常
class SecurityMonitorException implements Exception {
  final String message;
  SecurityMonitorException(this.message);

  @override
  String toString() => 'SecurityMonitorException: $message';
}
