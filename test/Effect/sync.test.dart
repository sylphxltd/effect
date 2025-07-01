import 'package:test/test.dart';
import '../../lib/src/effect.dart';
import '../../lib/src/exit.dart';
import '../../lib/src/cause.dart';
import '../test_utils.dart';

int sum(int n) {
  if (n < 0) {
    return 0;
  }
  return n + sum(n - 1);
}

void main() {
  group('Effect', () {
    test('runSyncExit with async is a defect with stack', () {
      final Exit<int, Object> exit = Effect.runSyncExit(
        Effect.promise(() => Future.value(0)).withSpan('asyncSpan')
      );
      if (exit.isFailure) {
        expect(Cause.pretty((exit as Failure).cause), contains('asyncSpan'));
      } else {
        expect(exit.runtimeType.toString(), equals('Failure'));
      }
    });

    It.effect('sync - effect', () {
      Effect<int, Object, Never> sumEffect(int n) {
        if (n < 0) {
          return Effect.sync(() => 0);
        }
        return Effect.sync(() => n).flatMap((int b) =>
          sumEffect(n - 1).map((int a) => a + b)
        );
      }
      
      return sumEffect(10).flatMap((int result) =>
        Effect.sync(() {
          expect(result, equals(sum(10)));
        })
      );
    });

    test('sync - must be lazy', () async {
      Effect<bool, Object, Never> program;
      try {
        program = Effect.sync(() {
          throw Exception('shouldn\'t happen!');
        });
        program = Effect.succeed(true);
      } on Exception {
        program = Effect.succeed(false);
      }
      final bool result = await Effect.runPromise<bool, Object, Never>(program);
      expect(result, isTrue);
    });

    test('suspend - must be lazy', () async {
      Effect<bool, Object, Never> program;
      try {
        program = Effect.suspend(() {
          throw Exception('shouldn\'t happen!');
        });
        program = Effect.succeed(true);
      } on Exception {
        program = Effect.succeed(false);
      }
      final bool result = await Effect.runPromise<bool, Object, Never>(program);
      expect(result, isTrue);
    });

    test('suspend - must catch throwable', () async {
      final Exception error = Exception('woops');
      final Exit<Never, Never> result = await Effect.runPromise<Exit<Never, Never>, Never, Never>(
        Effect.suspend<Never, Never, Never>(() {
          throw error;
        }).exit()
      );
      
      expect(result, equals(Exit.die(error)));
    });

    It.effect('suspendSucceed - must be evaluatable', () =>
      Effect.suspend(() => Effect.succeed(42)).flatMap((int result) =>
        Effect.sync(() {
          expect(result, equals(42));
        })
      )
    );

    It.effect('suspendSucceed - must not catch throwable', () {
      final Exception error = Exception('woops');
      return Effect.suspend<Never, Never, Never>(() {
        throw error;
      }).sandbox().either().flatMap((dynamic result) =>
        Effect.sync(() {
          expect(result.isLeft, isTrue);
          final cause = result.fold((dynamic l) => l, (dynamic r) => null) as Cause;
          expect(cause.toString(), contains('Exception: woops'));
        })
      );
    });
  });
}