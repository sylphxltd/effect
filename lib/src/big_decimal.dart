import 'option.dart';

/// High-precision decimal arithmetic for Dart.
///
/// BigDecimal provides arbitrary precision decimal arithmetic with support for
/// various rounding modes and mathematical operations.
class BigDecimal {
  final BigInt _value;
  final int _scale;

  const BigDecimal._(this._value, this._scale);

  /// Creates a BigDecimal with the given value and scale.
  /// 
  /// The scale represents the number of decimal places.
  /// A positive scale means digits after the decimal point.
  /// A negative scale means trailing zeros before the decimal point.
  /// 
  /// Example:
  /// ```dart
  /// BigDecimal.make(123n, 2) // represents 1.23
  /// BigDecimal.make(123n, -1) // represents 1230
  /// ```
  static BigDecimal make(BigInt value, int scale) {
    return BigDecimal._(value, scale);
  }

  /// Creates a normalized BigDecimal with the given value and scale.
  /// This is an unsafe operation that assumes the input is already normalized.
  static BigDecimal unsafeMakeNormalized(BigInt value, int scale) {
    return BigDecimal._(value, scale);
  }

  /// Checks if the given value is a BigDecimal.
  ///
  /// Example:
  /// ```dart
  /// BigDecimal.isBigDecimal(BigDecimal.unsafeFromString("123.45")) // true
  /// BigDecimal.isBigDecimal("123") // false
  /// BigDecimal.isBigDecimal(123) // false
  /// ```
  static bool isBigDecimal(Object? value) {
    return value is BigDecimal;
  }

  /// Returns the sign of the BigDecimal.
  /// Returns -1 for negative numbers, 0 for zero, and 1 for positive numbers.
  ///
  /// Example:
  /// ```dart
  /// BigDecimal.sign($("-5")) // -1
  /// BigDecimal.sign($("0")) // 0
  /// BigDecimal.sign($("5")) // 1
  /// ```
  static int sign(BigDecimal bd) {
    if (bd._value == BigInt.zero) return 0;
    return bd._value.isNegative ? -1 : 1;
  }

  /// Checks if two BigDecimal values are equal.
  /// This method normalizes both values before comparison, so trailing zeros are ignored.
  ///
  /// Example:
  /// ```dart
  /// BigDecimal.equals($("1"), $("1")) // true
  /// BigDecimal.equals($("0.00012300"), $("0.000123")) // true
  /// BigDecimal.equals($("5"), $("5.0")) // true
  /// BigDecimal.equals($("1"), $("2")) // false
  /// ```
  static bool equals(BigDecimal a, BigDecimal b) {
    return a == b;
  }

  /// Adds two BigDecimal values.
  ///
  /// Example:
  /// ```dart
  /// BigDecimal.sum($("2"), $("0")) // $("2")
  /// BigDecimal.sum($("2"), $("1")) // $("3")
  /// BigDecimal.sum($("1.23"), $("0.0045678")) // $("1.2345678")
  /// BigDecimal.sum($("123.456"), $("-123.456")) // $("0")
  /// ```
  static BigDecimal sum(BigDecimal a, BigDecimal b) {
    // Align scales
    final maxScale = a._scale > b._scale ? a._scale : b._scale;
    final aValue = a._value * BigInt.from(10).pow(maxScale - a._scale);
    final bValue = b._value * BigInt.from(10).pow(maxScale - b._scale);
    
    final resultValue = aValue + bValue;
    return BigDecimal._(resultValue, maxScale);
  }

  /// Multiplies two BigDecimal values.
  ///
  /// Example:
  /// ```dart
  /// BigDecimal.multiply($("3"), $("2")) // $("6")
  /// BigDecimal.multiply($("3"), $("0")) // $("0")
  /// BigDecimal.multiply($("3"), $("-1")) // $("-3")
  /// BigDecimal.multiply($("3"), $("0.5")) // $("1.5")
  /// ```
  static BigDecimal multiply(BigDecimal a, BigDecimal b) {
    final resultValue = a._value * b._value;
    final resultScale = a._scale + b._scale;
    return BigDecimal._(resultValue, resultScale);
  }

  /// Subtracts one BigDecimal from another.
  ///
  /// Example:
  /// ```dart
  /// BigDecimal.subtract($("3"), $("1")) // $("2")
  /// BigDecimal.subtract($("3"), $("0")) // $("3")
  /// BigDecimal.subtract($("3"), $("-1")) // $("4")
  /// BigDecimal.subtract($("3"), $("0.5")) // $("2.5")
  /// ```
  static BigDecimal subtract(BigDecimal a, BigDecimal b) {
    // Align scales
    final maxScale = a._scale > b._scale ? a._scale : b._scale;
    final aValue = a._value * BigInt.from(10).pow(maxScale - a._scale);
    final bValue = b._value * BigInt.from(10).pow(maxScale - b._scale);
    
    final resultValue = aValue - bValue;
    return BigDecimal._(resultValue, maxScale);
  }

  /// Helper function for rounding operations.
  /// Returns 1 if the value should be rounded up, 0 otherwise.
  ///
  /// This function examines the first (leftmost) digit to determine if rounding up is needed.
  /// - If the first digit is >= 5, returns 1 (round up)
  /// - If the first digit is < 5, returns 0 (don't round up)
  ///
  /// Example:
  /// ```dart
  /// BigDecimal.roundTerminal(BigInt.from(4)) // BigInt.zero
  /// BigDecimal.roundTerminal(BigInt.from(5)) // BigInt.one
  /// BigDecimal.roundTerminal(BigInt.from(49)) // BigInt.zero (first digit is 4)
  /// BigDecimal.roundTerminal(BigInt.from(59)) // BigInt.one (first digit is 5)
  /// ```
  static BigInt roundTerminal(BigInt value) {
    if (value == BigInt.zero) return BigInt.zero;
    
    // Get the absolute value for processing
    final absValue = value.abs();
    
    // Convert to string to get the first digit
    final str = absValue.toString();
    final firstDigit = int.parse(str[0]);
    
    // If first digit >= 5, round up
    return firstDigit >= 5 ? BigInt.one : BigInt.zero;
  }

  /// Divides one BigDecimal by another with high precision.
  /// Returns Option.none() if division by zero.
  ///
  /// Example:
  /// ```dart
  /// BigDecimal.divide($("4"), $("2")) // Some($("2"))
  /// BigDecimal.divide($("1"), $("3")) // Some($("0.333..."))
  /// BigDecimal.divide($("5"), $("0")) // None()
  /// ```
  static Option<BigDecimal> divide(BigDecimal a, BigDecimal b) {
    // Check for division by zero
    if (b._value == BigInt.zero) {
      return Option.none();
    }

    // For division, we need to calculate a/b with sufficient precision
    // We'll use a scale of 100 decimal places for high precision
    const precision = 100;
    
    // Scale up the dividend for precision
    final scaledDividend = a._value * BigInt.from(10).pow(precision);
    
    // Adjust for the scales
    final resultScale = a._scale - b._scale + precision;
    
    // Perform the division
    final quotient = scaledDividend ~/ b._value;
    
    return Option.some(BigDecimal._(quotient, resultScale));
  }

  /// Divides one BigDecimal by another unsafely (throws on division by zero).
  ///
  /// Example:
  /// ```dart
  /// BigDecimal.unsafeDivide($("4"), $("2")) // $("2")
  /// BigDecimal.unsafeDivide($("5"), $("0")) // throws RangeError
  /// ```
  static BigDecimal unsafeDivide(BigDecimal a, BigDecimal b) {
    final result = divide(a, b);
    return result.fold(
      () => throw RangeError('Division by zero'),
      (value) => value,
    );
  }

  /// Equivalence function for BigDecimal comparison.
  /// Returns true if two BigDecimals are mathematically equal.
  ///
  /// Example:
  /// ```dart
  /// BigDecimal.Equivalence($("1"), $("1.0"))       // true
  /// BigDecimal.Equivalence($("1"), $("2"))         // false
  /// ```
  static bool Equivalence(BigDecimal a, BigDecimal b) {
    return equals(a, b);
  }

  /// Ordering function for BigDecimal comparison.
  /// Returns -1 if a < b, 0 if a == b, 1 if a > b.
  ///
  /// Example:
  /// ```dart
  /// BigDecimal.Order($("1"), $("2"))       // -1
  /// BigDecimal.Order($("2"), $("1"))       // 1
  /// BigDecimal.Order($("2"), $("2"))       // 0
  /// ```
  static int Order(BigDecimal a, BigDecimal b) {
    // Align scales for comparison
    final maxScale = a._scale > b._scale ? a._scale : b._scale;
    final aValue = a._value * BigInt.from(10).pow(maxScale - a._scale);
    final bValue = b._value * BigInt.from(10).pow(maxScale - b._scale);
    
    final comparison = aValue.compareTo(bValue);
    if (comparison < 0) return -1;
    if (comparison > 0) return 1;
    return 0;
  }

  /// Returns true if a is less than b.
  ///
  /// Example:
  /// ```dart
  /// BigDecimal.lessThan($("2"), $("3"))     // true
  /// BigDecimal.lessThan($("3"), $("3"))     // false
  /// ```
  static bool lessThan(BigDecimal a, BigDecimal b) {
    return Order(a, b) < 0;
  }

  /// Returns true if a is less than or equal to b.
  ///
  /// Example:
  /// ```dart
  /// BigDecimal.lessThanOrEqualTo($("2"), $("3"))     // true
  /// BigDecimal.lessThanOrEqualTo($("3"), $("3"))     // true
  /// ```
  static bool lessThanOrEqualTo(BigDecimal a, BigDecimal b) {
    return Order(a, b) <= 0;
  }

  /// Returns true if a is greater than b.
  ///
  /// Example:
  /// ```dart
  /// BigDecimal.greaterThan($("4"), $("3"))     // true
  /// BigDecimal.greaterThan($("3"), $("3"))     // false
  /// ```
  static bool greaterThan(BigDecimal a, BigDecimal b) {
    return Order(a, b) > 0;
  }

  /// Returns true if a is greater than or equal to b.
  ///
  /// Example:
  /// ```dart
  /// BigDecimal.greaterThanOrEqualTo($("3"), $("3"))     // true
  /// BigDecimal.greaterThanOrEqualTo($("4"), $("3"))     // true
  /// ```
  static bool greaterThanOrEqualTo(BigDecimal a, BigDecimal b) {
    return Order(a, b) >= 0;
  }

  /// Returns the minimum of two BigDecimals.
  ///
  /// Example:
  /// ```dart
  /// BigDecimal.min($("2"), $("3"))         // $("2")
  /// BigDecimal.min($("5"), $("0.1"))       // $("0.1")
  /// ```
  static BigDecimal min(BigDecimal a, BigDecimal b) {
    return lessThan(a, b) ? a : b;
  }

  /// Returns the maximum of two BigDecimals.
  ///
  /// Example:
  /// ```dart
  /// BigDecimal.max($("2"), $("3"))         // $("3")
  /// BigDecimal.max($("5"), $("0.1"))       // $("5")
  /// ```
  static BigDecimal max(BigDecimal a, BigDecimal b) {
    return greaterThan(a, b) ? a : b;
  }

  /// Returns the absolute value of a BigDecimal.
  ///
  /// Example:
  /// ```dart
  /// BigDecimal.abs($("2"))                 // $("2")
  /// BigDecimal.abs($("-3"))                // $("3")
  /// ```
  static BigDecimal abs(BigDecimal a) {
    return a._value < BigInt.zero
        ? BigDecimal._(a._value.abs(), a._scale)
        : a;
  }

  /// Returns the negation of a BigDecimal.
  ///
  /// Example:
  /// ```dart
  /// BigDecimal.negate($("2"))              // $("-2")
  /// BigDecimal.negate($("-3"))             // $("3")
  /// ```
  static BigDecimal negate(BigDecimal a) {
    return BigDecimal._(-a._value, a._scale);
  }

  /// Returns the remainder of dividing a by b.
  /// Returns Option.none() if division by zero.
  ///
  /// Example:
  /// ```dart
  /// BigDecimal.remainder($("5"), $("2"))       // Some($("1"))
  /// BigDecimal.remainder($("4"), $("2"))       // Some($("0"))
  /// BigDecimal.remainder($("5"), $("0"))       // None()
  /// ```
  static Option<BigDecimal> remainder(BigDecimal a, BigDecimal b) {
    if (b._value == BigInt.zero) {
      return Option.none();
    }

    // For remainder: a % b = a - (a / b).truncate() * b
    final quotientOption = divide(a, b);
    if (quotientOption.isNone) {
      return Option.none();
    }

    final quotient = quotientOption.fold(() => throw StateError('Should not happen'), (q) => q);
    // Truncate the quotient (towards zero)
    final truncatedQuotient = _truncateToInteger(quotient);
    final product = multiply(truncatedQuotient, b);
    final remainderValue = subtract(a, product);

    return Option.some(remainderValue);
  }

  /// Returns the remainder of dividing a by b, throwing on division by zero.
  ///
  /// Example:
  /// ```dart
  /// BigDecimal.unsafeRemainder($("5"), $("2"))     // $("1")
  /// BigDecimal.unsafeRemainder($("5"), $("0"))     // throws RangeError
  /// ```
  static BigDecimal unsafeRemainder(BigDecimal a, BigDecimal b) {
    final result = remainder(a, b);
    return result.fold(
      () => throw RangeError('Division by zero'),
      (value) => value,
    );
  }

  /// Helper function to truncate a BigDecimal to an integer (towards zero).
  static BigDecimal _truncateToInteger(BigDecimal value) {
    if (value._scale <= 0) {
      return value; // Already an integer or larger
    }

    // Remove decimal places by dividing by 10^scale
    final divisor = BigInt.from(10).pow(value._scale);
    final truncatedValue = value._value ~/ divisor;
    return BigDecimal._(truncatedValue, 0);
  }

  /// Checks if a value is between minimum and maximum (inclusive).
  ///
  /// Example:
  /// ```dart
  /// BigDecimal.between($("3"), {minimum: $("0"), maximum: $("5")})  // true
  /// BigDecimal.between($("6"), {minimum: $("0"), maximum: $("5")})  // false
  /// ```
  static bool between(BigDecimal value, {required BigDecimal minimum, required BigDecimal maximum}) {
    return greaterThanOrEqualTo(value, minimum) && lessThanOrEqualTo(value, maximum);
  }

  /// Clamps a value between minimum and maximum.
  ///
  /// Example:
  /// ```dart
  /// BigDecimal.clamp($("3"), {minimum: $("0"), maximum: $("5")})   // $("3")
  /// BigDecimal.clamp($("-1"), {minimum: $("0"), maximum: $("5")})  // $("0")
  /// BigDecimal.clamp($("6"), {minimum: $("0"), maximum: $("5")})   // $("5")
  /// ```
  static BigDecimal clamp(BigDecimal value, {required BigDecimal minimum, required BigDecimal maximum}) {
    if (lessThan(value, minimum)) return minimum;
    if (greaterThan(value, maximum)) return maximum;
    return value;
  }

  /// Returns true if the BigDecimal represents zero.
  ///
  /// Example:
  /// ```dart
  /// BigDecimal.isZero($("0"))      // true
  /// BigDecimal.isZero($("0.000"))  // true
  /// BigDecimal.isZero($("1"))      // false
  /// ```
  static bool isZero(BigDecimal value) {
    return value._value == BigInt.zero;
  }

  /// Returns true if the BigDecimal is positive (> 0).
  ///
  /// Example:
  /// ```dart
  /// BigDecimal.isPositive($("1"))      // true
  /// BigDecimal.isPositive($("0"))      // false
  /// BigDecimal.isPositive($("-1"))     // false
  /// ```
  static bool isPositive(BigDecimal value) {
    return value._value > BigInt.zero;
  }

  /// Returns true if the BigDecimal is negative (< 0).
  ///
  /// Example:
  /// ```dart
  /// BigDecimal.isNegative($("-1"))     // true
  /// BigDecimal.isNegative($("0"))      // false
  /// BigDecimal.isNegative($("1"))      // false
  /// ```
  static bool isNegative(BigDecimal value) {
    return value._value < BigInt.zero;
  }

  /// Returns true if the BigDecimal represents an integer.
  ///
  /// Example:
  /// ```dart
  /// BigDecimal.isInteger($("1"))       // true
  /// BigDecimal.isInteger($("1.0"))     // true
  /// BigDecimal.isInteger($("1.1"))     // false
  /// ```
  static bool isInteger(BigDecimal value) {
    if (value._scale <= 0) {
      return true; // No decimal places or negative scale
    }

    // Check if all decimal places are zero
    final divisor = BigInt.from(10).pow(value._scale);
    return value._value % divisor == BigInt.zero;
  }

  /// Sums all BigDecimals in an iterable.
  ///
  /// Example:
  /// ```dart
  /// BigDecimal.sumAll([])                           // $("0")
  /// BigDecimal.sumAll([$("2.5"), $("0.5")])        // $("3")
  /// ```
  static BigDecimal sumAll(Iterable<BigDecimal> values) {
    BigDecimal result = BigDecimal._(BigInt.zero, 0);
    for (final value in values) {
      result = sum(result, value);
    }
    return result;
  }

  /// Creates a BigDecimal from a string representation.
  /// Throws an exception if the string is not a valid number.
  /// 
  /// Example:
  /// ```dart
  /// BigDecimal.unsafeFromString("123.45") // BigDecimal representing 123.45
  /// BigDecimal.unsafeFromString("0") // BigDecimal representing 0
  /// ```
  static BigDecimal unsafeFromString(String str) {
    if (str.isEmpty) {
      return BigDecimal._(BigInt.zero, 0);
    }

    // Handle scientific notation
    final expMatch = RegExp(r'^([+-]?[0-9]*\.?[0-9]+)[eE]([+-]?[0-9]+)$').firstMatch(str);
    if (expMatch != null) {
      final mantissa = expMatch.group(1)!;
      final exponent = int.parse(expMatch.group(2)!);
      
      final baseBd = unsafeFromString(mantissa);
      final newScale = baseBd._scale - exponent;
      return BigDecimal._(baseBd._value, newScale);
    }

    // Handle regular decimal notation
    final parts = str.split('.');
    if (parts.length > 2) {
      throw FormatException('Invalid decimal format: $str');
    }

    final integerPart = parts[0];
    final fractionalPart = parts.length > 1 ? parts[1] : '';
    
    final scale = fractionalPart.length;
    final valueStr = integerPart + fractionalPart;
    final value = BigInt.parse(valueStr.isEmpty ? '0' : valueStr);
    
    return BigDecimal._(value, scale);
  }

  /// The internal value (unscaled).
  BigInt get value => _value;

  /// The scale (number of decimal places).
  int get scale => _scale;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BigDecimal) return false;
    
    // Normalize both for comparison
    final thisNorm = normalize(this);
    final otherNorm = normalize(other);
    
    return thisNorm._value == otherNorm._value && thisNorm._scale == otherNorm._scale;
  }

  @override
  int get hashCode => Object.hash(_value, _scale);

  @override
  String toString() => 'BigDecimal(${format(this)})';

  /// Normalizes a BigDecimal by removing trailing zeros.
  static BigDecimal normalize(BigDecimal bd) {
    if (bd._value == BigInt.zero) {
      return BigDecimal._(BigInt.zero, 0);
    }

    BigInt value = bd._value;
    int scale = bd._scale;

    // Remove trailing zeros
    while (scale > 0 && value % BigInt.from(10) == BigInt.zero) {
      value = value ~/ BigInt.from(10);
      scale--;
    }

    // Handle case where we can represent as smaller scale (e.g., 1200 -> 12 * 10^2)
    while (scale < 0 && value % BigInt.from(10) == BigInt.zero) {
      value = value ~/ BigInt.from(10);
      scale++;
    }

    return BigDecimal._(value, scale);
  }

  /// Formats a BigDecimal as a string.
  static String format(BigDecimal bd) {
    final normalized = normalize(bd);
    final value = normalized._value;
    final scale = normalized._scale;

    if (scale <= 0) {
      // Integer or large number
      if (scale == 0) {
        return value.toString();
      } else {
        // Need to add zeros
        final magnitude = -scale;
        if (magnitude > 20) {
          // Use scientific notation for very large numbers
          final str = value.toString();
          if (str.length == 1) {
            return '${str}e+${magnitude}';
          } else {
            final first = str[0];
            final rest = str.substring(1);
            final exp = magnitude + rest.length;
            return '$first.${rest}e+$exp';
          }
        } else {
          return value.toString() + '0' * magnitude;
        }
      }
    } else {
      // Decimal number
      final str = value.abs().toString();
      final sign = value.isNegative ? '-' : '';
      
      if (str.length <= scale) {
        // Need leading zeros
        final zeros = '0' * (scale - str.length);
        return '${sign}0.${zeros}${str}';
      } else {
        // Split at decimal point
        final integerPart = str.substring(0, str.length - scale);
        final fractionalPart = str.substring(str.length - scale);
        return '${sign}${integerPart}.${fractionalPart}';
      }
    }
  }
}

/// Shorthand function for creating BigDecimal from string.
/// Equivalent to BigDecimal.unsafeFromString.
BigDecimal $(String str) => BigDecimal.unsafeFromString(str);