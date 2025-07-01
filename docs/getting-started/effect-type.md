# The Effect Type

The `Effect` type is the core abstraction in Effect Dart. It represents a description of a computation that may succeed, fail, or require dependencies.

## Type Signature

```dart
Effect<A, E, R>
```

Where:
- `A` (Success): The type of value the effect produces on success
- `E` (Error): The type of expected errors that can occur
- `R` (Requirements): The type of dependencies required from context

## Understanding the Type Parameters

### Success Type (A)

The success type represents what the effect produces when it succeeds:

```dart
// Effect that succeeds with an int
Effect<int, Never, void> numberEffect = Effect.succeed(42);

// Effect that succeeds with a String
Effect<String, Never, void> textEffect = Effect.succeed("Hello");

// Effect that succeeds with a custom type
Effect<User, Never, void> userEffect = Effect.succeed(User(id: "123", name: "John"));
```

### Error Type (E)

The error type represents expected failures that can occur:

```dart
// Effect that can fail with a String error
Effect<int, String, void> mayFailEffect = Effect.fail("Something went wrong");

// Effect that can fail with a custom error type
Effect<User, UserNotFoundError, void> userLookup = 
  Effect.fail(UserNotFoundError("User not found"));

// Effect that never fails (uses Never type)
Effect<int, Never, void> safeEffect = Effect.succeed(42);
```

### Requirements Type (R)

The requirements type represents dependencies the effect needs:

```dart
// Effect that requires a DatabaseService
Effect<User, DatabaseError, DatabaseService> fetchUser = 
  Effect.service<DatabaseService>()
    .flatMap((db) => Effect.async(() => db.getUser("123")));

// Effect that requires multiple services
Effect<String, EmailError, EmailService & LoggerService> sendEmail = 
  Effect.service<EmailService>()
    .flatMap((email) => Effect.service<LoggerService>()
      .flatMap((logger) => Effect.async(() async {
        logger.log("Sending email...");
        return await email.send("Hello!");
      })));

// Effect that requires no dependencies
Effect<int, Never, void> simpleEffect = Effect.succeed(42);
```

## Type Evolution

As you transform effects, their types evolve:

```dart
// Start with Effect<int, Never, void>
final initial = Effect.succeed(10);

// Map transforms the success type: Effect<String, Never, void>
final mapped = initial.map((x) => x.toString());

// FlatMap can change all type parameters
final chained = mapped.flatMap((str) => 
  str.length > 5 
    ? Effect.succeed(str.length)      // Effect<int, Never, void>
    : Effect.fail("Too short"));      // Effect<int, String, void>
// Result: Effect<int, String, void>

// CatchAll can change the error type
final recovered = chained.catchAll((error) => 
  Effect.succeed(0));                 // Effect<int, Never, void>
// Result: Effect<int, Never, void>
```

## Working with Never

The `Never` type represents "this can never happen":

```dart
// This effect can never fail
Effect<int, Never, void> safeEffect = Effect.succeed(42);

// This effect can never succeed (always fails)
Effect<Never, String, void> alwaysFails = Effect.fail("Error");

// This effect needs no dependencies
Effect<int, String, void> noDeps = Effect.sync(() => 42);
```

## Type Inference

Dart's type inference works well with Effect:

```dart
// Type is inferred as Effect<int, Never, void>
final effect1 = Effect.succeed(42);

// Type is inferred as Effect<String, String, void>
final effect2 = Effect.sync(() {
  if (Random().nextBool()) {
    return "Success";
  } else {
    throw "Error"; // Caught and becomes typed error
  }
});

// Explicit typing when needed
final Effect<User, UserError, DatabaseService> userEffect = 
  Effect.service<DatabaseService>()
    .flatMap((db) => Effect.async(() => db.getUser("123")));
```

## Common Patterns

### Void Effects

Effects that don't return a meaningful value:

```dart
// Effect<void, Never, void>
final logEffect = Effect.sync(() => print("Hello"));

// Effect<void, String, LoggerService>
final serviceLogEffect = Effect.service<LoggerService>()
  .flatMap((logger) => Effect.sync(() => logger.log("Message")));
```

### Error Accumulation

When you need to collect multiple errors:

```dart
// Effect<List<String>, List<String>, void>
final validationEffect = Effect.succeed(<String>[])
  .flatMap((errors) => validateName(name)
    .catchAll((error) => Effect.succeed(errors..add(error))))
  .flatMap((errors) => validateEmail(email)
    .catchAll((error) => Effect.succeed(errors..add(error))));
```

### Resource Management

Effects that manage resources:

```dart
// Effect<String, FileError, FileSystem>
final readFileEffect = Effect.service<FileSystem>()
  .flatMap((fs) => Effect.async(() => fs.readFile("config.txt")));
```

## Type Safety Benefits

The Effect type system provides several benefits:

1. **Compile-time Error Checking**: Unhandled errors are caught at compile time
2. **Dependency Tracking**: Required services are explicit in the type
3. **Composition Safety**: Type mismatches are caught when composing effects
4. **Documentation**: Types serve as documentation for what effects do

## Next Steps

- Learn about [Creating Effects](./creating-effects)
- Understand [Running Effects](./running-effects)
- Explore [Building Pipelines](./building-pipelines)