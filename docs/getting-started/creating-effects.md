# Creating Effects

Effect Dart provides several ways to create effects depending on your use case. This guide covers all the different constructors and when to use them.

## Basic Effect Constructors

### Effect.succeed

Creates an effect that always succeeds with a given value:

```dart
// Effect<int, Never, void>
final successEffect = Effect.succeed(42);

// Effect<String, Never, void>
final messageEffect = Effect.succeed("Hello, World!");

// Effect<User, Never, void>
final userEffect = Effect.succeed(User(id: "123", name: "John"));
```

### Effect.fail

Creates an effect that always fails with a given error:

```dart
// Effect<Never, String, void>
final failureEffect = Effect.fail("Something went wrong");

// Effect<Never, CustomError, void>
final customErrorEffect = Effect.fail(CustomError("Invalid input"));
```

## Synchronous Effects

### Effect.sync

Creates an effect from a synchronous computation that might throw:

```dart
// Safe synchronous computation
final safeSync = Effect.sync(() => 42 * 2);

// Risky synchronous computation
final riskySync = Effect.sync(() {
  if (Random().nextBool()) {
    return "Success!";
  } else {
    throw Exception("Random failure!");
  }
});

// File reading example
final readConfig = Effect.sync(() {
  final file = File('config.json');
  if (!file.existsSync()) {
    throw FileSystemException('Config file not found');
  }
  return file.readAsStringSync();
});
```

## Asynchronous Effects

### Effect.async

Creates an effect from an async computation:

```dart
// Simple async effect
final asyncEffect = Effect.async(() async {
  await Future.delayed(Duration(seconds: 1));
  return "Async result";
});

// HTTP request example
final fetchData = Effect.async(() async {
  final response = await http.get(Uri.parse('https://api.example.com/data'));
  if (response.statusCode == 200) {
    return response.body;
  } else {
    throw HttpException('Failed to fetch data: ${response.statusCode}');
  }
});

// Database query example
final queryUser = Effect.async(() async {
  final db = await openDatabase('app.db');
  final result = await db.query('users', where: 'id = ?', whereArgs: ['123']);
  if (result.isEmpty) {
    throw UserNotFoundException('User not found');
  }
  return User.fromMap(result.first);
});
```

### Effect.asyncCallback

Creates an effect from callback-based async operations:

```dart
// Timer-based callback
final timerEffect = Effect.asyncCallback<String>((callback) {
  Timer(Duration(seconds: 1), () {
    callback(Effect.succeed('Timer completed'));
  });
});

// Error handling with callbacks
final riskyCallback = Effect.asyncCallback<int>((callback) {
  Timer(Duration(milliseconds: 100), () {
    if (Random().nextBool()) {
      callback(Effect.succeed(42));
    } else {
      callback(Effect.fail('Callback failed'));
    }
  });
});

// WebSocket example
final websocketEffect = Effect.asyncCallback<String>((callback) {
  final socket = WebSocket.connect('ws://localhost:8080');
  socket.then((ws) {
    ws.listen(
      (message) => callback(Effect.succeed(message)),
      onError: (error) => callback(Effect.fail(error.toString())),
    );
  });
});
```

## Utility Effects

### Effect.sleep

Creates an effect that delays execution:

```dart
// Sleep for 1 second
final sleepEffect = Effect.sleep(Duration(seconds: 1));

// Combine with other effects
final delayedMessage = Effect.sleep(Duration(milliseconds: 500))
    .flatMap((_) => Effect.succeed("Delayed message"));
```

### Effect.promise

Creates an effect from a Future:

```dart
// From existing Future
Future<String> existingFuture = fetchDataFromApi();
final promiseEffect = Effect.promise(() => existingFuture);

// Inline Future creation
final inlinePromise = Effect.promise(() => Future.delayed(
  Duration(seconds: 1), 
  () => "Promise result"
));
```

### Effect.suspend

Creates a lazily evaluated effect:

```dart
// Lazy evaluation - computation doesn't run until effect is executed
final lazyEffect = Effect.suspend(() {
  print('This only prints when effect runs');
  return Effect.succeed('computed value');
});

// Exception handling in suspended effects
final riskyLazy = Effect.suspend(() {
  if (Random().nextBool()) {
    throw Exception('Random failure');
  }
  return Effect.succeed('success');
});

// Recursive effects
Effect<int, Never, void> countdown(int n) {
  if (n <= 0) {
    return Effect.succeed(0);
  }
  return Effect.suspend(() => 
    Effect.sync(() => print('Countdown: $n'))
      .flatMap((_) => countdown(n - 1))
  );
}
```

## Service-Based Effects

### Effect.service

Creates an effect that requires a service from the context:

```dart
// Require a single service
final dbEffect = Effect.service<DatabaseService>();

// Use the service
final fetchUser = Effect.service<DatabaseService>()
    .flatMap((db) => Effect.async(() => db.getUser('123')));

// Multiple services
final complexEffect = Effect.service<DatabaseService>()
    .flatMap((db) => Effect.service<LoggerService>()
      .flatMap((logger) => Effect.async(() async {
        logger.log('Fetching user...');
        final user = await db.getUser('123');
        logger.log('User fetched: ${user.name}');
        return user;
      })));
```

## Error Handling During Creation

### Try-Catch Pattern

```dart
// Wrap risky operations
final safeEffect = Effect.sync(() {
  try {
    return riskyOperation();
  } catch (e) {
    throw SafeError('Operation failed: $e');
  }
});
```

### Validation Effects

```dart
// Input validation
Effect<String, ValidationError, void> validateEmail(String email) {
  return Effect.sync(() {
    if (!email.contains('@')) {
      throw ValidationError('Invalid email format');
    }
    return email;
  });
}

// Chaining validations
final validateUser = validateEmail(email)
    .flatMap((validEmail) => validateAge(age)
      .map((validAge) => User(email: validEmail, age: validAge)));
```

## Best Practices

### 1. Use Appropriate Constructors

```dart
// Good: Use sync for synchronous operations
final syncEffect = Effect.sync(() => computeValue());

// Bad: Don't use async for sync operations
final badAsync = Effect.async(() async => computeValue());
```

### 2. Handle Exceptions Properly

```dart
// Good: Let Effect handle exceptions
final goodEffect = Effect.sync(() => riskyOperation());

// Okay: Handle specific exceptions
final handledEffect = Effect.sync(() {
  try {
    return riskyOperation();
  } on SpecificException catch (e) {
    throw MyCustomError(e.message);
  }
});
```

### 3. Use Descriptive Error Types

```dart
// Good: Specific error types
sealed class UserError {}
class UserNotFound extends UserError {}
class UserInvalid extends UserError {}

Effect<User, UserError, DatabaseService> fetchUser(String id) {
  return Effect.service<DatabaseService>()
      .flatMap((db) => Effect.async(() => db.getUser(id)));
}

// Less ideal: Generic error types
Effect<User, String, DatabaseService> fetchUserGeneric(String id) {
  return Effect.service<DatabaseService>()
      .flatMap((db) => Effect.async(() => db.getUser(id)));
}
```

## Next Steps

- Learn about [Running Effects](./running-effects)
- Explore [Building Pipelines](./building-pipelines)
- Understand [Error Handling](/error-handling/)