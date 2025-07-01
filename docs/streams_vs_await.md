# Why Streams Could Be Better Than Await

## Current Approach (await)
```dart
Effect.gen(() async {
  const tenYearsMillis = 10 * 365 * 24 * 60 * 60 * 1000;
  int lastRandom = 0;
  while (lastRandom < tenYearsMillis ~/ 2) {
    lastRandom = await Random.nextIntBetween(0, tenYearsMillis)(); // Eager execution
  }
  return lastRandom;
})
```

## Stream-based Approach (closer to yield*)
```dart
Effect.gen(() async* {
  const tenYearsMillis = 10 * 365 * 24 * 60 * 60 * 1000;
  int lastRandom = 0;
  while (lastRandom < tenYearsMillis ~/ 2) {
    lastRandom = yield Random.nextIntBetween(0, tenYearsMillis); // Lazy evaluation!
  }
  return lastRandom;
})
```

## Why Streams Would Be Better

### 1. **Lazy Evaluation**
- **Current**: Effects execute immediately when awaited
- **Streams**: Effects only execute when consumed

### 2. **More Functional**
- **Current**: Side effects happen during construction  
- **Streams**: Pure description until interpreted

### 3. **Better Composability**
- **Current**: Hard to compose without execution
- **Streams**: Effects can be combined without running

### 4. **Closer to Effect-TS**
- **JavaScript**: `yield* effect` delegates to generator
- **Dart Streams**: `yield effect` adds to stream

### 5. **Error Handling**
- **Current**: Try/catch around await
- **Streams**: Stream error handling with proper propagation

## Implementation Strategy

We could implement:

```dart
class Effect<A, E, R> {
  // Stream-based generator
  static Effect<A, Object, Never> gen<A>(
    Stream<Effect> Function() generator
  ) => _StreamGen(generator);
  
  // Make Effects yielable
  Stream<Effect> get stream => Stream.value(this);
}

// Usage:
Effect.gen(() async* {
  yield Random.nextIntBetween(0, 100);
  yield Console.log("Hello");
  // etc.
});
```

This would be much closer to JavaScript's generator semantics!