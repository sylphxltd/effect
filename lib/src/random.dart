import 'dart:math' as math;
import 'effect.dart';

/// Random number generation utilities
class Random {
  static final math.Random _random = math.Random();

  /// Generates a random integer between min (inclusive) and max (exclusive)
  static Effect<int, Never, Never> nextIntBetween(int min, int max) {
    if (min >= max) {
      return Effect.succeed(min); // Default to min if invalid range
    }
    
    final range = max - min;
    
    // For large ranges, use nextDouble and scale
    if (range > 0x7FFFFFFF) {
      final randomDouble = _random.nextDouble();
      final result = (randomDouble * range).floor() + min;
      return Effect.succeed(result);
    }
    
    return Effect.succeed(_random.nextInt(range) + min);
  }

  /// Shuffles the elements of an iterable randomly
  static Effect<List<T>, Never, Never> shuffle<T>(Iterable<T> iterable) {
    final list = List<T>.from(iterable);
    list.shuffle(_random);
    return Effect.succeed(list);
  }
}