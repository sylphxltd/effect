import 'package:effect_dart/effect_dart.dart';

// Define services outside of main
abstract class Logger {
  void log(String message);
}

class ConsoleLogger implements Logger {
  @override
  void log(String message) {
    print('[LOG] $message');
  }
}

void main() async {
  print('=== Effect.dart Comprehensive Example ===');
  print('');

  // === Array Operations ===
  print('--- Array Operations ---');
  
  final numbers = [1, 2, 3, 4, 5];
  print('Original: $numbers');
  
  final doubled = Array.map(numbers, (n) => n * 2);
  print('Doubled: $doubled');
  
  final evens = Array.filter(numbers, (n) => n % 2 == 0);
  print('Evens: $evens');
  
  final firstEven = Array.find(numbers, (n) => n % 2 == 0);
  print('First even: ${firstEven.fold(() => 'none', (n) => n.toString())}');
  
  final sum = Array.foldLeft(numbers, 0, (acc, n) => acc + n);
  print('Sum: $sum');
  
  final (evenPart, oddPart) = Array.partition(numbers, (n) => n % 2 == 0);
  print('Partition - Evens: $evenPart, Odds: $oddPart');
  
  final zipped = Array.zip(numbers, ['a', 'b', 'c', 'd', 'e']);
  print('Zipped: $zipped');
  
  print('');

  // === Option Type ===
  print('--- Option Type ---');
  
  final someValue = Option.some(42);
  final noneValue = Option.none<int>();
  final nullable = Option.fromNullable(null);
  
  print('Some value: ${someValue.fold(() => 'none', (v) => 'some($v)')}');
  print('None value: ${noneValue.fold(() => 'none', (v) => 'some($v)')}');
  print('From null: ${nullable.fold(() => 'none', (v) => 'some($v)')}');
  
  final doubled2 = someValue.map((n) => n * 2);
  print('Doubled some: ${doubled2.fold(() => 'none', (v) => 'some($v)')}');
  
  final chained = someValue.flatMap((n) => 
    n > 0 ? Option.some('positive: $n') : Option.none());
  print('Chained: ${chained.fold(() => 'none', (v) => 'some($v)')}');
  
  print('');

  // === Either Type ===
  print('--- Either Type ---');
  
  final success = Either.right(42);
  final failure = Either.left('Error occurred');
  final voidResult = Either.voidValue;
  
  // Type checking
  print('Is Either: ${Either.isEither(success)}');
  print('Is Right: ${success.isRight}');
  print('Is Left: ${failure.isLeft}');
  
  // Pattern matching
  final result = success.match(
    onLeft: (error) => 'Failed: $error',
    onRight: (value) => 'Success: $value',
  );
  print('Match result: $result');
  
  // Transformations
  final doubled3 = success.map((x) => x * 2);
  final errorMapped = failure.mapLeft((e) => 'Prefix: $e');
  final bothMapped = success.mapBoth(
    onLeft: (e) => 'Error: $e',
    onRight: (v) => v * 3,
  );
  
  print('Doubled: ${doubled3.fold((l) => 'Left: $l', (r) => 'Right: $r')}');
  print('Error mapped: ${errorMapped.fold((l) => 'Left: $l', (r) => 'Right: $r')}');
  print('Both mapped: ${bothMapped.fold((l) => 'Left: $l', (r) => 'Right: $r')}');
  
  // Chaining operations
  final computed = success
      .flatMap((x) => x > 0 ? Either.right(x * 2) : Either.left('Invalid'))
      .andThen((x) => Either.right(x + 1));
  print('Computed: ${computed.fold((l) => 'Left: $l', (r) => 'Right: $r')}');
  
  // Filtering
  final filtered = success.filterOrLeft(
    (x) => x > 50,
    () => 'Value too small',
  );
  print('Filtered: ${filtered.fold((l) => 'Left: $l', (r) => 'Right: $r')}');
  
  // Exception handling
  final safe = Either.tryCall(() => int.parse('42'));
  final safeFailed = Either.tryCall(() => int.parse('abc'));
  final withCustomError = Either.tryWith(
    tryFn: () => int.parse('abc'),
    catchFn: (e) => 'Parse error: ${e.runtimeType}',
  );
  
  print('Safe parse: ${safe.fold((l) => 'Left: $l', (r) => 'Right: $r')}');
  print('Failed parse: ${safeFailed.fold((l) => 'Left: ${l.runtimeType}', (r) => 'Right: $r')}');
  print('Custom error: ${withCustomError.fold((l) => 'Left: $l', (r) => 'Right: $r')}');
  
  // Extracting values
  final value = success.getOrElse(0);
  final valueOrNull = failure.getOrNull();
  print('Get or else: $value');
  print('Get or null: $valueOrNull');
  
  // Combining multiple Eithers
  final combined = success.zipWith(Either.right(3), (a, b) => a + b);
  print('Combined: ${combined.fold((l) => 'Left: $l', (r) => 'Right: $r')}');
  
  // Collecting results
  final allResults = Either.all([
    Either.right(1),
    Either.right(2),
    Either.right(3),
  ]);
  print('All results: ${allResults.fold((l) => 'Left: $l', (r) => 'Right: $r')}');
  
  final withFailure = Either.all([
    Either.right(1),
    Either.left('error'),
    Either.right(3),
  ]);
  print('With failure: ${withFailure.fold((l) => 'Left: $l', (r) => 'Right: $r')}');
  
  // Alternative handling
  final alternative = failure.orElse(() => Either.right(42));
  print('Alternative: ${alternative.fold((l) => 'Left: $l', (r) => 'Right: $r')}');
  
  // Merging when both sides have same type
  final merged = Either.right(42).merge<int>();
  final mergedLeft = Either.left(24).merge<int>();
  print('Merged right: $merged');
  print('Merged left: $mergedLeft');
  
  // Utility operations
  final flipped = Either.flip(success);
  print('Flipped: ${flipped.fold((l) => 'Left: $l', (r) => 'Right: $r')}');
  
  print('');

  // === Effect System ===
  print('--- Effect System ---');
  
  // Simple success effect
  final successEffect = Effect.succeed(100);
  print('Success effect result: ${await successEffect.runToExit()}');
  
  // Simple failure effect
  final failEffect = Effect.fail('Something went wrong');
  print('Fail effect result: ${await failEffect.runToExit()}');
  
  // Chaining effects
  final pipeline = Effect.succeed(10)
      .map((n) => n * 2)
      .flatMap((n) => Effect.succeed(n + 5))
      .map((n) => 'Final result: $n');
  
  print('Pipeline result: ${await pipeline.runToExit()}');
  
  // Async effect
  final asyncEffect = Effect.async(() async {
    await Future.delayed(Duration(milliseconds: 100));
    return 'Async completed';
  });
  
  print('Async effect result: ${await asyncEffect.runToExit()}');
  
  // Error handling - demonstrating failure
  final failureEffect = Effect.fail('Something went wrong!');
  print('Failure effect result: ${await failureEffect.runToExit()}');
  
  print('');

  // === Service Dependencies ===
  print('--- Service Dependencies ---');
  
  // Effect that requires a service
  final logEffect = Effect.service<Logger>()
      .flatMap((logger) => Effect.sync(() {
        logger.log('Hello from Effect!');
        return 'Logged successfully';
      }));
  
  // Provide the service and run
  final context = Context.empty().add<Logger>(ConsoleLogger());
  final serviceResult = await logEffect.runToExit(context);
  print('Service effect result: $serviceResult');
  
  print('');

  // === Complex Pipeline ===
  print('--- Complex Pipeline ---');
  
  final complexPipeline = Effect.succeed(['1', '2', 'invalid', '4', '5'])
      .map((strings) => Array.map(strings, (s) => int.tryParse(s)))
      .map((maybeNumbers) => Array.filter(maybeNumbers, (n) => n != null))
      .map((numbers) => Array.map(numbers, (n) => n!))
      .map((numbers) => Array.filter(numbers, (n) => n % 2 == 0))
      .map((evens) => Array.foldLeft(evens, 0, (acc, n) => acc + n))
      .flatMap((sum) => sum > 0 
          ? Effect.succeed('Sum of even numbers: $sum')
          : Effect.fail('No even numbers found'));
  
  print('Complex pipeline result: ${await complexPipeline.runToExit()}');
  
  print('');
  print('=== Example completed! ===');
}