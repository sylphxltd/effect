import 'dart:async';
import 'package:test/test.dart';
import '../../lib/src/effect.dart';
import '../../lib/src/exit.dart';
import '../../lib/src/cause.dart';
import '../test_utils.dart';

void main() {
  group('Effect Async Tests', () {
    It.effect('simple async must return', () =>
      Effect.asyncCallback<int>((cb) {
        cb(Effect.succeed(42));
      }).flatMap((result) =>
        Effect.sync(() {
          expect(result, equals(42));
        })
      )
    );

    It.effect('async with callback must return', () =>
      Effect.asyncCallback<int>((cb) {
        // Simulate async operation
        Future.delayed(Duration(milliseconds: 10), () {
          cb(Effect.succeed(42));
        });
      }).flatMap((result) =>
        Effect.sync(() {
          expect(result, equals(42));
        })
      )
    );

    It.effect('async with failure', () =>
      Effect.asyncCallback<int>((cb) {
        cb(Effect.fail('async error'));
      }).catchAll((error) =>
        Effect.sync(() {
          expect(error, equals('async error'));
          return 0; // Return a dummy value since this is just a test
        })
      )
    );

    It.effect('async with exception', () =>
      Effect.asyncCallback<int>((cb) {
        cb(Effect.sync(() => throw Exception('async exception')));
      }).sandbox().either().flatMap((result) =>
        Effect.sync(() {
          expect(result.isLeft, isTrue);
          final cause = result.fold((l) => l, (r) => null) as Cause;
          expect(cause.toString(), contains('async exception'));
          return null;
        })
      )
    );

    test('sleep 0 must return', () async {
      final result = await Effect.sleep(Duration.zero).runToExit();
      expect(result.isSuccess, isTrue);
      expect(result.fold((cause) => 'error', (value) => 'success'), equals('success'));
    });

    It.effect('promise must return', () =>
      Effect.promise(() => Future.value(42)).flatMap((result) =>
        Effect.sync(() {
          expect(result, equals(42));
        })
      )
    );

    It.effect('promise with delay', () =>
      Effect.promise(() => Future.delayed(Duration(milliseconds: 10), () => 42))
        .flatMap((result) =>
          Effect.sync(() {
            expect(result, equals(42));
          })
        )
    );

    It.effect('promise with error', () =>
      Effect.promise<int>(() => Future.error(Exception('promise error')))
        .sandbox().either().flatMap((result) =>
          Effect.sync(() {
            expect(result.isLeft, isTrue);
            final cause = result.fold((l) => l, (r) => null) as Cause;
            expect(cause.toString(), contains('promise error'));
          })
        )
    );

    It.effect('shallow bind of async chain', () {
      final array = List.generate(10, (i) => i);
      Effect<int, Object, Never> chain = Effect.succeed(0);
      
      for (final _ in array) {
        chain = chain.flatMap((n) =>
          Effect.asyncCallback<int>((cb) {
            cb(Effect.succeed(n + 1));
          })
        );
      }
      
      return chain.flatMap((result) =>
        Effect.sync(() {
          expect(result, equals(10));
        })
      );
    });

    It.effect('async with immediate callback', () =>
      Effect.asyncCallback<String>((cb) {
        // Call callback immediately (synchronously)
        cb(Effect.succeed('immediate'));
      }).flatMap((result) =>
        Effect.sync(() {
          expect(result, equals('immediate'));
        })
      )
    );

    It.effect('async with delayed callback', () =>
      Effect.asyncCallback<String>((cb) {
        // Call callback after a delay
        Timer(Duration(milliseconds: 5), () {
          cb(Effect.succeed('delayed'));
        });
      }).flatMap((result) =>
        Effect.sync(() {
          expect(result, equals('delayed'));
        })
      )
    );
  });
}