---
title: Combine Framework
layer: mobile
type: concept
priority: high
version: 2.0.0
tags:
  - Mobile
  - iOS
  - Swift
  - Reactive
  - ReactiveProgramming
  - Apple
description: Apple's reactive programming framework for processing asynchronous events and values over time using a publisher-subscriber model with built-in operators for transformation, filtering, and composition.
---

# Combine Framework

## Description

Combine is Apple's native reactive programming framework, introduced in iOS 13 (2019). It provides a unified declarative API for processing values over time, replacing callback-based and delegate-based asynchronous patterns with a composable chain of **Publishers** and **Subscribers**.

Core abstractions:
- **Publisher** — produces a sequence of values over time, potentially with errors. Defined by three associated types: `Output`, `Failure` (either `Never` for infallible publishers, or an `Error` type), and a `receive` method. Examples: `PassthroughSubject`, `CurrentValueSubject`, `URLSession.dataTaskPublisher`, `NotificationCenter.publisher`.
- **Subscriber** — consumes values from a publisher. Subscribers request values (demand), receive them, and can cancel. Examples: `sink`, `assign`, `AsyncStream` bridge.
- **Operator** — transforms, filters, combines, or otherwise manipulates the stream. Examples: `map`, `flatMap`, `filter`, `debounce`, `merge`, `combineLatest`, `switchToLatest`, `catch`, `retry`.
- **Subscription** — the connection between a publisher and subscriber. Manages lifecycle and backpressure.
- **Cancellable** — a handle to cancel a subscription and release resources. Stored in a `Set<AnyCancellable>` to keep subscriptions alive.
- **Scheduler** — controls which thread/queue code executes on. `RunLoop.main` (UI thread), `DispatchQueue.global()` (background), `OperationQueue`.

Combine interoperates with Swift Concurrency (`async/await`) via `.task` (Publisher to AsyncStream) and `.publish` (AsyncSequence to Publisher).

## When to Use

- **Binding UI state to data models in UIKit/AppKit** — where SwiftUI's `@State` is not available. Combine's `assign(to:on:)` and `sink` provide clean one-way or two-way bindings between view models and views.
- **Chaining multiple asynchronous operations** — e.g., authenticate → fetch user profile → load preferences. `flatMap` chains these with automatic error propagation and cancellation, avoiding callback hell.
- **Debouncing user input** — search field text changes trigger API calls. `.debounce(for: .milliseconds(300), scheduler: RunLoop.main)` waits for the user to stop typing before firing the request.
- **Combining multiple data sources** — `combineLatest` merges two or more publishers (e.g., location updates + weather API responses) and emits a tuple whenever any source updates.
- **Managing lifecycle with subscriptions** — Combine's `Cancellable` model makes it explicit when work should stop. When a view controller deallocates, its `Set<AnyCancellable>` is deallocated, automatically cancelling all subscriptions.
- **Building MVVM architectures on iOS 13+** — Combine's `@Published` property wrapper turns any property into a publisher, making ViewModel-to-View binding trivial in both UIKit and SwiftUI.
- **Replacing NotificationCenter and target-action** — Combine provides typed, composable wrappers around notification streams: `NotificationCenter.default.publisher(for: .keyboardWillShow)`.

## When NOT to Use

- **Supporting iOS 12 or earlier** — Combine requires iOS 13+. For older targets, use RxSwift or callbacks.
- **Simple one-off async tasks** — a single network request is cleaner with `async/await` than setting up a Combine pipeline with `sink` and `AnyCancellable`. Use `URLSession`'s `async` methods directly.
- **When the team has no reactive programming experience** — Combine has a steep learning curve. Operators like `flatMap`, `switchToLatest`, and `share` have subtle semantics. If the team is unfamiliar, invest in training or use `async/await`.
- **High-frequency event processing (>1000 events/sec)** — Combine's operator chains add allocation overhead per event. For real-time audio processing or high-frequency sensor data, use direct callbacks or a specialized library.
- **When you need features Combine lacks** — Combine does not have a built-in `distinctUntilChanged` (you must implement it), no `connectable` publisher with manual connect, and limited backpressure support. RxSwift or ReactiveSwift fill these gaps.
- **In performance-critical rendering loops** — Combine's scheduler-based threading adds latency. Use CADisplayLink or Metal's render loop for frame-synced work.

## Tradeoffs

| Dimension | Combine | Swift async/await |
|-----------|---------|-------------------|
| **Composability** | Rich operator library (`map`, `flatMap`, `merge`, `combineLatest`) | Linear composition with `async let` and `TaskGroup` |
| **Cancellation** | Automatic via `AnyCancellable` deallocation | Manual via `Task.cancel()` and `checkCancellation()` |
| **Learning curve** | Steep (monadic operators, scheduler types, lifetime management) | Gentle (looks like synchronous code) |
| **Backpressure** | Limited (subscribers request demand, but operators do not all respect it) | None built-in; must implement manually |
| **iOS support** | iOS 13+ only | iOS 15+ (with back-deployment to 13) |
| **Error handling** | Type-level errors (`Publisher<Output, Failure>`) | `throws` with `try/await` |
| **Memory overhead** | Each operator creates a box; chains allocate ~100–500 bytes per subscription | Minimal; compiler transforms to state machines |
| **Interoperability** | Bridges to async/await via `.values` and `.publish` | Bridges to Combine via `AsyncStream` and `AsyncPublisher` |

| Dimension | Combine | RxSwift |
|-----------|---------|---------|
| **Native support** | Built into Apple platforms (no third-party dependency) | Third-party; adds ~2 MB to app binary |
| **Operator coverage** | ~60 operators | ~130 operators |
| **Community** | Apple documentation and WWDC sessions | Large open-source community, extensive tutorials |
| **Subject types** | `PassthroughSubject`, `CurrentValueSubject` | `PublishRelay`, `BehaviorRelay`, `ReplaySubject`, `AsyncSubject` |
| **Scheduler abstraction** | `Scheduler` protocol (RunLoop, DispatchQueue, OperationQueue) | `ImmediateScheduler`, `MainScheduler`, `ConcurrentDispatchQueueScheduler` |

## Alternatives

- **Swift async/await (iOS 15+)** — the modern default for most async work. Cleaner syntax, structured concurrency, and better tooling. Combine should be reserved for stream-processing scenarios.
- **RxSwift** — mature third-party reactive library with more operators, broader community, and iOS 12 support. Adds a dependency but is battle-tested in production apps since 2015.
- **AsyncStream + Task** — Apple's low-level concurrency primitives. Build custom reactive streams without Combine's overhead. Best for simple pub/sub within a module.
- **Delegate pattern** — the traditional Apple approach. Protocols with callbacks. More boilerplate but zero overhead and universally understood by iOS developers.
- **Closure-based callbacks** — simple and direct for one-off async operations. Does not compose well but requires no framework knowledge.
- **NotificationCenter** — built-in pub/sub for app-wide events. Unstructured and untyped but requires no setup. Wrap with Combine's `.publisher(for:)` for type safety.

## Failure Modes

1. **Cancellable not stored → immediate deallocation and subscription cancellation** → assigning `publisher.sink { ... }` to a local variable causes it to be deallocated at the end of the scope, silently stopping the stream → always store subscriptions in a `Set<AnyCancellable>` as an instance property: `cancellable.store(in: &subscriptions)`.

2. **Retain cycles in sink closures** → `[weak self]` is omitted, and the closure captures `self` strongly. The ViewModel is never deallocated because the subscription holds a strong reference, and the ViewModel holds the subscription → always capture `[weak self]` in `sink` closures: `.sink { [weak self] value in self?.handle(value) }`.

3. **Publishing on the wrong scheduler** → a network response publisher emits on a background queue, and the subscriber updates UI directly, causing undefined behavior or crashes → always specify `.receive(on: RunLoop.main)` before UI-affecting operators. Use `.subscribe(on: DispatchQueue.global())` for upstream work.

4. **`flatMap` vs `switchToLatest` confusion** → `flatMap` subscribes to all inner publishers concurrently, causing race conditions when a new search query fires before the previous one completes. `switchToLatest` cancels the previous inner publisher → use `switchToLatest` for search-type scenarios where only the latest result matters. Use `flatMap` for independent parallel operations.

5. **`@Published` mutation on a background thread** → a ViewModel's `@Published var isLoading = true` is set from a background task. SwiftUI re-renders on the wrong thread → all `@Published` mutations that affect UI must occur on the main thread. Use `MainActor` annotation on the ViewModel class or `.receive(on: RunLoop.main)`.

6. **Error pipeline silently terminating** → a publisher with a non-`Never` failure type encounters an error, and the subscription terminates without the error being handled → always handle errors in `sink(receiveCompletion:)` or use `.catch { _ in Just(fallback) }` to recover. A terminated publisher does not restart automatically.

7. **`share()` causing unexpected behavior** → calling `.share()` on a publisher turns it into a reference-type shared subscription. Subscribers that attach after values have been emitted miss those values → understand that `.share()` is for hot publishers. For cold publishers (like network requests), each subscriber triggers a new execution unless `.share()` is applied.

8. **Memory leaks from long-lived subjects** → a `PassthroughSubject` or `CurrentValueSubject` is held as a global singleton and accumulates subscribers that are never removed → subjects should be owned by the lifecycle of the component that publishes them (e.g., a ViewModel). Call `.send(completion: .finished)` when the component is destroyed.

9. **Over-engineering simple state** — wrapping a boolean toggle in a Combine pipeline with `map`, `removeDuplicates`, and `debounce` when a simple `@State var isOn: Bool` suffices → use Combine for streams of events over time, not for single-value state. Prefer SwiftUI's `@State` for simple UI state.

10. **Testing with real schedulers** — using `RunLoop.main` or `DispatchQueue.global()` in unit tests introduces timing-dependent flakiness → inject a `TestScheduler` (from the CombineTestSupport or a custom implementation) in tests to control time deterministically and advance the clock manually.

## Code Examples

### Search with Debounce and Cancellation (MVVM)

```swift
import Combine
import Foundation

class SearchViewModel: ObservableObject {
    @Published var query = ""
    @Published var results: [SearchResult] = []
    @Published var isLoading = false
    @Published var error: Error?

    private let apiClient: APIClient
    private var cancellables = Set<AnyCancellable>()

    init(apiClient: APIClient) {
        self.apiClient = apiClient

        $query
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .filter { !$0.isEmpty && $0.count >= 2 }
            .map { query -> AnyPublisher<[SearchResult], Error> in
                isLoading = true
                return apiClient.search(query: query)
                    .receive(on: DispatchQueue.main)
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let err) = completion {
                        self?.error = err
                    }
                },
                receiveValue: { [weak self] results in
                    self?.results = results
                    self?.error = nil
                }
            )
            .store(in: &cancellables)
    }
}
```

### Combining Multiple Publishers

```swift
class DashboardViewModel: ObservableObject {
    @Published var location: CLLocation?
    @Published var weather: Weather?
    @Published var dashboardState: DashboardState = .loading

    private let locationManager: LocationManager
    private let weatherService: WeatherService
    private var cancellables = Set<AnyCancellable>()

    init(locationManager: LocationManager, weatherService: WeatherService) {
        self.locationManager = locationManager
        self.weatherService = weatherService

        // Combine location and weather: emit whenever either updates
        // but only after both have emitted at least once
        Publishers.CombineLatest(locationManager.$location, weatherService.$weather)
            .receive(on: DispatchQueue.main)
            .map { location, weather -> DashboardState in
                .loaded(location: location, weather: weather)
            }
            .assign(to: &$dashboardState)

        // Fetch weather when location changes
        locationManager.$location
            .compactMap { $0 }
            .flatMap { [weak weatherService] location in
                weatherService?.fetchWeather(for: location)
                    .catch { _ in Just(nil) }
                    ?? Just(nil)
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$weather)
            .store(in: &cancellables)
    }
}

enum DashboardState {
    case loading
    case loaded(location: CLLocation, weather: Weather?)
}
```

### Bridging Combine to async/await

```swift
extension Publisher {
    /// Convert a Combine publisher to an async sequence for use with for-await
    var values: AsyncStream<Output> where Failure == Never {
        AsyncStream { continuation in
            let cancellable = sink(
                receiveCompletion: { _ in continuation.finish() },
                receiveValue: { continuation.yield($0) }
            )
            continuation.onTermination = { _ in cancellable.cancel() }
        }
    }
}

// Usage in a Swift Concurrency context:
func observeNotifications() async {
    let notificationCenter = NotificationCenter.default
    let publisher = notificationCenter.publisher(for: UIApplication.didEnterBackgroundNotification)

    for await _ in publisher.values {
        await saveAppState()
    }
}
```

### Unit Testing a Combine Publisher

```swift
import XCTest
import Combine

final class SearchViewModelTests: XCTestCase {
    var cancellables: Set<AnyCancellable>!
    let testScheduler = DispatchQueue.test // Xcode 14+ TestScheduler

    override func setUp() {
        cancellables = []
    }

    func test_queryDebounce_delaysSearch() {
        let mockAPI = MockAPIClient()
        let viewModel = SearchViewModel(apiClient: mockAPI)

        var emittedResults: [[SearchResult]] = []
        viewModel.$results
            .dropFirst() // skip initial empty value
            .sink { results in emittedResults.append(results) }
            .store(in: &cancellables)

        viewModel.query = "Swift"

        // Advance scheduler by less than debounce interval — no search yet
        testScheduler.advance(by: .milliseconds(200))
        XCTAssertTrue(emittedResults.isEmpty)

        // Advance past debounce — search should fire
        testScheduler.advance(by: .milliseconds(200))
        XCTAssertEqual(emittedResults.count, 1)
    }
}
```

## Best Practices

- **Always store cancellables.** A subscription that is not stored is deallocated immediately, and the stream never fires. Use `var cancellables = Set<AnyCancellable>()` as an instance property.
- **Use `@Published` for state that drives UI** and Combine operators for event streams. Do not use `@Published` for events that do not represent state (e.g., "button tapped" — use `PassthroughSubject<Void, Never>` instead).
- **Prefer `switchToLatest` over `flatMap`** when the inner publisher represents a request where only the latest response matters (search, typeahead, pagination).
- **Annotate ViewModels with `@MainActor`** to guarantee all published property mutations occur on the main thread. This prevents SwiftUI/UIKit thread-safety violations.
- **Use `removeDuplicates()`** on publishers that may emit the same value repeatedly (e.g., a location manager emitting the same coordinates). This prevents unnecessary UI updates.
- **Test with injected schedulers.** Do not use `RunLoop.main` or `DispatchQueue.global()` in unit tests. Inject a test scheduler and advance time deterministically.
- **Prefer async/await for new code** on iOS 15+ targets. Reserve Combine for scenarios where its stream operators (`combineLatest`, `debounce`, `merge`) provide clear value over `async let`.
- **Handle errors explicitly.** A publisher with a non-`Never` failure type will terminate the stream on error. Use `.catch` to recover or `.replaceError(with:)` to provide a default value.
- **Use `share()` sparingly.** It turns a cold publisher into a hot one, which can cause subscribers to miss values. Only use it when multiple subscribers should share a single underlying subscription (e.g., a network request that should not be duplicated).
- **Name your subscriptions.** When debugging, use `.handleEvents(receiveSubscription:)` to log subscription lifecycle events. This is invaluable for tracking down silent failures.

## Related Topics

- [[SwiftUI]]
- [[Swift]]
- [[iOSArchitecture]]
- [[Concurrency]]
- [[Mobile MOC]]
- [[MobileArchitecture]]
- [[MobileTesting]]
- [[iOSDataAndNetworking]]
