import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../errors/exceptions.dart';
import '../errors/failures.dart';

class ErrorHandler {
  static final Logger _logger = Logger();

  static String handleException(Exception e) {
    if (e is NetworkException) {
      _logger.e('Network error: ${e.message}', error: e);
      return e.message;
    } else if (e is StorageException) {
      _logger.e('Storage error: ${e.message}', error: e);
      return '数据保存失败，请稍后重试';
    } else if (e is BusinessException) {
      _logger.w('Business error: ${e.message}', error: e);
      return e.message;
    } else if (e is AuthException) {
      _logger.w('Auth error: ${e.message}', error: e);
      return '请先登录';
    } else {
      _logger.e('Unknown error: ${e.toString()}', error: e);
      return '操作失败，请稍后重试';
    }
  }

  static Failure exceptionToFailure(Exception e) {
    if (e is NetworkException) {
      return NetworkFailure(message: e.message, code: e.code);
    } else if (e is StorageException) {
      return StorageFailure(message: e.message, code: e.code);
    } else if (e is BusinessException) {
      return BusinessFailure(message: e.message, code: e.code);
    } else {
      return const BusinessFailure(message: '未知错误');
    }
  }

  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
