import 'cause.dart';

/// Represents the result of executing an Effect.
/// 
/// An Exit can either be a Success with a value or a Failure with a cause.
sealed class Exit<A, E> {
  const Exit();

  /// Creates a successful exit with the given value
  static Exit<A, Never> succeed<A>(A value) => Success(value);

  /// Creates a failed exit with the given error
  static Exit<Never, E> fail<E>(E error) => Failure(Cause.fail(error));

  /// Creates a failed exit that died with the given throwable
  static Exit<Never, Never> die(Object throwable, [StackTrace? stackTrace]) =>
      Failure(Cause.die(throwable, stackTrace));

  /// Creates a failed exit with the given cause
  static Exit<Never, E> failCause<E>(Cause<E> cause) => Failure(cause);

  /// Maps the success value of this exit
  Exit<B, E> map<B>(B Function(A) f) {
    return switch (this) {
      Success(:final value) => Success(f(value)),
      Failure() => this as Exit<B, E>,
    };
  }

  /// Maps the error type of this exit
  Exit<A, E2> mapError<E2>(E2 Function(E) f) {
    return switch (this) {
      Success() => this as Exit<A, E2>,
      Failure(:final cause) => Failure(cause.map(f)),
    };
  }

  /// Flat maps this exit with a function that returns another exit
  Exit<B, E2> flatMap<B, E2>(Exit<B, E2> Function(A) f) {
    return switch (this) {
      Success(:final value) => f(value),
      Failure() => this as Exit<B, E2>,
    };
  }

  /// Folds this exit into a single value
  C fold<C>(
    C Function(Cause<E>) onFailure,
    C Function(A) onSuccess,
  ) {
    return switch (this) {
      Success(:final value) => onSuccess(value),
      Failure(:final cause) => onFailure(cause),
    };
  }

  /// Returns true if this is a Success
  bool get isSuccess => this is Success<A, E>;

  /// Returns true if this is a Failure
  bool get isFailure => this is Failure<A, E>;

  @override
  String toString() {
    return switch (this) {
      Success(:final value) => 'Success($value)',
      Failure(:final cause) => 'Failure($cause)',
    };
  }
}

/// Represents a successful exit with a value
final class Success<A, E> extends Exit<A, E> {
  final A value;
  const Success(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<A, E> && value == other.value;

  @override
  int get hashCode => value.hashCode;
}

/// Represents a failed exit with a cause
final class Failure<A, E> extends Exit<A, E> {
  final Cause<E> cause;
  const Failure(this.cause);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure<A, E> && cause == other.cause;

  @override
  int get hashCode => cause.hashCode;
}