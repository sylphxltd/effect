# effect_dart

A powerful Effect library for Dart inspired by [Effect-TS](https://effect.website/), providing functional programming patterns for managing side effects, errors, and dependencies in a type-safe and composable way.

## Features

- **Type-safe Effects**: Encode success, error, and dependency types in the type system
- **Lazy Evaluation**: Effects are descriptions that don't execute until run
- **Error Handling**: Built-in error handling with typed errors and causes
- **Dependency Injection**: Type-safe context system for managing dependencies
- **Concurrency**: Built-in support for concurrent and parallel execution
- **Composability**: Chain and combine effects using functional operations
- **Functional Data Types**: Option, Either, Array utilities for functional programming
- **Array Operations**: Comprehensive array manipulation functions (prepend, append, take, etc.)

## The Effect Type

```dart
Effect<Success, Error, Requirements>
```

Where:
- `Success`: The type of value the effect produces on success
- `Error`: The type of expected errors that can occur
- `Requirements`: The type of dependencies required from context

## Quick Start

Add to your `pubspec.yaml`:

```yaml
dependencies:
  effect_dart: ^0.1.0
```

## Basic Usage

### Creating Effects

```dart
import 'package:effect_dart/effect_dart.dart';

// Success effect
final success = Effect.succeed(42);

// Failure effect  
final failure = Effect.fail('Something went wrong');

// Sync computation that might throw
final risky = Effect.sync(() {
  if (Random().nextBool()) {
    return 'Success!';
  } else {
    throw Exception('Failed!');
  }
});

// Async computation
final async = Effect.async(() async {
  await Future.delayed(Duration(seconds: 1));
  return 'Done!';
});
```

### Running Effects

```dart
// Get the exit result (Success or Failure)
final exit = await effect.runToExit();

// Run unsafely (throws on failure)
final result = await effect.runUnsafe();

// Using the runtime directly
final runtime = Runtime.defaultRuntime;
final exit2 = await runtime.runToExit(effect);
```

### Transforming Effects

```dart
// Map success values
final mapped = Effect.succeed(21)
    .map((x) => x * 2);

// Chain effects
final chained = Effect.succeed(10)
    .flatMap((x) => Effect.succeed(x + 5))
    .flatMap((x) => Effect.succeed(x.toString()));

// Handle errors
final recovered = Effect.fail('error')
    .catchAll((err) => Effect.succeed('fallback'));

// Map errors
final mappedError = Effect.fail(404)
    .mapError((code) => 'HTTP Error: $code');
```

### Dependency Injection

```dart
// Define services
class DatabaseService {
  Future<String> getData(String id) async => 'Data for $id';
}

class LoggerService {
  void log(String message) => print('[LOG] $message');
}

// Create effects that require services
final dbEffect = Effect.service<DatabaseService>()
    .flatMap((db) => Effect.async(() => db.getData('user123')));

final logEffect = Effect.service<LoggerService>()
    .flatMap((logger) => Effect.sync(() => logger.log('Done')));

// Provide services via context
final context = Context.empty()
    .add(DatabaseService())
    .add(LoggerService());

// Or provide individual services
final effectWithService = dbEffect.provideService(DatabaseService());

// Run with context
final result = await dbEffect.runToExit(context);
```

### Concurrent Execution

```dart
final effect1 = Effect.async(() => Future.delayed(Duration(milliseconds: 100), () => 'A'));
final effect2 = Effect.async(() => Future.delayed(Duration(milliseconds: 200), () => 'B'));
final effect3 = Effect.async(() => Future.delayed(Duration(milliseconds: 150), () => 'C'));

// Run all concurrently
final results = await Runtime.defaultRuntime.runConcurrently([
  effect1, effect2, effect3
]);

// Race (first to complete wins)
final winner = await Runtime.defaultRuntime.runRace([
  effect1, effect2, effect3
]);

// Using fibers for fine-grained control
final fiber1 = effect1.fork();
final fiber2 = effect2.fork();

final (exit1, exit2) = await fiber1.zip(fiber2);
```

## Advanced Examples

### Error Recovery Pipeline

```dart
final pipeline = Effect.succeed('https://api.example.com/data')
    .flatMap((url) => httpGet(url))
    .mapError((httpError) => 'Network error: $httpError')
    .catchAll((error) => Effect.succeed('{"fallback": true}'))
    .flatMap((json) => parseJson(json))
    .map((data) => transformData(data));

final result = await pipeline.runToExit();
```

### Service-Oriented Architecture

```dart
abstract class UserRepository {
  Future<User?> findById(String id);
}

abstract class EmailService {
  Future<void> sendEmail(String to, String subject, String body);
}

final sendWelcomeEmail = (String userId) => 
  Effect.service<UserRepository>()
    .flatMap((repo) => Effect.async(() => repo.findById(userId)))
    .flatMap((user) => user != null 
      ? Effect.service<EmailService>()
          .flatMap((email) => Effect.async(() => 
            email.sendEmail(user.email, 'Welcome!', 'Welcome to our service!')))
      : Effect.fail('User not found'))
    .map((_) => 'Email sent successfully');

// Provide all dependencies
final context = Context.empty()
    .add<UserRepository>(DatabaseUserRepository())
    .add<EmailService>(SmtpEmailService());

final result = await sendWelcomeEmail('user123').runToExit(context);
```

## Functional Data Types

### Array Operations

```dart
import 'package:effect_dart/effect_dart.dart';

// Create arrays
final single = Array.of(42);                    // [42]
final empty = Array.empty<int>();              // []
final fromSet = Array.fromIterable({1, 2, 3}); // [1, 2, 3]

// Prepend and append
final prepended = Array.prepend([2, 3], 1);    // [1, 2, 3]
final appended = Array.append([1, 2], 3);      // [1, 2, 3]

// Array manipulation
final numbers = [1, 2, 3, 4, 5];
final firstTwo = Array.take(numbers, 2);       // [1, 2]
final lastTwo = Array.takeRight(numbers, 2);   // [4, 5]

// Safe operations with Option
final tail = Array.tail([1, 2, 3]);           // Some([2, 3])
final init = Array.init([1, 2, 3]);           // Some([1, 2])
final emptyTail = Array.tail(<int>[]);         // None()
```

### Option Type

```dart
// Create Options
final some = Option.some(42);                  // Some(42)
final none = Option.none<int>();              // None()
final nullable = Option.fromNullable(null);   // None()

// Transform values
final doubled = some.map((x) => x * 2);       // Some(84)
final chained = some.flatMap((x) =>
  x > 0 ? Option.some(x.toString()) : Option.none()); // Some("42")

// Extract values safely
final value = some.getOrElse(0);              // 42
final defaulted = none.getOrElse(0);          // 0

// Pattern matching
final result = some.fold(
  () => 'No value',
  (value) => 'Value: $value'
);
```

### BigDecimal

High-precision decimal arithmetic for financial and scientific calculations:

```dart
import 'package:effect_dart/effect_dart.dart';

// Create BigDecimals
final price = $("123.456");              // From string
final quantity = $("2.5");               // Using $ shorthand
final zero = $("0");                     // Zero

// Type checking
print(BigDecimal.isBigDecimal(price));   // true
print(BigDecimal.isBigDecimal("123"));   // false

// Basic arithmetic operations
final total = BigDecimal.multiply(price, quantity);    // 308.64
final tax = BigDecimal.multiply(total, $("0.08"));     // 24.6912
final finalAmount = BigDecimal.sum(total, tax);        // 333.2512
final discounted = BigDecimal.subtract(total, $("10")); // 298.64

// Safe division with Option type
final result = BigDecimal.divide($("10"), $("3"));     // Some(3.333...)
final byZero = BigDecimal.divide($("10"), $("0"));     // None()

// Unsafe division (throws on division by zero)
final quotient = BigDecimal.unsafeDivide($("15"), $("3")); // 5.0

// Sign operations
print(BigDecimal.sign($("-5")));         // -1
print(BigDecimal.sign($("0")));          // 0
print(BigDecimal.sign($("5")));          // 1

// Precise equality comparison (handles trailing zeros)
final a = $("1.0");
final b = $("1.00");
print(BigDecimal.equals(a, b));          // true (normalized comparison)

// Rounding utilities
print(BigDecimal.roundTerminal(BigInt.from(4)));  // 0 (don't round up)
print(BigDecimal.roundTerminal(BigInt.from(5)));  // 1 (round up)

// Remainder operations
final rem = BigDecimal.remainder($("5"), $("2"));   // Some(1)
final unsafeRem = BigDecimal.unsafeRemainder($("5"), $("2")); // 1

// Comparison operations
print(BigDecimal.lessThan($("2"), $("3")));        // true
print(BigDecimal.greaterThan($("4"), $("3")));     // true
print(BigDecimal.Order($("1"), $("2")));           // -1

// Utility functions
print(BigDecimal.isZero($("0")));                  // true
print(BigDecimal.isInteger($("1.0")));             // true
print(BigDecimal.isPositive($("1")));              // true
print(BigDecimal.isNegative($("-1")));             // true

// Bounds checking and clamping
final inRange = BigDecimal.between($("3"), minimum: $("0"), maximum: $("5")); // true
final clamped = BigDecimal.clamp($("6"), minimum: $("0"), maximum: $("5"));   // 5

// Aggregation
final total = BigDecimal.sumAll([$("1.5"), $("2.5"), $("3.0")]); // 7.0
```

## API Reference

### Effect

- `Effect.succeed<A>(A value)` - Create successful effect
- `Effect.fail<E>(E error)` - Create failed effect  
- `Effect.sync<A>(A Function())` - Sync computation
- `Effect.async<A>(Future<A> Function())` - Async computation
- `Effect.service<A>()` - Require service from context

#### Instance Methods

- `map<B>(B Function(A))` - Transform success value
- `mapError<E2>(E2 Function(E))` - Transform error value
- `flatMap<B>(Effect<B, E2, R2> Function(A))` - Chain effects
- `catchAll<E2>(Effect<A, E2, R2> Function(E))` - Handle errors
- `provideContext(Context<R>)` - Provide context
- `provideService<S>(S)` - Provide single service
- `runToExit([Context<R>?])` - Execute and get Exit
- `runUnsafe([Context<R>?])` - Execute unsafely

### Context

- `Context.empty()` - Empty context
- `Context.of<T>(T service)` - Single service context
- `add<T>(T service)` - Add service
- `get<T>()` - Retrieve service
- `has<T>()` - Check if service exists
- `merge(Context other)` - Combine contexts

### Runtime

- `Runtime.defaultRuntime` - Default runtime instance
- `runToExit<A, E, R>(Effect<A, E, R>)` - Execute effect
- `runUnsafe<A, E, R>(Effect<A, E, R>)` - Execute unsafely
- `runConcurrently<A, E, R>(List<Effect<A, E, R>>)` - Concurrent execution
- `runRace<A, E, R>(List<Effect<A, E, R>>)` - Race execution
- `fork<A, E, R>(Effect<A, E, R>)` - Create fiber

### Exit

- `Exit.succeed<A>(A value)` - Success exit
- `Exit.fail<E>(E error)` - Failure exit
- `Exit.die(Object throwable)` - Defect exit
- `map<B>(B Function(A))` - Transform success
- `fold<C>(C Function(Cause<E>), C Function(A))` - Fold to value

### Either

- `Either.left<L, R>(L value)` - Left value
- `Either.right<L, R>(R value)` - Right value
- `map<R2>(R2 Function(R))` - Transform right
- `flatMap<R2>(Either<L, R2> Function(R))` - Chain eithers
- `fold<T>(T Function(L), T Function(R))` - Fold to value

## Running Examples

```bash
# Run the basic example
dart run example/basic_example.dart

# Run tests
dart test

# Run with melos (if you have it installed)
melos test
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Inspiration

This library is heavily inspired by [Effect-TS](https://effect.website/), bringing similar concepts and patterns to the Dart ecosystem. Special thanks to the Effect-TS team for their innovative work in functional programming.