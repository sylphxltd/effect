/// Represents a value that can be either a Left (error) or Right (success).
/// 
/// Either is commonly used in functional programming to handle computations
/// that may fail without throwing exceptions.
sealed class Either<L, R> {
  const Either();

  /// Creates a Left value (typically representing an error)
  static Either<L, R> left<L, R>(L value) => Left(value);

  /// Creates a Right value (typically representing success)
  static Either<L, R> right<L, R>(R value) => Right(value);

  /// Maps the right value if this is a Right, otherwise returns this Left unchanged
  Either<L, R2> map<R2>(R2 Function(R) f) {
    return switch (this) {
      Left() => this as Either<L, R2>,
      Right(:final value) => Right(f(value)),
    };
  }

  /// Maps the left value if this is a Left, otherwise returns this Right unchanged
  Either<L2, R> mapLeft<L2>(L2 Function(L) f) {
    return switch (this) {
      Left(:final value) => Left(f(value)),
      Right() => this as Either<L2, R>,
    };
  }

  /// Flat maps the right value if this is a Right
  Either<L, R2> flatMap<R2>(Either<L, R2> Function(R) f) {
    return switch (this) {
      Left() => this as Either<L, R2>,
      Right(:final value) => f(value),
    };
  }

  /// Flat maps the left value if this is a Left
  Either<L2, R> flatMapLeft<L2>(Either<L2, R> Function(L) f) {
    return switch (this) {
      Left(:final value) => f(value),
      Right() => this as Either<L2, R>,
    };
  }

  /// Folds this Either into a single value
  T fold<T>(T Function(L) onLeft, T Function(R) onRight) {
    return switch (this) {
      Left(:final value) => onLeft(value),
      Right(:final value) => onRight(value),
    };
  }

  /// Returns the right value if this is a Right, otherwise returns the default value
  R getOrElse(R defaultValue) {
    return switch (this) {
      Left() => defaultValue,
      Right(:final value) => value,
    };
  }

  /// Returns the right value if this is a Right, otherwise computes and returns a default value
  R getOrElseGet(R Function() defaultValue) {
    return switch (this) {
      Left() => defaultValue(),
      Right(:final value) => value,
    };
  }

  /// Returns true if this is a Left
  bool get isLeft => this is Left<L, R>;

  /// Returns true if this is a Right
  bool get isRight => this is Right<L, R>;

  /// Swaps Left and Right
  Either<R, L> swap() {
    return switch (this) {
      Left(:final value) => Right(value),
      Right(:final value) => Left(value),
    };
  }

  @override
  String toString() {
    return switch (this) {
      Left(:final value) => 'Left($value)',
      Right(:final value) => 'Right($value)',
    };
  }
}

/// Represents the left side of Either (typically an error)
final class Left<L, R> extends Either<L, R> {
  final L value;
  const Left(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Left<L, R> && value == other.value;

  @override
  int get hashCode => value.hashCode;
}

/// Represents the right side of Either (typically a success value)
final class Right<L, R> extends Either<L, R> {
  final R value;
  const Right(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Right<L, R> && value == other.value;

  @override
  int get hashCode => value.hashCode;
}

/// Extension methods for working with Either
extension EitherExtensions<L, R> on Either<L, R> {
  /// Converts this Either to a nullable value, returning null for Left
  R? toNullable() => isRight ? (this as Right<L, R>).value : null;

  /// Converts this Either to a list, containing the right value or empty for Left
  List<R> toList() => isRight ? [(this as Right<L, R>).value] : [];

  /// Filters the right value with a predicate, converting to Left if false
  Either<L, R> filter(bool Function(R) predicate, L Function() orElse) {
    return switch (this) {
      Left() => this,
      Right(:final value) => predicate(value) ? this : Left(orElse()),
    };
  }
}