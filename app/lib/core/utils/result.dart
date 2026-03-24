import '../errors/failures.dart';

sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

final class Error<T> extends Result<T> {
  final Failure failure;
  const Error(this.failure);
}

extension ResultExtension<T> on Result<T> {
  bool get isSuccess => this is Success<T>;
  bool get isError => this is Error<T>;

  T? get dataOrNull => this is Success<T> ? (this as Success<T>).data : null;
  Failure? get failureOrNull =>
      this is Error<T> ? (this as Error<T>).failure : null;

  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(Failure failure) onError,
  }) {
    return switch (this) {
      Success<T>(:final data) => onSuccess(data),
      Error<T>(:final failure) => onError(failure),
    };
  }

  Result<R> map<R>(R Function(T data) transform) {
    return switch (this) {
      Success<T>(:final data) => Success(transform(data)),
      Error<T>(:final failure) => Error(failure),
    };
  }

  Result<R> flatMap<R>(Result<R> Function(T data) transform) {
    return switch (this) {
      Success<T>(:final data) => transform(data),
      Error<T>(:final failure) => Error(failure),
    };
  }
}
