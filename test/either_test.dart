import 'package:test/test.dart';
import '../lib/src/either.dart';
import '../lib/src/option.dart';

void main() {
  group('Either Tests', () {
    test('void', () {
      expect(Either.voidValue.isRight, isTrue);
      expect(Either.voidValue.fold((_) => false, (v) => v == null), isTrue);
    });

    test('isEither', () {
      expect(Either.isEither(Either.right(1)), isTrue);
      expect(Either.isEither(Either.left("e")), isTrue);
      expect(Either.isEither(Option.some(1)), isFalse);
    });

    test('getRight', () {
      final rightOption = Either.getRight(Either.right(1));
      expect(rightOption.isSome, isTrue);
      expect(rightOption.fold(() => null, (v) => v), equals(1));

      final leftOption = Either.getRight(Either.left("a"));
      expect(leftOption.isNone, isTrue);
    });

    test('getLeft', () {
      final rightOption = Either.getLeft(Either.right(1));
      expect(rightOption.isNone, isTrue);

      final leftOption = Either.getLeft(Either.left("e"));
      expect(leftOption.isSome, isTrue);
      expect(leftOption.fold(() => null, (v) => v), equals("e"));
    });

    test('isLeft', () {
      expect(Either.right(1).isLeft, isFalse);
      expect(Either.left(1).isLeft, isTrue);
    });

    test('isRight', () {
      expect(Either.right(1).isRight, isTrue);
      expect(Either.left(1).isRight, isFalse);
    });

    test('flip', () {
      final flippedRight = Either.flip(Either.right("a"));
      expect(flippedRight.isLeft, isTrue);
      expect(flippedRight.fold((v) => v, (_) => null), equals("a"));

      final flippedLeft = Either.flip(Either.left("b"));
      expect(flippedLeft.isRight, isTrue);
      expect(flippedLeft.fold((_) => null, (v) => v), equals("b"));
    });

    test('map', () {
      final result1 = Either.right("abc").map((s) => s.length);
      expect(result1.isRight, isTrue);
      expect(result1.fold((_) => null, (v) => v), equals(3));

      final result2 = Either.left("s").map((s) => s.length);
      expect(result2.isLeft, isTrue);
      expect(result2.fold((v) => v, (_) => null), equals("s"));
    });

    test('mapBoth', () {
      final result1 = Either.right(1).mapBoth(
        onLeft: (s) => s.length,
        onRight: (n) => n > 2,
      );
      expect(result1.isRight, isTrue);
      expect(result1.fold((_) => null, (v) => v), equals(false));

      final result2 = Either.left("a").mapBoth(
        onLeft: (s) => s.length,
        onRight: (n) => n > 2,
      );
      expect(result2.isLeft, isTrue);
      expect(result2.fold((v) => v, (_) => null), equals(1));
    });

    test('mapLeft', () {
      final result1 = Either.right("a").mapLeft((n) => n * 2);
      expect(result1.isRight, isTrue);
      expect(result1.fold((_) => null, (v) => v), equals("a"));

      final result2 = Either.left(1).mapLeft((n) => n * 2);
      expect(result2.isLeft, isTrue);
      expect(result2.fold((v) => v, (_) => null), equals(2));
    });

    test('match', () {
      final result1 = Either.left("abc").match(
        onLeft: (s) => "left${s.length}",
        onRight: (s) => "right${s.length}",
      );
      expect(result1, equals("left3"));

      final result2 = Either.right("abc").match(
        onLeft: (s) => "left${s.length}",
        onRight: (s) => "right${s.length}",
      );
      expect(result2, equals("right3"));
    });

    test('merge', () {
      final result1 = Either.right(1).merge<int>();
      expect(result1, equals(1));

      final result2 = Either.left("a").merge<String>();
      expect(result2, equals("a"));
    });

    test('liftPredicate', () {
      final isPositive = (int n) => n > 0;
      final onError = (int n) => "$n is not positive";
      
      final result1 = Either.liftPredicate(1, isPositive, onError);
      expect(result1.isRight, isTrue);
      expect(result1.fold((_) => null, (v) => v), equals(1));

      final result2 = Either.liftPredicate(-1, isPositive, onError);
      expect(result2.isLeft, isTrue);
      expect(result2.fold((v) => v, (_) => null), equals("-1 is not positive"));

      final isNumber = (dynamic n) => n is int;
      final onNumberError = (dynamic n) => "$n is not a number";

      final result3 = Either.liftPredicate(1, isNumber, onNumberError);
      expect(result3.isRight, isTrue);
      expect(result3.fold((_) => null, (v) => v), equals(1));

      final result4 = Either.liftPredicate("string", isNumber, onNumberError);
      expect(result4.isLeft, isTrue);
      expect(result4.fold((v) => v, (_) => null), equals("string is not a number"));
    });

    test('filterOrLeft', () {
      final result1 = Either.right(1).filterOrLeft((n) => n > 0, () => "a");
      expect(result1.isRight, isTrue);
      expect(result1.fold((_) => null, (v) => v), equals(1));

      final result2 = Either.right(1).filterOrLeft((n) => n > 1, () => "a");
      expect(result2.isLeft, isTrue);
      expect(result2.fold((v) => v, (_) => null), equals("a"));

      final Either<int, int> leftEither = Either.left(1);
      final result3 = leftEither.filterOrLeft((n) => n > 0, () => "a");
      expect(result3.isLeft, isTrue);
      expect(result3.fold((v) => v, (_) => null), equals(1));
    });

    test('fromNullable', () {
      final result1 = Either.fromNullable(null, () => "fallback");
      expect(result1.isLeft, isTrue);
      expect(result1.fold((v) => v, (_) => null), equals("fallback"));

      final result2 = Either.fromNullable(1, () => "fallback");
      expect(result2.isRight, isTrue);
      expect(result2.fold((_) => null, (v) => v), equals(1));
    });

    test('fromOption', () {
      final result1 = Either.fromOption(Option.none(), () => "none");
      expect(result1.isLeft, isTrue);
      expect(result1.fold((v) => v, (_) => null), equals("none"));

      final result2 = Either.fromOption(Option.some(1), () => "none");
      expect(result2.isRight, isTrue);
      expect(result2.fold((_) => null, (v) => v), equals(1));
    });

    test('tryCall', () {
      final result1 = Either.tryCall(() => 1);
      expect(result1.isRight, isTrue);
      expect(result1.fold((_) => null, (v) => v), equals(1));

      final result2 = Either.tryCall(() => throw "error");
      expect(result2.isLeft, isTrue);
      expect(result2.fold((v) => v, (_) => null), equals("error"));
    });

    test('tryWith', () {
      final result1 = Either.tryWith(
        tryFn: () => 1,
        catchFn: (e) => Exception(e.toString()),
      );
      expect(result1.isRight, isTrue);
      expect(result1.fold((_) => null, (v) => v), equals(1));

      final result2 = Either.tryWith(
        tryFn: () => throw "error",
        catchFn: (e) => Exception(e.toString()),
      );
      expect(result2.isLeft, isTrue);
      expect(result2.fold((v) => v.toString(), (_) => null), equals("Exception: error"));
    });

    test('getOrNull', () {
      final result1 = Either.right(1).getOrNull();
      expect(result1, equals(1));

      final result2 = Either.left("a").getOrNull();
      expect(result2, isNull);
    });

    test('getOrThrowWith', () {
      final result1 = Either.right(1).getOrThrowWith((e) => Exception("Unexpected Left: $e"));
      expect(result1, equals(1));

      expect(
        () => Either.left("e").getOrThrowWith((e) => Exception("Unexpected Left: $e")),
        throwsA(isA<Exception>()),
      );
    });

    test('getOrThrow', () {
      final result1 = Either.right(1).getOrThrow();
      expect(result1, equals(1));

      expect(
        () => Either.left("e").getOrThrow(),
        throwsA(isA<Exception>()),
      );
    });

    test('andThen', () {
      final result1 = Either.right(1).andThen((a) => Either.right(2));
      expect(result1.isRight, isTrue);
      expect(result1.fold((_) => null, (v) => v), equals(2));

      final result2 = Either.left("error").andThen((a) => Either.right(2));
      expect(result2.isLeft, isTrue);
      expect(result2.fold((v) => v, (_) => null), equals("error"));
    });

    test('ap', () {
      final double_ = (int n) => n * 2;
      
      // Test successful application of function to value
      final result1 = Either.right(double_).ap(Either.right(5));
      expect(result1.isRight, isTrue);
      expect(result1.fold((_) => null, (v) => v), equals(10));

      // Test function is Left
      final Either<String, Function> leftFunc = Either.left("error");
      final result2 = leftFunc.ap(Either.right(5));
      expect(result2.isLeft, isTrue);
      expect(result2.fold((v) => v, (_) => null), equals("error"));

      // Test value is Left
      final result3 = Either.right(double_).ap(Either.left("value error"));
      expect(result3.isLeft, isTrue);
      expect(result3.fold((v) => v, (_) => null), equals("value error"));
    });

    test('zipWith', () {
      final Either<int, int> left0 = Either.left(0);
      final result1 = left0.zipWith(Either.right(2), (a, b) => a + b);
      expect(result1.isLeft, isTrue);
      expect(result1.fold((v) => v, (_) => null), equals(0));

      final Either<int, int> left0_2 = Either.left(0);
      final result2 = Either.right(1).zipWith(left0_2, (a, b) => a + b);
      expect(result2.isLeft, isTrue);
      expect(result2.fold((v) => v, (_) => null), equals(0));

      final result3 = Either.right(1).zipWith(Either.right(2), (a, b) => a + b);
      expect(result3.isRight, isTrue);
      expect(result3.fold((_) => null, (v) => v), equals(3));
    });

    test('all', () {
      // empty list
      final result1 = Either.all(<Either<String, int>>[]);
      expect(result1.isRight, isTrue);
      expect(result1.fold((_) => null, (v) => v), equals(<int>[]));

      // single right
      final result2 = Either.all([Either.right(1)]);
      expect(result2.isRight, isTrue);
      expect(result2.fold((_) => null, (v) => v), equals([1]));

      // multiple rights
      final result3 = Either.all([Either.right(1), Either.right(2)]);
      expect(result3.isRight, isTrue);
      expect(result3.fold((_) => null, (v) => v), equals([1, 2]));

      // contains left
      final result4 = Either.all([Either.right(1), Either.left("e")]);
      expect(result4.isLeft, isTrue);
      expect(result4.fold((v) => v, (_) => null), equals("e"));
    });

    test('orElse', () {
      final result1 = Either.right(1).orElse(() => Either.right(2));
      expect(result1.isRight, isTrue);
      expect(result1.fold((_) => null, (v) => v), equals(1));

      final result2 = Either.right(1).orElse(() => Either.left("b"));
      expect(result2.isRight, isTrue);
      expect(result2.fold((_) => null, (v) => v), equals(1));

      final result3 = Either.left("a").orElse(() => Either.right(2));
      expect(result3.isRight, isTrue);
      expect(result3.fold((_) => null, (v) => v), equals(2));

      final result4 = Either.left("a").orElse(() => Either.left("b"));
      expect(result4.isLeft, isTrue);
      expect(result4.fold((v) => v, (_) => null), equals("b"));
    });
  });
}