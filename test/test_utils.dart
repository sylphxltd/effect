import 'package:test/test.dart';
import '../lib/src/effect.dart';

/// Global function to create effect tests
void testEffect(String description, Effect<dynamic, Object, Never> Function() testEffect) {
  test(description, () async {
    await Effect.runPromise(testEffect());
  });
}

/// Global it object with effect method for Effect-TS style testing
class It {
  static void effect(String description, Effect<dynamic, Object, Never> Function() testEffect) {
    test(description, () async {
      await Effect.runPromise(testEffect());
    });
  }
  
  /// Regular test method for compatibility
  static void call(String description, dynamic Function() testFunction) {
    test(description, testFunction);
  }
}

// Global it instance
final it = It();