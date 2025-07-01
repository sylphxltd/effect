import '../lib/src/effect.dart';

// 這是 Dart 中 yield 的正確用法
Iterable<Effect> exampleGenerator() sync* {
  yield Effect.succeed(1);
  yield Effect.succeed(2);
  yield Effect.succeed(3);
  // 但是你不能在這裡獲取這些 Effect 的結果！
}

// 這樣是不行的：
/*
Iterable<Effect> wrongGenerator() sync* {
  final result = yield Effect.succeed(1); // 錯誤！yield 不返回值
  print(result); // 這行永遠不會執行
}
*/

// Effect-TS 的 yield* 語法實際上是 JavaScript/TypeScript 的特殊語法
// 在 TypeScript 中：
/*
function* generator() {
  const result = yield* Effect.succeed(1); // 這在 TS 中可以獲取結果
  console.log(result); // 可以使用結果
}
*/

void main() {
  // Dart 的 yield 只是產生值，不能獲取結果
  for (final effect in exampleGenerator()) {
    print('Generated effect: $effect');
  }
}