# Why Effect?

Effect Dart brings the power of functional programming to Dart, providing a robust foundation for building reliable, maintainable, and testable applications. Here's why you should consider using Effect in your Dart projects.

## The Problem with Traditional Dart Code

Traditional Dart code often suffers from several issues:

### 1. Untracked Side Effects

```dart
// Traditional approach - side effects are hidden
Future<User> getUser(String id) async {
  // Hidden side effects:
  // - Network call might fail
  // - Database might be unavailable
  // - Logging happens as side effect
  logger.log('Fetching user $id');
  
  final response = await http.get('/users/$id');
  if (response.statusCode != 200) {
    throw HttpException('User not found');
  }
  
  return User.fromJson(response.body);
}
```

### 2. Exception-Based Error Handling

```dart
// Exceptions make error handling unpredictable
try {
  final user = await getUser('123');
  final profile = await getProfile(user.id);
  return profile;
} catch (e) {
  // What types of errors can occur here?
  // How should we handle different error types?
  return null;
}
```

### 3. Hidden Dependencies

```dart
// Dependencies are hidden and hard to test
class UserService {
  Future<User> createUser(String name, String email) async {
    // Hidden dependencies on global state
    final db = DatabaseConnection.instance;
    final logger = Logger.instance;
    final emailService = EmailService.instance;
    
    // Implementation...
  }
}
```

## The Effect Solution

Effect Dart solves these problems by making side effects, errors, and dependencies explicit in the type system.

### 1. Explicit Side Effects

```dart
// Effect approach - everything is explicit
Effect<User, UserError, DatabaseService & LoggerService> getUser(String id) {
  return Effect.service<LoggerService>()
      .flatMap((logger) => Effect.sync(() => logger.log('Fetching user $id')))
      .flatMap((_) => Effect.service<DatabaseService>())
      .flatMap((db) => Effect.async(() => db.getUser(id)))
      .mapError((e) => UserError.notFound(id));
}
```

### 2. Typed Error Handling

```dart
// Errors are part of the type system
sealed class UserError {
  const UserError();
}

class UserNotFound extends UserError {
  final String id;
  const UserNotFound(this.id);
}

class DatabaseError extends UserError {
  final String message;
  const DatabaseError(this.message);
}

// Now errors are explicit and handled at compile time
Effect<User, UserError, DatabaseService> fetchUser(String id) {
  return Effect.service<DatabaseService>()
      .flatMap((db) => Effect.async(() => db.getUser(id)));
}

// Error handling is explicit and type-safe
final userEffect = fetchUser('123')
    .catchAll((error) => switch (error) {
      UserNotFound(id: final id) => Effect.succeed(User.guest(id)),
      DatabaseError(message: final msg) => Effect.fail(ServiceUnavailable(msg)),
    });
```

### 3. Explicit Dependencies

```dart
// Dependencies are explicit in the type system
Effect<User, UserError, DatabaseService & EmailService & LoggerService> 
createUser(String name, String email) {
  return Effect.service<DatabaseService>()
      .flatMap((db) => Effect.service<EmailService>()
        .flatMap((emailSvc) => Effect.service<LoggerService>()
          .flatMap((logger) => Effect.async(() async {
            logger.log('Creating user: $name');
            final user = await db.createUser(name, email);
            await emailSvc.sendWelcomeEmail(user);
            return user;
          }))));
}
```

## Key Benefits

### 1. Predictability

Effects are pure descriptions of computations. The same effect will always produce the same result when run with the same context.

```dart
// This effect is predictable - it will always behave the same way
final effect = Effect.succeed(42).map((x) => x * 2);

// Running it multiple times gives the same result
final result1 = await effect.runUnsafe(); // 84
final result2 = await effect.runUnsafe(); // 84
```

### 2. Composability

Complex workflows can be built by combining simple effects:

```dart
// Simple effects
final validateEmail = (String email) => 
    email.contains('@') 
        ? Effect.succeed(email)
        : Effect.fail('Invalid email');

final validateAge = (int age) =>
    age >= 18
        ? Effect.succeed(age)
        : Effect.fail('Must be 18 or older');

// Compose them into a complex workflow
final createUser = (String name, String email, int age) =>
    validateEmail(email)
        .flatMap((_) => validateAge(age))
        .flatMap((_) => Effect.service<UserService>())
        .flatMap((service) => Effect.async(() => 
            service.createUser(name, email, age)));
```

### 3. Testability

Dependencies are explicit, making testing straightforward:

```dart
// Easy to test with mock dependencies
test('createUser should validate email', () async {
  final mockUserService = MockUserService();
  final context = Context.of(mockUserService);
  
  final effect = createUser('John', 'invalid-email', 25);
  final exit = await effect.runToExit(context);
  
  expect(exit.isFailure, true);
  expect(exit.cause, contains('Invalid email'));
});
```

### 4. Error Safety

Errors are tracked in the type system, preventing unhandled exceptions:

```dart
// Compiler ensures all error cases are handled
final safeEffect = riskyEffect
    .catchAll((error) => switch (error) {
      NetworkError() => Effect.succeed(cachedData),
      ValidationError() => Effect.fail(UserInputError()),
      // Compiler ensures all cases are covered
    });
```

### 5. Resource Management

Effects provide built-in resource management:

```dart
// Resources are automatically cleaned up
final fileEffect = Effect.bracket(
  acquire: () => Effect.sync(() => File('data.txt').openSync()),
  use: (file) => Effect.sync(() => file.readAsStringSync()),
  release: (file) => Effect.sync(() => file.closeSync()),
);
```

### 6. Concurrency

Built-in support for structured concurrency:

```dart
// Safe concurrent execution
final results = await Runtime.defaultRuntime.runConcurrently([
  fetchUser('1'),
  fetchUser('2'),
  fetchUser('3'),
]);

// Fibers for fine-grained control
final fiber1 = longRunningTask1.fork();
final fiber2 = longRunningTask2.fork();
final (result1, result2) = await fiber1.zip(fiber2);
```

## Real-World Comparison

### Traditional Approach

```dart
class OrderService {
  Future<Order?> processOrder(OrderRequest request) async {
    try {
      // Validate request (might throw)
      if (!isValidRequest(request)) {
        throw ValidationException('Invalid request');
      }
      
      // Check inventory (might throw, depends on global DB)
      final inventory = await InventoryService.instance.checkStock(request.items);
      if (!inventory.available) {
        throw InsufficientStockException();
      }
      
      // Process payment (might throw, depends on global payment service)
      final payment = await PaymentService.instance.charge(request.payment);
      
      // Create order (might throw, depends on global DB)
      final order = await DatabaseService.instance.createOrder(request, payment);
      
      // Send confirmation (might throw, depends on global email service)
      await EmailService.instance.sendConfirmation(order);
      
      return order;
    } catch (e) {
      // What errors can occur? How should we handle them?
      Logger.instance.error('Order processing failed: $e');
      return null;
    }
  }
}
```

### Effect Approach

```dart
sealed class OrderError {
  const OrderError();
}
class ValidationError extends OrderError {
  final String message;
  const ValidationError(this.message);
}
class InsufficientStock extends OrderError {
  final List<String> items;
  const InsufficientStock(this.items);
}
class PaymentFailed extends OrderError {
  final String reason;
  const PaymentFailed(this.reason);
}

Effect<Order, OrderError, InventoryService & PaymentService & DatabaseService & EmailService> 
processOrder(OrderRequest request) {
  return validateRequest(request)
      .flatMap((_) => checkInventory(request.items))
      .flatMap((_) => processPayment(request.payment))
      .flatMap((payment) => createOrder(request, payment))
      .flatMap((order) => sendConfirmation(order).map((_) => order));
}

// Usage with explicit error handling
final orderEffect = processOrder(request)
    .catchAll((error) => switch (error) {
      ValidationError(message: final msg) => 
          Effect.fail(BadRequest(msg)),
      InsufficientStock(items: final items) => 
          Effect.fail(OutOfStock(items)),
      PaymentFailed(reason: final reason) => 
          Effect.fail(PaymentError(reason)),
    });

// Easy to test
test('processOrder handles validation errors', () async {
  final context = Context.empty()
      .add(MockInventoryService())
      .add(MockPaymentService())
      .add(MockDatabaseService())
      .add(MockEmailService());
  
  final effect = processOrder(invalidRequest);
  final exit = await effect.runToExit(context);
  
  expect(exit.isFailure, true);
  expect(exit.cause, isA<ValidationError>());
});
```

## When to Use Effect

Effect Dart is particularly beneficial for:

- **Complex business logic** with multiple dependencies
- **Error-prone operations** like network calls, file I/O, database operations
- **Applications requiring high reliability** like financial systems
- **Code that needs extensive testing** with dependency injection
- **Concurrent/parallel processing** with structured concurrency
- **Long-running applications** that need resource management

## Migration Strategy

You don't need to rewrite your entire application at once:

1. **Start with new features** - Use Effect for new functionality
2. **Wrap existing code** - Create Effect wrappers around existing services
3. **Gradual refactoring** - Convert critical paths to Effect over time
4. **Interoperability** - Effect works alongside traditional Dart code

```dart
// Wrap existing service
Effect<User, DatabaseError, void> getUserEffect(String id) {
  return Effect.async(() => existingUserService.getUser(id))
      .mapError((e) => DatabaseError(e.toString()));
}
```

## Next Steps

- [Installation](./installation) - Get started with Effect Dart
- [The Effect Type](./effect-type) - Understand the core abstraction
- [Creating Effects](./creating-effects) - Learn how to create effects
- [Running Effects](./running-effects) - Learn how to execute effects