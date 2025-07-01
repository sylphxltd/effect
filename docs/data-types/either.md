# Either

The `Either<L, R>` type represents a value that can be either a Left (typically an error) or a Right (typically a success value). It's a fundamental data type for functional error handling and provides a comprehensive API for working with values that might fail.

## Creating Either Values

### Basic Constructors

```dart
import 'package:effect_dart/effect_dart.dart';

// Create success values (Right)
final success = Either.right(42);
final message = Either.right("Hello, World!");

// Create error values (Left)
final failure = Either.left("Error occurred");
final customError = Either.left(ValidationError("Invalid input"));

// Predefined void result
final voidResult = Either.voidValue; // Right(null)
```

### From Other Types

```dart
// From nullable values
final fromNull = Either.fromNullable(null, () => "Was null"); 
// Left("Was null")

final fromValue = Either.fromNullable("hello", () => "Was null"); 
// Right("hello")

// From Option
final fromSome = Either.fromOption(Option.some(10), () => "Was none"); 
// Right(10)

final fromNone = Either.fromOption(Option.none(), () => "Was none"); 
// Left("Was none")
```

### Exception Handling

```dart
// Safe function calls
final safe = Either.tryCall(() => int.parse("42")); 
// Right(42)

final safeFailed = Either.tryCall(() => int.parse("abc")); 
// Left(FormatException)

// With custom error handling
final withCustomError = Either.tryWith(
  tryFn: () => int.parse("abc"),
  catchFn: (e) => "Parse error: $e",
); 
// Left("Parse error: ...")
```

## Type Checking and Guards

```dart
final value = Either.right(42);

// Type checking
print(Either.isEither(value)); // true
print(value.isRight); // true
print(value.isLeft); // false

// Extract values safely
final rightOption = Either.getRight(value); // Some(42)
final leftOption = Either.getLeft(value); // None()
```

## Pattern Matching

```dart
final result = Either.right(42);

// Using match method
final message = result.match(
  onLeft: (error) => "Failed: $error",
  onRight: (value) => "Success: $value",
);
print(message); // "Success: 42"

// Using fold (alias for match)
final folded = result.fold(
  (error) => "Error: $error",
  (value) => "Value: $value",
);
```

## Transformations

### Mapping Values

```dart
final number = Either.right(21);

// Transform success values
final doubled = number.map((x) => x * 2); // Right(42)

// Transform error values
final errorMapped = Either.left("error")
    .mapLeft((e) => "Prefix: $e"); // Left("Prefix: error")

// Transform both sides
final bothMapped = number.mapBoth(
  onLeft: (e) => "Error: $e",
  onRight: (v) => v * 2,
); // Right(42)
```

### Chaining Operations

```dart
final number = Either.right(10);

// Chain computations
final computed = number
    .flatMap((x) => x > 0 
        ? Either.right(x * 2) 
        : Either.left("Invalid"))
    .andThen((x) => Either.right(x + 1)); // Right(21)

// Alternative chaining syntax
final chained = number
    .flatMap((x) => Either.right(x.toString()))
    .flatMap((s) => Either.right(s.length)); // Right(2)
```

## Filtering and Validation

```dart
final number = Either.right(42);

// Filter with predicate
final filtered = number.filterOrLeft(
  (x) => x > 50,
  () => "Value too small",
); // Left("Value too small")

// Lift predicate into Either
final predicate = Either.liftPredicate<int, String>(
  (x) => x > 0,
  (x) => "Value must be positive: $x",
);

final positive = predicate(5); // Right(5)
final negative = predicate(-1); // Left("Value must be positive: -1")
```

## Extracting Values

```dart
final success = Either.right(42);
final failure = Either.left("error");

// Get value or default
final value1 = success.getOrElse(0); // 42
final value2 = failure.getOrElse(0); // 0

// Get value or null
final nullable1 = success.getOrNull(); // 42
final nullable2 = failure.getOrNull(); // null

// Get value or throw
final throwing1 = success.getOrThrow(); // 42
// final throwing2 = failure.getOrThrow(); // Throws!
```

## Combining Eithers

### Zip Operations

```dart
final either1 = Either.right(10);
final either2 = Either.right(5);

// Combine two Eithers
final combined = either1.zipWith(either2, (a, b) => a + b); 
// Right(15)

// With failure
final failed = Either.left("error").zipWith(either2, (a, b) => a + b); 
// Left("error")
```

### Applicative Pattern

```dart
// Function to apply
final add = (int a) => (int b) => a + b;

// Apply function through Eithers
final applied = Either.right(add)
    .ap(Either.right(10))
    .ap(Either.right(5)); // Right(15)

// With failure
final failedApp = Either.right(add)
    .ap(Either.left("error"))
    .ap(Either.right(5)); // Left("error")
```

### Collecting Results

```dart
// Collect all successes
final allSuccess = Either.all([
  Either.right(1),
  Either.right(2),
  Either.right(3),
]); // Right([1, 2, 3])

// First failure short-circuits
final withFailure = Either.all([
  Either.right(1),
  Either.left("error"),
  Either.right(3),
]); // Left("error")
```

## Alternative Handling

```dart
final failure = Either.left("primary error");

// Provide alternative
final alternative = failure.orElse(() => Either.right(42)); 
// Right(42)

// Chain alternatives
final chained = failure
    .orElse(() => Either.left("secondary error"))
    .orElse(() => Either.right("fallback")); // Right("fallback")
```

## Utility Operations

### Flipping Sides

```dart
final right = Either.right(42);
final flipped = Either.flip(right); // Left(42)

final left = Either.left("error");
final flippedLeft = Either.flip(left); // Right("error")
```

### Merging When Same Type

```dart
// When both sides have the same type
final rightInt = Either.right(42);
final merged1 = rightInt.merge<int>(); // 42

final leftInt = Either.left(24);
final merged2 = leftInt.merge<int>(); // 24
```

## Real-World Examples

### Validation Pipeline

```dart
class User {
  final String name;
  final String email;
  final int age;
  
  User(this.name, this.email, this.age);
}

Either<String, String> validateName(String name) {
  return name.isNotEmpty 
      ? Either.right(name)
      : Either.left("Name cannot be empty");
}

Either<String, String> validateEmail(String email) {
  return email.contains('@')
      ? Either.right(email)
      : Either.left("Invalid email format");
}

Either<String, int> validateAge(int age) {
  return age >= 0 && age <= 120
      ? Either.right(age)
      : Either.left("Age must be between 0 and 120");
}

// Combine validations
Either<String, User> createUser(String name, String email, int age) {
  return validateName(name)
      .flatMap((validName) => validateEmail(email)
          .flatMap((validEmail) => validateAge(age)
              .map((validAge) => User(validName, validEmail, validAge))));
}

// Usage
final result = createUser("John", "john@example.com", 30);
result.match(
  onLeft: (error) => print("Validation failed: $error"),
  onRight: (user) => print("User created: ${user.name}"),
);
```

### HTTP Client

```dart
sealed class HttpError {}
class NetworkError extends HttpError {
  final String message;
  NetworkError(this.message);
}
class ParseError extends HttpError {
  final String message;
  ParseError(this.message);
}

Either<HttpError, Map<String, dynamic>> parseJson(String response) {
  return Either.tryWith(
    tryFn: () => jsonDecode(response) as Map<String, dynamic>,
    catchFn: (e) => ParseError("Failed to parse JSON: $e"),
  );
}

Future<Either<HttpError, Map<String, dynamic>>> fetchData(String url) async {
  return Either.tryWith(
    tryFn: () async {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw NetworkError("HTTP ${response.statusCode}");
      }
    },
    catchFn: (e) => e is HttpError ? e : NetworkError(e.toString()),
  ).then((either) => either.flatMap(parseJson));
}
```

### Configuration Loading

```dart
sealed class ConfigError {}
class FileNotFound extends ConfigError {}
class InvalidFormat extends ConfigError {}

Either<ConfigError, Map<String, dynamic>> loadConfig(String path) {
  return Either.tryWith(
    tryFn: () {
      final file = File(path);
      if (!file.existsSync()) {
        throw FileNotFound();
      }
      final content = file.readAsStringSync();
      return jsonDecode(content) as Map<String, dynamic>;
    },
    catchFn: (e) {
      if (e is ConfigError) return e;
      if (e is FileSystemException) return FileNotFound();
      return InvalidFormat();
    },
  );
}

// Usage with defaults
final config = loadConfig('config.json')
    .getOrElse({'host': 'localhost', 'port': 8080});
```

## Integration with Effects

Either works seamlessly with Effect:

```dart
// Convert Either to Effect
final either = Either.right(42);
final effect = either.fold(
  (error) => Effect.fail(error),
  (value) => Effect.succeed(value),
);

// Convert Effect to Either
final effectResult = Effect.succeed(42).either();
// This creates Effect<Either<E, A>, Never, R>
```

## Best Practices

### 1. Use Specific Error Types

```dart
// Good: Specific error types
sealed class ValidationError {}
class EmptyName extends ValidationError {}
class InvalidEmail extends ValidationError {}

Either<ValidationError, User> validateUser(String name, String email) {
  // Implementation
}

// Less ideal: Generic string errors
Either<String, User> validateUserGeneric(String name, String email) {
  // Implementation
}
```

### 2. Chain Operations Efficiently

```dart
// Good: Chain operations
final result = parseInput(input)
    .flatMap(validateData)
    .flatMap(processData)
    .map(formatOutput);

// Less efficient: Nested matching
final step1 = parseInput(input);
if (step1.isRight) {
  final step2 = validateData(step1.getOrThrow());
  if (step2.isRight) {
    // ... more nesting
  }
}
```

### 3. Use Pattern Matching

```dart
// Good: Use match for handling both cases
result.match(
  onLeft: (error) => handleError(error),
  onRight: (value) => handleSuccess(value),
);

// Avoid: Manual type checking
if (result.isRight) {
  handleSuccess(result.getOrThrow());
} else {
  handleError(/* how to get the error? */);
}
```

## API Reference

### Constructors
- `Either.right<L, R>(R value)` - Create Right value
- `Either.left<L, R>(L value)` - Create Left value
- `Either.voidValue` - Predefined Right(null)
- `Either.fromNullable<L, R>(R?, L Function())` - From nullable
- `Either.fromOption<L, R>(Option<R>, L Function())` - From Option
- `Either.tryCall<R>(R Function())` - Safe function call
- `Either.tryWith<L, R>(R Function(), L Function(Object))` - With error handler

### Type Guards
- `Either.isEither(dynamic)` - Type guard
- `isLeft` - Check if Left
- `isRight` - Check if Right
- `Either.getLeft<L, R>(Either<L, R>)` - Extract Left as Option
- `Either.getRight<L, R>(Either<L, R>)` - Extract Right as Option

### Transformations
- `map<R2>(R2 Function(R))` - Transform Right value
- `mapLeft<L2>(L2 Function(L))` - Transform Left value
- `mapBoth<L2, R2>(L2 Function(L), R2 Function(R))` - Transform both
- `flatMap<R2>(Either<L, R2> Function(R))` - Chain operations
- `andThen<R2>(Either<L, R2> Function(R))` - Alias for flatMap

### Pattern Matching
- `match<T>(T Function(L), T Function(R))` - Pattern match
- `fold<T>(T Function(L), T Function(R))` - Alias for match

### Filtering
- `filterOrLeft(bool Function(R), L Function())` - Filter with predicate
- `Either.liftPredicate<R, L>(bool Function(R), L Function(R))` - Lift predicate

### Value Extraction
- `getOrElse(R defaultValue)` - Get value or default
- `getOrNull()` - Get value or null
- `getOrThrow()` - Get value or throw

### Combining
- `zipWith<R2, R3>(Either<L, R2>, R3 Function(R, R2))` - Combine two Eithers
- `ap<R2>(Either<L, R2>)` - Applicative apply
- `Either.all<L, R>(List<Either<L, R>>)` - Collect all results

### Alternatives
- `orElse(Either<L, R> Function())` - Provide alternative

### Utilities
- `Either.flip<L, R>(Either<L, R>)` - Swap Left and Right
- `merge<T>()` - Merge when both sides same type (requires T = L = R)