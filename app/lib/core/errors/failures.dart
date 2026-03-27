class Failure {
  final String message;
  final String? code;

  const Failure({
    required this.message,
    this.code,
  });
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message, super.code})
      : super(
          message: message ?? '网络请求失败',
          code: code ?? 'NETWORK_ERROR',
        );
}

class StorageFailure extends Failure {
  const StorageFailure({super.message, super.code})
      : super(
          message: message ?? '存储操作失败',
          code: code ?? 'STORAGE_ERROR',
        );
}
