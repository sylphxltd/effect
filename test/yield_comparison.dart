// TypeScript 風格 (這在 Dart 中不可能)
/*
function* tsGenerator() {
  const result1 = yield* Effect.succeed(1); // 獲取結果: 1
  const result2 = yield* Effect.succeed(result1 + 1); // 獲取結果: 2
  return result1 + result2; // 返回: 3
}
*/

// Dart 的實際情況
import '../lib/src/effect.dart';

// 這是 Dart 中 yield 的實際行為
Iterable<Effect> dartGenerator() sync* {
  yield Effect.succeed(1);
  yield Effect.succeed(2);
  // 問題：我們無法獲取這些 Effect 的結果！
  // final result = yield Effect.succeed(1); // 編譯錯誤！
}

// 這就是為什麼我們需要不同的方法
void main() {
  print('Dart generator 只能產生 Effect，不能獲取結果');
  
  for (final effect in dartGenerator()) {
    print('Generated: $effect');
    // 我們需要手動運行每個 effect 來獲取結果
  }
}