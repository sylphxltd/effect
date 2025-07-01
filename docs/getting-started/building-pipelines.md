# Building Pipelines

Effect pipelines are the heart of functional programming with Effect Dart. They allow you to compose complex workflows from simple, reusable effects while maintaining type safety and error handling.

## What is a Pipeline?

A pipeline is a sequence of effects chained together using operators like `flatMap`, `map`, and `catchAll`. Each step in the pipeline can transform data, handle errors, or perform side effects.

```dart
// Simple pipeline
final pipeline = Effect.succeed("hello")
    .map((s) => s.toUpperCase())           // Transform: "HELLO"
    .flatMap((s) => Effect.succeed("$s!")) // Chain: "HELLO!"
    .map((s) => s.length);                 // Transform: 6

final result = await pipeline.runUnsafe(); // 6
```

## Basic Pipeline Operations

### map - Transform Success Values

Use `map` to transform the success value of an effect:

```dart
final numberEffect = Effect.succeed(42);

final pipeline = numberEffect
    .map((n) => n * 2)           // 84
    .map((n) => n.toString())    // "84"
    .map((s) => "Result: $s");   // "Result: 84"

final result = await pipeline.runUnsafe(); // "Result: 84"
```

### flatMap - Chain Effects

Use `flatMap` to chain effects together:

```dart
Effect<String, String, void> validateEmail(String email) {
  return email.contains('@')
      ? Effect.succeed(email)
      : Effect.fail('Invalid email');
}

Effect<User, String, DatabaseService> createUser(String email) {
  return Effect.service<DatabaseService>()
      .flatMap((db) => Effect.async(() => db.createUser(email)));
}

// Pipeline with chaining
final pipeline = Effect.succeed("user@example.com")
    .flatMap(validateEmail)           // Validate email
    .flatMap(createUser)              // Create user if valid
    .map((user) => "Created: ${user.name}");

final result = await pipeline.runToExit();
```

### mapError - Transform Errors

Use `mapError` to transform error values:

```dart
final riskyEffect = Effect.fail(404);

final pipeline = riskyEffect
    .mapError((code) => "HTTP Error: $code")
    .catchAll((error) => Effect.succeed("Fallback: $error"));

final result = await pipeline.runUnsafe(); // "Fallback: HTTP Error: 404"
```

## Real-World Pipeline Examples

### Data Processing Pipeline

```dart
// Data processing pipeline
Effect<ProcessedData, ProcessingError, FileService & ValidationService & DatabaseService>
processDataFile(String filePath) {
  return readFile(filePath)
      .flatMap(parseData)
      .flatMap(validateData)
      .flatMap(enrichData)
      .flatMap(saveToDatabase)
      .map((id) => ProcessedData(id, DateTime.now()));
}

Effect<String, FileError, FileService> readFile(String path) {
  return Effect.service<FileService>()
      .flatMap((fs) => Effect.async(() => fs.readAsString(path)));
}

Effect<RawData, ParseError, void> parseData(String content) {
  return Effect.sync(() {
    try {
      return RawData.fromJson(jsonDecode(content));
    } catch (e) {
      throw ParseError('Invalid JSON: $e');
    }
  });
}

Effect<ValidData, ValidationError, ValidationService> validateData(RawData data) {
  return Effect.service<ValidationService>()
      .flatMap((validator) => Effect.async(() => validator.validate(data)));
}

Effect<EnrichedData, EnrichmentError, void> enrichData(ValidData data) {
  return Effect.async(() async {
    // Enrich data with external sources
    final enriched = await enrichWithExternalData(data);
    return enriched;
  });
}

Effect<String, DatabaseError, DatabaseService> saveToDatabase(EnrichedData data) {
  return Effect.service<DatabaseService>()
      .flatMap((db) => Effect.async(() => db.save(data)));
}
```

### User Registration Pipeline

```dart
// User registration pipeline
Effect<RegistrationResult, RegistrationError, UserService & EmailService & LoggerService>
registerUser(RegistrationRequest request) {
  return validateRegistrationRequest(request)
      .flatMap(checkUserExists)
      .flatMap(createUserAccount)
      .flatMap(sendWelcomeEmail)
      .flatMap(logRegistration)
      .map((user) => RegistrationResult.success(user));
}

Effect<ValidatedRequest, ValidationError, void> validateRegistrationRequest(RegistrationRequest request) {
  return Effect.sync(() {
    final errors = <String>[];
    
    if (request.email.isEmpty || !request.email.contains('@')) {
      errors.add('Invalid email');
    }
    
    if (request.password.length < 8) {
      errors.add('Password too short');
    }
    
    if (request.name.isEmpty) {
      errors.add('Name required');
    }
    
    if (errors.isNotEmpty) {
      throw ValidationError(errors);
    }
    
    return ValidatedRequest(request.email, request.password, request.name);
  });
}

Effect<ValidatedRequest, UserExistsError, UserService> checkUserExists(ValidatedRequest request) {
  return Effect.service<UserService>()
      .flatMap((service) => Effect.async(() => service.findByEmail(request.email)))
      .flatMap((existingUser) => existingUser != null
          ? Effect.fail(UserExistsError(request.email))
          : Effect.succeed(request));
}

Effect<User, UserCreationError, UserService> createUserAccount(ValidatedRequest request) {
  return Effect.service<UserService>()
      .flatMap((service) => Effect.async(() => service.create(
          request.name, 
          request.email, 
          request.password
      )));
}

Effect<User, EmailError, EmailService> sendWelcomeEmail(User user) {
  return Effect.service<EmailService>()
      .flatMap((service) => Effect.async(() => service.sendWelcomeEmail(user)))
      .map((_) => user); // Return user for next step
}

Effect<User, LogError, LoggerService> logRegistration(User user) {
  return Effect.service<LoggerService>()
      .flatMap((logger) => Effect.sync(() {
        logger.log('User registered: ${user.email}');
        return user;
      }));
}
```

### HTTP API Pipeline

```dart
// HTTP API request pipeline
Effect<ApiResponse<T>, ApiError, HttpService & AuthService & LoggerService>
apiRequest<T>(String endpoint, {Map<String, dynamic>? body}) {
  return getAuthToken()
      .flatMap((token) => buildRequest(endpoint, token, body))
      .flatMap(executeRequest)
      .flatMap(parseResponse<T>)
      .flatMap(logRequest);
}

Effect<String, AuthError, AuthService> getAuthToken() {
  return Effect.service<AuthService>()
      .flatMap((auth) => Effect.async(() => auth.getValidToken()));
}

Effect<HttpRequest, RequestError, void> buildRequest(
    String endpoint, 
    String token, 
    Map<String, dynamic>? body
) {
  return Effect.sync(() {
    return HttpRequest(
      url: 'https://api.example.com$endpoint',
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body != null ? jsonEncode(body) : null,
    );
  });
}

Effect<HttpResponse, NetworkError, HttpService> executeRequest(HttpRequest request) {
  return Effect.service<HttpService>()
      .flatMap((http) => Effect.async(() => http.execute(request)));
}

Effect<ApiResponse<T>, ParseError, void> parseResponse<T>(HttpResponse response) {
  return Effect.sync(() {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final data = jsonDecode(response.body);
        return ApiResponse<T>.success(data);
      } catch (e) {
        throw ParseError('Failed to parse response: $e');
      }
    } else {
      throw ApiError('HTTP ${response.statusCode}: ${response.body}');
    }
  });
}

Effect<ApiResponse<T>, LogError, LoggerService> logRequest<T>(ApiResponse<T> response) {
  return Effect.service<LoggerService>()
      .flatMap((logger) => Effect.sync(() {
        logger.log('API request completed: ${response.status}');
        return response;
      }));
}
```

## Error Handling in Pipelines

### catchAll - Handle All Errors

```dart
final pipeline = riskyOperation()
    .flatMap(processResult)
    .catchAll((error) => switch (error) {
      NetworkError() => Effect.succeed(cachedResult),
      ValidationError() => Effect.fail(UserInputError()),
      _ => Effect.fail(UnknownError()),
    });
```

### orElse - Provide Alternatives

```dart
final pipeline = primaryDataSource()
    .orElse(() => secondaryDataSource())
    .orElse(() => fallbackDataSource())
    .orElse(() => Effect.succeed(defaultData));
```

### retry - Retry on Failure

```dart
final pipeline = unstableNetworkCall()
    .retry(Schedule.exponential(Duration(seconds: 1)).take(3))
    .catchAll((error) => Effect.succeed(fallbackData));
```

## Conditional Pipelines

### when - Conditional Execution

```dart
Effect<String, Never, void> conditionalPipeline(bool shouldProcess) {
  return Effect.succeed("data")
      .flatMap((data) => shouldProcess
          ? processData(data)
          : Effect.succeed(data))
      .map((result) => "Result: $result");
}
```

### ifThenElse - Branching Logic

```dart
Effect<String, ProcessingError, DatabaseService> smartProcessing(Data data) {
  return Effect.succeed(data)
      .flatMap((d) => d.size > 1000
          ? largeBatchProcessing(d)
          : smallBatchProcessing(d))
      .flatMap(saveResults);
}
```

## Parallel Pipelines

### zip - Combine Results

```dart
final pipeline = Effect.succeed("user123")
    .flatMap((userId) => {
      final userEffect = fetchUser(userId);
      final profileEffect = fetchProfile(userId);
      final settingsEffect = fetchSettings(userId);
      
      return userEffect.zip(profileEffect).zip(settingsEffect)
          .map(((userProfile, settings)) => UserData(
              userProfile.$1,  // user
              userProfile.$2,  // profile
              settings
          ));
    });
```

### forEach - Process Collections

```dart
Effect<List<ProcessedItem>, ProcessingError, ProcessingService> 
processItems(List<Item> items) {
  return Effect.forEach(items, (item) => 
      validateItem(item)
          .flatMap(enrichItem)
          .flatMap(transformItem)
  );
}
```

## Pipeline Composition Patterns

### Builder Pattern

```dart
class PipelineBuilder<A, E, R> {
  final Effect<A, E, R> _effect;
  
  PipelineBuilder(this._effect);
  
  PipelineBuilder<B, E, R> transform<B>(B Function(A) f) {
    return PipelineBuilder(_effect.map(f));
  }
  
  PipelineBuilder<B, E2, R2> chain<B, E2, R2>(Effect<B, E2, R2> Function(A) f) {
    return PipelineBuilder(_effect.flatMap(f));
  }
  
  PipelineBuilder<A, E2, R> handleError<E2>(Effect<A, E2, R> Function(E) f) {
    return PipelineBuilder(_effect.catchAll(f));
  }
  
  Effect<A, E, R> build() => _effect;
}

// Usage
final pipeline = PipelineBuilder(Effect.succeed("input"))
    .transform((s) => s.toUpperCase())
    .chain((s) => validateString(s))
    .transform((s) => s.trim())
    .handleError((e) => Effect.succeed("default"))
    .build();
```

### Middleware Pattern

```dart
typedef Middleware<A, E, R> = Effect<A, E, R> Function(Effect<A, E, R>);

Middleware<A, E, R> loggingMiddleware<A, E, R>(String name) {
  return (effect) => Effect.service<LoggerService>()
      .flatMap((logger) => Effect.sync(() => logger.log('Starting $name')))
      .flatMap((_) => effect)
      .flatMap((result) => Effect.service<LoggerService>()
          .flatMap((logger) => Effect.sync(() {
            logger.log('Completed $name');
            return result;
          })));
}

Middleware<A, E, R> timingMiddleware<A, E, R>(String name) {
  return (effect) => Effect.sync(() => DateTime.now())
      .flatMap((start) => effect
          .flatMap((result) => Effect.sync(() {
            final duration = DateTime.now().difference(start);
            print('$name took ${duration.inMilliseconds}ms');
            return result;
          })));
}

// Apply middleware
final pipeline = Effect.succeed("data")
    .pipe(loggingMiddleware("data-processing"))
    .pipe(timingMiddleware("data-processing"))
    .flatMap(processData);
```

## Testing Pipelines

```dart
import 'package:test/test.dart';
import 'package:effect_dart/effect_dart.dart';

void main() {
  group('Pipeline Tests', () {
    test('should process data successfully', () async {
      // Arrange
      final mockContext = Context.empty()
          .add<FileService>(MockFileService())
          .add<ValidationService>(MockValidationService())
          .add<DatabaseService>(MockDatabaseService());
      
      // Act
      final pipeline = processDataFile('test.json');
      final exit = await pipeline.runToExit(mockContext);
      
      // Assert
      expect(exit.isSuccess, true);
      final result = exit.getOrNull();
      expect(result?.id, isNotNull);
    });
    
    test('should handle validation errors', () async {
      // Arrange
      final mockContext = Context.empty()
          .add<FileService>(MockFileService())
          .add<ValidationService>(FailingValidationService())
          .add<DatabaseService>(MockDatabaseService());
      
      // Act
      final pipeline = processDataFile('invalid.json');
      final exit = await pipeline.runToExit(mockContext);
      
      // Assert
      expect(exit.isFailure, true);
      expect(exit.cause, isA<ValidationError>());
    });
  });
}
```

## Best Practices

### 1. Keep Steps Small and Focused

```dart
// Good: Small, focused steps
final pipeline = Effect.succeed(input)
    .flatMap(validateInput)
    .flatMap(enrichData)
    .flatMap(processData)
    .flatMap(saveResult);

// Avoid: Large, monolithic steps
final pipeline = Effect.succeed(input)
    .flatMap(doEverything); // Too much in one step
```

### 2. Use Descriptive Names

```dart
// Good: Clear, descriptive names
final userRegistrationPipeline = validateUserInput(request)
    .flatMap(checkEmailAvailability)
    .flatMap(createUserAccount)
    .flatMap(sendWelcomeEmail);

// Avoid: Generic names
final pipeline = step1(request)
    .flatMap(step2)
    .flatMap(step3);
```

### 3. Handle Errors Appropriately

```dart
// Good: Specific error handling
final pipeline = fetchUserData(id)
    .catchAll((error) => switch (error) {
      UserNotFound() => Effect.succeed(defaultUser),
      NetworkError() => retryWithBackoff(fetchUserData(id)),
      _ => Effect.fail(UnexpectedError(error)),
    });
```

### 4. Use Type-Safe Error Handling

```dart
// Good: Typed errors
sealed class ProcessingError {}
class ValidationError extends ProcessingError {}
class NetworkError extends ProcessingError {}
class DatabaseError extends ProcessingError {}

Effect<Result, ProcessingError, Services> pipeline = ...;
```

## Next Steps

- [Control Flow Operators](./control-flow-operators) - Advanced flow control
- [Using Generators](./using-generators) - Generator-based effects
- [Error Handling](/error-handling/) - Comprehensive error management
- [Concurrency](/concurrency/) - Parallel and concurrent pipelines