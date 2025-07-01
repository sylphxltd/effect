import { defineConfig } from 'vitepress'

export default defineConfig({
  title: 'Effect Dart',
  description: 'A powerful Effect library for Dart inspired by Effect-TS',
  base: '/effect/',
  
  // Temporarily ignore dead links while building documentation
  ignoreDeadLinks: true,
  
  themeConfig: {
    nav: [
      { text: 'Home', link: '/' },
      { text: 'Getting Started', link: '/getting-started/' },
      { text: 'API Reference', link: '/api/' },
      { text: 'Examples', link: '/examples/' }
    ],

    sidebar: {
      '/getting-started/': [
        {
          text: 'Getting Started',
          items: [
            { text: 'Introduction', link: '/getting-started/' },
            { text: 'Why Effect?', link: '/getting-started/why-effect' },
            { text: 'Installation', link: '/getting-started/installation' },
            { text: 'Create Effect App', link: '/getting-started/create-effect-app' },
            { text: 'Importing Effect', link: '/getting-started/importing-effect' }
          ]
        },
        {
          text: 'Core Concepts',
          items: [
            { text: 'The Effect Type', link: '/getting-started/effect-type' },
            { text: 'Creating Effects', link: '/getting-started/creating-effects' },
            { text: 'Running Effects', link: '/getting-started/running-effects' },
            { text: 'Using Generators', link: '/getting-started/using-generators' },
            { text: 'Building Pipelines', link: '/getting-started/building-pipelines' }
          ]
        },
        {
          text: 'Control Flow',
          items: [
            { text: 'Control Flow Operators', link: '/getting-started/control-flow-operators' }
          ]
        }
      ],
      
      '/error-handling/': [
        {
          text: 'Error Handling',
          items: [
            { text: 'Two Types of Errors', link: '/error-handling/two-types-of-errors' },
            { text: 'Expected Errors', link: '/error-handling/expected-errors' },
            { text: 'Unexpected Errors', link: '/error-handling/unexpected-errors' },
            { text: 'Fallback', link: '/error-handling/fallback' },
            { text: 'Matching', link: '/error-handling/matching' },
            { text: 'Retrying', link: '/error-handling/retrying' },
            { text: 'Timing Out', link: '/error-handling/timing-out' },
            { text: 'Sandboxing', link: '/error-handling/sandboxing' },
            { text: 'Error Accumulation', link: '/error-handling/error-accumulation' },
            { text: 'Error Channel Operations', link: '/error-handling/error-channel-operations' },
            { text: 'Parallel and Sequential Errors', link: '/error-handling/parallel-sequential-errors' },
            { text: 'Yieldable Errors', link: '/error-handling/yieldable-errors' }
          ]
        }
      ],

      '/dependency-management/': [
        {
          text: 'Dependency Management',
          items: [
            { text: 'Managing Services', link: '/dependency-management/managing-services' },
            { text: 'Default Services', link: '/dependency-management/default-services' },
            { text: 'Managing Layers', link: '/dependency-management/managing-layers' },
            { text: 'Layer Memoization', link: '/dependency-management/layer-memoization' }
          ]
        }
      ],

      '/observability/': [
        {
          text: 'Observability',
          items: [
            { text: 'Introduction', link: '/observability/' },
            { text: 'Scope', link: '/observability/scope' },
            { text: 'Logging', link: '/observability/logging' },
            { text: 'Metrics', link: '/observability/metrics' },
            { text: 'Tracing', link: '/observability/tracing' },
            { text: 'Supervisor', link: '/observability/supervisor' }
          ]
        }
      ],

      '/configuration/': [
        {
          text: 'Configuration',
          items: [
            { text: 'Configuration', link: '/configuration/' }
          ]
        }
      ],

      '/runtime/': [
        {
          text: 'Runtime',
          items: [
            { text: 'Introduction', link: '/runtime/' }
          ]
        }
      ],

      '/scheduling/': [
        {
          text: 'Scheduling',
          items: [
            { text: 'Repetition', link: '/scheduling/repetition' },
            { text: 'Built-In Schedules', link: '/scheduling/built-in-schedules' },
            { text: 'Schedule Combinators', link: '/scheduling/schedule-combinators' },
            { text: 'Cron', link: '/scheduling/cron' },
            { text: 'Examples', link: '/scheduling/examples' }
          ]
        }
      ],

      '/state-management/': [
        {
          text: 'State Management',
          items: [
            { text: 'Ref', link: '/state-management/ref' },
            { text: 'SynchronizedRef', link: '/state-management/synchronized-ref' },
            { text: 'SubscriptionRef', link: '/state-management/subscription-ref' }
          ]
        }
      ],

      '/resource-management/': [
        {
          text: 'Resource Management',
          items: [
            { text: 'Batching', link: '/resource-management/batching' },
            { text: 'Caching Effects', link: '/resource-management/caching-effects' },
            { text: 'Cache', link: '/resource-management/cache' }
          ]
        }
      ],

      '/concurrency/': [
        {
          text: 'Concurrency',
          items: [
            { text: 'Basic Concurrency', link: '/concurrency/basic-concurrency' },
            { text: 'Fibers', link: '/concurrency/fibers' },
            { text: 'Deferred', link: '/concurrency/deferred' },
            { text: 'Queue', link: '/concurrency/queue' },
            { text: 'PubSub', link: '/concurrency/pubsub' },
            { text: 'Semaphore', link: '/concurrency/semaphore' },
            { text: 'Latch', link: '/concurrency/latch' }
          ]
        }
      ],

      '/streaming/': [
        {
          text: 'Streaming',
          items: [
            { text: 'Introduction', link: '/streaming/' },
            { text: 'Creating Streams', link: '/streaming/creating-streams' },
            { text: 'Consuming Streams', link: '/streaming/consuming-streams' },
            { text: 'Error Handling', link: '/streaming/error-handling' },
            { text: 'Operations', link: '/streaming/operations' },
            { text: 'Resourceful Streams', link: '/streaming/resourceful-streams' }
          ]
        }
      ],

      '/sinks/': [
        {
          text: 'Sinks',
          items: [
            { text: 'Introduction', link: '/sinks/' },
            { text: 'Creating Sinks', link: '/sinks/creating-sinks' },
            { text: 'Operations', link: '/sinks/operations' },
            { text: 'Concurrency', link: '/sinks/concurrency' },
            { text: 'Leftovers', link: '/sinks/leftovers' }
          ]
        }
      ],

      '/testing/': [
        {
          text: 'Testing',
          items: [
            { text: 'TestClock', link: '/testing/test-clock' }
          ]
        }
      ],

      '/style-guide/': [
        {
          text: 'Style Guide',
          items: [
            { text: 'Guidelines', link: '/style-guide/guidelines' },
            { text: 'Dual APIs', link: '/style-guide/dual-apis' },
            { text: 'Branded Types', link: '/style-guide/branded-types' },
            { text: 'Pattern Matching', link: '/style-guide/pattern-matching' },
            { text: 'Excessive Nesting', link: '/style-guide/excessive-nesting' }
          ]
        }
      ],

      '/data-types/': [
        {
          text: 'Data Types',
          items: [
            { text: 'BigDecimal', link: '/data-types/big-decimal' },
            { text: 'Cause', link: '/data-types/cause' },
            { text: 'Chunk', link: '/data-types/chunk' },
            { text: 'Data', link: '/data-types/data' },
            { text: 'DateTime', link: '/data-types/date-time' },
            { text: 'Duration', link: '/data-types/duration' },
            { text: 'Either', link: '/data-types/either' },
            { text: 'Exit', link: '/data-types/exit' },
            { text: 'HashSet', link: '/data-types/hash-set' },
            { text: 'Option', link: '/data-types/option' },
            { text: 'Redacted', link: '/data-types/redacted' }
          ]
        }
      ],

      '/traits/': [
        {
          text: 'Traits',
          items: [
            { text: 'Equal', link: '/traits/equal' },
            { text: 'Hash', link: '/traits/hash' },
            { text: 'Equivalence', link: '/traits/equivalence' },
            { text: 'Order', link: '/traits/order' }
          ]
        }
      ],

      '/schema/': [
        {
          text: 'Schema',
          items: [
            { text: 'Introduction', link: '/schema/' },
            { text: 'Getting Started', link: '/schema/getting-started' },
            { text: 'Basic Usage', link: '/schema/basic-usage' },
            { text: 'Filters', link: '/schema/filters' },
            { text: 'Advanced Usage', link: '/schema/advanced-usage' },
            { text: 'Projections', link: '/schema/projections' },
            { text: 'Transformations', link: '/schema/transformations' },
            { text: 'Annotations', link: '/schema/annotations' },
            { text: 'Error Messages', link: '/schema/error-messages' },
            { text: 'Error Formatters', link: '/schema/error-formatters' },
            { text: 'Class APIs', link: '/schema/class-apis' },
            { text: 'Default Constructors', link: '/schema/default-constructors' },
            { text: 'Effect Data Types', link: '/schema/effect-data-types' },
            { text: 'Standard Schema', link: '/schema/standard-schema' },
            { text: 'Arbitrary', link: '/schema/arbitrary' },
            { text: 'JSON Schema', link: '/schema/json-schema' },
            { text: 'Equivalence', link: '/schema/equivalence' },
            { text: 'Pretty Printer', link: '/schema/pretty-printer' }
          ]
        }
      ]
    },

    socialLinks: [
      { icon: 'github', link: 'https://github.com/sylphxltd/effect' }
    ],

    footer: {
      message: 'Released under the MIT License.',
      copyright: 'Copyright © 2024-present Effect Dart Contributors'
    }
  }
})