# Importing Effect

This guide covers how to properly import and use Effect Dart in your applications, including best practices for organizing imports and exports.

## Basic Import

The simplest way to get started is to import the main Effect Dart library:

```dart
import 'package:effect_dart/effect_dart.dart';
```

This gives you access to all the core Effect types and functions:

```dart
import 'package:effect_dart/effect_dart.dart';

void main() async {
  // All Effect functionality is available
  final effect = Effect.succeed(42);
  final option = Option.some("hello");
  final either = Either.right(100);
  final bigDecimal = $("123.45");
  
  final result = await effect.runUnsafe();
  print(result); // 42
}
```

## Selective Imports

For better performance and cleaner code, you can import specific modules:

### Core Effect Types

```dart
// Import only Effect-related functionality
import 'package:effect_dart/effect_dart.dart' show 
    Effect, 
    Context, 
    Runtime, 
    Exit, 
    Success, 
    Failure;

void main() async {
  final effect = Effect.succeed(42);
  final context = Context.empty();
  final runtime = Runtime.defaultRuntime;
  
  final exit = await runtime.runToExit(effect);
  // Use exit...
}
```

### Data Types Only

```dart
// Import only data types
import 'package:effect_dart/effect_dart.dart' show 
    Option, 
    Either, 
    BigDecimal;

void processData() {
  final maybeValue = Option.some(42);
  final result = Either.right("success");
  final price = $("99.99");
  
  // Process data types...
}
```

### Specific Functionality

```dart
// Import specific utilities
import 'package:effect_dart/effect_dart.dart' show 
    Array,
    Cause;

void arrayOperations() {
  final numbers = [1, 2, 3, 4, 5];
  final firstTwo = Array.take(numbers, 2);
  final tail = Array.tail(numbers);
  
  // Array operations...
}
```

## Aliasing Imports

Use aliases to avoid naming conflicts or for convenience:

```dart
import 'package:effect_dart/effect_dart.dart' as Effect;

void main() async {
  final effect = Effect.Effect.succeed(42);
  final option = Effect.Option.some("hello");
  final either = Effect.Either.right(100);
  
  final result = await effect.runUnsafe();
}
```

Or alias specific types:

```dart
import 'package:effect_dart/effect_dart.dart';
import 'package:effect_dart/effect_dart.dart' as E show Effect;

void main() async {
  // Use regular import for most things
  final option = Option.some(42);
  
  // Use alias for Effect to avoid conflicts
  final effect = E.Effect.succeed(option);
  
  final result = await effect.runUnsafe();
}
```

## Conditional Imports

For platform-specific code, use conditional imports:

```dart
// lib/src/platform/io_platform.dart
import 'dart:io';
import 'package:effect_dart/effect_dart.dart';

Effect<String, FileError, void> readFile(String path) {
  return Effect.async(() async {
    try {
      final file = File(path);
      return await file.readAsString();
    } catch (e) {
      throw FileError('Failed to read file: $e');
    }
  });
}

class FileError {
  final String message;
  FileError(this.message);
}
```

```dart
// lib/src/platform/web_platform.dart
import 'dart:html';
import 'package:effect_dart/effect_dart.dart';

Effect<String, StorageError, void> readFromStorage(String key) {
  return Effect.sync(() {
    final value = window.localStorage[key];
    if (value == null) {
      throw StorageError('Key not found: $key');
    }
    return value;
  });
}

class StorageError {
  final String message;
  StorageError(this.message);
}
```

```dart
// lib/src/platform/platform.dart
export 'io_platform.dart' if (dart.library.html) 'web_platform.dart';
```

## Library Organization

### Creating Your Own Effect Library

Organize your Effect-based code into reusable libraries:

```dart
// lib/src/effects/user_effects.dart
import 'package:effect_dart/effect_dart.dart';
import '../models/user.dart';
import '../services/user_service.dart';

// User-related effects
Effect<User, UserError, UserService> getUser(String id) {
  return Effect.service<UserService>()
      .flatMap((service) => Effect.async(() => service.findById(id)));
}

Effect<User, UserError, UserService> createUser(String name, String email) {
  return Effect.service<UserService>()
      .flatMap((service) => Effect.async(() => service.create(name, email)));
}

Effect<void, UserError, UserService> deleteUser(String id) {
  return Effect.service<UserService>()
      .flatMap((service) => Effect.async(() => service.delete(id)));
}

// User errors
sealed class UserError {
  const UserError();
}

class UserNotFound extends UserError {
  final String id;
  const UserNotFound(this.id);
}

class UserAlreadyExists extends UserError {
  final String email;
  const UserAlreadyExists(this.email);
}
```

### Barrel Exports

Create barrel files to simplify imports:

```dart
// lib/src/effects/effects.dart
export 'user_effects.dart';
export 'auth_effects.dart';
export 'notification_effects.dart';
export 'file_effects.dart';
```

```dart
// lib/src/services/services.dart
export 'user_service.dart';
export 'auth_service.dart';
export 'notification_service.dart';
export 'file_service.dart';
```

```dart
// lib/my_app.dart
export 'src/effects/effects.dart';
export 'src/services/services.dart';
export 'src/models/models.dart';

// Re-export Effect Dart for convenience
export 'package:effect_dart/effect_dart.dart';
```

### Using Your Library

```dart
// In your application
import 'package:my_app/my_app.dart';

void main() async {
  // All your effects and Effect Dart functionality available
  final userEffect = getUser('123');
  final context = Context.of(UserServiceImpl());
  
  final exit = await userEffect.runToExit(context);
  // Handle result...
}
```

## Import Best Practices

### 1. Group Imports Logically

```dart
// Dart core libraries
import 'dart:async';
import 'dart:convert';

// Third-party packages
import 'package:effect_dart/effect_dart.dart';
import 'package:http/http.dart' as http;

// Local imports
import '../models/user.dart';
import '../services/user_service.dart';
import 'user_effects.dart';
```

### 2. Use Show/Hide Appropriately

```dart
// Good: Import only what you need
import 'package:effect_dart/effect_dart.dart' show 
    Effect, 
    Option, 
    Either;

// Avoid: Importing everything when you only need a few things
import 'package:effect_dart/effect_dart.dart';
```

### 3. Avoid Import Conflicts

```dart
// Good: Use aliases to avoid conflicts
import 'dart:io' as io;
import 'package:effect_dart/effect_dart.dart';
import 'package:my_app/io_utils.dart' as app_io;

void main() {
  final file = io.File('data.txt');
  final effect = Effect.succeed(42);
  final result = app_io.processFile(file);
}
```

### 4. Keep Imports Minimal

```dart
// Good: Only import what you use
import 'package:effect_dart/effect_dart.dart' show Effect, Option;

Effect<String, Never, void> processValue(Option<int> maybeValue) {
  return Effect.succeed(maybeValue.fold(
    () => "No value",
    (value) => "Value: $value",
  ));
}
```

## Common Import Patterns

### Service Layer Pattern

```dart
// lib/src/services/base_service.dart
import 'package:effect_dart/effect_dart.dart';

abstract class BaseService<T, E> {
  Effect<T, E, void> findById(String id);
  Effect<T, E, void> create(T entity);
  Effect<void, E, void> update(String id, T entity);
  Effect<void, E, void> delete(String id);
}
```

```dart
// lib/src/services/user_service.dart
import 'package:effect_dart/effect_dart.dart';
import '../models/user.dart';
import 'base_service.dart';

class UserService extends BaseService<User, UserError> {
  @override
  Effect<User, UserError, void> findById(String id) {
    return Effect.async(() async {
      // Implementation
    });
  }
  
  // Other methods...
}
```

### Repository Pattern

```dart
// lib/src/repositories/repository.dart
import 'package:effect_dart/effect_dart.dart';

abstract class Repository<T, ID, E> {
  Effect<T, E, void> findById(ID id);
  Effect<List<T>, E, void> findAll();
  Effect<T, E, void> save(T entity);
  Effect<void, E, void> deleteById(ID id);
}
```

### Effect Composition Pattern

```dart
// lib/src/workflows/user_workflow.dart
import 'package:effect_dart/effect_dart.dart';
import '../effects/user_effects.dart';
import '../effects/notification_effects.dart';
import '../effects/audit_effects.dart';

Effect<User, WorkflowError, UserService & NotificationService & AuditService> 
createUserWorkflow(String name, String email) {
  return createUser(name, email)
      .flatMap((user) => sendWelcomeNotification(user.email)
          .flatMap((_) => logUserCreation(user.id))
          .map((_) => user))
      .mapError((error) => WorkflowError.fromUserError(error));
}
```

## Testing Imports

### Test-Specific Imports

```dart
// test/user_effects_test.dart
import 'package:test/test.dart';
import 'package:effect_dart/effect_dart.dart';
import '../lib/src/effects/user_effects.dart';

// Mock services for testing
import 'mocks/mock_user_service.dart';

void main() {
  group('User Effects', () {
    test('should get user by id', () async {
      final mockService = MockUserService();
      final context = Context.of<UserService>(mockService);
      
      final effect = getUser('123');
      final exit = await effect.runToExit(context);
      
      expect(exit.isSuccess, true);
    });
  });
}
```

## Next Steps

- [Building Pipelines](./building-pipelines) - Learn to compose effects
- [Using Generators](./using-generators) - Advanced effect patterns
- [Control Flow Operators](./control-flow-operators) - Flow control in effects
- [Error Handling](/error-handling/) - Comprehensive error management