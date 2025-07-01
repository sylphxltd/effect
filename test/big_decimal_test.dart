import 'package:test/test.dart';
import 'package:effect_dart/effect_dart.dart';

void assertDivide(String x, String y, String z) {
  final divideResult = BigDecimal.divide($(x), $(y));
  expect(divideResult.isSome, isTrue, reason: 'Expected $x / $y to not be None');
  expect(divideResult.fold(() => null, (value) => value), equals($(z)),
         reason: 'Expected $x / $y to be $z');
  expect(BigDecimal.unsafeDivide($(x), $(y)), equals($(z)),
         reason: 'Expected $x / $y to be $z');
}

void main() {
  group('BigDecimal Tests', () {
    test('isBigDecimal', () {
      expect(BigDecimal.isBigDecimal($("0")), isTrue);
      expect(BigDecimal.isBigDecimal($("987")), isTrue);
      expect(BigDecimal.isBigDecimal($("123.0")), isTrue);
      expect(BigDecimal.isBigDecimal($("0.123")), isTrue);
      expect(BigDecimal.isBigDecimal($("123.456")), isTrue);
      expect(BigDecimal.isBigDecimal("1"), isFalse);
      expect(BigDecimal.isBigDecimal(true), isFalse);
    });

    test('sign', () {
      expect(BigDecimal.sign($("-5")), equals(-1));
      expect(BigDecimal.sign($("0")), equals(0));
      expect(BigDecimal.sign($("5")), equals(1));
      expect(BigDecimal.sign($("-123.456")), equals(-1));
      expect(BigDecimal.sign($("456.789")), equals(1));
    });

    test('equals', () {
      expect(BigDecimal.equals($("1"), $("1")), isTrue);
      expect(BigDecimal.equals($("0.00012300"), $("0.000123")), isTrue);
      expect(BigDecimal.equals($("5"), $("5.0")), isTrue);
      expect(BigDecimal.equals($("123.0000"), $("123.00")), isTrue);
      expect(BigDecimal.equals($("1"), $("2")), isFalse);
      expect(BigDecimal.equals($("1"), $("1.1")), isFalse);
      expect(BigDecimal.equals($("1"), $("0.1")), isFalse);
    });

    test('sum', () {
      expect(BigDecimal.sum($("2"), $("0")), equals($("2")));
      expect(BigDecimal.sum($("0"), $("2")), equals($("2")));
      expect(BigDecimal.sum($("0"), $("0")), equals($("0")));
      expect(BigDecimal.sum($("2"), $("1")), equals($("3")));
      expect(BigDecimal.sum($("3.00000"), $("50")), equals($("53")));
      expect(BigDecimal.sum($("1.23"), $("0.0045678")), equals($("1.2345678")));
      expect(BigDecimal.sum($("123.456"), $("-123.456")), equals($("0")));
    });

    test('multiply', () {
      expect(BigDecimal.multiply($("3"), $("2")), equals($("6")));
      expect(BigDecimal.multiply($("3"), $("0")), equals($("0")));
      expect(BigDecimal.multiply($("3"), $("-1")), equals($("-3")));
      expect(BigDecimal.multiply($("3"), $("0.5")), equals($("1.5")));
      expect(BigDecimal.multiply($("3"), $("-2.5")), equals($("-7.5")));
    });

    test('subtract', () {
      expect(BigDecimal.subtract($("0"), $("1")), equals($("-1")));
      expect(BigDecimal.subtract($("2.1"), $("1")), equals($("1.1")));
      expect(BigDecimal.subtract($("3"), $("1")), equals($("2")));
      expect(BigDecimal.subtract($("3"), $("0")), equals($("3")));
      expect(BigDecimal.subtract($("3"), $("-1")), equals($("4")));
      expect(BigDecimal.subtract($("3"), $("0.5")), equals($("2.5")));
      expect(BigDecimal.subtract($("3"), $("-2.5")), equals($("5.5")));
    });

    test('roundTerminal', () {
      expect(BigDecimal.roundTerminal(BigInt.from(0)), equals(BigInt.zero));
      expect(BigDecimal.roundTerminal(BigInt.from(4)), equals(BigInt.zero));
      expect(BigDecimal.roundTerminal(BigInt.from(5)), equals(BigInt.one));
      expect(BigDecimal.roundTerminal(BigInt.from(9)), equals(BigInt.one));
      expect(BigDecimal.roundTerminal(BigInt.from(49)), equals(BigInt.zero));
      expect(BigDecimal.roundTerminal(BigInt.from(59)), equals(BigInt.one));
      expect(BigDecimal.roundTerminal(BigInt.from(99)), equals(BigInt.one));
      expect(BigDecimal.roundTerminal(BigInt.from(-4)), equals(BigInt.zero));
      expect(BigDecimal.roundTerminal(BigInt.from(-5)), equals(BigInt.one));
      expect(BigDecimal.roundTerminal(BigInt.from(-9)), equals(BigInt.one));
      expect(BigDecimal.roundTerminal(BigInt.from(-49)), equals(BigInt.zero));
      expect(BigDecimal.roundTerminal(BigInt.from(-59)), equals(BigInt.one));
      expect(BigDecimal.roundTerminal(BigInt.from(-99)), equals(BigInt.one));
    });

    test('divide', () {
      assertDivide("0", "1", "0");
      assertDivide("0", "10", "0");
      assertDivide("2", "1", "2");
      assertDivide("20", "1", "20");
      assertDivide("10", "10", "1");
      assertDivide("100", "10.0", "10");
      assertDivide("20.0", "200", "0.1");
      assertDivide("4", "2", "2.0");
      assertDivide("15", "3", "5.0");
      assertDivide("1", "2", "0.5");
      assertDivide("1", "0.02", "50");
      assertDivide("1", "0.2", "5");
      assertDivide("1.0", "0.02", "50");
      assertDivide("1", "0.020", "50");
      assertDivide("5.0", "4.00", "1.25");
      assertDivide("5.0", "4.000", "1.25");
      assertDivide("5", "4.000", "1.25");
      assertDivide("5", "4", "1.25");
      assertDivide("100", "5", "20");
      assertDivide("-50", "5", "-10");
      assertDivide("200", "-5", "-40.0");

      // Test division by zero
      expect(BigDecimal.divide($("5"), $("0")).isNone, isTrue);
      expect(() => BigDecimal.unsafeDivide($("5"), $("0")), throwsA(isA<RangeError>()));
    });

    test('Equivalence', () {
      expect(BigDecimal.Equivalence($("1"), $("1")), isTrue);
      expect(BigDecimal.Equivalence($("0.00012300"), $("0.000123")), isTrue);
      expect(BigDecimal.Equivalence($("5"), $("5.00")), isTrue);
      expect(BigDecimal.Equivalence($("1"), $("2")), isFalse);
      expect(BigDecimal.Equivalence($("1"), $("1.1")), isFalse);
    });

    test('Order', () {
      expect(BigDecimal.Order($("1"), $("2")), equals(-1));
      expect(BigDecimal.Order($("2"), $("1")), equals(1));
      expect(BigDecimal.Order($("2"), $("2")), equals(0));
      expect(BigDecimal.Order($("1"), $("1.1")), equals(-1));
      expect(BigDecimal.Order($("1.1"), $("1")), equals(1));
      expect(BigDecimal.Order($("0.00012300"), $("0.000123")), equals(0));
      expect(BigDecimal.Order($("5"), $("5.000")), equals(0));
      expect(BigDecimal.Order($("5"), $("0.500")), equals(1));
      expect(BigDecimal.Order($("5"), $("50.00")), equals(-1));
    });

    test('lessThan', () {
      expect(BigDecimal.lessThan($("2"), $("3")), isTrue);
      expect(BigDecimal.lessThan($("3"), $("3")), isFalse);
      expect(BigDecimal.lessThan($("4"), $("3")), isFalse);
    });

    test('lessThanOrEqualTo', () {
      expect(BigDecimal.lessThanOrEqualTo($("2"), $("3")), isTrue);
      expect(BigDecimal.lessThanOrEqualTo($("3"), $("3")), isTrue);
      expect(BigDecimal.lessThanOrEqualTo($("4"), $("3")), isFalse);
    });

    test('greaterThan', () {
      expect(BigDecimal.greaterThan($("2"), $("3")), isFalse);
      expect(BigDecimal.greaterThan($("3"), $("3")), isFalse);
      expect(BigDecimal.greaterThan($("4"), $("3")), isTrue);
    });

    test('greaterThanOrEqualTo', () {
      expect(BigDecimal.greaterThanOrEqualTo($("2"), $("3")), isFalse);
      expect(BigDecimal.greaterThanOrEqualTo($("3"), $("3")), isTrue);
      expect(BigDecimal.greaterThanOrEqualTo($("4"), $("3")), isTrue);
    });

    test('min', () {
      expect(BigDecimal.min($("2"), $("3")), equals($("2")));
      expect(BigDecimal.min($("5"), $("0.1")), equals($("0.1")));
      expect(BigDecimal.min($("0.005"), $("3")), equals($("0.005")));
      expect(BigDecimal.min($("123.456"), $("1.2")), equals($("1.2")));
    });

    test('max', () {
      expect(BigDecimal.max($("2"), $("3")), equals($("3")));
      expect(BigDecimal.max($("5"), $("0.1")), equals($("5")));
      expect(BigDecimal.max($("0.005"), $("3")), equals($("3")));
      expect(BigDecimal.max($("123.456"), $("1.2")), equals($("123.456")));
    });

    test('abs', () {
      expect(BigDecimal.abs($("2")), equals($("2")));
      expect(BigDecimal.abs($("-3")), equals($("3")));
      expect(BigDecimal.abs($("0.000456")), equals($("0.000456")));
      expect(BigDecimal.abs($("-0.123")), equals($("0.123")));
    });

    test('negate', () {
      expect(BigDecimal.negate($("2")), equals($("-2")));
      expect(BigDecimal.negate($("-3")), equals($("3")));
      expect(BigDecimal.negate($("0.000456")), equals($("-0.000456")));
      expect(BigDecimal.negate($("-0.123")), equals($("0.123")));
    });

    test('remainder', () {
      final r1 = BigDecimal.remainder($("5"), $("2"));
      expect(r1.isSome, isTrue);
      expect(r1.fold(() => null, (v) => v), equals($("1")));

      final r2 = BigDecimal.remainder($("4"), $("2"));
      expect(r2.isSome, isTrue);
      expect(r2.fold(() => null, (v) => v), equals($("0")));

      final r3 = BigDecimal.remainder($("123.456"), $("0.2"));
      expect(r3.isSome, isTrue);
      expect(r3.fold(() => null, (v) => v), equals($("0.056")));

      expect(BigDecimal.remainder($("5"), $("0")).isNone, isTrue);
    });

    test('unsafeRemainder', () {
      expect(BigDecimal.unsafeRemainder($("5"), $("2")), equals($("1")));
      expect(BigDecimal.unsafeRemainder($("4"), $("2")), equals($("0")));
      expect(BigDecimal.unsafeRemainder($("123.456"), $("0.2")), equals($("0.056")));
      expect(() => BigDecimal.unsafeRemainder($("5"), $("0")), throwsA(isA<RangeError>()));
    });

    test('between', () {
      expect(BigDecimal.between($("3"), minimum: $("0"), maximum: $("5")), isTrue);
      expect(BigDecimal.between($("-1"), minimum: $("0"), maximum: $("5")), isFalse);
      expect(BigDecimal.between($("6"), minimum: $("0"), maximum: $("5")), isFalse);
      expect(BigDecimal.between($("0.0123"), minimum: $("0.02"), maximum: $("5")), isFalse);
      expect(BigDecimal.between($("0.05"), minimum: $("0.02"), maximum: $("5")), isTrue);
    });

    test('clamp', () {
      expect(BigDecimal.clamp($("3"), minimum: $("0"), maximum: $("5")), equals($("3")));
      expect(BigDecimal.clamp($("-1"), minimum: $("0"), maximum: $("5")), equals($("0")));
      expect(BigDecimal.clamp($("6"), minimum: $("0"), maximum: $("5")), equals($("5")));
      expect(BigDecimal.clamp($("0.0123"), minimum: $("0.02"), maximum: $("5")), equals($("0.02")));
    });

    test('isZero', () {
      expect(BigDecimal.isZero($("0")), isTrue);
      expect(BigDecimal.isZero($("0.000")), isTrue);
      expect(BigDecimal.isZero($("1")), isFalse);
    });

    test('isPositive', () {
      expect(BigDecimal.isPositive($("1")), isTrue);
      expect(BigDecimal.isPositive($("0")), isFalse);
      expect(BigDecimal.isPositive($("-1")), isFalse);
    });

    test('isNegative', () {
      expect(BigDecimal.isNegative($("-1")), isTrue);
      expect(BigDecimal.isNegative($("0")), isFalse);
      expect(BigDecimal.isNegative($("1")), isFalse);
    });

    test('isInteger', () {
      expect(BigDecimal.isInteger($("0")), isTrue);
      expect(BigDecimal.isInteger($("1")), isTrue);
      expect(BigDecimal.isInteger($("1.0")), isTrue);
      expect(BigDecimal.isInteger($("1.1")), isFalse);
    });

    test('sumAll', () {
      expect(BigDecimal.sumAll([]), equals($("0")));
      expect(BigDecimal.sumAll([$("2.5"), $("0.5")]), equals($("3")));
      expect(BigDecimal.sumAll([$("2.5"), $("1500"), $("123.456")]), equals($("1625.956")));
    });
  });
}