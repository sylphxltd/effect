# Create Effect App

This guide shows you how to create a new Dart application using Effect Dart from scratch, setting up the project structure and basic configuration.

## Prerequisites

- Dart SDK 3.0.0 or higher
- Your favorite IDE (VS Code, IntelliJ IDEA, etc.)

## Creating a New Project

### 1. Create Dart Project

```bash
# Create a new Dart project
dart create my_effect_app
cd my_effect_app
```

### 2. Add Effect Dart Dependency

Edit your `pubspec.yaml` file:

```yaml
name: my_effect_app
description: A sample Effect Dart application
version: 1.0.0

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  effect_dart: ^0.1.0

dev_dependencies:
  test: ^1.24.0
  lints: ^3.0.0
```

### 3. Install Dependencies

```bash
dart pub get
```

## Project Structure

Organize your Effect Dart application with a clear structure:

```
my_effect_app/
├── lib/
│   ├── main.dart              # Application entry point
│   ├── src/
│   │   ├── effects/           # Effect definitions
│   │   ├── services/          # Service interfaces and implementations
│   │   ├── models/            # Data models
│   │   └── config/            # Configuration
│   └── my_effect_app.dart     # Main library export
├── test/                      # Tests
├── example/                   # Example usage
└── pubspec.yaml
```

## Basic Application Setup

### 1. Main Entry Point

Create `lib/main.dart`:

```dart
import 'package:effect_dart/effect_dart.dart';
import 'src/app.dart';

void main() async {
  // Create application context with services
  final context = createAppContext();
  
  // Create and run the main application effect
  final app = createApp();
  
  // Run the application
  final exit = await app.runToExit(context);
  
  exit.fold(
    (cause) {
      print('Application failed: $cause');
      exit(1);
    },
    (result) {
      print('Application completed successfully: $result');
      exit(0);
    },
  );
}
```

### 2. Application Effect

Create `lib/src/app.dart`:

```dart
import 'package:effect_dart/effect_dart.dart';
import 'services/logger_service.dart';
import 'services/config_service.dart';
import 'services/database_service.dart';

// Main application effect
Effect<String, AppError, LoggerService & ConfigService & DatabaseService> createApp() {
  return Effect.service<LoggerService>()
      .flatMap((logger) => Effect.sync(() => logger.log('Starting application...')))
      .flatMap((_) => initializeServices())
      .flatMap((_) => runMainLogic())
      .flatMap((result) => Effect.service<LoggerService>()
          .flatMap((logger) => Effect.sync(() {
            logger.log('Application completed');
            return result;
          })));
}

// Initialize all services
Effect<void, AppError, ConfigService & DatabaseService & LoggerService> initializeServices() {
  return Effect.service<ConfigService>()
      .flatMap((config) => Effect.service<DatabaseService>()
          .flatMap((db) => Effect.service<LoggerService>()
              .flatMap((logger) => Effect.async(() async {
                logger.log('Initializing services...');
                await config.load();
                await db.connect();
                logger.log('Services initialized');
              }))));
}

// Main application logic
Effect<String, AppError, LoggerService & DatabaseService> runMainLogic() {
  return Effect.service<LoggerService>()
      .flatMap((logger) => Effect.sync(() => logger.log('Running main logic...')))
      .flatMap((_) => Effect.service<DatabaseService>()
          .flatMap((db) => Effect.async(() async {
            // Your main application logic here
            final data = await db.fetchData();
            return 'Processed ${data.length} items';
          })));
}

// Application context with all services
Context<LoggerService & ConfigService & DatabaseService> createAppContext() {
  return Context.empty()
      .add<LoggerService>(ConsoleLoggerService())
      .add<ConfigService>(FileConfigService())
      .add<DatabaseService>(SqliteDatabaseService());
}

// Application errors
sealed class AppError {
  const AppError();
}

class ConfigurationError extends AppError {
  final String message;
  const ConfigurationError(this.message);
  
  @override
  String toString() => 'Configuration Error: $message';
}

class DatabaseError extends AppError {
  final String message;
  const DatabaseError(this.message);
  
  @override
  String toString() => 'Database Error: $message';
}

class ServiceError extends AppError {
  final String service;
  final String message;
  const ServiceError(this.service, this.message);
  
  @override
  String toString() => 'Service Error [$service]: $message';
}
```

### 3. Service Definitions

Create `lib/src/services/logger_service.dart`:

```dart
// Logger service interface
abstract class LoggerService {
  void log(String message);
  void error(String message);
  void warn(String message);
  void debug(String message);
}

// Console implementation
class ConsoleLoggerService implements LoggerService {
  @override
  void log(String message) {
    print('[INFO] ${DateTime.now()}: $message');
  }
  
  @override
  void error(String message) {
    print('[ERROR] ${DateTime.now()}: $message');
  }
  
  @override
  void warn(String message) {
    print('[WARN] ${DateTime.now()}: $message');
  }
  
  @override
  void debug(String message) {
    print('[DEBUG] ${DateTime.now()}: $message');
  }
}
```

Create `lib/src/services/config_service.dart`:

```dart
// Configuration service interface
abstract class ConfigService {
  Future<void> load();
  String get(String key);
  T getValue<T>(String key, T defaultValue);
}

// File-based implementation
class FileConfigService implements ConfigService {
  final Map<String, dynamic> _config = {};
  
  @override
  Future<void> load() async {
    // Load configuration from file or environment
    _config['database_url'] = 'sqlite:///app.db';
    _config['log_level'] = 'info';
    _config['port'] = 8080;
  }
  
  @override
  String get(String key) {
    return _config[key]?.toString() ?? '';
  }
  
  @override
  T getValue<T>(String key, T defaultValue) {
    final value = _config[key];
    if (value is T) {
      return value;
    }
    return defaultValue;
  }
}
```

Create `lib/src/services/database_service.dart`:

```dart
// Database service interface
abstract class DatabaseService {
  Future<void> connect();
  Future<void> disconnect();
  Future<List<Map<String, dynamic>>> fetchData();
  Future<void> saveData(Map<String, dynamic> data);
}

// SQLite implementation
class SqliteDatabaseService implements DatabaseService {
  bool _connected = false;
  
  @override
  Future<void> connect() async {
    // Simulate database connection
    await Future.delayed(Duration(milliseconds: 100));
    _connected = true;
  }
  
  @override
  Future<void> disconnect() async {
    _connected = false;
  }
  
  @override
  Future<List<Map<String, dynamic>>> fetchData() async {
    if (!_connected) {
      throw Exception('Database not connected');
    }
    
    // Simulate data fetching
    await Future.delayed(Duration(milliseconds: 50));
    return [
      {'id': 1, 'name': 'Item 1'},
      {'id': 2, 'name': 'Item 2'},
      {'id': 3, 'name': 'Item 3'},
    ];
  }
  
  @override
  Future<void> saveData(Map<String, dynamic> data) async {
    if (!_connected) {
      throw Exception('Database not connected');
    }
    
    // Simulate data saving
    await Future.delayed(Duration(milliseconds: 30));
  }
}
```

## Testing Your Application

Create `test/app_test.dart`:

```dart
import 'package:test/test.dart';
import 'package:effect_dart/effect_dart.dart';
import '../lib/src/app.dart';
import '../lib/src/services/logger_service.dart';
import '../lib/src/services/config_service.dart';
import '../lib/src/services/database_service.dart';

// Mock services for testing
class MockLoggerService implements LoggerService {
  final List<String> logs = [];
  
  @override
  void log(String message) => logs.add('INFO: $message');
  
  @override
  void error(String message) => logs.add('ERROR: $message');
  
  @override
  void warn(String message) => logs.add('WARN: $message');
  
  @override
  void debug(String message) => logs.add('DEBUG: $message');
}

class MockConfigService implements ConfigService {
  final Map<String, dynamic> _config = {
    'database_url': 'test://memory',
    'log_level': 'debug',
  };
  
  @override
  Future<void> load() async {}
  
  @override
  String get(String key) => _config[key]?.toString() ?? '';
  
  @override
  T getValue<T>(String key, T defaultValue) {
    final value = _config[key];
    return value is T ? value : defaultValue;
  }
}

class MockDatabaseService implements DatabaseService {
  bool _connected = false;
  
  @override
  Future<void> connect() async {
    _connected = true;
  }
  
  @override
  Future<void> disconnect() async {
    _connected = false;
  }
  
  @override
  Future<List<Map<String, dynamic>>> fetchData() async {
    if (!_connected) throw Exception('Not connected');
    return [{'id': 1, 'name': 'Test Item'}];
  }
  
  @override
  Future<void> saveData(Map<String, dynamic> data) async {
    if (!_connected) throw Exception('Not connected');
  }
}

void main() {
  group('Effect App Tests', () {
    test('should run application successfully', () async {
      // Arrange
      final context = Context.empty()
          .add<LoggerService>(MockLoggerService())
          .add<ConfigService>(MockConfigService())
          .add<DatabaseService>(MockDatabaseService());
      
      // Act
      final app = createApp();
      final exit = await app.runToExit(context);
      
      // Assert
      expect(exit.isSuccess, true);
      final result = exit.getOrNull();
      expect(result, contains('Processed 1 items'));
    });
    
    test('should handle service initialization errors', () async {
      // Arrange - Use a database service that fails to connect
      final failingDb = FailingDatabaseService();
      final context = Context.empty()
          .add<LoggerService>(MockLoggerService())
          .add<ConfigService>(MockConfigService())
          .add<DatabaseService>(failingDb);
      
      // Act
      final app = createApp();
      final exit = await app.runToExit(context);
      
      // Assert
      expect(exit.isFailure, true);
    });
  });
}

class FailingDatabaseService implements DatabaseService {
  @override
  Future<void> connect() async {
    throw Exception('Connection failed');
  }
  
  @override
  Future<void> disconnect() async {}
  
  @override
  Future<List<Map<String, dynamic>>> fetchData() async {
    throw Exception('Not implemented');
  }
  
  @override
  Future<void> saveData(Map<String, dynamic> data) async {
    throw Exception('Not implemented');
  }
}
```

## Running Your Application

```bash
# Run the application
dart run

# Run tests
dart test

# Run with specific configuration
dart run --define=LOG_LEVEL=debug
```

## Best Practices

### 1. Service Organization

- Keep service interfaces separate from implementations
- Use dependency injection through Effect's context system
- Create mock implementations for testing

### 2. Error Handling

- Define specific error types for different failure modes
- Use typed errors in Effect signatures
- Handle errors at appropriate levels

### 3. Configuration

- Load configuration early in the application lifecycle
- Use environment variables for deployment-specific settings
- Validate configuration on startup

### 4. Testing

- Create mock services for unit testing
- Test error scenarios as well as success paths
- Use Effect's testing utilities for complex scenarios

## Next Steps

- [Importing Effect](./importing-effect) - Learn about imports and exports
- [Building Pipelines](./building-pipelines) - Create complex effect pipelines
- [Error Handling](/error-handling/) - Advanced error handling patterns
- [Dependency Management](/dependency-management/) - Service management patterns

## Example Projects

Check out these example projects for inspiration:

- **CLI Tool**: Command-line application with file processing
- **Web Server**: HTTP server with database integration
- **Data Pipeline**: ETL pipeline with error recovery
- **Microservice**: Service with external API integration