import 'package:test/test.dart';
import 'package:effect_dart/effect_dart.dart';

void main() {
  group('Random Tests', () {
    test('generator pattern works', () async {
      final effect = Effect.gen(() sync* {
        // Yield a sequence of random number generations
        yield Random.nextIntBetween(0, 100);
        yield Random.nextIntBetween(100, 200);
        yield Random.nextIntBetween(200, 300);
      });
      
      final exit = await effect.runToExit();
      expect(exit.isSuccess, isTrue);
      // The result should be the last generated number (200-300 range)
      final result = exit.fold(
        (cause) => throw Exception('Effect failed: $cause'),
        (value) => value,
      );
      expect(result, greaterThanOrEqualTo(200));
      expect(result, lessThan(300));
    });

    test('shuffle works with generator', () async {
      final effect = Effect.gen(() sync* {
        // Generate range and shuffle it
        yield Random.shuffle(Array.range(0, 10));
      });
      
      final exit = await effect.runToExit();
      expect(exit.isSuccess, isTrue);
      
      final shuffled = exit.fold(
        (cause) => throw Exception('Effect failed: $cause'),
        (value) => value as List<int>,
      );
      
      // Should contain all elements 0-9
      expect(shuffled.length, equals(10));
      for (int i = 0; i < 10; i++) {
        expect(shuffled.contains(i), isTrue);
      }
      
      // Should be different from sorted (very high probability)
      final sorted = Array.range(0, 10);
      expect(shuffled, isNot(equals(sorted)));
    });
  });
}