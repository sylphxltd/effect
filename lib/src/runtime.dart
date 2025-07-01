import 'dart:async';
import 'effect.dart';
import 'exit.dart';
import 'context.dart';
import 'cause.dart';
import 'either.dart';

/// The Effect Runtime System that executes effects.
/// 
/// The runtime is responsible for interpreting Effect descriptions into
/// actual side effects and managing their execution.
class Runtime {
  static Runtime? _defaultInstance;

  /// The default runtime instance
  static Runtime get defaultRuntime {
    return _defaultInstance ??= Runtime._();
  }

  Runtime._();

  /// Runs an effect and returns its Exit result
  Future<Exit<A, E>> runToExit<A, E, R>(
    Effect<A, E, R> effect, [
    Context<R>? context,
  ]) async {
    return effect.runToExit(context);
  }

  /// Runs an effect unsafely, throwing on failure
  Future<A> runUnsafe<A, E, R>(
    Effect<A, E, R> effect, [
    Context<R>? context,
  ]) async {
    return effect.runUnsafe(context);
  }

  /// Runs an effect in a fire-and-forget manner
  void runFireAndForget<A, E, R>(
    Effect<A, E, R> effect, [
    Context<R>? context,
  ]) {
    unawaited(effect.runToExit(context));
  }

  /// Runs an effect and handles success/failure with callbacks
  Future<void> runWithCallbacks<A, E, R>(
    Effect<A, E, R> effect, {
    void Function(A)? onSuccess,
    void Function(E)? onFailure,
    void Function(Object)? onDefect,
    Context<R>? context,
  }) async {
    final exit = await effect.runToExit(context);
    
    switch (exit) {
      case Success(:final value):
        onSuccess?.call(value);
      case Failure(:final cause):
        switch (cause) {
          case Fail(:final error):
            onFailure?.call(error);
          case Die(:final throwable):
            onDefect?.call(throwable);
        }
    }
  }

  /// Runs multiple effects concurrently and returns when all complete
  Future<List<Exit<A, E>>> runConcurrently<A, E, R>(
    List<Effect<A, E, R>> effects, [
    Context<R>? context,
  ]) async {
    final futures = effects.map((effect) => effect.runToExit(context));
    return await Future.wait(futures);
  }

  /// Runs multiple effects concurrently and returns the first successful result
  Future<Exit<A, E>> runRace<A, E, R>(
    List<Effect<A, E, R>> effects, [
    Context<R>? context,
  ]) async {
    if (effects.isEmpty) {
      throw ArgumentError('Cannot race empty list of effects');
    }

    final futures = effects.map((effect) => effect.runToExit(context));
    return await Future.any(futures);
  }

  /// Creates a fiber that can be used to manage concurrent execution
  Fiber<A, E> fork<A, E, R>(
    Effect<A, E, R> effect, [
    Context<R>? context,
  ]) {
    return Fiber._(effect.runToExit(context));
  }
}

/// A fiber represents a lightweight thread of execution for an effect.
/// 
/// Fibers allow for concurrent execution and can be awaited, interrupted,
/// or joined with other fibers.
class Fiber<A, E> {
  final Future<Exit<A, E>> _future;
  final Completer<void>? _interruptCompleter;

  Fiber._(this._future) : _interruptCompleter = null;

  Fiber._interruptible(this._future, this._interruptCompleter);

  /// Awaits the completion of this fiber
  Future<Exit<A, E>> await() => _future;

  /// Joins this fiber, returning the result or throwing on failure
  Future<A> join() async {
    final exit = await _future;
    switch (exit) {
      case Success(:final value):
        return value;
      case Failure(:final cause):
        throw cause.toException();
    }
  }

  /// Interrupts this fiber (if interruptible)
  void interrupt() {
    _interruptCompleter?.complete();
  }

  /// Returns true if this fiber is interruptible
  bool get isInterruptible => _interruptCompleter != null;

  /// Combines this fiber with another fiber, returning when both complete
  Future<(Exit<A, E>, Exit<B, F>)> zip<B, F>(Fiber<B, F> other) async {
    final results = await Future.wait([_future, other._future]);
    return (results[0] as Exit<A, E>, results[1] as Exit<B, F>);
  }

  /// Races this fiber with another, returning the first to complete
  Future<Either<Exit<A, E>, Exit<B, F>>> race<B, F>(Fiber<B, F> other) async {
    final result = await Future.any([
      _future.then((exit) => (0, exit)),
      other._future.then((exit) => (1, exit)),
    ]);

    return switch (result) {
      (0, final Exit<Object?, Object?> exit) => Either.left(exit as Exit<A, E>),
      (1, final Exit<Object?, Object?> exit) => Either.right(exit as Exit<B, F>),
      _ => throw StateError('Unexpected race result'),
    };
  }
}

/// Helper to run effects without explicitly creating a runtime
extension EffectRunner<A, E, R> on Effect<A, E, R> {
  /// Runs this effect using the default runtime
  Future<Exit<A, E>> run([Context<R>? context]) =>
      Runtime.defaultRuntime.runToExit(this, context);

  /// Runs this effect unsafely using the default runtime
  Future<A> runUnsafeWithDefaultRuntime([Context<R>? context]) =>
      Runtime.defaultRuntime.runUnsafe(this, context);

  /// Forks this effect into a fiber using the default runtime
  Fiber<A, E> fork([Context<R>? context]) =>
      Runtime.defaultRuntime.fork(this, context);
}