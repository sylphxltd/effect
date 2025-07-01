import 'package:effect_dart/effect_dart.dart';

void main() async {
  print('=== Effect.dart Basic Examples ===\n');

  // Example 1: Basic success and failure
  await basicSuccessFailureExample();

  // Example 2: Mapping and chaining effects
  await mappingAndChainingExample();

  // Example 3: Error handling
  await errorHandlingExample();

  // Example 4: Using context/dependency injection
  await contextExample();

  // Example 5: Concurrent execution
  await concurrentExample();
}

Future<void> basicSuccessFailureExample() async {
  print('1. Basic Success and Failure:');

  // Create a successful effect
  final successEffect = Effect.succeed(42);
  final result1 = await successEffect.runToExit();
  print('Success result: $result1');

  // Create a failed effect
  final failureEffect = Effect.fail('Something went wrong');
  final result2 = await failureEffect.runToExit();
  print('Failure result: $result2');

  // Create an effect that might throw
  final riskyEffect = Effect.sync(() {
    if (DateTime.now().millisecondsSinceEpoch % 2 == 0) {
      return 'Lucky!';
    } else {
      throw Exception('Unlucky!');
    }
  });
  final result3 = await riskyEffect.runToExit();
  print('Risky result: $result3\n');
}

Future<void> mappingAndChainingExample() async {
  print('2. Mapping and Chaining:');

  // Map over success values
  final mappedEffect = Effect.succeed(21)
      .map((x) => x * 2)
      .map((x) => 'The answer is $x');

  final result = await mappedEffect.runToExit();
  print('Mapped result: $result');

  // Chain effects with flatMap
  final chainedEffect = Effect.succeed(10)
      .flatMap((x) => Effect.succeed(x + 5))
      .flatMap((x) => Effect.succeed(x * 2));

  final result2 = await chainedEffect.runToExit();
  print('Chained result: $result2\n');
}

Future<void> errorHandlingExample() async {
  print('3. Error Handling:');

  // Create an effect that can succeed or fail
  final riskyEffect = Effect.sync<String>(() {
    if (DateTime.now().millisecondsSinceEpoch % 2 == 0) {
      return 'Success!';
    } else {
      throw 'Network error';
    }
  });

  // Recover from errors using catchAll
  final recoveredEffect = riskyEffect
      .catchAll((error) => Effect.succeed('Fallback: $error'));

  final result = await recoveredEffect.runToExit();
  print('Recovered result: $result');

  // Map errors
  final mappedErrorEffect = Effect.fail(404)
      .mapError((code) => 'HTTP Error: $code');

  final result2 = await mappedErrorEffect.runToExit();
  print('Mapped error result: $result2\n');
}

// Define some services for dependency injection
class DatabaseService {
  Future<String> getData(String id) async {
    await Future.delayed(Duration(milliseconds: 100));
    return 'Data for $id';
  }
}

class LoggerService {
  void log(String message) {
    print('[LOG] $message');
  }
}

Future<void> contextExample() async {
  print('4. Context/Dependency Injection:');

  // Create an effect that requires services
  final dbEffect = Effect.service<DatabaseService>()
      .flatMap((db) => Effect.async(() => db.getData('user123')));

  final logEffect = Effect.service<LoggerService>()
      .flatMap((logger) => Effect.sync(() => logger.log('Operation completed')));

  // Combine effects
  final combinedEffect = dbEffect
      .flatMap((data) => logEffect.map((_) => data));

  // Provide the services
  final context = Context.empty()
      .add(DatabaseService())
      .add(LoggerService());

  final result = await combinedEffect.runToExit(context);
  print('Context result: $result\n');
}

Future<void> concurrentExample() async {
  print('5. Concurrent Execution:');

  // Create multiple async effects
  final effect1 = Effect.async(() async {
    await Future.delayed(Duration(milliseconds: 100));
    return 'Task 1 completed';
  });

  final effect2 = Effect.async(() async {
    await Future.delayed(Duration(milliseconds: 200));
    return 'Task 2 completed';
  });

  final effect3 = Effect.async(() async {
    await Future.delayed(Duration(milliseconds: 150));
    return 'Task 3 completed';
  });

  // Run them concurrently
  final results = await Runtime.defaultRuntime
      .runConcurrently([effect1, effect2, effect3]);

  print('Concurrent results:');
  for (int i = 0; i < results.length; i++) {
    print('  Task ${i + 1}: ${results[i]}');
  }

  // Race them (first one to complete wins)
  final raceResult = await Runtime.defaultRuntime
      .runRace([effect1, effect2, effect3]);
  
  print('Race winner: $raceResult\n');
}