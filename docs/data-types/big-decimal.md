# BigDecimal

BigDecimal provides high-precision decimal arithmetic for financial and scientific calculations where floating-point precision errors are unacceptable. It's designed to handle monetary calculations, scientific computations, and any scenario requiring exact decimal arithmetic.

## Creating BigDecimals

### Basic Construction

```dart
import 'package:effect_dart/effect_dart.dart';

// From string (recommended)
final price = $("123.456");
final quantity = $("2.5");
final zero = $("0");

// Using the constructor
final amount = BigDecimal("999.99");
final negative = BigDecimal("-42.50");
```

### Type Checking

```dart
// Check if a value is a BigDecimal
print(BigDecimal.isBigDecimal(price)); // true
print(BigDecimal.isBigDecimal("123")); // false
print(BigDecimal.isBigDecimal(123.45)); // false
```

## Basic Arithmetic Operations

### Addition and Subtraction

```dart
final price = $("123.45");
final tax = $("9.88");
final discount = $("10.00");

// Addition
final total = BigDecimal.sum(price, tax); // 133.33
final grandTotal = BigDecimal.sumAll([price, tax, $("5.00")]); // 138.33

// Subtraction
final discounted = BigDecimal.subtract(total, discount); // 123.33
```

### Multiplication

```dart
final price = $("123.456");
final quantity = $("2.5");
final taxRate = $("0.08");

// Basic multiplication
final subtotal = BigDecimal.multiply(price, quantity); // 308.64
final tax = BigDecimal.multiply(subtotal, taxRate); // 24.6912
```

### Division

BigDecimal provides both safe and unsafe division operations:

```dart
final dividend = $("10");
final divisor = $("3");
final zero = $("0");

// Safe division (returns Option)
final result = BigDecimal.divide(dividend, divisor); 
// Some(3.333333333333333...)

final divideByZero = BigDecimal.divide(dividend, zero); 
// None()

// Unsafe division (throws on division by zero)
final quotient = BigDecimal.unsafeDivide($("15"), $("3")); // 5.0

try {
  BigDecimal.unsafeDivide($("10"), $("0")); // Throws!
} catch (e) {
  print("Division by zero error: $e");
}
```

### Remainder Operations

```dart
final dividend = $("7");
final divisor = $("3");

// Safe remainder
final remainder = BigDecimal.remainder(dividend, divisor); // Some(1)

// Unsafe remainder
final rem = BigDecimal.unsafeRemainder(dividend, divisor); // 1

// Remainder by zero returns None/throws
final remByZero = BigDecimal.remainder($("7"), $("0")); // None()
```

## Comparison Operations

### Equality

BigDecimal provides precise equality that handles trailing zeros correctly:

```dart
final a = $("1.0");
final b = $("1.00");
final c = $("1.01");

// Precise equality (normalizes trailing zeros)
print(BigDecimal.equals(a, b)); // true
print(BigDecimal.equals(a, c)); // false

// Standard equality
print(a == b); // May be false due to string representation
```

### Ordering

```dart
final small = $("1.5");
final medium = $("2.0");
final large = $("3.5");

// Comparison operations
print(BigDecimal.lessThan(small, medium)); // true
print(BigDecimal.lessThanOrEqualTo(medium, medium)); // true
print(BigDecimal.greaterThan(large, medium)); // true
print(BigDecimal.greaterThanOrEqualTo(large, large)); // true

// Order function (-1, 0, 1)
print(BigDecimal.Order(small, medium)); // -1
print(BigDecimal.Order(medium, medium)); // 0
print(BigDecimal.Order(large, medium)); // 1

// Min and max
final minimum = BigDecimal.min(small, large); // 1.5
final maximum = BigDecimal.max(small, large); // 3.5
```

## Sign Operations

```dart
final positive = $("5.5");
final negative = $("-3.2");
final zero = $("0");

// Get sign (-1, 0, 1)
print(BigDecimal.sign(positive)); // 1
print(BigDecimal.sign(negative)); // -1
print(BigDecimal.sign(zero)); // 0

// Absolute value
final abs1 = BigDecimal.abs(negative); // 3.2
final abs2 = BigDecimal.abs(positive); // 5.5

// Negate
final negated = BigDecimal.negate(positive); // -5.5
```

## Utility Functions

### Type Checking

```dart
final value = $("42.0");
final negative = $("-10");
final zero = $("0");

print(BigDecimal.isZero(zero)); // true
print(BigDecimal.isPositive(value)); // true
print(BigDecimal.isNegative(negative)); // true
print(BigDecimal.isInteger($("42.0"))); // true
print(BigDecimal.isInteger($("42.5"))); // false
```

### Bounds Checking

```dart
final value = $("3.5");
final min = $("0");
final max = $("5");

// Check if value is within bounds
final inRange = BigDecimal.between(value, minimum: min, maximum: max); // true

// Clamp value to bounds
final clamped = BigDecimal.clamp($("6"), minimum: min, maximum: max); // 5
final clampedLow = BigDecimal.clamp($("-1"), minimum: min, maximum: max); // 0
```

## Rounding Utilities

```dart
// Terminal digit rounding helper
print(BigDecimal.roundTerminal(BigInt.from(4))); // 0 (don't round up)
print(BigDecimal.roundTerminal(BigInt.from(5))); // 1 (round up)
print(BigDecimal.roundTerminal(BigInt.from(6))); // 1 (round up)
```

## Real-World Examples

### Financial Calculations

```dart
class Invoice {
  final List<LineItem> items;
  final BigDecimal taxRate;
  
  Invoice(this.items, this.taxRate);
  
  BigDecimal get subtotal {
    final amounts = items.map((item) => 
        BigDecimal.multiply(item.price, item.quantity));
    return BigDecimal.sumAll(amounts);
  }
  
  BigDecimal get tax {
    return BigDecimal.multiply(subtotal, taxRate);
  }
  
  BigDecimal get total {
    return BigDecimal.sum(subtotal, tax);
  }
}

class LineItem {
  final String description;
  final BigDecimal price;
  final BigDecimal quantity;
  
  LineItem(this.description, this.price, this.quantity);
}

// Usage
final invoice = Invoice([
  LineItem("Widget A", $("12.50"), $("3")),
  LineItem("Widget B", $("8.75"), $("2")),
], $("0.08")); // 8% tax

print("Subtotal: ${invoice.subtotal}"); // 55.00
print("Tax: ${invoice.tax}"); // 4.40
print("Total: ${invoice.total}"); // 59.40
```

### Currency Conversion

```dart
class CurrencyConverter {
  final Map<String, BigDecimal> rates;
  
  CurrencyConverter(this.rates);
  
  Option<BigDecimal> convert(BigDecimal amount, String from, String to) {
    if (from == to) return Option.some(amount);
    
    final fromRate = rates[from];
    final toRate = rates[to];
    
    if (fromRate == null || toRate == null) {
      return Option.none();
    }
    
    // Convert to base currency, then to target
    return BigDecimal.divide(amount, fromRate)
        .flatMap((baseAmount) => Option.some(
            BigDecimal.multiply(baseAmount, toRate)));
  }
}

// Usage
final converter = CurrencyConverter({
  'USD': $("1.0"),      // Base currency
  'EUR': $("0.85"),
  'GBP': $("0.73"),
  'JPY': $("110.0"),
});

final result = converter.convert($("100"), 'USD', 'EUR');
result.fold(
  () => print("Conversion failed"),
  (amount) => print("100 USD = $amount EUR"), // 85.0 EUR
);
```

### Scientific Calculations

```dart
class Statistics {
  static BigDecimal mean(List<BigDecimal> values) {
    if (values.isEmpty) return $("0");
    
    final sum = BigDecimal.sumAll(values);
    final count = $("${values.length}");
    return BigDecimal.unsafeDivide(sum, count);
  }
  
  static BigDecimal variance(List<BigDecimal> values) {
    if (values.length < 2) return $("0");
    
    final meanValue = mean(values);
    final squaredDiffs = values.map((x) {
      final diff = BigDecimal.subtract(x, meanValue);
      return BigDecimal.multiply(diff, diff);
    }).toList();
    
    final sumSquaredDiffs = BigDecimal.sumAll(squaredDiffs);
    final n = $("${values.length - 1}"); // Sample variance
    return BigDecimal.unsafeDivide(sumSquaredDiffs, n);
  }
}

// Usage
final data = [
  $("10.5"), $("12.3"), $("9.8"), $("11.2"), $("10.9")
];

final meanValue = Statistics.mean(data);
final varianceValue = Statistics.variance(data);

print("Mean: $meanValue");
print("Variance: $varianceValue");
```

### Percentage Calculations

```dart
class PercentageCalculator {
  // Calculate percentage of a value
  static BigDecimal percentageOf(BigDecimal value, BigDecimal percentage) {
    final percent = BigDecimal.unsafeDivide(percentage, $("100"));
    return BigDecimal.multiply(value, percent);
  }
  
  // Calculate what percentage one value is of another
  static Option<BigDecimal> percentageRatio(BigDecimal part, BigDecimal whole) {
    return BigDecimal.divide(part, whole)
        .map((ratio) => BigDecimal.multiply(ratio, $("100")));
  }
  
  // Apply percentage increase/decrease
  static BigDecimal applyPercentage(BigDecimal value, BigDecimal percentage) {
    final change = percentageOf(value, percentage);
    return BigDecimal.sum(value, change);
  }
}

// Usage
final originalPrice = $("100.00");
final discount = $("-15"); // 15% discount
final tax = $("8.5"); // 8.5% tax

// Apply discount
final discountedPrice = PercentageCalculator.applyPercentage(
    originalPrice, discount); // 85.00

// Apply tax
final finalPrice = PercentageCalculator.applyPercentage(
    discountedPrice, tax); // 92.225

print("Original: $originalPrice");
print("After discount: $discountedPrice");
print("Final price: $finalPrice");
```

## Integration with Effects

BigDecimal works seamlessly with Effect for error handling:

```dart
Effect<BigDecimal, String, void> safeDivision(BigDecimal a, BigDecimal b) {
  return BigDecimal.divide(a, b).fold(
    () => Effect.fail("Division by zero"),
    (result) => Effect.succeed(result),
  );
}

// Usage
final divisionEffect = safeDivision($("10"), $("3"));
final result = await divisionEffect.runToExit();

result.fold(
  (error) => print("Error: $error"),
  (value) => print("Result: $value"),
);
```

## Best Practices

### 1. Always Use String Construction

```dart
// Good: Use string literals
final price = $("123.45");
final rate = BigDecimal("0.08");

// Avoid: Converting from double (precision loss)
final badPrice = $(123.45.toString()); // May have precision issues
```

### 2. Use Safe Division

```dart
// Good: Handle division by zero
final result = BigDecimal.divide(dividend, divisor);
result.fold(
  () => handleDivisionByZero(),
  (value) => processResult(value),
);

// Risky: Unsafe division without checks
final result = BigDecimal.unsafeDivide(dividend, divisor); // May throw
```

### 3. Aggregate Operations

```dart
// Good: Use sumAll for multiple additions
final total = BigDecimal.sumAll([price1, price2, price3, tax]);

// Less efficient: Chain additions
final total = BigDecimal.sum(
    BigDecimal.sum(BigDecimal.sum(price1, price2), price3), 
    tax);
```

### 4. Comparison Operations

```dart
// Good: Use comparison functions
if (BigDecimal.greaterThan(balance, minimumBalance)) {
  // Process transaction
}

// Avoid: String comparison
if (balance.toString().compareTo(minimumBalance.toString()) > 0) {
  // This doesn't work correctly for numbers
}
```

## API Reference

### Constructors
- `BigDecimal(String value)` - Create from string
- `$(String value)` - Shorthand constructor

### Type Guards
- `BigDecimal.isBigDecimal(dynamic value)` - Type checking

### Arithmetic
- `BigDecimal.sum(BigDecimal a, BigDecimal b)` - Addition
- `BigDecimal.sumAll(List<BigDecimal> values)` - Sum multiple values
- `BigDecimal.subtract(BigDecimal a, BigDecimal b)` - Subtraction
- `BigDecimal.multiply(BigDecimal a, BigDecimal b)` - Multiplication
- `BigDecimal.divide(BigDecimal a, BigDecimal b)` - Safe division (returns Option)
- `BigDecimal.unsafeDivide(BigDecimal a, BigDecimal b)` - Unsafe division (throws)
- `BigDecimal.remainder(BigDecimal a, BigDecimal b)` - Safe remainder
- `BigDecimal.unsafeRemainder(BigDecimal a, BigDecimal b)` - Unsafe remainder

### Comparison
- `BigDecimal.equals(BigDecimal a, BigDecimal b)` - Precise equality
- `BigDecimal.lessThan(BigDecimal a, BigDecimal b)` - Less than
- `BigDecimal.lessThanOrEqualTo(BigDecimal a, BigDecimal b)` - Less than or equal
- `BigDecimal.greaterThan(BigDecimal a, BigDecimal b)` - Greater than
- `BigDecimal.greaterThanOrEqualTo(BigDecimal a, BigDecimal b)` - Greater than or equal
- `BigDecimal.Order(BigDecimal a, BigDecimal b)` - Compare (-1, 0, 1)
- `BigDecimal.min(BigDecimal a, BigDecimal b)` - Minimum value
- `BigDecimal.max(BigDecimal a, BigDecimal b)` - Maximum value

### Sign Operations
- `BigDecimal.sign(BigDecimal value)` - Get sign (-1, 0, 1)
- `BigDecimal.abs(BigDecimal value)` - Absolute value
- `BigDecimal.negate(BigDecimal value)` - Negate value

### Utilities
- `BigDecimal.isZero(BigDecimal value)` - Check if zero
- `BigDecimal.isPositive(BigDecimal value)` - Check if positive
- `BigDecimal.isNegative(BigDecimal value)` - Check if negative
- `BigDecimal.isInteger(BigDecimal value)` - Check if integer
- `BigDecimal.between(BigDecimal value, {BigDecimal minimum, BigDecimal maximum})` - Range check
- `BigDecimal.clamp(BigDecimal value, {BigDecimal minimum, BigDecimal maximum})` - Clamp to range
- `BigDecimal.roundTerminal(BigInt digit)` - Rounding helper