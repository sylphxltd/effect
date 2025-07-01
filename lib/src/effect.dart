import 'dart:async';
import 'context.dart';
import 'exit.dart';
import 'cause.dart';
import 'either.dart';

/// The Effect type represents an immutable description of a workflow or operation
/// that is lazily executed.
/// 
/// Type parameters:
/// - [A] (Success): The type of value that an effect can succeed with
/// - [E] (Error): The type of expected errors that can occur
/// - [R] (Requirements): The contextual data required by the effect
abstract class Effect<A, E, R> {
  const Effect();

  /// Creates an effect that succeeds with the given value
  static Effect<A, Never, Never> succeed<A>(A value) => _Succeed(value);

  /// Creates an effect that fails with the given error
  static Effect<Never, E, Never> fail<E>(E error) => _Fail(error);

  /// Creates an effect that dies with the given throwable
  static Effect<Never, Never, Never> die(Object throwable) => _Die(throwable);

  /// Creates an effect from a synchronous computation that might throw
  static Effect<A, Object, Never> sync<A>(A Function() computation) =>
      _Sync(computation);

  /// Creates an effect from an asynchronous computation
  static Effect<A, Object, Never> async<A>(Future<A> Function() computation) =>
      _Async(computation);

  /// Creates an effect from a Promise/Future
  static Effect<A, Object, Never> promise<A>(Future<A> Function() computation) =>
      _Async(computation);

  /// Creates an effect that suspends computation
  static Effect<A, E, R> suspend<A, E, R>(Effect<A, E, R> Function() computation) =>
      _Suspend(computation);

  /// Creates an effect that requires a specific service from the context
  static Effect<A, Never, A> service<A extends Object>() => _Service<A>();

  /// Creates an effect from an Iterable generator (like Effect-TS yield*)
  /// This allows you to yield Effects in a functional way using sync* and yield*
  static Effect<A, Object, Never> gen<A>(
    Iterable<Effect> Function() generator
  ) => _IterableGen(generator);

  /// Maps the success value of this effect
  Effect<B, E, R> map<B>(B Function(A) f) => _Map(this, f);

  /// Maps the error value of this effect
  Effect<A, E2, R> mapError<E2>(E2 Function(E) f) => _MapError(this, f);

  /// Flat maps this effect with another effect
  Effect<B, E2, R2> flatMap<B, E2, R2>(
    Effect<B, E2, R2> Function(A) f,
  ) => _FlatMap(this, f);

  /// Catches and recovers from errors
  Effect<A, E2, R2> catchAll<E2, R2>(
    Effect<A, E2, R2> Function(E) f,
  ) => _CatchAll(this, f);

  /// Provides the required context to this effect
  Effect<A, E, Never> provideContext(Context<R> context) =>
      _ProvideContext(this, context);

  /// Provides a specific service to this effect
  Effect<A, E, R2> provideService<S extends Object, R2>(
    S service,
  ) => _ProvideService<A, E, R, S, R2>(this, service);

  /// Adds a span for tracing
  Effect<A, E, R> withSpan(String spanName) => _WithSpan(this, spanName);

  /// Pipes this effect through a function
  B pipe<B>(B Function(Effect<A, E, R>) f) => f(this);

  /// Gets the exit of this effect
  Effect<Exit<A, E>, Never, R> exit() => _Exit(this);

  /// Sandboxes this effect to expose all failures as typed errors
  Effect<A, Cause<E>, R> sandbox() => _Sandbox(this);

  /// Converts this effect to an Either
  Effect<Either<E, A>, Never, R> either() => _Either(this);

  /// Runs this effect and returns an Exit
  Future<Exit<A, E>> runToExit([Context<R>? context]);

  /// Runs this effect synchronously and returns an Exit
  static Exit<A, E> runSyncExit<A, E, R>(Effect<A, E, R> effect) {
    try {
      // For sync effects, we can run them immediately
      if (effect is _Succeed<A>) {
        return Exit.succeed(effect.value);
      }
      if (effect is _Fail<E>) {
        return Exit.fail(effect.error);
      }
      if (effect is _Die) {
        return Exit.die(effect.throwable);
      }
      if (effect is _Sync) {
        try {
          final result = (effect as _Sync).computation();
          return Exit.succeed(result) as Exit<A, E>;
        } catch (e) {
          return Exit.die(e) as Exit<A, E>;
        }
      }
      if (effect is _WithSpan) {
        final spanEffect = effect as _WithSpan;
        final innerExit = runSyncExit(spanEffect.effect);
        return switch (innerExit) {
          Success() => innerExit as Exit<A, E>,
          Failure(:final cause) => switch (cause) {
            Fail() => innerExit as Exit<A, E>,
            Die(:final throwable) => Exit.die('${spanEffect.spanName}: $throwable') as Exit<A, E>,
          },
        };
      }
      // For async effects, this should be a defect
      return Exit.die('Cannot run async effect synchronously') as Exit<A, E>;
    } catch (e) {
      return Exit.die(e) as Exit<A, E>;
    }
  }

  /// Runs this effect as a Promise/Future
  static Future<A> runPromise<A, E, R>(Effect<A, E, R> effect) async {
    final exit = await effect.runToExit();
    return exit.fold(
      (cause) => throw cause.toException(),
      (value) => value,
    );
  }

  /// Runs this effect unsafely, throwing on failure
  Future<A> runUnsafe([Context<R>? context]) async {
    final exit = await runToExit(context);
    return switch (exit) {
      Success(:final value) => value,
      Failure(:final cause) => throw cause.toException(),
    };
  }
}

// Internal effect implementations

class _Succeed<A> extends Effect<A, Never, Never> {
  final A value;
  const _Succeed(this.value);

  @override
  Future<Exit<A, Never>> runToExit([Context<Never>? context]) async =>
      Exit.succeed(value);
}

class _Fail<E> extends Effect<Never, E, Never> {
  final E error;
  const _Fail(this.error);

  @override
  Future<Exit<Never, E>> runToExit([Context<Never>? context]) async =>
      Exit.fail(error);
}

class _Die extends Effect<Never, Never, Never> {
  final Object throwable;
  const _Die(this.throwable);

  @override
  Future<Exit<Never, Never>> runToExit([Context<Never>? context]) async =>
      Exit.die(throwable);
}

class _Sync<A> extends Effect<A, Object, Never> {
  final A Function() computation;
  const _Sync(this.computation);

  @override
  Future<Exit<A, Object>> runToExit([Context<Never>? context]) async {
    try {
      return Exit.succeed(computation());
    } catch (e) {
      return Exit.die(e);
    }
  }
}

class _Async<A> extends Effect<A, Object, Never> {
  final Future<A> Function() computation;
  const _Async(this.computation);

  @override
  Future<Exit<A, Object>> runToExit([Context<Never>? context]) async {
    try {
      final result = await computation();
      return Exit.succeed(result);
    } catch (e) {
      return Exit.die(e);
    }
  }
}

class _Service<A extends Object> extends Effect<A, Never, A> {
  const _Service();

  @override
  Future<Exit<A, Never>> runToExit([Context<A>? context]) async {
    if (context == null) {
      throw StateError('Service $A not provided in context');
    }
    final service = context.get<A>();
    return Exit.succeed(service);
  }
}

class _IterableGen<A> extends Effect<A, Object, Never> {
  final Iterable<Effect> Function() generator;
  const _IterableGen(this.generator);

  @override
  Future<Exit<A, Object>> runToExit([Context<Never>? context]) async {
    try {
      A? result;
      for (final effect in generator()) {
        final exit = await effect.runToExit(context);
        if (exit.isFailure) {
          return exit as Exit<A, Object>;
        }
        // Store the last successful result
        result = exit.fold(
          (cause) => throw EffectException(cause),
          (value) => value as A,
        );
      }
      if (result == null) {
        throw StateError('Generator produced no result');
      }
      return Exit.succeed(result);
    } catch (e) {
      return Exit.die(e);
    }
  }
}

class _Map<A, B, E, R> extends Effect<B, E, R> {
  final Effect<A, E, R> effect;
  final B Function(A) f;
  const _Map(this.effect, this.f);

  @override
  Future<Exit<B, E>> runToExit([Context<R>? context]) async {
    final exit = await effect.runToExit(context);
    return exit.map(f);
  }
}

class _MapError<A, E, E2, R> extends Effect<A, E2, R> {
  final Effect<A, E, R> effect;
  final E2 Function(E) f;
  const _MapError(this.effect, this.f);

  @override
  Future<Exit<A, E2>> runToExit([Context<R>? context]) async {
    final exit = await effect.runToExit(context);
    return exit.mapError(f);
  }
}

class _FlatMap<A, B, E, E2, R, R2> extends Effect<B, E2, R2> {
  final Effect<A, E, R> effect;
  final Effect<B, E2, R2> Function(A) f;
  const _FlatMap(this.effect, this.f);

  @override
  Future<Exit<B, E2>> runToExit([Context<R2>? context]) async {
    final exit = await effect.runToExit(context as Context<R>?);
    return switch (exit) {
      Success(:final value) => await f(value).runToExit(context),
      Failure(:final cause) => switch (cause) {
        Fail(:final error) => Exit.die('FlatMap error conversion: $error'),
        Die(:final throwable, :final stackTrace) => Exit.die(throwable, stackTrace),
      },
    };
  }
}

class _CatchAll<A, E, E2, R, R2> extends Effect<A, E2, R2> {
  final Effect<A, E, R> effect;
  final Effect<A, E2, R2> Function(E) f;
  const _CatchAll(this.effect, this.f);

  @override
  Future<Exit<A, E2>> runToExit([Context<R2>? context]) async {
    final exit = await effect.runToExit(context as Context<R>?);
    return switch (exit) {
      Success() => exit as Exit<A, E2>,
      Failure(:final cause) => switch (cause) {
        Fail(:final error) => await f(error).runToExit(context),
        _ => Exit.failCause(cause as Cause<E2>),
      },
    };
  }
}

class _ProvideContext<A, E, R> extends Effect<A, E, Never> {
  final Effect<A, E, R> effect;
  final Context<R> context;
  const _ProvideContext(this.effect, this.context);

  @override
  Future<Exit<A, E>> runToExit([Context<Never>? _]) async =>
      effect.runToExit(context);
}

class _ProvideService<A, E, R, S extends Object, R2> extends Effect<A, E, R2> {
  final Effect<A, E, R> effect;
  final S service;
  const _ProvideService(this.effect, this.service);

  @override
  Future<Exit<A, E>> runToExit([Context<R2>? context]) async {
    final newContext = (context ?? Context.empty()).add(service);
    return effect.runToExit(newContext as Context<R>);
  }
}

/// Utility class for extracting types from Effect
extension EffectTypes<A, E, R> on Effect<A, E, R> {
  /// Extract the success type
  Type get successType => A;
  
  /// Extract the error type  
  Type get errorType => E;
  
  /// Extract the requirements type
  Type get requirementsType => R;
}

/// Extension to make Effects awaitable within Effect.gen
extension EffectAwaitable<A, E, R> on Effect<A, E, R> {
  /// Allows this Effect to be awaited within Effect.gen
  Future<A> call() async {
    final exit = await runToExit();
    return exit.fold(
      (cause) => throw EffectException(cause),
      (value) => value,
    );
  }
}

/// Exception thrown when an Effect fails within Effect.gen
class EffectException implements Exception {
  final Cause cause;
  EffectException(this.cause);
  
  @override
  String toString() => 'EffectException: $cause';
}

// Additional implementation classes

class _Suspend<A, E, R> extends Effect<A, E, R> {
  final Effect<A, E, R> Function() computation;
  const _Suspend(this.computation);

  @override
  Future<Exit<A, E>> runToExit([Context<R>? context]) async {
    try {
      final effect = computation();
      return await effect.runToExit(context);
    } catch (e) {
      return Exit.die(e) as Exit<A, E>;
    }
  }
}

class _WithSpan<A, E, R> extends Effect<A, E, R> {
  final Effect<A, E, R> effect;
  final String spanName;
  const _WithSpan(this.effect, this.spanName);

  @override
  Future<Exit<A, E>> runToExit([Context<R>? context]) async {
    final exit = await effect.runToExit(context);
    return switch (exit) {
      Success() => exit,
      Failure(:final cause) => switch (cause) {
        Fail() => exit,
        Die(:final throwable) => Exit.die('$spanName: $throwable') as Exit<A, E>,
      },
    };
  }
}

class _Exit<A, E, R> extends Effect<Exit<A, E>, Never, R> {
  final Effect<A, E, R> effect;
  const _Exit(this.effect);

  @override
  Future<Exit<Exit<A, E>, Never>> runToExit([Context<R>? context]) async {
    final exit = await effect.runToExit(context);
    return Exit.succeed(exit);
  }
}

class _Sandbox<A, E, R> extends Effect<A, Cause<E>, R> {
  final Effect<A, E, R> effect;
  const _Sandbox(this.effect);

  @override
  Future<Exit<A, Cause<E>>> runToExit([Context<R>? context]) async {
    final exit = await effect.runToExit(context);
    return switch (exit) {
      Success(:final value) => Exit.succeed(value),
      Failure(:final cause) => Exit.fail(cause),
    };
  }
}

class _Either<A, E, R> extends Effect<Either<E, A>, Never, R> {
  final Effect<A, E, R> effect;
  const _Either(this.effect);

  @override
  Future<Exit<Either<E, A>, Never>> runToExit([Context<R>? context]) async {
    final exit = await effect.runToExit(context);
    return switch (exit) {
      Success(:final value) => Exit.succeed(Either.right(value)),
      Failure(:final cause) => switch (cause) {
        Fail(:final error) => Exit.succeed(Either.left(error)),
        Die() => Exit.die(cause.throwable),
      },
    };
  }
}