/// Represents the cause of an effect failure.
/// 
/// A cause can be either an expected error (Fail) or an unexpected defect (Die).
sealed class Cause<E> {
  const Cause();

  /// Creates a Fail cause from an expected error
  static Cause<E> fail<E>(E error) => Fail(error);

  /// Creates a Die cause from an unexpected throwable
  static Cause<Never> die(Object throwable, [StackTrace? stackTrace]) =>
      Die(throwable, stackTrace);

  /// Converts this cause to an exception that can be thrown
  Exception toException() {
    return switch (this) {
      Fail(:final error) => error is Exception 
          ? error 
          : Exception('Effect failed with error: $error'),
      Die(:final throwable) => throwable is Exception
          ? throwable
          : Exception('Effect died with throwable: $throwable'),
    };
  }

  /// Maps the error type of this cause
  Cause<E2> map<E2>(E2 Function(E) f) {
    return switch (this) {
      Fail(:final error) => Fail(f(error)),
      Die() as Die => this as Cause<E2>,
    };
  }

  @override
  String toString() {
    return switch (this) {
      Fail(:final error) => 'Fail($error)',
      Die(:final throwable, :final stackTrace) => 
          'Die($throwable${stackTrace != null ? ', $stackTrace' : ''})',
    };
  }
}

/// Represents a failure caused by an expected error
final class Fail<E> extends Cause<E> {
  final E error;
  const Fail(this.error);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Fail<E> && error == other.error;

  @override
  int get hashCode => error.hashCode;
}

/// Represents a failure caused by an unexpected defect/throwable
final class Die extends Cause<Never> {
  final Object throwable;
  final StackTrace? stackTrace;
  const Die(this.throwable, [this.stackTrace]);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Die && 
      throwable == other.throwable && 
      stackTrace == other.stackTrace;

  @override
  int get hashCode => Object.hash(throwable, stackTrace);
}