---
title: Flutter
layer: mobile
type: concept
priority: high
version: 2.0.0
tags:
  - Mobile
  - CrossPlatform
  - Flutter
  - Dart
  - UI
description: Google's UI toolkit for building natively compiled, cross-platform applications from a single Dart codebase, using a reactive rendering engine and a custom widget tree.
---

# Flutter

## Description

Flutter is Google's open-source UI toolkit for building natively compiled applications for mobile (iOS, Android), web, desktop (Windows, macOS, Linux), and embedded devices from a single codebase. Unlike React Native, which uses a JavaScript bridge to communicate with native UI components, Flutter renders its own UI using the Skia (or Impeller) graphics engine, drawing every pixel directly. This eliminates the bridge overhead and ensures visual consistency across platforms.

Architecture layers:
- **Framework (Dart)** — the entire widget library (Material, Cupertino, adaptive widgets), rendering engine, animation system, and gesture handling. Written in Dart, this is the layer developers interact with.
- **Engine (C++)** — the low-level rendering engine using Skia/Impeller, text layout (Minikin), Dart runtime, and platform channel implementation. Handles GPU composition, accessibility, and input events.
- **Embedder (platform-native)** — platform-specific code that sets up the render surface, manages the event loop, and provides platform plugins (iOS, Android, macOS, Windows, Linux, web).
- **Platform Channels** — the communication mechanism between Dart code and platform-native code (Swift/Kotlin). Uses serialized method calls (`MethodChannel`) and event streams (`EventChannel`). Enables access to native APIs (camera, sensors, biometrics) that Flutter does not wrap.

Key concepts:
- **Everything is a Widget** — layout, styling, padding, alignment, and event handling are all widgets. Composition over inheritance.
- **Widget → Element → RenderObject** — the three-tree architecture. Widgets are immutable configurations, Elements manage the widget lifecycle, and RenderObjects handle layout and painting. Flutter diffs the widget tree and updates only the changed parts of the render tree.
- **Hot Reload** — injects updated Dart source code into the running Dart VM while preserving app state. Uses the Dart JIT compiler and does not restart the app. Does not preserve state across changes to `main()` or native code.
- **StatefulWidget vs StatelessWidget** — stateless widgets are rebuilt from parent state; stateful widgets hold mutable state via a `State` object and call `setState()` to trigger rebuilds.
- **Build context** — `BuildContext` is a handle to a widget's location in the tree. It is used to look up inherited widgets (`Theme.of(context)`, `MediaQuery.of(context)`) and navigate (`Navigator.of(context).push()`).

## When to Use

- **Cross-platform mobile apps with shared UI** — when you need iOS and Android apps with 80–95% code sharing and pixel-perfect visual consistency. Flutter's custom rendering ensures identical appearance on both platforms.
- **MVP or rapid prototyping** — hot reload enables sub-second iteration on UI changes. A single developer can build a functional prototype across two platforms in days.
- **Custom, highly branded UI** — when your design system does not follow Material Design or Apple's HIG. Flutter draws everything from scratch, so custom animations, non-standard layouts, and bespoke components are as easy as standard widgets.
- **Apps targeting 3+ platforms** — mobile (iOS + Android) + web + desktop from one codebase. Flutter's multi-platform support is more mature than React Native's for desktop targets.
- **Performance-sensitive UI** — Flutter's direct rendering (no bridge) provides consistent 60/120 FPS even on complex animations and scroll lists. For comparison, React Native's bridge can drop frames during heavy JS-GC or bridge serialization.
- **Greenfield projects** — no legacy native code to integrate. Starting from scratch avoids the integration tax of bridging Flutter with existing Swift/Kotlin modules.

## When NOT to Use

- **Heavy native SDK integration** — apps that rely deeply on platform-specific SDKs (ARKit, HealthKit, Core ML on iOS; ML Kit, Play Services, CameraX on Android). Each requires a platform channel and native plugin, which adds maintenance overhead and potential version incompatibilities.
- **Apps requiring native look-and-feel per platform** — Flutter widgets approximate Material and Cupertino but are not pixel-perfect replicas. If your app must feel 100% native on each platform (e.g., a banking app), use native development (SwiftUI + Jetpack Compose).
- **Large existing native codebases** — adding Flutter to an existing iOS/Android app ("Add-to-App") is possible but introduces complexity: two UI frameworks, two navigation systems, and shared state management. The integration cost often exceeds the benefit.
- **Web-first applications** — Flutter's web support compiles to Canvas/WASM, not HTML/CSS. This means no native HTML semantics, poor SEO, larger initial download (~5–15 MB), and limited browser developer tool support. Use React, Angular, or Vue for web-first apps.
- **When Dart expertise is unavailable** — Dart is a niche language. Hiring Flutter developers is harder than hiring React Native or native developers. If your team is already proficient in JavaScript/TypeScript, React Native may be a better fit.
- **Accessibility-critical applications** — Flutter's accessibility support has improved but lags behind native platforms. Screen reader (VoiceOver/TalkBack) integration works for standard widgets but breaks with custom painted components. For government, healthcare, or education apps with strict a11y requirements, test thoroughly before committing.
- **App size constraints** — a minimal Flutter app is ~15–25 MB (ARM64 release), compared to ~3–5 MB for a native app. If your target market has limited bandwidth (emerging markets, IoT devices), the binary size is a liability.

## Tradeoffs

| Dimension | Flutter | React Native |
|-----------|---------|-------------|
| **Rendering** | Custom engine (Skia/Impeller), no bridge | Native components via JS bridge (or Fabric new architecture) |
| **Performance** | Consistent 60/120 FPS; no bridge bottleneck | Bridge can cause frame drops; new architecture (Fabric/TurboModules) improves this |
| **UI consistency** | Pixel-perfect across platforms | Platform-specific rendering (may differ) |
| **Ecosystem** | pub.dev (~40K packages), curated quality | npm (~2M packages), variable quality |
| **Language** | Dart (statically typed, easy to learn, small ecosystem) | TypeScript/JavaScript (large ecosystem, more complexity) |
| **Binary size** | 15–25 MB (minimal app) | 5–15 MB (minimal app) |
| **Hot reload** | Sub-second, state-preserving | Fast Refresh (React 18+), similar experience |
| **Web support** | Canvas/WASM (not HTML) | HTML/CSS/JS (native web) |
| **Maturity** | Stable since 2018; strong Google backing | Stable since 2015; large community (Meta) |

| Dimension | Flutter | Native (SwiftUI + Jetpack Compose) |
|-----------|---------|-----------------------------------|
| **Code sharing** | 90%+ across platforms | 0% (separate codebases) |
| **Platform integration** | Via plugins (delayed for new OS features) | Direct, day-one access to new APIs |
| **Performance** | Near-native for most UI work | Native (obviously) |
| **Team size** | 1–2 developers for both platforms | 2 teams (iOS + Android) |
| **Time to market** | Faster for cross-platform | Slower (two codebases) |
| **Long-term maintenance** | One codebase to maintain, but Flutter SDK upgrades can break plugins | Two codebases but each uses stable, well-documented platform APIs |

## Alternatives

- **React Native** — the dominant cross-platform alternative. Uses JavaScript/TypeScript and renders native components. Better for teams with React experience. The new Fabric architecture closes the performance gap with Flutter.
- **Native development (SwiftUI + Kotlin/Jetpack Compose)** — the gold standard for platform-specific quality, performance, and access to new APIs. Required when the app must feel indistinguishable from a first-party Apple/Google app.
- **Kotlin Multiplatform (KMP) + Compose Multiplatform** — shares business logic in Kotlin and renders UI with Compose on both platforms. Gaining traction as a middle ground between native and Flutter.
- **Xamarin / .NET MAUI** — Microsoft's cross-platform framework using C#. Strong in enterprise environments but smaller community and less performant than Flutter.
- **Ionic / Capacitor** — web-based cross-platform using HTML/CSS/JS inside a WebView. Lower performance but enables web developers to build mobile apps. Suitable for simple CRUD apps.
- **Unity** — for game-like experiences or highly interactive 3D UI. Not a general-purpose app framework but overlaps with Flutter for custom animated experiences.

## Failure Modes

1. **Excessive rebuilds from oversized `build()` methods** — a `build()` method that constructs an entire screen (100+ widgets) re-executes on every `setState()`, causing jank at 60 FPS → break the UI into small, focused widgets. Use `const` constructors for static subtrees. Use `ValueListenableBuilder` or `Selector` patterns to rebuild only the widgets that depend on changed state.

2. **Hot reload losing state** — hot reload re-injects updated code but does not re-run `initState()` or `main()`. If you change the structure of a `StatefulWidget`, the state is lost and the UI breaks → use hot restart (Shift+R) when changing widget hierarchies, global variables, or `main()`. Hot reload works best for cosmetic changes (colors, padding, text).

3. **Platform channel serialization overhead** — passing large data structures (images, byte arrays, lists of 10K+ objects) over `MethodChannel` causes significant latency because data is serialized to/from JSON or platform-standard formats → use `BasicMessageChannel` with binary codecs for large payloads, or process data natively and pass only the result. Avoid passing `Uint8List` of >1 MB over channels.

4. **Impeller rendering artifacts on iOS** — Flutter's new Impeller engine (default on iOS since Flutter 3.16) eliminates shader compilation jank but has known issues with certain blend modes, clip paths, and text rendering → test your app with Impeller enabled (`flutter run --enable-impeller`). If visual bugs appear, fall back to Skia (`--no-enable-impeller`) and file an issue. Monitor the Impeller roadmap for fixes.

5. **Memory leaks from uncancelled streams** — a `StreamSubscription` created in `initState()` is not cancelled in `dispose()`, and the stream continues to fire events to a disposed widget → always cancel subscriptions in `dispose()`. Use `StreamBuilder` for automatic lifecycle management, or store the `StreamSubscription` and call `subscription.cancel()` in `dispose`.

6. **Widget test brittleness from finder changes** — widget tests that find widgets by text (`find.text('Submit')`) break when the text is localized or changed → find widgets by `Key` (`find.byKey(ValueKey('submit_button'))`) in tests. Keys are stable across localization and design changes.

7. **Plugin incompatibility after Flutter SDK upgrades** — a Flutter SDK minor version upgrade breaks a third-party plugin that depends on internal APIs → pin your Flutter SDK version in `pubspec.yaml` (`flutter: ">=3.16.0 <3.17.0"`). Before upgrading, run `flutter pub outdated` and check plugin changelogs. Test on CI with the new SDK before merging.

8. **`BuildContext` misuse** — calling `Navigator.of(context).push()` from a `build()` method of a widget that is itself inside the `Navigator`'s route, using a context that does not have the `Navigator` as an ancestor → use a `Builder` widget or `GlobalKey` to access a context that has the desired ancestor. Alternatively, use `GoRouter` with a `GlobalKey<NavigatorState>`.

9. **Layout overflow errors** — a `Column` with unbounded height contains an `Expanded` widget with a `ListView`, causing a render error because the inner `ListView` has infinite constraints → use `ShrinkWrapping` (`ListView.builder(shrinkWrap: true)`) or `CustomScrollView` with `SliverList` for nested scrollable content. Alternatively, set a fixed height with `SizedBox` or `ConstrainedBox`.

10. **State management anti-pattern: passing callbacks down 5+ levels** — a `setState` callback is passed through 6 layers of widgets, making the code unreadable and every ancestor rebuild on state change → use a state management solution (Riverpod, BLoC, Provider) for state that crosses more than 2 widget boundaries. Keep `setState` for local, self-contained widget state.

## Code Examples

### State Management with Provider (Recommended for Mid-Sized Apps)

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Order {
  final String id;
  final String item;
  final double total;
  final bool isPaid;

  const Order({required this.id, required this.item, required this.total, this.isPaid = false});
  Order copyWith({bool? isPaid}) => Order(id: id, item: item, total: total, isPaid: isPaid ?? this.isPaid);
}

class OrderNotifier extends ChangeNotifier {
  final List<Order> _orders = [];
  List<Order> get orders => List.unmodifiable(_orders);

  void addOrder(Order order) {
    _orders.add(order);
    notifyListeners();
  }

  void markPaid(String id) {
    final idx = _orders.indexWhere((o) => o.id == id);
    if (idx != -1) {
      _orders[idx] = _orders[idx].copyWith(isPaid: true);
      notifyListeners();
    }
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => OrderNotifier(),
      child: const MyApp(),
    ),
  );
}

class OrderListScreen extends StatelessWidget {
  const OrderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderNotifier>().orders;

    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return ListTile(
            title: Text(order.item),
            subtitle: Text('\$${order.total.toStringAsFixed(2)}'),
            trailing: order.isPaid
                ? const Icon(Icons.check_circle, color: Colors.green)
                : IconButton(
                    icon: const Icon(Icons.payment),
                    onPressed: () => context.read<OrderNotifier>().markPaid(order.id),
                  ),
          );
        },
      ),
    );
  }
}
```

### Platform Channel — Calling Native Code (iOS/Android)

```dart
import 'package:flutter/services.dart';

class BatteryPlugin {
  static const MethodChannel _channel = MethodChannel('com.example/battery');

  static Future<int> getBatteryLevel() async {
    try {
      final int result = await _channel.invokeMethod('getBatteryLevel');
      return result;
    } on PlatformException catch (e) {
      throw Exception('Failed to get battery level: ${e.message}');
    }
  }
}

// Usage in a widget
class BatteryIndicator extends StatefulWidget {
  const BatteryIndicator({super.key});

  @override
  State<BatteryIndicator> createState() => _BatteryIndicatorState();
}

class _BatteryIndicatorState extends State<BatteryIndicator> {
  int _batteryLevel = -1;

  @override
  void initState() {
    super.initState();
    _fetchBatteryLevel();
  }

  Future<void> _fetchBatteryLevel() async {
    final level = await BatteryPlugin.getBatteryLevel();
    if (mounted) {
      setState(() => _batteryLevel = level);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_batteryLevel == -1) return const CircularProgressIndicator();
    return Text('Battery: $_batteryLevel%');
  }
}
```

### Animation with Implicit and Explicit Animations

```dart
class AnimatedCard extends StatefulWidget {
  final bool isSelected;
  const AnimatedCard({super.key, required this.isSelected});

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isSelected) _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      widget.isSelected ? _controller.forward() : _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.isSelected ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text('Card Content'),
      ),
    );
  }
}
```

### GoRouter for Declarative Navigation

```dart
import 'package:go_router/go_router.dart';

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'order/:id',
          builder: (context, state) {
            final orderId = state.pathParameters['id']!;
            return OrderDetailScreen(orderId: orderId);
          },
        ),
        GoRoute(
          path: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => const NotFoundScreen(),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'My App',
    );
  }
}
```

## Best Practices

- **Use `const` constructors wherever possible.** `const` widgets are canonicalized and skipped during rebuilds. Every `const` you add is a widget Flutter does not need to diff.
- **Keep `build()` methods small and focused.** Extract logical UI sections into separate widgets. A `build()` method should not exceed ~50 lines of widget construction.
- **Use `ListView.builder` (lazy list) instead of `ListView(children: [...])`.** The builder version only creates widgets visible on screen plus a small buffer, reducing memory from O(N) to O(visible).
- **Prefer composition over deep inheritance.** Flutter's widget system is designed for composition. Wrap widgets instead of subclassing them. `InheritedWidget` enables data sharing without passing callbacks through the tree.
- **Use `Keys` for widgets that must preserve state across rebuilds.** When a list of similar widgets is reordered, Flutter matches widgets by type. Keys ensure correct matching: `ListView.builder(key: ValueKey(item.id), ...)`.
- **Test with `Key`-based finders, not text-based finders.** Widget tests that find by text break on localization. Keys are stable: `find.byKey(const ValueKey('submit_button'))`.
- **Use GoRouter for navigation in new projects.** It provides declarative routing, deep linking, nested navigation, and URL-based state management. `Navigator.push` is imperative and harder to test.
- **Profile before optimizing.** Use Flutter DevTools (flutter run --profile) to identify actual bottlenecks: rebuild count, GPU raster cache misses, and shader compilation jank. Do not guess.
- **Pin your Flutter SDK version in CI.** Use `flutter-version:` in your CI config. Upgrading Flutter can break plugins, and you want to control when this happens.
- **Use Impeller on iOS and test thoroughly.** Impeller eliminates shader compilation jank (the "first animation stutter" problem) but has known rendering edge cases. Enable it in production once your app passes visual regression testing.

## Related Topics

- [[Mobile MOC]]
- [[MobileArchitecture]]
- [[ReactNative]]
- [[CrossPlatform]]
- [[SwiftUI]]
- [[JetpackCompose]]
- [[MobileTesting]]
- [[Dart]]
