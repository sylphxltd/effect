# Introduction

Welcome to Effect Dart! This library brings the power of functional programming to Dart, inspired by the excellent [Effect-TS](https://effect.website/) library.

Effect Dart provides a comprehensive toolkit for managing side effects, errors, and dependencies in a type-safe and composable way. Whether you're building web applications, mobile apps, or server-side services, Effect Dart helps you write more predictable, testable, and maintainable code.

## What is an Effect?

An Effect is a description of a computation that may:
- Succeed with a value of type `A`
- Fail with an error of type `E`
- Require dependencies of type `R`

```dart
Effect<A, E, R>
```

Effects are **lazy** - they don't execute until you explicitly run them. This allows for powerful composition patterns and better control over when and how computations execute.

## Key Concepts

### 1. Type Safety
Effects encode their success type, error type, and requirements in the type system:

```dart
// An effect that succeeds with an int, never fails, and needs no dependencies
Effect<int, Never, void> successEffect = Effect.succeed(42);

// An effect that might fail with a String error
Effect<int, String, void> riskyEffect = Effect.fail("Something went wrong");

// An effect that requires a DatabaseService
Effect<User, DatabaseError, DatabaseService> userEffect = 
  Effect.service<DatabaseService>()
    .flatMap((db) => Effect.async(() => db.getUser("123")));
```

### 2. Lazy Evaluation
Effects are descriptions, not executions:

```dart
// This doesn't print anything yet - it's just a description
final effect = Effect.sync(() {
  print("Hello, World!");
  return 42;
});

// Only when we run it does the computation execute
await effect.runUnsafe(); // Prints: Hello, World!
```

### 3. Composability
Effects can be combined and transformed using functional operators:

```dart
final pipeline = Effect.succeed(10)
    .map((x) => x * 2)                    // Transform success value
    .flatMap((x) => Effect.succeed(x + 5)) // Chain another effect
    .catchAll((error) => Effect.succeed(0)); // Handle errors

final result = await pipeline.runUnsafe(); // 25
```

### 4. Error Handling
Effects distinguish between expected errors (failures) and unexpected errors (defects):

```dart
// Expected error - part of the type signature
final mayFail = Effect.fail("Expected error");

// Unexpected error - caught and converted to defect
final mayThrow = Effect.sync(() => throw Exception("Unexpected!"));
```

### 5. Dependency Injection
Effects can declare their dependencies in the type system:

```dart
// Define a service
abstract class Logger {
  void log(String message);
}

// Create an effect that needs a Logger
final logEffect = Effect.service<Logger>()
    .flatMap((logger) => Effect.sync(() => logger.log("Hello!")));

// Provide the dependency
final context = Context.of(ConsoleLogger());
await logEffect.runUnsafe(context);
```

## Benefits

### Predictability
Effects are pure descriptions. The same effect will always produce the same result when run with the same context.

### Testability
Dependencies are explicit in the type system, making it easy to provide test implementations.

### Composability
Complex workflows can be built by combining simple effects using functional operators.

### Error Safety
Errors are tracked in the type system, preventing unhandled exceptions.

### Concurrency
Built-in support for structured concurrency with fibers and parallel execution.

## Next Steps

- [Why Effect?](./why-effect) - Learn more about the benefits
- [Installation](./installation) - Get Effect Dart set up in your project
- [The Effect Type](./effect-type) - Deep dive into the Effect type
- [Creating Effects](./creating-effects) - Learn how to create effects
- [Running Effects](./running-effects) - Learn how to execute effects