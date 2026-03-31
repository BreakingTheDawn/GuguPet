import 'package:flutter_test/flutter_test.dart';
import 'package:jobpet/features/feedback/services/feedback_service.dart';
import 'package:jobpet/features/feedback/data/models/user_feedback.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FeedbackRequest', () {
    test('should create request with all fields', () {
      final request = FeedbackRequest(
        userId: 'user_001',
        type: FeedbackType.bug,
        title: 'Bug报告',
        content: '这是一个测试反馈',
        rating: 3,
        includeDeviceInfo: true,
        includeErrorLog: true,
      );

      expect(request.userId, 'user_001');
      expect(request.type, FeedbackType.bug);
      expect(request.title, 'Bug报告');
      expect(request.content, '这是一个测试反馈');
      expect(request.rating, 3);
    });

    test('should convert to JSON correctly', () {
      final request = FeedbackRequest(
        userId: 'user_001',
        type: FeedbackType.suggestion,
        title: '建议',
        content: '希望能增加深色模式',
      );

      final json = request.toJson();

      expect(json['user_id'], 'user_001');
      expect(json['type'], 'suggestion');
      expect(json['title'], '建议');
      expect(json['content'], '希望能增加深色模式');
    });
  });

  group('FeedbackResult', () {
    test('should create success result', () {
      final result = FeedbackResult.success('fb_001');

      expect(result.success, true);
      expect(result.feedbackId, 'fb_001');
      expect(result.errorMessage, isNull);
    });

    test('should create failure result', () {
      final result = FeedbackResult.failure('网络错误');

      expect(result.success, false);
      expect(result.feedbackId, isNull);
      expect(result.errorMessage, '网络错误');
    });
  });
}
