import 'option.dart';

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

  /// A predefined right value containing void (null in Dart)
  static Either<Never, dynamic> get voidValue => right(null);

  /// Type guard to check if a value is an Either
  static bool isEither(dynamic value) => value is Either;


  /// Flip the sides of an Either (alias for swap)
  static Either<R, L> flip<L, R>(Either<L, R> either) => either.swap();

  /// Get the right value as an Option
  static Option<R> getRight<L, R>(Either<L, R> either) {
    return either.fold(
      (_) => Option.none(),
      (value) => Option.some(value),
    );
  }

  /// Get the left value as an Option
  static Option<L> getLeft<L, R>(Either<L, R> either) {
    return either.fold(
      (value) => Option.some(value),
      (_) => Option.none(),
    );
  }

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

  /// Maps both left and right values
  Either<L2, R2> mapBoth<L2, R2>({
    required L2 Function(L) onLeft,
    required R2 Function(R) onRight,
  }) {
    return switch (this) {
      Left(:final value) => Left(onLeft(value)),
      Right(:final value) => Right(onRight(value)),
    };
  }

  /// Static version of mapBoth
  static Either<L2, R2> mapBothStatic<L, R, L2, R2>(
    Either<L, R> either, {
    required L2 Function(L) onLeft,
    required R2 Function(R) onRight,
  }) => either.mapBoth(onLeft: onLeft, onRight: onRight);

  /// Pattern match on Either with callbacks for both cases
  T match<T>({
    required T Function(L) onLeft,
    required T Function(R) onRight,
  }) => fold(onLeft, onRight);

  /// Static version of match
  static T matchStatic<L, R, T>(
    Either<L, R> either, {
    required T Function(L) onLeft,
    required T Function(R) onRight,
  }) => either.match(onLeft: onLeft, onRight: onRight);

  /// Merge left and right into a single value
  T merge<T>() {
    return switch (this) {
      Left(:final value) => value as T,
      Right(:final value) => value as T,
    };
  }

  /// Static version of merge
  static T mergeStatic<T>(Either<T, T> either) => either.merge<T>();

  /// Lift a predicate into an Either
  static Either<E, A> liftPredicate<A, E>(
    A value,
    bool Function(A) predicate,
    E Function(A) onError,
  ) {
    return predicate(value) ? right(value) : left(onError(value));
  }

  /// Filter with a predicate, converting to Left if false
  Either<dynamic, R> filterOrLeft<E>(
    bool Function(R) predicate,
    E Function() onError,
  ) {
    return switch (this) {
      Left(:final value) => Left(value),
      Right(:final value) => predicate(value) ? Right(value) : Left(onError()),
    };
  }

  /// Static version of filterOrLeft
  static Either<dynamic, R> filterOrLeftStatic<L, R, E>(
    Either<L, R> either,
    bool Function(R) predicate,
    E Function() onError,
  ) => either.filterOrLeft(predicate, onError);

  /// Create Either from nullable value
  static Either<E, A> fromNullable<A, E>(A? value, E Function() onNull) {
    return value != null ? right(value) : left(onNull());
  }

  /// Create Either from Option
  static Either<E, A> fromOption<A, E>(Option<A> option, E Function() onNone) {
    return option.fold(
      () => left(onNone()),
      (value) => right(value),
    );
  }

  /// Try to execute a function, catching exceptions
  static Either<Object, A> tryCall<A>(A Function() f) {
    try {
      return right(f());
    } catch (e) {
      return left(e);
    }
  }

  /// Try to execute a function with custom error handling
  static Either<E, A> tryWith<A, E>({
    required A Function() tryFn,
    required E Function(Object) catchFn,
  }) {
    try {
      return right(tryFn());
    } catch (e) {
      return left(catchFn(e));
    }
  }

  /// Get right value or null
  R? getOrNull() {
    return switch (this) {
      Left() => null,
      Right(:final value) => value,
    };
  }

  /// Static version of getOrNull
  static R? getOrNullStatic<L, R>(Either<L, R> either) => either.getOrNull();

  /// Get right value or throw with custom error
  R getOrThrowWith(Object Function(L) onLeft) {
    return switch (this) {
      Left(:final value) => throw onLeft(value),
      Right(:final value) => value,
    };
  }

  /// Get right value or throw
  R getOrThrow() {
    return switch (this) {
      Left() => throw Exception("getOrThrow called on a Left"),
      Right(:final value) => value,
    };
  }

  /// Static versions
  static R getOrThrowWithStatic<L, R>(Either<L, R> either, Object Function(L) onLeft) =>
      either.getOrThrowWith(onLeft);

  static R getOrThrowStatic<L, R>(Either<L, R> either) => either.getOrThrow();

  /// Chain computation (alias for flatMap)
  Either<L, R2> andThen<R2>(Either<L, R2> Function(R) f) => flatMap(f);

  /// Static version with various overloads
  static Either<L, R2> andThenStatic<L, R, R2>(
    Either<L, R> either,
    Either<L, R2> Function(R) f,
  ) => either.andThen(f);

  /// Applicative apply - this Either should contain a function
  Either<L, R2> ap<A, R2>(Either<L, A> value) {
    return flatMap((fn) => value.map((v) => (fn as Function)(v) as R2));
  }

  /// Zip with another Either using a combiner function
  Either<L, C> zipWith<R2, C>(Either<L, R2> other, C Function(R, R2) f) {
    return switch (this) {
      Left() => this as Either<L, C>,
      Right(:final value) => switch (other) {
        Left() => other as Either<L, C>,
        Right() => right(f(value, (other as Right<L, R2>).value)),
      },
    };
  }

  /// Static version of zipWith
  static Either<L, C> zipWithStatic<L, R, R2, C>(
    Either<L, R> either1,
    Either<L, R2> either2,
    C Function(R, R2) f,
  ) => either1.zipWith(either2, f);

  /// Collect all Either values into a single Either
  static Either<L, List<R>> all<L, R>(Iterable<Either<L, R>> eithers) {
    final List<R> results = [];
    for (final either in eithers) {
      switch (either) {
        case Left(:final value):
          return Left(value);
        case Right(:final value):
          results.add(value);
      }
    }
    return Right(results);
  }

  /// Alternative computation - use this Either if Right, otherwise try the alternative
  Either<L2, R> orElse<L2>(Either<L2, R> Function() alternative) {
    return switch (this) {
      Left() => alternative(),
      Right(:final value) => Right(value),
    };
  }

  /// Static version of orElse
  static Either<L2, R> orElseStatic<L, R, L2>(
    Either<L, R> either,
    Either<L2, R> Function() alternative,
  ) => either.orElse(alternative);

  /// Flat maps the right value if this is a Right
  Either<L, R2> flatMap<R2>(Either<L, R2> Function(R) f) {
    return switch (this) {
      Left(:final value) => Left(value),
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