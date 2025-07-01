import 'package:test/test.dart';
import 'package:effect_dart/effect_dart.dart';

void main() {
  group('Effect Tests', () {
    test('succeed creates successful effect', () async {
      final effect = Effect.succeed(42);
      final exit = await effect.runToExit();

      expect(exit, isA<Success<int, Never>>());
      expect((exit as Success).value, equals(42));
    });

    test('fail creates failed effect', () async {
      final effect = Effect.fail('error');
      final exit = await effect.runToExit();

      expect(exit, isA<Failure<Never, String>>());
      expect((exit as Failure).cause, isA<Fail<String>>());
      expect(((exit as Failure).cause as Fail).error, equals('error'));
    });

    test('map transforms success value', () async {
      final effect = Effect.succeed(21).map((x) => x * 2);
      final exit = await effect.runToExit();

      expect(exit, isA<Success<int, Never>>());
      expect((exit as Success).value, equals(42));
    });

    test('map does not affect failed effect', () async {
      final effect = Effect.fail<String>('error').map<int>((x) => 999); // Use constant instead of multiplication
      final exit = await effect.runToExit();

      expect(exit, isA<Failure>());
    });

    test('flatMap chains effects', () async {
      final effect = Effect.succeed(10)
          .flatMap((x) => Effect.succeed(x + 5))
          .flatMap((x) => Effect.succeed(x * 2));
      
      final exit = await effect.runToExit();

      expect(exit, isA<Success<int, Never>>());
      expect((exit as Success).value, equals(30));
    });

    test('flatMap propagates failure', () async {
      final effect = Effect.succeed(10)
          .flatMap<String, String, Never>((x) => Effect.fail('error'))
          .flatMap((x) => Effect.succeed('transformed'));
      
      final exit = await effect.runToExit();

      expect(exit, isA<Failure>());
    });

    test('sync effect captures exceptions', () async {
      final effect = Effect.sync<int>(() => throw 'error');
      final exit = await effect.runToExit();

      expect(exit, isA<Failure>());
      expect((exit as Failure).cause, isA<Die>());
    });

    test('async effect works', () async {
      final effect = Effect.async(() async {
        await Future.delayed(Duration(milliseconds: 10));
        return 'done';
      });
      
      final exit = await effect.runToExit();

      expect(exit, isA<Success<String, Object>>());
      expect((exit as Success).value, equals('done'));
    });

    test('runUnsafe throws on failure', () async {
      final effect = Effect.fail('error');
      
      expect(() => effect.runUnsafe(), throwsA(isA<Exception>()));
    });

    test('runUnsafe returns value on success', () async {
      final effect = Effect.succeed(42);
      final result = await effect.runUnsafe();
      
      expect(result, equals(42));
    });
  });

  group('Context Tests', () {
    test('empty context has no services', () {
      final context = Context.empty();
      
      expect(context.isEmpty, isTrue);
      expect(context.size, equals(0));
    });

    test('can add and retrieve services', () {
      final context = Context.empty()
          .add('hello')
          .add(42);
      
      expect(context.size, equals(2));
      expect(context.get<String>(), equals('hello'));
      expect(context.get<int>(), equals(42));
    });

    test('service effect requires context', () async {
      final effect = Effect.service<String>();
      
      expect(() => effect.runToExit(), throwsA(isA<StateError>()));
    });

    test('service effect works with context', () async {
      final effect = Effect.service<String>();
      final context = Context.of('hello world');
      final exit = await effect.runToExit(context);
      
      expect(exit, isA<Success<String, Never>>());
      expect((exit as Success).value, equals('hello world'));
    });

    test('provideService works', () async {
      final effect = Effect.service<String>()
          .provideService('provided');
      
      final exit = await effect.runToExit();
      
      expect(exit, isA<Success<String, Never>>());
      expect((exit as Success).value, equals('provided'));
    });
  });

  group('Either Tests', () {
    test('left creates left value', () {
      final either = Either.left<String, int>('error');
      
      expect(either.isLeft, isTrue);
      expect(either.isRight, isFalse);
      expect((either as Left).value, equals('error'));
    });

    test('right creates right value', () {
      final either = Either.right<String, int>(42);
      
      expect(either.isLeft, isFalse);
      expect(either.isRight, isTrue);
      expect((either as Right).value, equals(42));
    });

    test('map transforms right value', () {
      final either = Either.right<String, int>(21)
          .map((x) => x * 2);
      
      expect(either.isRight, isTrue);
      expect((either as Right).value, equals(42));
    });

    test('map does not affect left value', () {
      final either = Either.left<String, int>('error')
          .map((x) => x * 2);
      
      expect(either.isLeft, isTrue);
      expect((either as Left).value, equals('error'));
    });

    test('fold works correctly', () {
      final leftResult = Either.left<String, int>('error')
          .fold((l) => 'Left: $l', (r) => 'Right: $r');
      
      final rightResult = Either.right<String, int>(42)
          .fold((l) => 'Left: $l', (r) => 'Right: $r');
      
      expect(leftResult, equals('Left: error'));
      expect(rightResult, equals('Right: 42'));
    });
  });

  group('Exit Tests', () {
    test('succeed creates success exit', () {
      final exit = Exit.succeed(42);
      
      expect(exit.isSuccess, isTrue);
      expect(exit.isFailure, isFalse);
      expect((exit as Success).value, equals(42));
    });

    test('fail creates failure exit', () {
      final exit = Exit.fail('error');
      
      expect(exit.isSuccess, isFalse);
      expect(exit.isFailure, isTrue);
      expect((exit as Failure).cause, isA<Fail<String>>());
    });

    test('map transforms success value', () {
      final exit = Exit.succeed(21).map((x) => x * 2);
      
      expect(exit.isSuccess, isTrue);
      expect((exit as Success).value, equals(42));
    });

    test('fold works correctly', () {
      final successResult = Exit.succeed(42)
          .fold((cause) => 'Failed: $cause', (value) => 'Success: $value');
      
      final failureResult = Exit.fail('error')
          .fold((cause) => 'Failed: $cause', (value) => 'Success: $value');
      
      expect(successResult, equals('Success: 42'));
      expect(failureResult, startsWith('Failed:'));
    });
  });

  group('Cause Tests', () {
    test('fail creates fail cause', () {
      final cause = Cause.fail('error');
      
      expect(cause, isA<Fail<String>>());
      expect((cause as Fail).error, equals('error'));
    });

    test('die creates die cause', () {
      final cause = Cause.die('throwable');
      
      expect(cause, isA<Die>());
      expect((cause as Die).throwable, equals('throwable'));
    });

    test('toException converts cause to exception', () {
      final failCause = Cause.fail('error');
      final dieCause = Cause.die('throwable');
      
      expect(failCause.toException(), isA<Exception>());
      expect(dieCause.toException(), isA<Exception>());
    });
  });
}