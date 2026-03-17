class Failure {
  final String message;
  final String? code;

  const Failure({
    required this.message,
    this.code,
  });
}

class NetworkFailure extends Failure {
  const NetworkFailure({String? message})
      : super(
          message: message ?? '网络请求失败',
          code: 'NETWORK_ERROR',
        );
}

class StorageFailure extends Failure {
  const StorageFailure({String? message})
      : super(
          message: message ?? '存储操作失败',
          code: 'STORAGE_ERROR',
        );
}

class BusinessFailure extends Failure {
  const BusinessFailure({
    required String message,
    String? code,
  }) : super(
          message: message,
          code: code,
        );
}
