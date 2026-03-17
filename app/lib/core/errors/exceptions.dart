abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => '[$code] $message';
}

class NetworkException extends AppException {
  NetworkException({
    String? message,
    String? code,
    dynamic originalError,
  }) : super(
          message: message ?? '网络请求失败',
          code: code ?? 'NETWORK_ERROR',
          originalError: originalError,
        );
}

class TimeoutException extends NetworkException {
  TimeoutException({dynamic originalError})
      : super(
          message: '请求超时',
          code: 'TIMEOUT',
          originalError: originalError,
        );
}

class NoConnectionException extends NetworkException {
  NoConnectionException({dynamic originalError})
      : super(
          message: '网络连接不可用',
          code: 'NO_CONNECTION',
          originalError: originalError,
        );
}

class StorageException extends AppException {
  StorageException({
    String? message,
    String? code,
    dynamic originalError,
  }) : super(
          message: message ?? '存储操作失败',
          code: code ?? 'STORAGE_ERROR',
          originalError: originalError,
        );
}

class DatabaseException extends StorageException {
  DatabaseException({dynamic originalError})
      : super(
          message: '数据库操作失败',
          code: 'DATABASE_ERROR',
          originalError: originalError,
        );
}

class BusinessException extends AppException {
  BusinessException({
    required String message,
    String? code,
    dynamic originalError,
  }) : super(
          message: message,
          code: code ?? 'BUSINESS_ERROR',
          originalError: originalError,
        );
}

class AuthException extends BusinessException {
  AuthException({String? message, dynamic originalError})
      : super(
          message: message ?? '认证失败',
          code: 'AUTH_ERROR',
          originalError: originalError,
        );
}

class VipRequiredException extends BusinessException {
  VipRequiredException({String? feature, dynamic originalError})
      : super(
          message: feature != null ? '$feature需要Pro版会员' : '需要Pro版会员',
          code: 'VIP_REQUIRED',
          originalError: originalError,
        );
}
