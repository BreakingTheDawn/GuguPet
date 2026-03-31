import 'package:flutter_test/flutter_test.dart';
import 'package:jobpet/features/feedback/data/models/user_feedback.dart';
import 'package:jobpet/features/feedback/data/models/error_record.dart';

void main() {
  group('UserFeedback', () {
    test('should create feedback with all fields', () {
      final feedback = UserFeedback(
        id: 'fb_001',
        userId: 'user_001',
        type: FeedbackType.bug,
        title: '登录失败',
        content: '使用微信登录时提示网络错误',
        rating: 2,
        imageUrls: ['https://example.com/screenshot.png'],
        deviceInfo: DeviceInfo(
          platform: 'android',
          osVersion: '13',
          deviceModel: 'Pixel 7',
          appVersion: '1.0.2',
        ),
        appInfo: AppInfo(
          version: '1.0.2',
          buildNumber: '1',
        ),
        status: FeedbackStatus.pending,
        createdAt: DateTime(2026, 3, 30),
      );

      expect(feedback.id, 'fb_001');
      expect(feedback.type, FeedbackType.bug);
      expect(feedback.content, '使用微信登录时提示网络错误');
      expect(feedback.rating, 2);
      expect(feedback.typeDisplayName, 'Bug报告');
      expect(feedback.statusDisplayName, '待处理');
    });

    test('should serialize to JSON correctly', () {
      final feedback = UserFeedback(
        id: 'fb_002',
        userId: 'user_001',
        type: FeedbackType.suggestion,
        title: '建议',
        content: '希望能增加深色模式',
        rating: 4,
        status: FeedbackStatus.pending,
        createdAt: DateTime(2026, 3, 30),
      );

      final json = feedback.toJson();

      expect(json['id'], 'fb_002');
      expect(json['type'], 'suggestion');
      expect(json['content'], '希望能增加深色模式');
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'id': 'fb_003',
        'user_id': 'user_001',
        'type': 'praise',
        'title': '好评',
        'content': '非常好用的App',
        'rating': 5,
        'status': 'resolved',
        'created_at': '2026-03-30T10:00:00.000',
      };

      final feedback = UserFeedback.fromJson(json);

      expect(feedback.id, 'fb_003');
      expect(feedback.type, FeedbackType.praise);
      expect(feedback.status, FeedbackStatus.resolved);
      expect(feedback.typeDisplayName, '表扬');
      expect(feedback.statusDisplayName, '已解决');
    });

    test('should copy with new values', () {
      final feedback = UserFeedback(
        id: 'fb_004',
        userId: 'user_001',
        type: FeedbackType.bug,
        title: '测试',
        content: '测试内容',
        createdAt: DateTime(2026, 3, 30),
      );

      final updated = feedback.copyWith(
        status: FeedbackStatus.resolved,
        adminReply: '已修复',
      );

      expect(updated.status, FeedbackStatus.resolved);
      expect(updated.adminReply, '已修复');
      expect(updated.id, 'fb_004');
    });
  });

  group('ErrorRecord', () {
    test('should create error record with all fields', () {
      final error = ErrorRecord(
        id: 'err_001',
        type: ErrorType.flutter,
        message: 'Null check operator used on a null value',
        stackTrace: '#0 main (file:///app/main.dart:10)',
        logs: ['Log line 1', 'Log line 2'],
        timestamp: DateTime(2026, 3, 30),
      );

      expect(error.id, 'err_001');
      expect(error.type, ErrorType.flutter);
      expect(error.hasStackTrace, true);
      expect(error.hasLogs, true);
      expect(error.typeDisplayName, 'Flutter错误');
    });

    test('should serialize to JSON correctly', () {
      final error = ErrorRecord(
        id: 'err_002',
        type: ErrorType.network,
        message: 'Connection timeout',
        timestamp: DateTime(2026, 3, 30),
      );

      final json = error.toJson();

      expect(json['id'], 'err_002');
      expect(json['type'], 'network');
      expect(json['message'], 'Connection timeout');
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'id': 'err_003',
        'type': 'dart',
        'message': 'Exception: Test error',
        'stack_trace': '#0 test (file:///test.dart:5)',
        'logs': ['log1', 'log2'],
        'timestamp': '2026-03-30T10:00:00.000',
      };

      final error = ErrorRecord.fromJson(json);

      expect(error.id, 'err_003');
      expect(error.type, ErrorType.dart);
      expect(error.hasStackTrace, true);
      expect(error.logs.length, 2);
    });

    test('should truncate long message', () {
      final longMessage = 'A' * 150;
      final error = ErrorRecord(
        id: 'err_004',
        type: ErrorType.custom,
        message: longMessage,
        timestamp: DateTime(2026, 3, 30),
      );

      expect(error.truncatedMessage.length, 103); // 100 + '...'
      expect(error.truncatedMessage.endsWith('...'), true);
    });
  });

  group('DeviceInfo', () {
    test('should create and serialize device info', () {
      final deviceInfo = DeviceInfo(
        platform: 'android',
        osVersion: '13',
        deviceModel: 'Pixel 7',
        appVersion: '1.0.0',
        networkType: 'wifi',
        isRooted: false,
      );

      final json = deviceInfo.toJson();
      final fromJson = DeviceInfo.fromJson(json);

      expect(fromJson.platform, 'android');
      expect(fromJson.osVersion, '13');
      expect(fromJson.networkType, 'wifi');
    });
  });

  group('AppInfo', () {
    test('should create and serialize app info', () {
      final appInfo = AppInfo(
        version: '1.0.0',
        buildNumber: '1',
        lastScreen: '/home',
        errorLog: 'Error log content',
      );

      final json = appInfo.toJson();
      final fromJson = AppInfo.fromJson(json);

      expect(fromJson.version, '1.0.0');
      expect(fromJson.buildNumber, '1');
      expect(fromJson.lastScreen, '/home');
    });
  });
}
