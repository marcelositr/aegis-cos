---
title: MVVM
layer: architecture
type: concept
priority: high
version: 2.0.0
tags:
  - Architecture
  - Mobile
  - Patterns
  - UI
  - StateManagement
description: Model-View-ViewModel architectural pattern that separates UI rendering from business logic through a testable, state-driven presentation layer.
---

# MVVM

## Description

MVVM (Model-View-ViewModel) is a UI architectural pattern that separates concerns into three layers:

- **Model** — domain data and business logic. Platform-agnostic. Contains entities, repositories, validation rules, and business invariants. Knows nothing about the UI.
- **View** — the UI layer (screens, components, widgets). Passive and declarative. Binds to the ViewModel's exposed state and forwards user interactions to it. Contains minimal logic: layout, styling, and data binding wiring.
- **ViewModel** — the presentation layer. Transforms Model data into UI-ready state, handles user interactions, manages loading/error states, and survives UI lifecycle events (screen rotation, background/foreground transitions). Contains no UI framework references.

The defining characteristic of MVVM (vs. MVP or MVC) is **data binding** — the View observes the ViewModel's state reactively and re-renders automatically when state changes. The ViewModel does not hold a reference to the View. This unidirectional dependency (View → ViewModel → Model) enables unit testing of presentation logic without a UI runtime.

### Data Flow

```
User interaction → View → Command → ViewModel → State emission → View (auto-update)
                                                    ↓
                                               Model (fetch/mutate)
                                                    ↓
                                         ViewModel transforms → new State
```

The ViewModel exposes **state streams** (observables, StateFlows, reactive signals) that the View subscribes to. The View never pulls data from the ViewModel — the ViewModel pushes state, and the View renders it.

## When to Use

- **Medium-to-complex mobile applications** — apps with multiple screens, non-trivial business logic, and state that survives configuration changes. MVVM's testability and separation of concerns pay dividends as complexity grows.
- **Teams practicing test-driven development** — ViewModel logic is pure (no UI framework dependencies), making it trivially unit-testable. You can test loading states, error handling, data transformation, and navigation decisions without an emulator.
- **Apps with frequent UI redesigns or multi-platform targets** — the ViewModel is platform-agnostic. The same ViewModel can drive an Android View, an iOS UIView, or a web component. Only the View layer is platform-specific.
- **Reactive UI frameworks** — Jetpack Compose, SwiftUI, Flutter (with reactive state management) map naturally to MVVM because they are declarative and state-driven. The ViewModel emits state, the framework renders it.

## When NOT to Use

- **Simple screens with minimal logic** — a settings screen with toggle switches and a text input does not need a ViewModel. The added abstraction (state streams, binding, testing infrastructure) costs more than it saves. Use simple component-level state.
- **Highly animated, gesture-driven UI** — complex animations, drag interactions, and physics-based UI (games, drawing apps, media players) require tight coupling between user input and rendering. MVVM's indirection through the ViewModel adds latency to the input→render pipeline. Use pattern variants or direct event handling for these screens.
- **Teams without reactive programming experience** — MVVM requires understanding of observables, subscription lifecycle, and state management. If the team is not comfortable with reactive streams, the implementation will have memory leaks, race conditions, and untestable ViewModels.
- **When you need fine-grained render control** — MVVM abstracts the render cycle. If you need to control exactly when and how rendering happens (custom view rendering, OpenGL surfaces), MVVM's declarative binding is a mismatch.

## Tradeoffs

### MVVM vs. MVP (Model-View-Presenter)

| Dimension | MVVM | MVP |
|-----------|------|-----|
| **View reference** | ViewModel has NO reference to View (data binding) | Presenter holds interface reference to View |
| **Testability** | ViewModel is fully testable (no UI deps) | Presenter testable but needs View mock interface |
| **Boilerplate** | Higher (binding setup, state streams) | Lower (direct method calls) |
| **Learning curve** | Requires reactive programming knowledge | Straightforward OOP |
| **UI framework coupling** | None in ViewModel | Presenter depends on View interface |
| **Best for** | Declarative UIs, complex state, multi-platform | Imperative UIs, simpler screens, small teams |

### MVVM vs. MVI (Model-View-Intent)

| Dimension | MVVM | MVI |
|-----------|------|-----|
| **State model** | Multiple state properties (isLoading, data, error) | Single immutable state object |
| **Intent handling** | Individual methods per user action | Unified intent dispatch |
| **State transitions** | Implicit (set each property independently) | Explicit (reducer function: State + Intent → State) |
| **Debuggability** | Harder to trace state changes (multiple streams) | Full state history via intent log |
| **Complexity** | Moderate | Higher (requires reducer, state machine mental model) |
| **Best for** | Most mobile apps | Apps requiring reproducible state debugging, undo/redo |

MVI is essentially MVVM with a single state object and explicit state transitions. Many teams start with MVVM and migrate individual ViewModels to MVI when state debugging becomes difficult.

### MVVM vs. Clean Architecture

MVVM and Clean Architecture are complementary, not competing. MVVM organizes the **presentation layer**. Clean Architecture organizes the **entire application** (presentation, domain, data layers). In a Clean Architecture + MVVM stack:

```
Presentation Layer (MVVM)
├── View (Activity/Fragment/Composable/UIView)
├── ViewModel (presentation logic, state management)
└── (uses)

Domain Layer (Clean Architecture)
├── Use Cases / Interactors (single-responsibility business logic)
├── Entities (domain models)
└── Repository interfaces

Data Layer (Clean Architecture)
├── Repository implementations
├── Data sources (API, database, cache)
└── DTOs and mappers
```

The ViewModel calls Use Cases. Use Cases call Repositories. Each layer depends only on the layer below it (dependency rule).

## Alternatives

- **MVC (Model-View-Controller)** — the original pattern. Controller mediates between View and Model. On mobile, MVC often devolves into "Massive View Controller" because the framework forces lifecycle and rendering logic into the same class as presentation logic. Avoid on mobile.
- **MVP (Model-View-Presenter)** — Presenter holds a reference to a View interface. More testable than MVC but still requires mock View interfaces. A reasonable choice for teams not ready for reactive programming.
- **MVI (Model-View-Intent)** — single state object, explicit intents, reducer-based transitions. More predictable state management at the cost of higher boilerplate. See tradeoff table above.
- **Component-level state** — for simple screens, keep state in the UI component itself (React `useState`, Compose `remember`, SwiftUI `@State`). No separate ViewModel needed. This is the right default for simple screens.
- **Redux/Flux** — global state container with unidirectional data flow. Overkill for most mobile apps. Appropriate when many screens share the same state (e.g., a social app with a global user session and notification state).

## Failure Modes

1. **Massive ViewModel** — the ViewModel accumulates 500+ lines of business logic, data transformation, navigation decisions, and analytics tracking. It becomes as unmaintainable as the "Massive View Controller" it was meant to replace. Real cause: using ViewModel as a god object for the entire screen instead of a presentation transformer. Mitigation: extract business logic to Use Cases / Interactors. The ViewModel should orchestrate, not compute. If a ViewModel method exceeds 50 lines, the logic belongs in the domain layer. Apply the single-responsibility principle: one ViewModel per screen scope, not per feature.

2. **ViewModel holds View references (memory leaks)** — the ViewModel stores a reference to the View (Activity, Fragment, ViewController) or to View-specific types (TextView, UILabel). When the View is destroyed (configuration change, navigation back), the GC cannot collect it because the ViewModel (which survives configuration changes) holds a reference. Memory accumulates with each rotation until OOM. Mitigation: the ViewModel must NEVER import UI framework types. Use one-way data binding or reactive streams. If the ViewModel needs to trigger navigation, use a navigation event channel (SharedFlow, NavigateEffect, callback interface), not a direct View reference.

3. **Missing subscription disposal** — the View subscribes to ViewModel state streams but never unsubscribes when the View is destroyed. Each screen open adds new subscriptions. After 20 opens, 20 subscriptions fire on each state emission, causing duplicate renders, duplicate API calls, and memory growth. Mitigation: tie subscription lifecycle to View lifecycle. In Android: `viewLifecycleOwner.lifecycleScope.launchWhenStarted`. In iOS: store cancellables and cancel in `onDisappear`. In Flutter: dispose controllers in `dispose()`. Framework-managed bindings (Compose, SwiftUI) handle this automatically — prefer them when available.

4. **ViewModels testing business logic instead of presentation logic** — testing repository implementations, network calls, or database queries inside the ViewModel. The ViewModel should not contain business logic — it should delegate to Use Cases. What you test in the ViewModel is: "given this Use Case output, does the ViewModel produce the correct UI state?" Mitigation: mock all Use Cases in ViewModel tests. Test business logic in Use Case tests. Test data fetching in Repository tests. Each layer tests its own responsibility.

5. **State explosion — too many independent state properties** — a ViewModel exposes `isLoading: Boolean`, `isError: Boolean`, `data: List<T>?`, `errorMessage: String?`, `isRefreshing: Boolean`, `hasMore: Boolean`, etc. These properties are independent, so the View can observe contradictory states (`isLoading = true` AND `isError = true` AND `data = [...]` simultaneously). The UI renders nonsensical combinations. Mitigation: use a **sealed state class** (single source of truth) that represents all mutually exclusive states:

```kotlin
// Good: sealed state — only one state is active at a time
sealed class UserListState {
    object Loading : UserListState()
    data class Success(val users: List<User>, val hasMore: Boolean) : UserListState()
    data class Error(val message: String, val retryable: Boolean) : UserListState()
    object Empty : UserListState()
}

// ViewModel exposes a single stream
val state: StateFlow<UserListState> = _state

// View renders exactly one state
when (state) {
    is Loading -> showLoading()
    is Success -> showUsers(state.users, state.hasMore)
    is Error -> showError(state.message, state.retryable)
    Empty -> showEmpty()
}
```

6. **Two-way data binding creates untraceable state mutations** — two-way binding (the View can write to ViewModel properties and the ViewModel can write to View properties) makes it impossible to determine the source of a state change. A text field updates the ViewModel, which updates another property, which triggers a re-render, which triggers another update — an infinite loop. Mitigation: **prefer one-way binding**. The ViewModel emits state, the View renders it. User input is sent to the ViewModel as events/commands, not as direct property writes. If two-way binding is unavoidable (form inputs), use explicit event handlers, not automatic binding.

7. **ViewModel survives beyond its screen scope** — a ViewModel scoped to an Activity survives when the user navigates to a different screen within the same Activity. The old ViewModel accumulates stale state and subscriptions. When the user navigates back, the UI renders stale data. Mitigation: scope ViewModels to the correct lifecycle boundary. In Android: ViewModel scoped to a Fragment (not the parent Activity) for per-screen state. In iOS: ViewModel created in `viewDidLoad` and nulled in `deinit`. Use navigation-aware scoping that clears ViewModels when the back stack is popped.

8. **No handling of ViewModel-side errors** — the ViewModel calls a Use Case, the Use Case throws, and the ViewModel does not catch it. The error crashes the app, or worse, the stream terminates silently and the View shows a perpetual loading spinner. Mitigation: every ViewModel must handle both success and error paths from its dependencies:

```kotlin
fun loadUsers() {
    viewModelScope.launch {
        _state.value = UserListState.Loading
        try {
            val users = getUsersUseCase()
            _state.value = if (users.isEmpty()) {
                UserListState.Empty
            } else {
                UserListState.Success(users, hasMore = users.size == PAGE_SIZE)
            }
        } catch (e: NetworkException) {
            _state.value = UserListState.Error(
                message = "Connection failed. Check your network.",
                retryable = true
            )
        } catch (e: Exception) {
            _state.value = UserListState.Error(
                message = "An unexpected error occurred",
                retryable = false
            )
            // Log non-retryable errors for investigation
            logger.error("Unexpected error loading users", e)
        }
    }
}
```

9. **Configuration change state loss** — the ViewModel is destroyed and recreated on configuration change (screen rotation, locale change, dark mode toggle) because it was not properly scoped or saved. All in-flight requests and UI state are lost. The user sees a loading spinner and loses their scroll position. Mitigation: use framework-managed ViewModel scoping (Android `ViewModelProvider`, iOS `@StateObject` with `@ObservedObject` passthrough). For state that must survive process death (not just configuration change), use `SavedStateHandle` or persistent storage.

## Best Practices

1. **One ViewModel per screen scope** — a ViewModel manages the state of a single screen. Do not share ViewModels across screens (use a shared state container like Redux or a domain-level service for cross-screen state). Do not use one ViewModel for multiple screens (it becomes a god object).

2. **ViewModels are dumb orchestrators** — the ViewModel's job is: call Use Cases, transform their output into UI state, and emit it. Business logic, data validation, caching decisions, and error classification belong in Use Cases. If your ViewModel has more than 200 lines, extract logic downward.

3. **Expose immutable state** — the View observes state but never mutates it. User interactions are sent as events to the ViewModel, which produces new state. This unidirectional flow makes state changes predictable and testable.

4. **Test ViewModels with mocked dependencies** — ViewModel tests should not make network calls, hit databases, or require a UI framework. Mock all Use Cases. Test state transitions: "when Use Case returns X, ViewModel emits state Y." Test error paths: "when Use Case throws, ViewModel emits error state."

5. **Handle loading, error, empty, and content states explicitly** — every screen has at least these four states. Model them as a sealed type (see Failure Mode 5). Never represent them as independent booleans.

6. **Never import UI framework types into the ViewModel** — this is the MVVM invariant. If your ViewModel imports `android.widget`, `UIKit`, `Material`, or any UI package, you have broken the pattern and created a memory leak risk. Use a linter rule to enforce this.

7. **Use framework-managed lifecycle integration** — let the framework manage subscription disposal and ViewModel lifecycle. Jetpack Compose's `collectAsStateWithLifecycle`, SwiftUI's `@ObservedObject`, and Flutter's `StreamBuilder` handle subscription cleanup automatically. Prefer these over manual subscription management.

8. **Design for offline and degraded states** — mobile networks are unreliable. The ViewModel must handle: no network, slow network, partial data, cached data, and stale data. Expose these as explicit states, not as errors. A screen showing cached data with a "last updated 3 hours ago" banner is better than an error screen.

9. **Separate navigation from ViewModel** — the ViewModel decides *what* happens next (e.g., "navigate to detail screen with this ID") but does not perform the navigation. It emits a navigation event that the View's navigation handler executes. This keeps the ViewModel testable and platform-agnostic.

10. **Audit ViewModel dependencies regularly** — if a ViewModel depends on more than 3-4 Use Cases, it is doing too much. Split the screen or extract a child ViewModel. A screen with tabs or sections often maps to a parent ViewModel (screen-level state) and child ViewModels (section-level state).

## Related Topics

- [[Architecture]] — MVVM as a presentation-layer pattern
- [[SeparationOfConcerns]] — the principle that MVVM implements
- [[StateManagement]] — managing UI state reactively
- [[Mobile]] — mobile-specific constraints (lifecycle, connectivity, memory)
- [[Android]] and [[iOS]] — platform-specific MVVM implementations
- [[Quality]] and [[CodeQuality]] — testing ViewModels as a quality gate
- [[ErrorHandling]] — how ViewModels handle and expose error states
- [[Resilience]] — offline-first and degraded-state handling in mobile ViewModels
- [[Design]] — UI design patterns that pair with MVVM
- [[Modularity]] and [[Cohesion]] — keeping ViewModels focused and cohesive
- [[Layering]] — where MVVM fits in the overall architecture
- [[Coupling]] — MVVM reduces coupling between UI and business logic
- [[ReactiveProgramming]] — the programming model that makes MVVM practical
- [[Testing]] — unit testing ViewModel logic without UI dependencies
