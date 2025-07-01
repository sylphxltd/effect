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

// Async callback-based effect
final asyncCallback = Effect.asyncCallback<String>((callback) {
  Timer(Duration(seconds: 1), () {
    callback(Effect.succeed('Callback result'));
  });
});

// Sleep/delay effect
final sleep = Effect.sleep(Duration(milliseconds: 500));

// Promise/Future effect
final promise = Effect.promise(() => Future.value('Promise result'));

// Suspended computation (lazy evaluation)
final suspended = Effect.suspend(() => Effect.succeed('Lazy value'));
```

### Running Effects

```dart
// Get the exit result (Success or Failure)
final exit = await effect.runToExit();

// Run unsafely (throws on failure)
final result = await effect.runUnsafe();

// Run synchronously (for sync effects only)
final syncExit = Effect.runSyncExit(effect);

// Run as Promise/Future
final result2 = await Effect.runPromise(effect);

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

// Add tracing spans
final traced = Effect.sync(() => 'Hello')
    .withSpan('greeting-operation');

// Pipe through functions
final piped = Effect.succeed(42)
    .pipe((effect) => effect.map((x) => x * 2));

// Get effect exit
final exitEffect = Effect.succeed('value').exit();

// Sandbox errors for type safety
final sandboxed = Effect.fail('error').sandbox();

// Convert to Either
final eitherEffect = Effect.succeed(42).either();
```

### Async Operations

```dart
// Callback-based async operations
final asyncCallback = Effect.asyncCallback<String>((callback) {
  // Register async operation with callback
  Timer(Duration(seconds: 1), () {
    callback(Effect.succeed('Async result'));
  });
});

// Sleep/delay operations
final delayed = Effect.sleep(Duration(milliseconds: 500))
    .flatMap((_) => Effect.succeed('After delay'));

// Chaining async operations
final asyncChain = Effect.asyncCallback<int>((cb) {
      cb(Effect.succeed(1));
    })
    .flatMap((n) => Effect.sleep(Duration(milliseconds: 100))
        .map((_) => n + 1))
    .flatMap((n) => Effect.asyncCallback<int>((cb) {
        Future.delayed(Duration(milliseconds: 50), () {
          cb(Effect.succeed(n * 2));
        });
      }));

// Error handling in async operations
final asyncWithError = Effect.asyncCallback<String>((callback) {
      Timer(Duration(milliseconds: 10), () {
        callback(Effect.fail('Async error'));
      });
    })
    .catchAll((error) => Effect.succeed('Recovered from: $error'));

// Combining async and sync operations
final mixed = Effect.succeed(10)
    .flatMap((n) => Effect.sleep(Duration(milliseconds: 10))
        .map((_) => n))
    .flatMap((n) => Effect.asyncCallback<String>((cb) {
        cb(Effect.succeed('Result: $n'));
      }));
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

### Synchronous Execution

For effects that don't require async operations, you can run them synchronously:

```dart
// Synchronous effects can be run immediately
final syncEffect = Effect.sync(() => 42);
final exit = Effect.runSyncExit(syncEffect);

switch (exit) {
  case Success(:final value):
    print('Result: $value'); // Result: 42
  case Failure(:final cause):
    print('Error: $cause');
}

// Async effects will fail when run synchronously
final asyncEffect = Effect.promise(() => Future.value(42));
final asyncExit = Effect.runSyncExit(asyncEffect);
// This will be a Failure with "Cannot run async effect synchronously"

// Tracing is preserved in synchronous execution
final tracedEffect = Effect.promise(() => Future.value(42))
    .withSpan('async-operation');
final tracedExit = Effect.runSyncExit(tracedEffect);
// Error message will include "async-operation: Cannot run async effect synchronously"
```

### Suspended Effects

Suspended effects provide lazy evaluation and proper error handling:

```dart
// Lazy evaluation - computation doesn't run until effect is executed
final lazyEffect = Effect.suspend(() {
  print('This only prints when effect runs');
  return Effect.succeed('computed value');
});

// Exception handling in suspended effects
final riskyEffect = Effect.suspend(() {
  if (Random().nextBool()) {
    throw Exception('Random failure');
  }
  return Effect.succeed('success');
});

final result = await Effect.runPromise(riskyEffect);
// Will either succeed with 'success' or fail with the exception
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
- `Effect.asyncCallback<A>(void Function(callback) register)` - Callback-based async effect
- `Effect.sleep(Duration)` - Sleep/delay effect
- `Effect.promise<A>(Future<A> Function())` - Create from Promise/Future
- `Effect.suspend<A, E, R>(Effect<A, E, R> Function())` - Suspend computation
- `Effect.service<A>()` - Require service from context
- `Effect.runSyncExit<A, E, R>(Effect<A, E, R>)` - Run synchronously
- `Effect.runPromise<A, E, R>(Effect<A, E, R>)` - Run as Promise/Future

#### Instance Methods

- `map<B>(B Function(A))` - Transform success value
- `mapError<E2>(E2 Function(E))` - Transform error value
- `flatMap<B>(Effect<B, E2, R2> Function(A))` - Chain effects
- `catchAll<E2>(Effect<A, E2, R2> Function(E))` - Handle errors
- `withSpan(String)` - Add tracing span
- `pipe<B>(B Function(Effect))` - Pipe through function
- `exit()` - Get Exit of effect
- `sandbox()` - Expose failures as typed errors
- `either()` - Convert to Either type
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

The `Either<L, R>` type represents a value that can be either a Left (error) or Right (success). It provides a comprehensive API for functional error handling:

```dart
import 'package:effect_dart/effect_dart.dart';

// Creating Either values
final success = Either.right(42);
final failure = Either.left("Error occurred");
final voidResult = Either.voidValue; // Predefined Right(null)

// Type checking and guards
print(Either.isEither(success)); // true
print(success.isRight); // true
print(failure.isLeft); // true

// Extracting values safely
final rightOption = Either.getRight(success); // Some(42)
final leftOption = Either.getLeft(failure); // Some("Error occurred")

// Pattern matching
final result = success.match(
  onLeft: (error) => "Failed: $error",
  onRight: (value) => "Success: $value",
);

// Transformations
final doubled = success.map((x) => x * 2); // Right(84)
final errorMapped = failure.mapLeft((e) => "Prefix: $e"); // Left("Prefix: Error occurred")
final bothMapped = success.mapBoth(
  onLeft: (e) => "Error: $e",
  onRight: (v) => v * 2,
); // Right(84)

// Chaining operations
final computed = success
    .flatMap((x) => x > 0 ? Either.right(x * 2) : Either.left("Invalid"))
    .andThen((x) => Either.right(x + 1)); // Right(85)

// Filtering
final filtered = success.filterOrLeft(
  (x) => x > 50,
  () => "Value too small",
); // Left("Value too small")

// Creating from various sources
final fromNull = Either.fromNullable(null, () => "Was null"); // Left("Was null")
final fromOption = Either.fromOption(Option.some(10), () => "Was none"); // Right(10)

// Exception handling
final safe = Either.tryCall(() => int.parse("42")); // Right(42)
final safeFailed = Either.tryCall(() => int.parse("abc")); // Left(FormatException)

final withCustomError = Either.tryWith(
  tryFn: () => int.parse("abc"),
  catchFn: (e) => "Parse error: $e",
); // Left("Parse error: ...")

// Extracting values
final value = success.getOrElse(0); // 42
final valueOrNull = failure.getOrNull(); // null
final valueOrThrow = success.getOrThrow(); // 42 (would throw for Left)

// Combining multiple Eithers
final combined = success.zipWith(Either.right(3), (a, b) => a + b); // Right(45)

// Applicative pattern
final add = (int a) => (int b) => a + b;
final applied = Either.right(add).ap(Either.right(10)).ap(Either.right(5)); // Right(15)

// Collecting results
final allResults = Either.all([
  Either.right(1),
  Either.right(2),
  Either.right(3),
]); // Right([1, 2, 3])

final withFailure = Either.all([
  Either.right(1),
  Either.left("error"),
  Either.right(3),
]); // Left("error")

// Alternative handling
final alternative = failure.orElse(() => Either.right(42)); // Right(42)

// Merging when both sides have same type
final merged = Either.right(42).merge<int>(); // 42
final mergedLeft = Either.left(24).merge<int>(); // 24

// Utility operations
final flipped = Either.flip(success); // Left(42)
```

**Key Either Functions:**
- `Either.voidValue` - Predefined Right(null)
- `Either.isEither()` - Type guard
- `Either.getRight()/getLeft()` - Extract values as Options
- `isLeft/isRight` - Type checking
- `flip()` - Swap Left and Right
- `map()/mapLeft()/mapBoth()` - Transform values
- `match()` - Pattern matching with callbacks
- `merge()` - Combine Left and Right into single value
- `Either.liftPredicate()` - Lift predicate into Either
- `filterOrLeft()` - Filter with predicate
- `Either.fromNullable()/fromOption()` - Create from other types
- `Either.tryCall()/tryWith()` - Exception handling
- `getOrElse()/getOrNull()/getOrThrow()` - Extract values
- `andThen()` - Chain computations (alias for flatMap)
- `ap()` - Applicative apply
- `zipWith()` - Combine two Eithers
- `Either.all()` - Collect multiple Eithers
- `orElse()` - Alternative computation

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