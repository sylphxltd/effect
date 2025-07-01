# Running Effects

Effects are lazy descriptions of computations - they don't execute until you explicitly run them. Effect Dart provides several ways to execute effects depending on your needs.

## Basic Execution Methods

### runUnsafe

The simplest way to run an effect, throwing exceptions on failure:

```dart
final effect = Effect.succeed(42);

// Run and get the result directly
final result = await effect.runUnsafe();
print(result); // 42

// With context
final contextualEffect = Effect.service<DatabaseService>()
    .flatMap((db) => Effect.async(() => db.getUser('123')));

final context = Context.of(DatabaseService());
final user = await contextualEffect.runUnsafe(context);
```

**Warning**: `runUnsafe` throws exceptions on failure. Use it only when you're certain the effect won't fail or when you want exceptions to propagate.

### runToExit

The safe way to run effects, returning an `Exit` that represents success or failure:

```dart
final effect = Effect.succeed(42);

// Run and get Exit result
final exit = await effect.runToExit();

switch (exit) {
  case Success(:final value):
    print('Success: $value');
  case Failure(:final cause):
    print('Failure: $cause');
}

// With error handling
final riskyEffect = Effect.sync(() {
  if (Random().nextBool()) {
    return "Success!";
  } else {
    throw Exception("Random failure!");
  }
});

final exit2 = await riskyEffect.runToExit();
exit2.fold(
  (cause) => print('Failed: $cause'),
  (value) => print('Succeeded: $value'),
);
```

## Synchronous Execution

### runSyncExit

For effects that don't require async operations:

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
```

## Promise/Future Integration

### runPromise

Convert an effect to a Future:

```dart
final effect = Effect.succeed(42);

// Convert to Future
final future = Effect.runPromise(effect);
final result = await future; // 42

// With error handling
final riskyEffect = Effect.fail("Error occurred");
try {
  await Effect.runPromise(riskyEffect);
} catch (e) {
  print('Caught: $e'); // Caught: Error occurred
}
```

## Using Runtime

### Default Runtime

The `Runtime` class provides more control over effect execution:

```dart
final runtime = Runtime.defaultRuntime;

// Run single effect
final exit = await runtime.runToExit(Effect.succeed(42));

// Run unsafely
final result = await runtime.runUnsafe(Effect.succeed(42));
```

### Concurrent Execution

Run multiple effects concurrently:

```dart
final effect1 = Effect.async(() => Future.delayed(Duration(milliseconds: 100), () => 'A'));
final effect2 = Effect.async(() => Future.delayed(Duration(milliseconds: 200), () => 'B'));
final effect3 = Effect.async(() => Future.delayed(Duration(milliseconds: 150), () => 'C'));

// Run all concurrently
final results = await Runtime.defaultRuntime.runConcurrently([
  effect1, effect2, effect3
]);
print(results); // ['A', 'B', 'C']

// Race (first to complete wins)
final winner = await Runtime.defaultRuntime.runRace([
  effect1, effect2, effect3
]);
print(winner); // 'A' (fastest)
```

## Context Management

### Providing Context

Effects that require dependencies need context:

```dart
// Define services
class DatabaseService {
  Future<User> getUser(String id) async => User(id: id, name: 'John');
}

class LoggerService {
  void log(String message) => print('[LOG] $message');
}

// Create effect that needs services
final effect = Effect.service<DatabaseService>()
    .flatMap((db) => Effect.service<LoggerService>()
      .flatMap((logger) => Effect.async(() async {
        logger.log('Fetching user...');
        return await db.getUser('123');
      })));

// Provide context
final context = Context.empty()
    .add(DatabaseService())
    .add(LoggerService());

final user = await effect.runUnsafe(context);
```

### Providing Individual Services

```dart
final dbEffect = Effect.service<DatabaseService>()
    .flatMap((db) => Effect.async(() => db.getUser('123')));

// Provide single service
final effectWithService = dbEffect.provideService(DatabaseService());
final user = await effectWithService.runUnsafe();
```

## Error Handling During Execution

### Exit Pattern Matching

```dart
final riskyEffect = Effect.sync(() {
  if (Random().nextBool()) {
    return "Success!";
  } else {
    throw Exception("Failed!");
  }
});

final exit = await riskyEffect.runToExit();

final message = exit.fold(
  (cause) => "Operation failed: $cause",
  (value) => "Operation succeeded: $value",
);
print(message);
```

### Exception Handling with runUnsafe

```dart
final riskyEffect = Effect.fail("Something went wrong");

try {
  await riskyEffect.runUnsafe();
} catch (e) {
  print('Caught exception: $e');
}
```

## Fiber Management

### Creating Fibers

Fibers provide fine-grained control over concurrent execution:

```dart
final effect1 = Effect.async(() => Future.delayed(Duration(seconds: 1), () => 'A'));
final effect2 = Effect.async(() => Future.delayed(Duration(seconds: 2), () => 'B'));

// Fork effects into fibers
final fiber1 = effect1.fork();
final fiber2 = effect2.fork();

// Wait for both to complete
final (exit1, exit2) = await fiber1.zip(fiber2);

print('Results: ${exit1.getOrNull()}, ${exit2.getOrNull()}');
```

## Performance Considerations

### Synchronous vs Asynchronous

```dart
// Prefer synchronous execution for sync effects
final syncEffect = Effect.sync(() => expensiveComputation());
final syncResult = Effect.runSyncExit(syncEffect); // Faster

// Use async execution for async effects
final asyncEffect = Effect.async(() => fetchFromNetwork());
final asyncResult = await asyncEffect.runToExit(); // Necessary
```

### Batching Operations

```dart
// Instead of running effects one by one
final results = <String>[];
for (final id in userIds) {
  final user = await fetchUser(id).runUnsafe();
  results.add(user.name);
}

// Run them concurrently
final effects = userIds.map(fetchUser).toList();
final users = await Runtime.defaultRuntime.runConcurrently(effects);
final names = users.map((user) => user.name).toList();
```

## Best Practices

### 1. Use runToExit for Production Code

```dart
// Good: Handle errors explicitly
final exit = await effect.runToExit();
exit.fold(
  (cause) => handleError(cause),
  (value) => handleSuccess(value),
);

// Avoid: Using runUnsafe without error handling
final result = await effect.runUnsafe(); // Can throw!
```

### 2. Provide Context at the Boundary

```dart
// Good: Provide context once at application boundary
void main() async {
  final context = Context.empty()
      .add(DatabaseService())
      .add(LoggerService());
  
  final app = createApp();
  await app.runUnsafe(context);
}

// Avoid: Providing context deep in the call stack
```

### 3. Use Appropriate Execution Method

```dart
// For testing: Use runSyncExit when possible
test('sync effect test', () {
  final effect = Effect.sync(() => 42);
  final exit = Effect.runSyncExit(effect);
  expect(exit.getOrNull(), equals(42));
});

// For integration: Use runToExit
final exit = await integrationEffect.runToExit();

// For simple scripts: runUnsafe is okay
final result = await simpleEffect.runUnsafe();
```

## Next Steps

- Learn about [Building Pipelines](./building-pipelines)
- Explore [Error Handling](/error-handling/)
- Understand [Dependency Management](/dependency-management/)