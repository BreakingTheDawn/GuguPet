import 'package:flutter_test/flutter_test.dart';
import 'package:jobpet/features/feedback/services/error_capture_service.dart';
import 'package:jobpet/features/feedback/data/models/error_record.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ErrorCaptureService', () {
    late ErrorCaptureService service;

    setUp(() {
      service = ErrorCaptureService();
      service.clearErrors();
      service.clearLogs();
    });

    test('should cache error records', () async {
      service.captureError(
        type: ErrorType.custom,
        message: 'Test error',
      );

      // 等待异步操作完成
      await Future.delayed(const Duration(milliseconds: 100));

      final lastError = service.getLastError();

      expect(lastError, isNotNull);
      expect(lastError!.message, 'Test error');
      expect(lastError.type, ErrorType.custom);
    });

    test('should limit cache size to 10', () async {
      for (var i = 0; i < 15; i++) {
        service.captureError(
          type: ErrorType.custom,
          message: 'Error $i',
        );
        // 每次捕获后等待一小段时间
        await Future.delayed(const Duration(milliseconds: 10));
      }

      // 等待所有异步操作完成
      await Future.delayed(const Duration(milliseconds: 100));

      final errors = service.getAllErrors();

      expect(errors.length, 10);
    });

    test('should clear errors', () async {
      service.captureError(
        type: ErrorType.custom,
        message: 'Test error',
      );

      // 等待异步操作完成
      await Future.delayed(const Duration(milliseconds: 100));

      service.clearErrors();

      expect(service.getLastError(), isNull);
      expect(service.hasErrors, false);
      expect(service.errorCount, 0);
    });

    test('should add and retrieve logs', () {
      service.clearLogs();
      service.addLog('Log line 1');
      service.addLog('Log line 2');

      final logs = service.getAllLogs();

      expect(logs.any((l) => l.contains('Log line 1')), true);
      expect(logs.any((l) => l.contains('Log line 2')), true);
    });

    test('should clear logs', () {
      service.addLog('Test log');
      service.clearLogs();

      expect(service.getAllLogs(), isEmpty);
    });
  });
}
