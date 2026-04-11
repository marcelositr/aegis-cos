---
title: SwiftUI
title_pt: SwiftUI
layer: mobile
type: concept
priority: high
version: 2.0.0
tags:
  - Mobile
  - Swift
  - SwiftUI
  - UI
  - Apple
  - DeclarativeUI
description: Apple's declarative UI framework for building user interfaces across all Apple platforms with a unified, state-driven rendering model.
description_pt: Framework declarativo da Apple para construcao de interfaces visuais em todas as plataformas Apple.
prerequisites:
  - SwiftProgramming
estimated_read_time: 15 min
difficulty: intermediate
---

# SwiftUI

## Description

SwiftUI is Apple's declarative UI framework, introduced at WWDC 2019. It replaced the imperative UIKit/AppKit paradigm (`view.addSubview`, `layoutSubviews`, delegate callbacks) with a declarative model where you describe what the UI should look like for a given state, and SwiftUI automatically computes the minimal set of changes needed to update the rendered view.

Key concepts:
- **Declarative rendering** — views are value types (`struct`) that conform to the `View` protocol. The `body` property returns a description of the UI, not the rendered views themselves. SwiftUI diffs the old and new view descriptions and applies only the changes.
- **State-driven UI** — property wrappers (`@State`, `@Binding`, `@ObservedObject`, `@StateObject`, `@Environment`, `@EnvironmentObject`) connect data to views. When state changes, SwiftUI re-evaluates the view's `body` and updates the rendered output.
- **Modifiers** — methods like `.font()`, `.padding()`, `.foregroundColor()` transform a view and return a new view type. Modifier order matters because each modifier wraps the previous result.
- **Layout system** — SwiftUI uses a constraint-based layout where parents propose sizes to children, children choose their size, and parents position them. `GeometryReader` provides access to the proposed size for custom layouts.
- **View lifecycle** — `.onAppear`, `.onDisappear`, `.onChange(of:)`, and `.task` replace `viewDidLoad`, `viewWillAppear`, and `viewDidDisappear`.
- **Cross-platform** — iOS, macOS, watchOS, tvOS, and visionOS share the same API. Platform-specific modifiers use `#if os(iOS)` or `.onTapGesture` (universal) vs platform-specific gestures.

## When to Use

- **New iOS/macOS projects targeting iOS 15+** — SwiftUI is production-ready and mature since iOS 15. For new apps, it reduces boilerplate by 50–70% compared to UIKit.
- **Rapid prototyping** — SwiftUI's previews (`#Preview`) provide instant visual feedback without running the simulator. Changes to layout, colors, and text are visible in seconds.
- **Multi-platform Apple apps** — one codebase for iOS, macOS, watchOS, and tvOS. The shared API means 80–90% of UI code is portable. Platform-specific adjustments are minimal.
- **Complex animations and transitions** — SwiftUI's animation API (`.animation()`, `.transition()`, `matchedGeometryEffect`) is dramatically simpler than UIKit's `UIView.animate` or Core Animation.
- **Data-driven UI** — forms, settings screens, dashboards, and list/detail interfaces. `Form`, `List`, `NavigationStack`, and `@FetchRequest` make CRUD interfaces trivial.
- **Accessibility** — SwiftUI automatically provides VoiceOver labels, Dynamic Type support, and Reduce Motion compliance for standard components. Custom views require explicit accessibility modifiers.

## When NOT to Use

- **Supporting iOS 14 or earlier** — SwiftUI is available on iOS 13+, but iOS 15 is the minimum viable version for production (iOS 13/14 have critical bugs and missing features). Use UIKit for older targets.
- **Highly custom UI that fights SwiftUI's layout system** — pixel-perfect custom transitions, complex gesture-driven interactions, or UI that requires direct access to CALayer. SwiftUI's layout model is intentionally abstracted. Use UIKit or AppKit.
- **Apps requiring extensive third-party UI libraries** — the SwiftUI ecosystem is growing but still smaller than UIKit's. If your app depends on specific UIKit libraries (charts, maps with custom overlays, PDF viewers), you will need `UIViewRepresentable` wrappers.
- **Performance-critical list rendering with 10,000+ heterogeneous items** — `LazyVStack` and `List` are efficient but can struggle with deeply nested, heterogeneous view hierarchies at extreme scale. UIKit's `UICollectionView` with diffable data sources is more performant for this niche case.
- **Apps with existing large UIKit codebases** — migrating a 100-screen UIKit app to SwiftUI incrementally is possible via `UIHostingController`, but the cost of maintaining both frameworks simultaneously often exceeds the benefit. Consider SwiftUI only for new screens.
- **When your team has no Swift experience** — SwiftUI requires understanding of Swift's type system, property wrappers, generics, and the declarative mental model. Without Swift proficiency, the learning curve is steep.

## Tradeoffs

| Dimension | SwiftUI | UIKit |
|-----------|---------|-------|
| **Boilerplate** | Low (declarative, no view controllers for simple screens) | High (view controllers, delegates, data sources) |
| **Learning curve** | Moderate (new paradigm for imperative developers) | Moderate (well-documented, 15+ years of resources) |
| **Performance** | Good (optimized for common cases; some overhead for complex hierarchies) | Best (direct access to rendering engine) |
| **Custom UI** | Limited (must work within the layout system) | Unlimited (direct CALayer, Core Graphics access) |
| **Previews** | Instant (`#Preview` with live updates) | None (requires simulator or device) |
| **Navigation** | `NavigationStack` (iOS 16+), path-based, type-safe | `UINavigationController`, push/pop, less type-safe |
| **List performance** | `LazyVStack`/`List` (good for most cases) | `UICollectionView` with diffable data sources (best for extreme cases) |
| **Animation** | Declarative (`.animation`, `.transition`) | Imperative (`UIView.animate`, Core Animation) |
| **Maturity** | Since 2019; missing some edge cases | Since 2008; comprehensive |

| Dimension | SwiftUI | Flutter |
|-----------|---------|---------|
| **Platform scope** | Apple only | iOS, Android, web, desktop, embedded |
| **Rendering** | Native (maps to UIKit/AppKit under the hood) | Custom engine (Skia/Impeller) |
| **Language** | Swift | Dart |
| **Hot reload** | Previews (fast, but limited to the previewed view) | Full app hot reload |
| **Ecosystem** | Apple's built-in components + growing third-party | pub.dev (~40K packages) |
| **Performance** | Native | Near-native (custom rendering) |

## Alternatives

- **UIKit** — Apple's mature imperative UI framework. Required for complex custom UI, backward compatibility (iOS 12 and earlier), and fine-grained control over the rendering pipeline.
- **Jetpack Compose (Android)** — Google's declarative UI framework, inspired by SwiftUI. The Android equivalent. If you are building cross-platform, Compose + SwiftUI share a similar mental model.
- **Flutter** — Google's cross-platform UI toolkit. Draws its own UI with Skia/Impeller. Better for cross-platform targeting Android + iOS from one codebase.
- **React Native** — Meta's cross-platform framework using JavaScript/TypeScript and native components. Larger ecosystem but a different programming model (JSX + hooks).
- **AppKit (macOS)** — Apple's older macOS UI framework. SwiftUI on macOS is mature enough for most apps, but AppKit is still needed for menu bar apps, complex document-based apps, and deep macOS integration.

## Failure Modes

1. **Mutating state outside the SwiftUI lifecycle** — modifying a property of an `ObservableObject` from a background thread causes undefined behavior and missed UI updates because SwiftUI's observation is tied to the main actor → annotate `ObservableObject` classes with `@MainActor` to guarantee all `@Published` property mutations occur on the main thread. Use `Task { @MainActor in ... }` when updating from async contexts.

2. **Excessive view recomputation from heavy `body` logic** — the `body` property is re-evaluated on every state change. If it contains expensive computation (sorting 10,000 items, parsing JSON, image processing), the UI janks → extract expensive computations into computed properties with caching, or move them to the ViewModel. Use `@State` or `@Observation` for derived values that should be computed once and cached until dependencies change.

3. **Modifier order causing unexpected layout** — `.padding()` before `.background()` produces a different result than `.background()` before `.padding()` because modifiers wrap the view in order. A common mistake: `.foregroundColor(.red).background(Color.blue)` works, but `.background(Color.blue).foregroundColor(.red)` applies the color to the background-wrapped view → understand that each modifier returns a new view that wraps the previous one. Apply modifiers in the order of the visual hierarchy you want.

4. **`@State` initialized with mutable references** — `@State var items = someArray` where `someArray` is a reference type (class). SwiftUI copies the reference, not the contents. Mutating the array's contents does not trigger a re-render → `@State` should only wrap value types (structs, enums, primitives). For reference types, use `@StateObject` (owns the instance) or `@ObservedObject` (observes an externally-owned instance).

5. **Missing `id` in `ForEach` causing incorrect diffing** — `ForEach(0..<items.count) { i in ... }` uses index as ID. When items are inserted or deleted, SwiftUI mismatches views with data → always use a stable, unique identifier: `ForEach(items, id: \.id) { item in ... }`. If items conform to `Identifiable`, use `ForEach(items) { item in ... }`.

6. **Navigation state desynchronization** — using `NavigationLink` with programmatic `isActive` binding, and the binding is not reset after navigation. The link becomes unclickable because `isActive` is still `true` → reset the binding in the destination view's `onDisappear`:
   ```swift
   NavigationLink(isActive: $isSelected) {
       DestinationView()
           .onDisappear { isSelected = false }
   } label: { Text("Go") }
   ```

7. **Memory leaks from strong reference cycles in `@ObservableObject`** — an `ObservableObject` holds a strong reference to a closure that captures `self`, and the View holds a strong reference to the `ObservableObject`. Neither is deallocated → use `[weak self]` in closures stored within `ObservableObject` classes. Use `@StateObject` (not `@ObservedObject`) for ViewModels created within the view to avoid recreating them on every render.

8. **`GeometryReader` causing infinite layout loops** — a `GeometryReader` inside a `ScrollView` with `.infinity` size proposals creates a recursive constraint where the parent proposes infinite size and the child requests infinite size → `GeometryReader` should not be the direct child of a `ScrollView`. Wrap it in a `VStack` or use `.frame(maxWidth: .infinity, maxHeight: .infinity)` to constrain it.

9. **Not handling Dynamic Type (accessibility font sizes)** — using fixed font sizes (`.font(.system(size: 16))`) ignores the user's accessibility settings → use semantic font sizes (`.font(.body)`, `.font(.headline)`) that automatically scale with Dynamic Type. For custom sizes, use `.font(.system(size: 16, weight: .regular, design: .default).scaled())` with `.dynamicTypeSize(.all)`.

10. **Over-using `@EnvironmentObject` as a global store** — passing the entire app state through `@EnvironmentObject` means every view subscribes to every change, causing excessive re-renders → use `@EnvironmentObject` for truly global, infrequently-changing data (theme, authentication status). For granular state, pass specific `@Binding` or use the `@Observable` macro (iOS 17+) with fine-grained observation.

## Code Examples

### Complete NavigationStack (iOS 16+)

```swift
import SwiftUI

struct OrderApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $navigationPath) {
                OrderListView()
                    .navigationDestination(for: Order.self) { order in
                        OrderDetailView(order: order)
                    }
                    .navigationDestination(for: String.self) { orderId in
                        // Navigate by ID
                        OrderDetailView(orderId: orderId)
                    }
            }
            .environment(\.navigationPath, $navigationPath)
        }
    }

    @State private var navigationPath = NavigationPath()
}

struct OrderListView: View {
    @StateObject private var viewModel = OrderListViewModel()

    var body: some View {
        List(viewModel.orders) { order in
            NavigationLink(value: order) {
                OrderRow(order: order)
            }
        }
        .navigationTitle("Orders")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Settings") {
                    // Push settings onto the path
                }
            }
        }
        .task { await viewModel.loadOrders() }
    }
}

struct OrderDetailView: View {
    let order: Order

    var body: some View {
        Form {
            Section("Details") {
                LabeledContent("Item", value: order.itemName)
                LabeledContent("Total", value: order.total, format: .currency(code: "USD"))
                LabeledContent("Status", value: order.status.rawValue)
            }

            Section("Actions") {
                Button("Cancel Order", role: .destructive) {
                    // Navigate back
                }
            }
        }
        .navigationTitle(order.itemName)
    }
}
```

### Custom Layout with GeometryReader

```swift
struct MasonryGrid<Item: Identifiable, Content: View>: View {
    let items: [Item]
    let spacing: CGFloat
    @ViewBuilder let content: (Item) -> Content

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let itemWidth = (width - spacing * 2) / 3 // 3 columns

            // Calculate column heights
            let layout = items.reduce(into: Array(repeating: CGFloat(0), count: 3)) { heights, item in
                let columnIndex = heights.index(of: heights.min()!)!
                heights[columnIndex] += itemHeight(item) + spacing
            }

            ScrollView {
                ZStack(alignment: .topLeading) {
                    ForEach(items) { item in
                        // Position each item in its column at the current height
                    }
                }
                .frame(height: layout.max() ?? 0)
            }
        }
    }

    private func itemHeight(_ item: Item) -> CGFloat {
        // Estimate height based on content
        100 // placeholder
    }
}
```

### Animation with matchedGeometryEffect

```swift
struct ExpandableCard: View {
    @State private var expandedId: String?

    let items = [
        (id: "a", title: "Card A", color: Color.blue),
        (id: "b", title: "Card B", color: Color.green),
        (id: "c", title: "Card C", color: Color.orange),
    ]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(items, id: \.id) { item in
                    CardItem(
                        item: item,
                        isExpanded: expandedId == item.id,
                        onTap: {
                            withAnimation(.spring(response: 0.4)) {
                                expandedId = expandedId == item.id ? nil : item.id
                            }
                        }
                    )
                    .matchedGeometryEffect(id: item.id, in: namespace)
                }
            }
            .padding()
        }
    }

    @Namespace private var namespace
}

struct CardItem: View {
    let item: (id: String, title: String, color: Color)
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.title)
                .font(isExpanded ? .title2 : .headline)

            if isExpanded {
                Text("This is the expanded content for \(item.title). It contains additional details that are only visible when the card is tapped.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(item.color.opacity(0.15))
        .cornerRadius(12)
        .onTapGesture(perform: onTap)
    }
}
```

### iOS 17+ @Observable Macro

```swift
import Observation

@Observable
class OrderViewModel {
    var orders: [Order] = []
    var isLoading = false
    var error: String?

    func loadOrders() async {
        isLoading = true
        defer { isLoading = false }

        do {
            orders = try await OrderAPI.fetchOrders()
            error = nil
        } catch {
            self.error = error.localizedDescription
        }
    }
}

// Usage in view — no @StateObject or @ObservedObject needed
struct OrderListView: View {
    private var viewModel = OrderViewModel() // Automatically observed

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if let error = viewModel.error {
                ContentUnavailableView("Load failed", systemImage: "exclamationmark.triangle", description: Text(error))
            } else {
                List(viewModel.orders) { order in
                    Text(order.itemName)
                }
            }
        }
        .task { await viewModel.loadOrders() }
    }
}
```

## Best Practices

- **Use `@State` for local, value-type state and `@Observable` (iOS 17+) or `@StateObject` for reference-type ViewModels.** `@State` is for self-contained view state. `@Observable` replaces `@StateObject`/`@ObservedObject` with fine-grained observation.
- **Keep `body` pure and fast.** No network calls, no file I/O, no heavy computation. The `body` is called frequently during SwiftUI's diffing process. Use `.task` for async work and computed properties for derived data.
- **Understand modifier order.** Each modifier wraps the previous view. `.padding().background(Color.red)` gives a red background behind the padding. `.background(Color.red).padding()` gives padding outside the red background.
- **Use `NavigationStack` (iOS 16+) over `NavigationView`** (deprecated). `NavigationStack` supports type-safe programmatic navigation via `NavigationPath` and works with the modern SwiftUI navigation model.
- **Prefer `LazyVStack`/`LazyHStack` over `VStack`/`HStack` for large lists.** Lazy containers only create views that are on screen, reducing memory and rendering cost.
- **Use `.task` instead of `.onAppear` for async work.** `.task` is automatically cancelled when the view disappears, preventing work on deallocated views.
- **Test on real devices, not just previews.** Previews do not capture performance, animation smoothness, hardware integration (camera, GPS), or memory pressure. Always validate on physical devices before shipping.
- **Support Dynamic Type and accessibility.** Use semantic font sizes (`.body`, `.headline`), test with the Accessibility Inspector, and ensure all interactive elements have adequate hit areas (minimum 44x44 points).
- **Use `@Bindable` (iOS 17+) for two-way bindings to `@Observable` objects.** It replaces `@Binding` for reference types: `@Bindable var viewModel: OrderViewModel`.
- **Profile with Instruments.** Use the SwiftUI instrument in Xcode to track view body evaluation count, render time, and unnecessary re-renders. Fix the hottest paths first.

## Related Topics

- [[Mobile MOC]]
- [[iOSArchitecture]]
- [[Swift]]
- [[iOSDataAndNetworking]]
- [[MobileArchitecture]]
- [[Combine]]
- [[UIKit]]
- [[MobileTesting]]
