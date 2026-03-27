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
    super.message,
    super.code,
    super.originalError,
  }) : super(
          message: message ?? '网络请求失败',
          code: code ?? 'NETWORK_ERROR',
        );
}

class TimeoutException extends NetworkException {
  TimeoutException({super.originalError})
      : super(
          message: '请求超时',
          code: 'TIMEOUT',
        );
}

class NoConnectionException extends NetworkException {
  NoConnectionException({super.originalError})
      : super(
          message: '网络连接不可用',
          code: 'NO_CONNECTION',
        );
}

class StorageException extends AppException {
  StorageException({
    super.message,
    super.code,
    super.originalError,
  }) : super(
          message: message ?? '存储操作失败',
          code: code ?? 'STORAGE_ERROR',
        );
}

class DatabaseException extends StorageException {
  DatabaseException({super.originalError})
      : super(
          message: '数据库操作失败',
          code: 'DATABASE_ERROR',
        );
}

class BusinessException extends AppException {
  BusinessException({
    required super.message,
    super.code,
    super.originalError,
  }) : super(
          code: code ?? 'BUSINESS_ERROR',
        );
}

class AuthException extends BusinessException {
  AuthException({super.message, super.originalError})
      : super(
          message: message ?? '认证失败',
          code: 'AUTH_ERROR',
        );
}

class VipRequiredException extends BusinessException {
  VipRequiredException({String? feature, super.originalError})
      : super(
          message: feature != null ? '$feature需要Pro版会员' : '需要Pro版会员',
          code: 'VIP_REQUIRED',
        );
}
