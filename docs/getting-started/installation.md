# Installation

Getting started with Effect Dart is simple. Follow these steps to add Effect Dart to your project.

## Prerequisites

- Dart SDK 3.0.0 or higher
- A Dart or Flutter project

## Add Dependency

Add Effect Dart to your `pubspec.yaml` file:

```yaml
dependencies:
  effect_dart: ^0.1.0
```

Then run:

```bash
dart pub get
```

Or if you're using Flutter:

```bash
flutter pub get
```

## Import the Library

Import Effect Dart in your Dart files:

```dart
import 'package:effect_dart/effect_dart.dart';
```

## Verify Installation

Create a simple test to verify everything is working:

```dart
import 'package:effect_dart/effect_dart.dart';

void main() async {
  // Create a simple effect
  final effect = Effect.succeed("Hello, Effect Dart!");
  
  // Run the effect
  final result = await effect.runUnsafe();
  
  print(result); // Prints: Hello, Effect Dart!
}
```

## Development Dependencies

For testing and development, you might also want to add:

```yaml
dev_dependencies:
  test: ^1.24.0
  # Other dev dependencies...
```

## IDE Support

Effect Dart works with any Dart-compatible IDE:

- **VS Code**: Install the Dart extension for full language support
- **IntelliJ IDEA/Android Studio**: Dart plugin provides excellent support
- **Vim/Neovim**: Use the Dart language server

## Next Steps

Now that you have Effect Dart installed, you can:

- Learn about [The Effect Type](./effect-type)
- Start [Creating Effects](./creating-effects)
- Explore [Running Effects](./running-effects)

## Troubleshooting

### Version Conflicts

If you encounter version conflicts, try:

```bash
dart pub deps
```

This will show you the dependency tree and help identify conflicts.

### Import Issues

Make sure you're importing from the correct package:

```dart
// Correct
import 'package:effect_dart/effect_dart.dart';

// Incorrect
import 'package:effect_dart/src/effect.dart'; // Don't import from src/
```

### Minimum Dart Version

Effect Dart requires Dart 3.0.0 or higher. Check your Dart version:

```bash
dart --version
```

If you need to upgrade:

```bash
# Using Dart SDK directly
dart upgrade

# Using Flutter (includes Dart)
flutter upgrade