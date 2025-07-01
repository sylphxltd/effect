# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-01-07

### Added
- Initial release of Effect.dart library
- Core `Effect<Success, Error, Requirements>` type with type-safe error handling
- Basic effect constructors:
  - `Effect.succeed()` - Create successful effects
  - `Effect.fail()` - Create failed effects
  - `Effect.sync()` - Synchronous computations that may throw
  - `Effect.async()` - Asynchronous computations
  - `Effect.service()` - Dependency injection effects
- Effect transformation methods:
  - `map()` - Transform success values
  - `mapError()` - Transform error values
  - `flatMap()` - Chain effects together
  - `catchAll()` - Handle and recover from errors
- Context system for dependency injection:
  - `Context<R>` type for managing services
  - `provideContext()` and `provideService()` for providing dependencies
  - Type-safe service retrieval
- Exit system representing effect results:
  - `Success<A>` and `Failure<E>` exit types
  - `Cause<E>` system for error classification (`Fail` vs `Die`)
- Runtime system for executing effects:
  - `Runtime.defaultRuntime` singleton
  - `runToExit()` for safe execution
  - `runUnsafe()` for throwing execution
  - Concurrent execution with `runConcurrently()` and `runRace()`
  - Fiber system for managing concurrent effects
- Either type for functional error handling:
  - `Either<L, R>` with `Left` and `Right` cases
  - Functional operations like `map`, `flatMap`, `fold`
- Comprehensive test suite covering all major functionality
- Example code demonstrating library usage
- Complete API documentation in README.md
- Melos configuration for project management
- Strict linting rules for code quality

### Features
- **Type Safety**: Complete type safety for success values, errors, and dependencies
- **Lazy Evaluation**: Effects are pure descriptions that don't execute until run
- **Composability**: Chain and combine effects using functional operations
- **Error Handling**: Built-in typed error handling with recovery mechanisms
- **Dependency Injection**: Type-safe context system inspired by Effect-TS
- **Concurrency**: Built-in support for parallel and concurrent execution
- **Resource Management**: Safe resource handling through the effect system

### Documentation
- Comprehensive README with examples and API reference
- Inline documentation for all public APIs
- Working examples in `example/` directory
- Test suite demonstrating usage patterns

### Development
- Melos configuration for monorepo-style development
- Comprehensive linting rules
- Automated testing setup
- Example code for library demonstration

## [Unreleased]

### Planned
- More concurrent combinators (timeout, retry, etc.)
- Resource management with bracket patterns
- Streaming support with Effect streams
- Performance optimizations
- Additional utility functions and combinators