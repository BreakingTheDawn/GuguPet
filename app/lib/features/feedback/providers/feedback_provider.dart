import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../data/models/user_feedback.dart';
import '../data/models/error_record.dart';
import '../services/feedback_service.dart';
import '../services/error_capture_service.dart';
import '../data/datasources/feedback_local_datasource.dart';

/// 反馈状态枚举
enum FeedbackProviderStatus {
  /// 初始状态
  initial,
  /// 提交中
  submitting,
  /// 提交成功
  success,
  /// 提交失败
  error,
}

/// 反馈Provider
/// 管理反馈状态和错误捕获
class FeedbackProvider extends ChangeNotifier {
  final FeedbackService _feedbackService;
  final ErrorCaptureService _errorCaptureService;

  FeedbackProviderStatus _status = FeedbackProviderStatus.initial;
  String? _errorMessage;
  List<UserFeedback> _feedbackHistory = [];
  ErrorRecord? _lastError;

  FeedbackProvider({
    required FeedbackService feedbackService,
    ErrorCaptureService? errorCaptureService,
  })  : _feedbackService = feedbackService,
        _errorCaptureService = errorCaptureService ?? ErrorCaptureService() {
    _init();
  }

  /// 创建本地反馈Provider
  factory FeedbackProvider.local({required Database database}) {
    final localDatasource = FeedbackLocalDatasource(database);
    final feedbackService = LocalFeedbackService(localDatasource: localDatasource);
    return FeedbackProvider(feedbackService: feedbackService);
  }

  /// 初始化
  void _init() {
    _errorCaptureService.onError = _handleError;
  }

  /// 当前状态
  FeedbackProviderStatus get status => _status;

  /// 错误消息
  String? get errorMessage => _errorMessage;

  /// 反馈历史
  List<UserFeedback> get feedbackHistory => List.unmodifiable(_feedbackHistory);

  /// 最后一个错误
  ErrorRecord? get lastError => _lastError;

  /// 是否有未处理的错误
  bool get hasUnhandledError => _lastError != null;

  /// 是否正在提交
  bool get isSubmitting => _status == FeedbackProviderStatus.submitting;

  /// 提交反馈
  Future<bool> submitFeedback({
    required String userId,
    required FeedbackType type,
    required String title,
    required String content,
    int? rating,
    List<String>? imagePaths,
    bool includeDeviceInfo = true,
    bool includeErrorLog = false,
  }) async {
    _status = FeedbackProviderStatus.submitting;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = FeedbackRequest(
        userId: userId,
        type: type,
        title: title,
        content: content,
        rating: rating,
        imagePaths: imagePaths,
        includeDeviceInfo: includeDeviceInfo,
        includeErrorLog: includeErrorLog,
        errorData: _lastError?.toJson(),
      );

      final result = await _feedbackService.submit(request);

      if (result.success) {
        _status = FeedbackProviderStatus.success;
        _lastError = null;
        notifyListeners();
        return true;
      } else {
        _status = FeedbackProviderStatus.error;
        _errorMessage = result.errorMessage ?? '提交失败';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = FeedbackProviderStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// 加载反馈历史
  Future<void> loadFeedbackHistory(String userId, {int page = 1, int size = 10}) async {
    try {
      _feedbackHistory = await _feedbackService.getUserFeedbacks(userId, page: page, size: size);
      notifyListeners();
    } catch (e) {
      debugPrint('加载反馈历史失败: $e');
    }
  }

  /// 处理错误
  void _handleError(ErrorRecord error) {
    _lastError = error;
    notifyListeners();
  }

  /// 清除错误
  void clearError() {
    _lastError = null;
    notifyListeners();
  }

  /// 重置状态
  void reset() {
    _status = FeedbackProviderStatus.initial;
    _errorMessage = null;
    notifyListeners();
  }

  /// 获取错误捕获服务
  ErrorCaptureService get errorCaptureService => _errorCaptureService;

  /// 初始化错误捕获
  void initializeErrorCapture() {
    _errorCaptureService.initialize();
  }
}
