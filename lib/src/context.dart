/// A collection that holds contextual data (services/dependencies) required by effects.
/// 
/// Context uses a type-safe approach where services are identified by their type.
class Context<R> {
  final Map<Type, Object> _services;

  const Context._(this._services);

  /// Creates an empty context
  static Context<Never> empty() => const Context._({});

  /// Creates a context with a single service
  static Context<T> of<T extends Object>(T service) =>
      Context._({T: service});

  /// Adds a service to this context, returning a new context
  Context<R> add<T extends Object>(T service) {
    final newServices = Map<Type, Object>.from(_services);
    newServices[T] = service;
    return Context._(newServices);
  }

  /// Gets a service from this context by its type
  T get<T extends Object>() {
    final service = _services[T];
    if (service == null) {
      throw StateError('Service of type $T not found in context');
    }
    return service as T;
  }

  /// Checks if a service of the given type exists in this context
  bool has<T extends Object>() => _services.containsKey(T);

  /// Returns the number of services in this context
  int get size => _services.length;

  /// Returns true if this context is empty
  bool get isEmpty => _services.isEmpty;

  /// Returns true if this context is not empty
  bool get isNotEmpty => _services.isNotEmpty;

  /// Returns all service types in this context
  Iterable<Type> get serviceTypes => _services.keys;

  /// Combines this context with another context
  /// Services from [other] will override services of the same type in this context
  Context<R> merge(Context other) {
    final newServices = Map<Type, Object>.from(_services);
    newServices.addAll(other._services);
    return Context._(newServices);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Context &&
      _services.length == other._services.length &&
      _services.keys.every((key) => _services[key] == other._services[key]);

  @override
  int get hashCode => _services.hashCode;

  @override
  String toString() {
    if (_services.isEmpty) {
      return 'Context.empty()';
    }
    final entries = _services.entries
        .map((e) => '${e.key}: ${e.value}')
        .join(', ');
    return 'Context($entries)';
  }
}

/// A tag class for creating strongly-typed service identifiers.
/// 
/// This allows for dependency injection patterns similar to Effect-TS.
abstract class Tag<T> {
  const Tag();
  
  /// The service type this tag represents
  Type get serviceType => T;
  
  /// Creates an effect that requires this service from the context
  // Effect<T, Never, T> get service => Effect.service<T>();
}

/// A convenience class for creating service tags with a name.
abstract class NamedTag<T> extends Tag<T> {
  final String name;
  const NamedTag(this.name);
  
  @override
  String toString() => 'Tag($name)';
}