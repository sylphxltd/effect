/// Array utilities for functional programming
/// 
/// This module provides functional utilities for working with Lists in Dart,
/// inspired by Effect-TS Array module.
library;

import 'option.dart';
import 'either.dart';

/// Array utilities for functional programming
class Array {
  Array._();

  /// Creates an array containing a single element.
  /// 
  /// Example:
  /// ```dart
  /// Array.of(1) // [1]
  /// ```
  static List<A> of<A>(A element) => [element];

  /// Creates an empty array.
  /// 
  /// Example:
  /// ```dart
  /// Array.empty<int>() // <int>[]
  /// ```
  static List<A> empty<A>() => <A>[];

  /// Creates an array from an iterable.
  /// If the iterable is already a List, returns the same reference.
  /// 
  /// Example:
  /// ```dart
  /// Array.fromIterable({1, 2, 3}) // [1, 2, 3]
  /// Array.fromIterable([1, 2, 3]) // [1, 2, 3] (same reference)
  /// ```
  static List<A> fromIterable<A>(Iterable<A> iterable) {
    if (iterable is List<A>) return iterable;
    return iterable.toList();
  }

  /// Ensures the input is an array.
  /// If the input is already a List, returns it as-is.
  /// Otherwise, wraps it in an array.
  /// 
  /// Example:
  /// ```dart
  /// Array.ensure(1) // [1]
  /// Array.ensure([1, 2]) // [1, 2]
  /// ```
  static List<A> ensure<A>(dynamic value) {
    if (value is List<A>) return value;
    return [value as A];
  }

  /// Prepends an element to the beginning of an array.
  ///
  /// Example:
  /// ```dart
  /// Array.prepend([1, 2, 3], 0) // [0, 1, 2, 3]
  /// ```
  static List<A> prepend<A>(Iterable<A> array, A element) {
    return [element, ...array];
  }

  /// Appends an element to the end of an array.
  ///
  /// Example:
  /// ```dart
  /// Array.append([1, 2, 3], 4) // [1, 2, 3, 4]
  /// ```
  static List<A> append<A>(Iterable<A> array, A element) {
    return [...array, element];
  }

  /// Prepends all elements from another array to the beginning.
  ///
  /// Example:
  /// ```dart
  /// Array.prependAll([3, 4], [1, 2]) // [1, 2, 3, 4]
  /// ```
  static List<A> prependAll<A>(Iterable<A> array, Iterable<A> prefix) {
    return [...prefix, ...array];
  }

  /// Appends all elements from another array to the end.
  ///
  /// Example:
  /// ```dart
  /// Array.appendAll([1, 2], [3, 4]) // [1, 2, 3, 4]
  /// ```
  static List<A> appendAll<A>(Iterable<A> array, Iterable<A> suffix) {
    return [...array, ...suffix];
  }

  /// Returns the tail of an array (all elements except the first).
  /// Returns None if the array is empty.
  ///
  /// Example:
  /// ```dart
  /// Array.tail([1, 2, 3]) // Some([2, 3])
  /// Array.tail([]) // None()
  /// ```
  static Option<List<A>> tail<A>(Iterable<A> array) {
    final list = fromIterable(array);
    if (list.isEmpty) return Option.none();
    return Option.some(list.sublist(1));
  }

  /// Returns the init of an array (all elements except the last).
  /// Returns None if the array is empty.
  ///
  /// Example:
  /// ```dart
  /// Array.init([1, 2, 3]) // Some([1, 2])
  /// Array.init([]) // None()
  /// ```
  static Option<List<A>> init<A>(Iterable<A> array) {
    final list = fromIterable(array);
    if (list.isEmpty) return Option.none();
    return Option.some(list.sublist(0, list.length - 1));
  }

  /// Takes the first n elements from an array.
  ///
  /// Example:
  /// ```dart
  /// Array.take([1, 2, 3, 4], 2) // [1, 2]
  /// Array.take([1, 2, 3, 4], 0) // []
  /// Array.take([1, 2, 3, 4], 10) // [1, 2, 3, 4]
  /// ```
  static List<A> take<A>(Iterable<A> array, int n) {
    if (n <= 0) return empty<A>();
    final list = fromIterable(array);
    if (n >= list.length) return list;
    return list.sublist(0, n);
  }

  /// Takes the last n elements from an array.
  ///
  /// Example:
  /// ```dart
  /// Array.takeRight([1, 2, 3, 4], 2) // [3, 4]
  /// Array.takeRight([1, 2, 3, 4], 0) // []
  /// Array.takeRight([1, 2, 3, 4], 10) // [1, 2, 3, 4]
  /// ```
  static List<A> takeRight<A>(Iterable<A> array, int n) {
    if (n <= 0) return empty<A>();
    final list = fromIterable(array);
    if (n >= list.length) return list;
    return list.sublist(list.length - n);
  }

  /// Takes elements from the beginning while the predicate is true.
  ///
  /// Example:
  /// ```dart
  /// Array.takeWhile([2, 4, 3, 6], (n) => n % 2 == 0) // [2, 4]
  /// Array.takeWhile([1, 2, 4], (n) => n % 2 == 0) // []
  /// ```
  static List<A> takeWhile<A>(Iterable<A> array, bool Function(A) predicate) {
    final result = <A>[];
    for (final element in array) {
      if (!predicate(element)) break;
      result.add(element);
    }
    return result;
  }

  /// Drops the first n elements from an array.
  ///
  /// Example:
  /// ```dart
  /// Array.drop([1, 2, 3, 4], 2) // [3, 4]
  /// Array.drop([1, 2, 3, 4], 0) // [1, 2, 3, 4]
  /// Array.drop([1, 2, 3, 4], 10) // []
  /// ```
  static List<A> drop<A>(Iterable<A> array, int n) {
    if (n <= 0) return fromIterable(array);
    final list = fromIterable(array);
    if (n >= list.length) return empty<A>();
    return list.sublist(n);
  }

  /// Drops the last n elements from an array.
  ///
  /// Example:
  /// ```dart
  /// Array.dropRight([1, 2, 3, 4], 2) // [1, 2]
  /// Array.dropRight([1, 2, 3, 4], 0) // [1, 2, 3, 4]
  /// Array.dropRight([1, 2, 3, 4], 10) // []
  /// ```
  static List<A> dropRight<A>(Iterable<A> array, int n) {
    if (n <= 0) return fromIterable(array);
    final list = fromIterable(array);
    if (n >= list.length) return empty<A>();
    return list.sublist(0, list.length - n);
  }

  /// Drops elements from the beginning while the predicate is true.
  ///
  /// Example:
  /// ```dart
  /// Array.dropWhile([1, 3, 2, 4], (n) => n % 2 == 1) // [2, 4]
  /// Array.dropWhile([2, 4], (n) => n % 2 == 1) // [2, 4]
  /// ```
  static List<A> dropWhile<A>(Iterable<A> array, bool Function(A) predicate) {
    final list = fromIterable(array);
    int dropCount = 0;
    for (final element in list) {
      if (!predicate(element)) break;
      dropCount++;
    }
    return list.sublist(dropCount);
  }

  /// Reverses an array.
  ///
  /// Example:
  /// ```dart
  /// Array.reverse([1, 2, 3]) // [3, 2, 1]
  /// Array.reverse([]) // []
  /// ```
  static List<A> reverse<A>(Iterable<A> array) {
    return fromIterable(array).reversed.toList();
  }

  /// Gets the element at the specified index.
  /// Returns None if the index is out of bounds.
  ///
  /// Example:
  /// ```dart
  /// Array.get([1, 2, 3], 1) // Some(2)
  /// Array.get([1, 2, 3], 5) // None()
  /// ```
  static Option<A> get<A>(Iterable<A> array, int index) {
    if (index < 0) return Option.none();
    final list = fromIterable(array);
    if (index >= list.length) return Option.none();
    return Option.some(list[index]);
  }

  /// Gets the first element of an array.
  /// Returns None if the array is empty.
  ///
  /// Example:
  /// ```dart
  /// Array.head([1, 2, 3]) // Some(1)
  /// Array.head([]) // None()
  /// ```
  static Option<A> head<A>(Iterable<A> array) {
    final list = fromIterable(array);
    if (list.isEmpty) return Option.none();
    return Option.some(list.first);
  }

  /// Gets the last element of an array.
  /// Returns None if the array is empty.
  ///
  /// Example:
  /// ```dart
  /// Array.last([1, 2, 3]) // Some(3)
  /// Array.last([]) // None()
  /// ```
  static Option<A> last<A>(Iterable<A> array) {
    final list = fromIterable(array);
    if (list.isEmpty) return Option.none();
    return Option.some(list.last);
  }

  /// Checks if an array is empty.
  ///
  /// Example:
  /// ```dart
  /// Array.isEmpty([]) // true
  /// Array.isEmpty([1]) // false
  /// ```
  static bool isEmpty<A>(Iterable<A> array) {
    return fromIterable(array).isEmpty;
  }

  /// Checks if an array is not empty.
  ///
  /// Example:
  /// ```dart
  /// Array.isNotEmpty([1]) // true
  /// Array.isNotEmpty([]) // false
  /// ```
  static bool isNotEmpty<A>(Iterable<A> array) {
    return fromIterable(array).isNotEmpty;
  }

  /// Gets the length of an array.
  ///
  /// Example:
  /// ```dart
  /// Array.length([1, 2, 3]) // 3
  /// Array.length([]) // 0
  /// ```
  static int length<A>(Iterable<A> array) {
    return fromIterable(array).length;
  }

  /// Maps each element to a new value using the provided function.
  ///
  /// Example:
  /// ```dart
  /// Array.map([1, 2, 3], (n) => n * 2) // [2, 4, 6]
  /// Array.map([], (n) => n * 2) // []
  /// ```
  static List<B> map<A, B>(Iterable<A> array, B Function(A) f) {
    return fromIterable(array).map(f).toList();
  }

  /// Filters elements that satisfy the predicate.
  ///
  /// Example:
  /// ```dart
  /// Array.filter([1, 2, 3, 4], (n) => n % 2 == 0) // [2, 4]
  /// Array.filter([], (n) => true) // []
  /// ```
  static List<A> filter<A>(Iterable<A> array, bool Function(A) predicate) {
    return fromIterable(array).where(predicate).toList();
  }

  /// Finds the first element that satisfies the predicate.
  ///
  /// Example:
  /// ```dart
  /// Array.find([1, 2, 3, 4], (n) => n % 2 == 0) // Some(2)
  /// Array.find([1, 3, 5], (n) => n % 2 == 0) // None()
  /// ```
  static Option<A> find<A>(Iterable<A> array, bool Function(A) predicate) {
    for (final element in array) {
      if (predicate(element)) {
        return Option.some(element);
      }
    }
    return Option.none();
  }

  /// Checks if the array contains the specified element.
  ///
  /// Example:
  /// ```dart
  /// Array.contains([1, 2, 3], 2) // true
  /// Array.contains([1, 2, 3], 4) // false
  /// ```
  static bool contains<A>(Iterable<A> array, A element) {
    return fromIterable(array).contains(element);
  }

  /// Checks if any element satisfies the predicate.
  ///
  /// Example:
  /// ```dart
  /// Array.some([1, 2, 3], (n) => n % 2 == 0) // true
  /// Array.some([1, 3, 5], (n) => n % 2 == 0) // false
  /// ```
  static bool some<A>(Iterable<A> array, bool Function(A) predicate) {
    return fromIterable(array).any(predicate);
  }

  /// Checks if all elements satisfy the predicate.
  ///
  /// Example:
  /// ```dart
  /// Array.every([2, 4, 6], (n) => n % 2 == 0) // true
  /// Array.every([1, 2, 3], (n) => n % 2 == 0) // false
  /// ```
  static bool every<A>(Iterable<A> array, bool Function(A) predicate) {
    return fromIterable(array).every(predicate);
  }

  /// Partitions an array into two arrays based on a predicate.
  /// Returns a tuple where the first array contains elements that satisfy
  /// the predicate, and the second contains those that don't.
  ///
  /// Example:
  /// ```dart
  /// Array.partition([1, 2, 3, 4], (n) => n % 2 == 0) // ([2, 4], [1, 3])
  /// ```
  static (List<A>, List<A>) partition<A>(Iterable<A> array, bool Function(A) predicate) {
    final trues = <A>[];
    final falses = <A>[];
    
    for (final element in array) {
      if (predicate(element)) {
        trues.add(element);
      } else {
        falses.add(element);
      }
    }
    
    return (trues, falses);
  }

  /// Zips two arrays together into an array of tuples.
  /// The resulting array has the length of the shorter input array.
  ///
  /// Example:
  /// ```dart
  /// Array.zip([1, 2, 3], ['a', 'b', 'c']) // [(1, 'a'), (2, 'b'), (3, 'c')]
  /// Array.zip([1, 2], ['a', 'b', 'c']) // [(1, 'a'), (2, 'b')]
  /// ```
  static List<(A, B)> zip<A, B>(Iterable<A> first, Iterable<B> second) {
    final firstList = fromIterable(first);
    final secondList = fromIterable(second);
    final result = <(A, B)>[];
    
    final minLength = firstList.length < secondList.length
        ? firstList.length
        : secondList.length;
    
    for (int i = 0; i < minLength; i++) {
      result.add((firstList[i], secondList[i]));
    }
    
    return result;
  }

  /// Flattens an array of arrays into a single array.
  ///
  /// Example:
  /// ```dart
  /// Array.flatten([[1, 2], [3, 4], [5]]) // [1, 2, 3, 4, 5]
  /// Array.flatten([]) // []
  /// ```
  static List<A> flatten<A>(Iterable<Iterable<A>> arrays) {
    final result = <A>[];
    for (final array in arrays) {
      result.addAll(array);
    }
    return result;
  }

  /// Reduces an array to a single value using the provided function.
  ///
  /// Example:
  /// ```dart
  /// Array.reduce([1, 2, 3, 4], (acc, n) => acc + n) // Some(10)
  /// Array.reduce([], (acc, n) => acc + n) // None()
  /// ```
  static Option<A> reduce<A>(Iterable<A> array, A Function(A, A) f) {
    final list = fromIterable(array);
    if (list.isEmpty) return Option.none();
    
    A acc = list.first;
    for (int i = 1; i < list.length; i++) {
      acc = f(acc, list[i]);
    }
    
    return Option.some(acc);
  }

  /// Folds an array from the left with an initial value.
  ///
  /// Example:
  /// ```dart
  /// Array.foldLeft([1, 2, 3], 0, (acc, n) => acc + n) // 6
  /// Array.foldLeft([], 10, (acc, n) => acc + n) // 10
  /// ```
  static B foldLeft<A, B>(Iterable<A> array, B initial, B Function(B, A) f) {
    B acc = initial;
    for (final element in array) {
      acc = f(acc, element);
    }
    return acc;
  }

  /// Joins array elements into a string using the provided separator.
  ///
  /// Example:
  /// ```dart
  /// Array.join([1, 2, 3], ', ') // '1, 2, 3'
  /// Array.join([], ', ') // ''
  /// ```
  static String join<A>(Iterable<A> array, String separator) {
    return fromIterable(array).join(separator);
  }
}