# Effect Dart Documentation

This directory contains the VitePress documentation for Effect Dart.

## Getting Started

### Prerequisites

- Node.js 18+ 
- npm or yarn

### Installation

```bash
# Install dependencies
npm install

# Start development server
npm run docs:dev

# Build for production
npm run docs:build

# Preview production build
npm run docs:preview
```

## Documentation Structure

```
docs/
├── .vitepress/
│   └── config.js          # VitePress configuration
├── index.md               # Homepage
├── getting-started/       # Getting started guides
│   ├── index.md          # Introduction
│   ├── why-effect.md     # Why use Effect?
│   ├── installation.md   # Installation guide
│   ├── effect-type.md    # The Effect type
│   ├── creating-effects.md # Creating effects
│   └── running-effects.md # Running effects
├── data-types/           # Data type documentation
│   ├── either.md         # Either type
│   ├── option.md         # Option type
│   └── big-decimal.md    # BigDecimal type
└── ...                   # Other sections
```

## Writing Documentation

### Markdown Guidelines

- Use clear, descriptive headings
- Include code examples for all concepts
- Provide real-world usage examples
- Use proper syntax highlighting for Dart code
- Include API reference sections

### Code Examples

Always include working code examples:

```dart
// Good: Complete, runnable example
import 'package:effect_dart/effect_dart.dart';

void main() async {
  final effect = Effect.succeed(42);
  final result = await effect.runUnsafe();
  print(result); // 42
}
```

### Cross-References

Use relative links to reference other documentation:

```markdown
See [The Effect Type](./effect-type) for more details.
```

## VitePress Configuration

The main configuration is in `docs/.vitepress/config.js`. Key sections:

- **Navigation**: Top-level navigation menu
- **Sidebar**: Hierarchical sidebar navigation
- **Theme**: Styling and layout options

## Deployment

The documentation can be deployed to:

- GitHub Pages
- Netlify
- Vercel
- Any static hosting service

Build the documentation:

```bash
npm run docs:build
```

The built files will be in `docs/.vitepress/dist/`.

## Contributing

When adding new documentation:

1. Create the markdown file in the appropriate directory
2. Add the page to the sidebar configuration in `config.js`
3. Follow the existing style and structure
4. Include comprehensive examples
5. Test locally before committing

## Troubleshooting

### Common Issues

**VitePress won't start:**
- Ensure Node.js 18+ is installed
- Delete `node_modules` and `package-lock.json`, then run `npm install`
- Check for ESM compatibility issues

**Missing dependencies:**
```bash
# Clean install
rm -rf node_modules package-lock.json
npm install
```

**Windows-specific issues:**
- Use PowerShell or Command Prompt
- Ensure proper file permissions
- Install Windows Build Tools if needed

### Getting Help

- Check the [VitePress documentation](https://vitepress.dev/)
- Review existing documentation files for examples
- Open an issue in the Effect Dart repository