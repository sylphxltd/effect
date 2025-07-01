# Option

The `Option<A>` type represents a value that may or may not be present. It's a safe alternative to nullable types, providing a comprehensive API for working with optional values without the risk of null pointer exceptions.

## Creating Options

### Basic Constructors

```dart
import 'package:effect_dart/effect_dart.dart';

// Create Some (value present)
final some = Option.some(42);
final message = Option.some("Hello, World!");

// Create None (no value)
final none = Option.none<int>();
final emptyString = Option.none<String>();
```

### From Nullable Values

```dart
// From nullable values
final fromNull = Option.fromNullable(null); // None()
final fromValue = Option.fromNullable("hello"); // Some("hello")

// From nullable with type annotation
final typedNone = Option.fromNullable<String>(null); // None<String>()
final typedSome = Option.fromNullable<int>(42); // Some<int>(42)
```

### Conditional Creation

```dart
// Create based on condition
final conditional = Option.when(true, () => "value"); // Some("value")
final conditionalFalse = Option.when(false, () => "value"); // None()

// Create from predicate
final fromPredicate = Option.fromPredicate(42, (x) => x > 0); // Some(42)
final failedPredicate = Option.fromPredicate(-5, (x) => x > 0); // None()
```

## Type Checking

```dart
final value = Option.some(42);
final empty = Option.none<int>();

// Check if Option has value
print(value.isSome); // true
print(value.isNone); // false
print(empty.isSome); // false
print(empty.isNone); // true

// Type guard
print(Option.isOption(value)); // true
print(Option.isOption(42)); // false
```

## Extracting Values

### Safe Extraction

```dart
final some = Option.some(42);
final none = Option.none<int>();

// Get value or default
final value1 = some.getOrElse(0); // 42
final value2 = none.getOrElse(0); // 0

// Get value or null
final nullable1 = some.getOrNull(); // 42
final nullable2 = none.getOrNull(); // null

// Get value or compute default
final computed1 = some.getOrElse(() => expensiveComputation()); // 42 (no computation)
final computed2 = none.getOrElse(() => expensiveComputation()); // result of computation
```

### Pattern Matching

```dart
final option = Option.some(42);

// Using fold
final result = option.fold(
  () => "No value",
  (value) => "Value: $value",
); // "Value: 42"

// Using match (alias for fold)
final matched = option.match(
  onNone: () => "Empty",
  onSome: (value) => "Found: $value",
); // "Found: 42"
```

## Transformations

### Mapping Values

```dart
final number = Option.some(21);
final empty = Option.none<int>();

// Transform present values
final doubled = number.map((x) => x * 2); // Some(42)
final emptyDoubled = empty.map((x) => x * 2); // None()

// Transform to different type
final stringified = number.map((x) => x.toString()); // Some("21")
```

### Chaining Operations

```dart
final number = Option.some(10);

// Chain operations that return Options
final result = number
    .flatMap((x) => x > 0 ? Option.some(x * 2) : Option.none())
    .flatMap((x) => x < 100 ? Option.some(x.toString()) : Option.none());
// Some("20")

// Chain with None propagation
final noneResult = Option.none<int>()
    .flatMap((x) => Option.some(x * 2))
    .flatMap((x) => Option.some(x.toString()));
// None()
```

## Filtering

```dart
final numbers = [
  Option.some(5),
  Option.some(-3),
  Option.some(10),
  Option.none<int>(),
];

// Filter based on predicate
final positive = Option.some(5).filter((x) => x > 0); // Some(5)
final negative = Option.some(-3).filter((x) => x > 0); // None()
final noneFiltered = Option.none<int>().filter((x) => x > 0); // None()

// Filter and transform
final evenDoubled = Option.some(4)
    .filter((x) => x % 2 == 0)
    .map((x) => x * 2); // Some(8)
```

## Combining Options

### Zip Operations

```dart
final option1 = Option.some(10);
final option2 = Option.some(5);
final option3 = Option.none<int>();

// Combine two Options
final combined = option1.zipWith(option2, (a, b) => a + b); // Some(15)
final withNone = option1.zipWith(option3, (a, b) => a + b); // None()

// Zip without transformation
final zipped = option1.zip(option2); // Some((10, 5))
```

### Alternative Values

```dart
final primary = Option.none<String>();
final fallback = Option.some("fallback");

// Provide alternative
final result = primary.orElse(() => fallback); // Some("fallback")

// Chain alternatives
final chained = primary
    .orElse(() => Option.none<String>())
    .orElse(() => Option.some("final fallback")); // Some("final fallback")
```

## Collection Operations

### Working with Lists

```dart
// Filter Some values from list of Options
final options = [
  Option.some(1),
  Option.none<int>(),
  Option.some(3),
  Option.some(4),
];

final values = options
    .where((opt) => opt.isSome)
    .map((opt) => opt.getOrThrow())
    .toList(); // [1, 3, 4]

// Or using catOptions (if available)
final catted = Option.catOptions(options); // [1, 3, 4]
```

### Traverse Operations

```dart
// Transform list to Option of list
List<Option<int>> parseNumbers(List<String> strings) {
  return strings.map((s) {
    final parsed = int.tryParse(s);
    return parsed != null ? Option.some(parsed) : Option.none<int>();
  }).toList();
}

// Sequence - convert List<Option<T>> to Option<List<T>>
final strings = ["1", "2", "3"];
final parsed = parseNumbers(strings);
final sequenced = Option.sequence(parsed); // Some([1, 2, 3])

final invalidStrings = ["1", "abc", "3"];
final invalidParsed = parseNumbers(invalidStrings);
final invalidSequenced = Option.sequence(invalidParsed); // None()
```

## Real-World Examples

### Configuration Loading

```dart
class Config {
  final String host;
  final int port;
  final Option<String> apiKey;
  
  Config(this.host, this.port, this.apiKey);
}

Option<Config> loadConfig(Map<String, dynamic> json) {
  return Option.fromNullable(json['host'] as String?)
      .flatMap((host) => Option.fromNullable(json['port'] as int?)
          .map((port) => Config(
              host, 
              port, 
              Option.fromNullable(json['api_key'] as String?)
          )));
}

// Usage
final configJson = {
  'host': 'localhost',
  'port': 8080,
  'api_key': null, // Optional
};

final config = loadConfig(configJson);
config.fold(
  () => print("Invalid configuration"),
  (cfg) => print("Server: ${cfg.host}:${cfg.port}"),
);
```

### User Profile

```dart
class UserProfile {
  final String name;
  final String email;
  final Option<String> avatar;
  final Option<DateTime> lastLogin;
  
  UserProfile(this.name, this.email, this.avatar, this.lastLogin);
  
  String get displayName => name;
  
  String get avatarUrl => avatar.getOrElse("default-avatar.png");
  
  String get lastLoginText => lastLogin.fold(
    () => "Never logged in",
    (date) => "Last login: ${date.toIso8601String()}",
  );
}

// Create user with optional fields
final user = UserProfile(
  "John Doe",
  "john@example.com",
  Option.some("avatar.jpg"),
  Option.none<DateTime>(),
);

print(user.avatarUrl); // "avatar.jpg"
print(user.lastLoginText); // "Never logged in"
```

### Database Queries

```dart
abstract class UserRepository {
  Future<Option<User>> findById(String id);
  Future<Option<User>> findByEmail(String email);
}

class UserService {
  final UserRepository repository;
  
  UserService(this.repository);
  
  Future<Option<User>> authenticateUser(String email, String password) async {
    final userOption = await repository.findByEmail(email);
    
    return userOption.flatMap((user) => 
        user.checkPassword(password) 
            ? Option.some(user)
            : Option.none<User>());
  }
  
  Future<String> getUserDisplayName(String id) async {
    final userOption = await repository.findById(id);
    
    return userOption.fold(
      () => "Unknown User",
      (user) => user.name,
    );
  }
}
```

### Form Validation

```dart
class ValidationResult<T> {
  final Option<T> value;
  final List<String> errors;
  
  ValidationResult(this.value, this.errors);
  
  bool get isValid => errors.isEmpty && value.isSome;
}

ValidationResult<String> validateEmail(String? input) {
  if (input == null || input.isEmpty) {
    return ValidationResult(Option.none(), ["Email is required"]);
  }
  
  if (!input.contains('@')) {
    return ValidationResult(Option.none(), ["Invalid email format"]);
  }
  
  return ValidationResult(Option.some(input), []);
}

ValidationResult<int> validateAge(String? input) {
  if (input == null || input.isEmpty) {
    return ValidationResult(Option.none(), ["Age is required"]);
  }
  
  final age = int.tryParse(input);
  if (age == null) {
    return ValidationResult(Option.none(), ["Age must be a number"]);
  }
  
  if (age < 0 || age > 120) {
    return ValidationResult(Option.none(), ["Age must be between 0 and 120"]);
  }
  
  return ValidationResult(Option.some(age), []);
}

// Usage
final emailResult = validateEmail("john@example.com");
final ageResult = validateAge("25");

if (emailResult.isValid && ageResult.isValid) {
  final email = emailResult.value.getOrThrow();
  final age = ageResult.value.getOrThrow();
  print("Valid user: $email, age $age");
}
```

### Caching

```dart
class Cache<K, V> {
  final Map<K, V> _cache = {};
  
  Option<V> get(K key) {
    return Option.fromNullable(_cache[key]);
  }
  
  void put(K key, V value) {
    _cache[key] = value;
  }
  
  Option<V> getOrCompute(K key, V Function() compute) {
    return get(key).orElse(() {
      final value = compute();
      put(key, value);
      return Option.some(value);
    });
  }
}

// Usage
final cache = Cache<String, String>();

final result = cache.getOrCompute("user:123", () {
  print("Computing expensive operation...");
  return "User data for 123";
});

print(result.getOrElse("Not found")); // Prints computed value
```

## Integration with Effects

Option works seamlessly with Effect:

```dart
// Convert Option to Effect
final option = Option.some(42);
final effect = option.fold(
  () => Effect.fail("Value not found"),
  (value) => Effect.succeed(value),
);

// Or using a helper
Effect<A, E, R> fromOption<A, E, R>(Option<A> option, E error) {
  return option.fold(
    () => Effect.fail(error),
    (value) => Effect.succeed(value),
  );
}

// Usage
final userEffect = fromOption(
  userOption, 
  UserNotFoundError("User does not exist")
);
```

## Best Practices

### 1. Prefer Option over Nullable

```dart
// Good: Use Option for optional values
class User {
  final String name;
  final Option<String> email;
  
  User(this.name, this.email);
}

// Less ideal: Nullable types
class UserNullable {
  final String name;
  final String? email; // Can be forgotten to check
  
  UserNullable(this.name, this.email);
}
```

### 2. Use Pattern Matching

```dart
// Good: Use fold/match for handling both cases
final message = userOption.fold(
  () => "No user found",
  (user) => "Welcome, ${user.name}!",
);

// Avoid: Manual checking
if (userOption.isSome) {
  final user = userOption.getOrThrow();
  print("Welcome, ${user.name}!");
} else {
  print("No user found");
}
```

### 3. Chain Operations

```dart
// Good: Chain operations
final result = getUserById(id)
    .flatMap((user) => getProfileById(user.profileId))
    .map((profile) => profile.displayName)
    .getOrElse("Unknown");

// Less elegant: Nested checking
final user = getUserById(id);
if (user.isSome) {
  final profile = getProfileById(user.getOrThrow().profileId);
  if (profile.isSome) {
    return profile.getOrThrow().displayName;
  }
}
return "Unknown";
```

### 4. Use Appropriate Extraction Methods

```dart
// Good: Use getOrElse for defaults
final port = config.port.getOrElse(8080);

// Good: Use fold for complex logic
final status = user.fold(
  () => "Guest user",
  (u) => u.isActive ? "Active: ${u.name}" : "Inactive: ${u.name}",
);

// Avoid: getOrThrow without certainty
final value = option.getOrThrow(); // Only if you're certain it's Some
```

## API Reference

### Constructors
- `Option.some<A>(A value)` - Create Some value
- `Option.none<A>()` - Create None value
- `Option.fromNullable<A>(A? value)` - From nullable
- `Option.when<A>(bool condition, A Function() value)` - Conditional creation
- `Option.fromPredicate<A>(A value, bool Function(A) predicate)` - From predicate

### Type Guards
- `Option.isOption(dynamic value)` - Type guard
- `isSome` - Check if Some
- `isNone` - Check if None

### Value Extraction
- `getOrElse(A defaultValue)` - Get value or default
- `getOrElse(A Function() defaultValue)` - Get value or compute default
- `getOrNull()` - Get value or null
- `getOrThrow()` - Get value or throw

### Pattern Matching
- `fold<B>(B Function() onNone, B Function(A) onSome)` - Pattern match
- `match<B>({required B Function() onNone, required B Function(A) onSome})` - Named pattern match

### Transformations
- `map<B>(B Function(A) f)` - Transform value
- `flatMap<B>(Option<B> Function(A) f)` - Chain operations
- `filter(bool Function(A) predicate)` - Filter with predicate

### Combining
- `zipWith<B, C>(Option<B> other, C Function(A, B) f)` - Combine with function
- `zip<B>(Option<B> other)` - Combine into tuple
- `orElse(Option<A> Function() alternative)` - Provide alternative

### Collection Operations
- `Option.catOptions<A>(List<Option<A>> options)` - Filter Some values
- `Option.sequence<A>(List<Option<A>> options)` - Convert to Option of List