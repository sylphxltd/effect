---
layout: home

hero:
  name: "Effect Dart"
  text: "Functional Programming for Dart"
  tagline: A powerful Effect library for Dart inspired by Effect-TS, providing functional programming patterns for managing side effects, errors, and dependencies in a type-safe and composable way.
  actions:
    - theme: brand
      text: Get Started
      link: /getting-started/
    - theme: alt
      text: View on GitHub
      link: https://github.com/sylphxltd/effect.dart

features:
  - title: Type-safe Effects
    details: Encode success, error, and dependency types in the type system for compile-time safety.
  - title: Lazy Evaluation
    details: Effects are descriptions that don't execute until run, enabling powerful composition patterns.
  - title: Error Handling
    details: Built-in error handling with typed errors and causes for robust error management.
  - title: Dependency Injection
    details: Type-safe context system for managing dependencies without global state.
  - title: Concurrency
    details: Built-in support for concurrent and parallel execution with fibers and structured concurrency.
  - title: Composability
    details: Chain and combine effects using functional operations for clean, readable code.
  - title: Functional Data Types
    details: Option, Either, Array utilities and more for functional programming patterns.
  - title: Comprehensive API
    details: Rich set of operators and utilities for building complex applications.
---

## Quick Example

```dart
import 'package:effect_dart/effect_dart.dart';

// Create effects
final fetchUser = Effect.async(() async {
  // Simulate API call
  await Future.delayed(Duration(seconds: 1));
  return User(id: '123', name: 'John Doe');
});

final sendEmail = (User user) => Effect.async(() async {
  // Simulate email sending
  await Future.delayed(Duration(milliseconds: 500));
  print('Email sent to ${user.name}');
});

// Compose effects
final pipeline = fetchUser
    .flatMap(sendEmail)
    .catchAll((error) => Effect.sync(() => print('Error: $error')));

// Run the effect
await pipeline.runUnsafe();
```

## The Effect Type

```dart
Effect<Success, Error, Requirements>
```

Where:
- `Success`: The type of value the effect produces on success
- `Error`: The type of expected errors that can occur  
- `Requirements`: The type of dependencies required from context

## Why Effect Dart?

- **Predictable**: Effects are pure descriptions of computations
- **Composable**: Build complex workflows from simple building blocks
- **Type-safe**: Leverage Dart's type system for compile-time guarantees
- **Testable**: Easy to test with dependency injection and pure functions
- **Concurrent**: Built-in support for structured concurrency
- **Error-safe**: Comprehensive error handling without exceptions

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  effect_dart: ^0.1.0
```

Then run:

```bash
dart pub get
```

## Learn More

- [Getting Started](/getting-started/) - Learn the basics
- [API Reference](/api/) - Complete API documentation
- [Examples](/examples/) - Real-world examples
- [GitHub](https://github.com/sylphxltd/effect.dart) - Source code and issues