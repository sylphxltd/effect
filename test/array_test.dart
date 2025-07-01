import 'package:test/test.dart';
import 'package:effect_dart/effect_dart.dart';

void main() {
  group('Array Tests', () {
    group('Basic constructors', () {
      test('of creates single element array', () {
        expect(Array.of(1), equals([1]));
        expect(Array.of('hello'), equals(['hello']));
        expect(Array.of(null), equals([null]));
      });

      test('empty creates empty array', () {
        expect(Array.empty<int>(), equals(<int>[]));
        expect(Array.empty<String>(), equals(<String>[]));
      });

      test('fromIterable returns same reference if input is already Array', () {
        final list = [1, 2, 3];
        expect(identical(Array.fromIterable(list), list), isTrue);
      });

      test('fromIterable converts Set to Array', () {
        expect(Array.fromIterable({1, 2, 3}), equals([1, 2, 3]));
      });

      test('ensure wraps non-array values', () {
        expect(Array.ensure(1), equals([1]));
        expect(Array.ensure(null), equals([null]));
      });

      test('ensure returns array as-is', () {
        expect(Array.ensure([1]), equals([1]));
        expect(Array.ensure([1, 2]), equals([1, 2]));
      });

      test('ensure with non-array iterables', () {
        final set = {1, 2};
        expect(Array.ensure(set), equals([set])); // Wraps the Set itself
      });
    });

    group('prepend and append', () {
      test('prepend adds element to beginning', () {
        expect(Array.prepend([1, 2, 3], 0), equals([0, 1, 2, 3]));
        expect(Array.prepend([[2]], [1]), equals([[1], [2]]));
        expect(Array.prepend({1, 2, 3}, 0), equals([0, 1, 2, 3]));
        expect(Array.prepend({[2]}, [1]), equals([[1], [2]]));
      });

      test('append adds element to end', () {
        expect(Array.append([1, 2, 3], 4), equals([1, 2, 3, 4]));
        expect(Array.append([[1]], [2]), equals([[1], [2]]));
        expect(Array.append({1, 2, 3}, 4), equals([1, 2, 3, 4]));
        expect(Array.append({[1]}, [2]), equals([[1], [2]]));
      });

      test('prependAll adds all elements to beginning', () {
        expect(Array.prependAll([3, 4], [1, 2]), equals([1, 2, 3, 4]));
        expect(Array.prependAll([3, 4], {1, 2}), equals([1, 2, 3, 4]));
        expect(Array.prependAll({3, 4}, [1, 2]), equals([1, 2, 3, 4]));
      });

      test('appendAll adds all elements to end', () {
        expect(Array.appendAll([1, 2], [3, 4]), equals([1, 2, 3, 4]));
        expect(Array.appendAll([1, 2], {3, 4}), equals([1, 2, 3, 4]));
        expect(Array.appendAll({1, 2}, [3, 4]), equals([1, 2, 3, 4]));
      });
    });

    group('tail and init', () {
      test('tail returns all elements except first', () {
        final result1 = Array.tail([1, 2, 3]);
        expect(result1.isSome, isTrue);
        expect(result1.getOrElse([]), equals([2, 3]));

        final result2 = Array.tail(<int>[]);
        expect(result2.isNone, isTrue);

        final result3 = Array.tail({1, 2, 3});
        expect(result3.isSome, isTrue);
        expect(result3.getOrElse([]), equals([2, 3]));
      });

      test('init returns all elements except last', () {
        final result1 = Array.init([1, 2, 3]);
        expect(result1.isSome, isTrue);
        expect(result1.getOrElse([]), equals([1, 2]));

        final result2 = Array.init(<int>[]);
        expect(result2.isNone, isTrue);

        final result3 = Array.init({1, 2, 3});
        expect(result3.isSome, isTrue);
        expect(result3.getOrElse([]), equals([1, 2]));
      });
    });

    group('take operations', () {
      test('take returns first n elements', () {
        expect(Array.take([1, 2, 3, 4], 2), equals([1, 2]));
        expect(Array.take([1, 2, 3, 4], 0), equals([]));
        expect(Array.take([1, 2, 3, 4], -10), equals([]));
        expect(Array.take([1, 2, 3, 4], 10), equals([1, 2, 3, 4]));

        expect(Array.take({1, 2, 3, 4}, 2), equals([1, 2]));
        expect(Array.take({1, 2, 3, 4}, 0), equals([]));
        expect(Array.take({1, 2, 3, 4}, -10), equals([]));
        expect(Array.take({1, 2, 3, 4}, 10), equals([1, 2, 3, 4]));
      });

      test('takeRight returns last n elements', () {
        expect(Array.takeRight(<int>[], 0), equals([]));
        expect(Array.takeRight([1, 2], 0), equals([]));
        expect(Array.takeRight([1, 2], 1), equals([2]));
        expect(Array.takeRight([1, 2], 2), equals([1, 2]));
        expect(Array.takeRight(<int>[], 1), equals([]));
        expect(Array.takeRight(<int>[], -1), equals([]));
        expect(Array.takeRight([1, 2], 3), equals([1, 2]));
        expect(Array.takeRight([1, 2], -1), equals([]));

        expect(Array.takeRight(<int>{}, 0), equals([]));
        expect(Array.takeRight({1, 2}, 0), equals([]));
        expect(Array.takeRight({1, 2}, 1), equals([2]));
        expect(Array.takeRight({1, 2}, 2), equals([1, 2]));
        expect(Array.takeRight(<int>{}, 1), equals([]));
        expect(Array.takeRight(<int>{}, -1), equals([]));
        expect(Array.takeRight({1, 2}, 3), equals([1, 2]));
        expect(Array.takeRight({1, 2}, -1), equals([]));
      });
    });

    group('drop operations', () {
      test('takeWhile takes elements while predicate is true', () {
        bool isEven(int n) => n % 2 == 0;
        expect(Array.takeWhile([2, 4, 3, 6], isEven), equals([2, 4]));
        expect(Array.takeWhile(<int>[], isEven), equals([]));
        expect(Array.takeWhile([1, 2, 4], isEven), equals([]));
        expect(Array.takeWhile([2, 4], isEven), equals([2, 4]));

        expect(Array.takeWhile({2, 4, 3, 6}, isEven), equals([2, 4]));
        expect(Array.takeWhile(<int>{}, isEven), equals([]));
        expect(Array.takeWhile({1, 2, 4}, isEven), equals([]));
        expect(Array.takeWhile({2, 4}, isEven), equals([2, 4]));
      });

      test('drop removes first n elements', () {
        expect(Array.drop(<int>[], 0), equals([]));
        expect(Array.drop([1, 2], 0), equals([1, 2]));
        expect(Array.drop([1, 2], 1), equals([2]));
        expect(Array.drop([1, 2], 2), equals([]));
        expect(Array.drop(<int>[], 1), equals([]));
        expect(Array.drop(<int>[], -1), equals([]));
        expect(Array.drop([1, 2], 3), equals([]));
        expect(Array.drop([1, 2], -1), equals([1, 2]));

        expect(Array.drop(<int>{}, 0), equals([]));
        expect(Array.drop({1, 2}, 0), equals([1, 2]));
        expect(Array.drop({1, 2}, 1), equals([2]));
        expect(Array.drop({1, 2}, 2), equals([]));
        expect(Array.drop(<int>{}, 1), equals([]));
        expect(Array.drop(<int>{}, -1), equals([]));
        expect(Array.drop({1, 2}, 3), equals([]));
        expect(Array.drop({1, 2}, -1), equals([1, 2]));
      });

      test('dropRight removes last n elements', () {
        expect(Array.dropRight([], 0), equals([]));
        expect(Array.dropRight([1, 2], 0), equals([1, 2]));
        expect(Array.dropRight([1, 2], 1), equals([1]));
        expect(Array.dropRight([1, 2], 2), equals([]));
        expect(Array.dropRight([], 1), equals([]));
        expect(Array.dropRight([1, 2], 3), equals([]));
        expect(Array.dropRight([], -1), equals([]));
        expect(Array.dropRight([1, 2], -1), equals([1, 2]));

        expect(Array.dropRight(<int>{}, 0), equals([]));
        expect(Array.dropRight({1, 2}, 0), equals([1, 2]));
        expect(Array.dropRight({1, 2}, 1), equals([1]));
        expect(Array.dropRight({1, 2}, 2), equals([]));
        expect(Array.dropRight(<int>{}, 1), equals([]));
        expect(Array.dropRight({1, 2}, 3), equals([]));
        expect(Array.dropRight(<int>{}, -1), equals([]));
        expect(Array.dropRight({1, 2}, -1), equals([1, 2]));
      });

      test('dropWhile removes elements while predicate is true', () {
        bool isPositive(int n) => n > 0;
        expect(Array.dropWhile(<int>[], isPositive), equals(<int>[]));
        expect(Array.dropWhile([1, 2], isPositive), equals(<int>[]));
        expect(Array.dropWhile([-1, -2], isPositive), equals([-1, -2]));
        expect(Array.dropWhile([-1, 2], isPositive), equals([-1, 2]));
        expect(Array.dropWhile([1, -2, 3], isPositive), equals([-2, 3]));

        expect(Array.dropWhile(<int>{}, isPositive), equals(<int>[]));
        expect(Array.dropWhile({1, 2}, isPositive), equals(<int>[]));
        expect(Array.dropWhile({-1, -2}, isPositive), equals([-1, -2]));
        expect(Array.dropWhile({-1, 2}, isPositive), equals([-1, 2]));
        expect(Array.dropWhile({1, -2, 3}, isPositive), equals([-2, 3]));
      });
    });

    group('basic operations', () {
      test('reverse reverses array', () {
        expect(Array.reverse([]), equals([]));
        expect(Array.reverse([1]), equals([1]));
        expect(Array.reverse([1, 2, 3]), equals([3, 2, 1]));

        expect(Array.reverse(<int>{}), equals([]));
        expect(Array.reverse({1}), equals([1]));
        expect(Array.reverse({1, 2, 3}), equals([3, 2, 1]));
      });

      test('get retrieves element at index', () {
        final result1 = Array.get([1, 2, 3], 0);
        expect(result1.isSome, isTrue);
        expect(result1.getOrElse(0), equals(1));

        final result2 = Array.get([1, 2, 3], 3);
        expect(result2.isNone, isTrue);

        final result3 = Array.get([1, 2, 3], -1);
        expect(result3.isNone, isTrue);
      });

      test('head gets first element', () {
        final result1 = Array.head([1, 2, 3]);
        expect(result1.isSome, isTrue);
        expect(result1.getOrElse(0), equals(1));

        final result2 = Array.head(<int>[]);
        expect(result2.isNone, isTrue);
      });

      test('last gets last element', () {
        final result1 = Array.last([1, 2, 3]);
        expect(result1.isSome, isTrue);
        expect(result1.getOrElse(0), equals(3));

        final result2 = Array.last(<int>[]);
        expect(result2.isNone, isTrue);
      });

      test('isEmpty checks if array is empty', () {
        expect(Array.isEmpty([]), isTrue);
        expect(Array.isEmpty([1]), isFalse);
        expect(Array.isEmpty({1, 2, 3}), isFalse);
      });

      test('isNotEmpty checks if array is not empty', () {
        expect(Array.isNotEmpty([1]), isTrue);
        expect(Array.isNotEmpty([]), isFalse);
        expect(Array.isNotEmpty({1, 2, 3}), isTrue);
      });

      test('length returns array length', () {
        expect(Array.length([]), equals(0));
        expect(Array.length([1]), equals(1));
        expect(Array.length([1, 2, 3]), equals(3));
        expect(Array.length({1, 2, 3}), equals(3));
      });
    });

    group('functional operations', () {
      test('map transforms elements', () {
        expect(Array.map([1, 2, 3], (n) => n * 2), equals([2, 4, 6]));
        expect(Array.map(<int>[], (n) => n * 2), equals(<int>[]));
        expect(Array.map(['a', 'b'], (s) => s.toUpperCase()), equals(['A', 'B']));

        expect(Array.map({1, 2, 3}, (n) => n * 2), equals([2, 4, 6]));
        expect(Array.map(<int>{}, (n) => n * 2), equals(<int>[]));
        expect(Array.map({'a', 'b'}, (s) => s.toUpperCase()), equals(['A', 'B']));
      });

      test('filter keeps elements that satisfy predicate', () {
        expect(Array.filter([1, 2, 3, 4], (n) => n % 2 == 0), equals([2, 4]));
        expect(Array.filter(<int>[], (n) => n % 2 == 0), equals(<int>[]));
        expect(Array.filter([1, 3, 5], (n) => n % 2 == 0), equals(<int>[]));

        expect(Array.filter({1, 2, 3, 4}, (n) => n % 2 == 0), equals([2, 4]));
        expect(Array.filter(<int>{}, (n) => n % 2 == 0), equals(<int>[]));
        expect(Array.filter({1, 3, 5}, (n) => n % 2 == 0), equals(<int>[]));
      });

      test('find returns first element that satisfies predicate', () {
        final result1 = Array.find([1, 2, 3, 4], (n) => n % 2 == 0);
        expect(result1.isSome, isTrue);
        expect(result1.getOrElse(0), equals(2));

        final result2 = Array.find([1, 3, 5], (n) => n % 2 == 0);
        expect(result2.isNone, isTrue);

        final result3 = Array.find(<int>[], (n) => n % 2 == 0);
        expect(result3.isNone, isTrue);
      });

      test('contains checks if element exists', () {
        expect(Array.contains([1, 2, 3], 2), isTrue);
        expect(Array.contains([1, 2, 3], 4), isFalse);
        expect(Array.contains(<int>[], 1), isFalse);

        expect(Array.contains({1, 2, 3}, 2), isTrue);
        expect(Array.contains({1, 2, 3}, 4), isFalse);
        expect(Array.contains(<int>{}, 1), isFalse);
      });

      test('some checks if any element satisfies predicate', () {
        expect(Array.some([1, 2, 3], (n) => n % 2 == 0), isTrue);
        expect(Array.some([1, 3, 5], (n) => n % 2 == 0), isFalse);
        expect(Array.some(<int>[], (n) => n % 2 == 0), isFalse);

        expect(Array.some({1, 2, 3}, (n) => n % 2 == 0), isTrue);
        expect(Array.some({1, 3, 5}, (n) => n % 2 == 0), isFalse);
        expect(Array.some(<int>{}, (n) => n % 2 == 0), isFalse);
      });

      test('every checks if all elements satisfy predicate', () {
        expect(Array.every([2, 4, 6], (n) => n % 2 == 0), isTrue);
        expect(Array.every([1, 2, 3], (n) => n % 2 == 0), isFalse);
        expect(Array.every(<int>[], (n) => n % 2 == 0), isTrue);

        expect(Array.every({2, 4, 6}, (n) => n % 2 == 0), isTrue);
        expect(Array.every({1, 2, 3}, (n) => n % 2 == 0), isFalse);
        expect(Array.every(<int>{}, (n) => n % 2 == 0), isTrue);
      });

      test('partition splits array based on predicate', () {
        final (evens, odds) = Array.partition([1, 2, 3, 4], (n) => n % 2 == 0);
        expect(evens, equals([2, 4]));
        expect(odds, equals([1, 3]));

        final (empty1, empty2) = Array.partition(<int>[], (n) => n % 2 == 0);
        expect(empty1, equals(<int>[]));
        expect(empty2, equals(<int>[]));

        final (allTrue, allFalse) = Array.partition([2, 4], (n) => n % 2 == 0);
        expect(allTrue, equals([2, 4]));
        expect(allFalse, equals(<int>[]));
      });
    });

    group('combination operations', () {
      test('zip combines two arrays into tuples', () {
        final result1 = Array.zip([1, 2, 3], ['a', 'b', 'c']);
        expect(result1, equals([(1, 'a'), (2, 'b'), (3, 'c')]));

        final result2 = Array.zip([1, 2], ['a', 'b', 'c']);
        expect(result2, equals([(1, 'a'), (2, 'b')]));

        final result3 = Array.zip([1, 2, 3], ['a']);
        expect(result3, equals([(1, 'a')]));

        final result4 = Array.zip(<int>[], ['a', 'b']);
        expect(result4, equals(<(int, String)>[]));

        final result5 = Array.zip({1, 2, 3}, {'a', 'b', 'c'});
        expect(result5, equals([(1, 'a'), (2, 'b'), (3, 'c')]));
      });

      test('flatten converts nested arrays to single array', () {
        expect(Array.flatten([[1, 2], [3, 4], [5]]), equals([1, 2, 3, 4, 5]));
        expect(Array.flatten(<List<int>>[]), equals(<int>[]));
        expect(Array.flatten([[1, 2]]), equals([1, 2]));
        expect(Array.flatten([<int>[], [1, 2]]), equals([1, 2]));

        expect(Array.flatten([{1, 2}, {3, 4}, {5}]), equals([1, 2, 3, 4, 5]));
      });

      test('reduce combines array elements into single value', () {
        final result1 = Array.reduce([1, 2, 3, 4], (acc, n) => acc + n);
        expect(result1.isSome, isTrue);
        expect(result1.getOrElse(0), equals(10));

        final result2 = Array.reduce(<int>[], (acc, n) => acc + n);
        expect(result2.isNone, isTrue);

        final result3 = Array.reduce([5], (acc, n) => acc + n);
        expect(result3.isSome, isTrue);
        expect(result3.getOrElse(0), equals(5));

        final result4 = Array.reduce(['a', 'b', 'c'], (acc, s) => acc + s);
        expect(result4.isSome, isTrue);
        expect(result4.getOrElse(''), equals('abc'));
      });

      test('foldLeft accumulates with initial value', () {
        expect(Array.foldLeft([1, 2, 3], 0, (acc, n) => acc + n), equals(6));
        expect(Array.foldLeft(<int>[], 10, (acc, n) => acc + n), equals(10));
        expect(Array.foldLeft([1, 2, 3], 1, (acc, n) => acc * n), equals(6));

        expect(Array.foldLeft({1, 2, 3}, 0, (acc, n) => acc + n), equals(6));
        expect(Array.foldLeft(<int>{}, 10, (acc, n) => acc + n), equals(10));
        expect(Array.foldLeft({1, 2, 3}, 1, (acc, n) => acc * n), equals(6));
      });

      test('join creates string from array elements', () {
        expect(Array.join([1, 2, 3], ', '), equals('1, 2, 3'));
        expect(Array.join(<int>[], ', '), equals(''));
        expect(Array.join(['a', 'b', 'c'], '-'), equals('a-b-c'));
        expect(Array.join([1], ', '), equals('1'));

        expect(Array.join({1, 2, 3}, ', '), equals('1, 2, 3'));
        expect(Array.join(<int>{}, ', '), equals(''));
        expect(Array.join({'a', 'b', 'c'}, '-'), equals('a-b-c'));
        expect(Array.join({1}, ', '), equals('1'));
      });
    });
  });
}