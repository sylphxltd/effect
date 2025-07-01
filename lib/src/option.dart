/// Option type for representing optional values
/// 
/// This module provides the Option type for handling nullable values
/// in a functional programming style, inspired by Effect-TS Option module.
library;

/// Represents an optional value that can be either Some(value) or None.
sealed class Option<A> {
  const Option();

  /// Creates an Option containing a value.
  static Option<A> some<A>(A value) => Some(value);

  /// Creates an empty Option.
  static Option<A> none<A>() => None<A>();

  /// Creates an Option from a nullable value.
  /// Returns None if the value is null, otherwise returns Some(value).
  static Option<A> fromNullable<A>(A? value) {
    return value == null ? none<A>() : some(value);
  }

  /// Maps the value inside this Option if it exists.
  Option<B> map<B>(B Function(A) f) {
    return switch (this) {
      Some(:final value) => some(f(value)),
      None() => none<B>(),
    };
  }

  /// Flat maps this Option with another Option-returning function.
  Option<B> flatMap<B>(Option<B> Function(A) f) {
    return switch (this) {
      Some(:final value) => f(value),
      None() => none<B>(),
    };
  }

  /// Returns the value if this is Some, otherwise returns the default value.
  A getOrElse(A defaultValue) {
    return switch (this) {
      Some(:final value) => value,
      None() => defaultValue,
    };
  }

  /// Returns true if this is Some.
  bool get isSome => this is Some<A>;

  /// Returns true if this is None.
  bool get isNone => this is None<A>;

  /// Folds this Option into a single value.
  B fold<B>(B Function() onNone, B Function(A) onSome) {
    return switch (this) {
      Some(:final value) => onSome(value),
      None() => onNone(),
    };
  }
}

/// Represents an Option containing a value.
final class Some<A> extends Option<A> {
  final A value;

  const Some(this.value);

  @override
  bool operator ==(Object other) {
    return other is Some<A> && value == other.value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Some($value)';
}

/// Represents an empty Option.
final class None<A> extends Option<A> {
  const None();

  @override
  bool operator ==(Object other) => other is None<A>;

  @override
  int get hashCode => 0;

  @override
  String toString() => 'None';
}