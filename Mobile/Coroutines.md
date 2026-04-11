---
title: Kotlin Coroutines
layer: mobile
type: concept
priority: high
version: 2.0.0
tags:
  - Mobile
  - Kotlin
  - Concurrency
  - Async
  - StructuredConcurrency
  - Android
description: Kotlin's lightweight concurrency model for writing asynchronous, non-blocking code in a sequential style using suspending functions, structured concurrency, and composable builders.
---

# Kotlin Coroutines

## Description

Kotlin Coroutines are a concurrency design pattern that simplifies asynchronous programming by allowing you to write non-blocking code in a sequential, imperative style. Unlike threads (which are managed by the OS and cost ~1MB of stack memory each), coroutines are managed entirely by the Kotlin runtime and cost only a few dozen bytes. A single thread can run thousands of concurrent coroutines.

Core concepts:
- **Suspending functions** (`suspend fun`) — functions that can pause execution without blocking the underlying thread. They can only be called from other suspending functions or from a coroutine body. The compiler transforms them into state machines (continuation-passing style).
- **CoroutineScope** — defines the lifecycle of coroutines. All coroutines must run within a scope. When the scope is cancelled, all child coroutines are cancelled automatically (structured concurrency). Common scopes: `CoroutineScope(Dispatchers.Main)`, `lifecycleScope` (Android Activity/Fragment), `viewModelScope` (Android ViewModel).
- **CoroutineContext** — a set of configuration elements for a coroutine: `Job` (lifecycle), `CoroutineDispatcher` (thread pool), `CoroutineName`, `CoroutineExceptionHandler`. Contexts are composable: `Dispatchers.IO + Job() + CoroutineName("FetchUser")`.
- **Dispatchers** — determine which thread(s) execute the coroutine:
  - `Dispatchers.Main` — Android UI thread. For UI updates only.
  - `Dispatchers.IO` — optimized for I/O-bound work (network, database, file). Shares threads with `Default`, capped at 64 or the number of cores (whichever is larger).
  - `Dispatchers.Default` — optimized for CPU-intensive work (JSON parsing, sorting, encryption). Capped at the number of CPU cores.
  - `Dispatchers.Unconfined` — starts in the current thread but may resume on any thread. Rarely used in production.
- **Coroutine builders** — `launch` (fire-and-forget, returns `Job`), `async` (returns a result via `Deferred<T>`), `runBlocking` (blocks the current thread — only for tests and `main()`).
- **Structured concurrency** — child coroutines are scoped to their parent. If a child fails, the parent and all siblings are cancelled. If the parent is cancelled, all children are cancelled. This eliminates coroutine leaks.
- **Flow** — a cold asynchronous stream that emits multiple values sequentially. The cold analogue of `Sequence`. Built on coroutines and supports operators like `map`, `filter`, `debounce`, `combine`. Replaces RxJava/Kotlin Flow in most Android applications.

## When to Use

- **Replacing callbacks and listeners** — network calls, database queries, and file operations that previously required callbacks become sequential code with `suspend` functions.
- **Concurrent decomposition** — fetching data from three independent APIs and combining the results. `async { }` for each API, then `awaitAll()`. Far cleaner than `CountDownLatch` or callback nesting.
- **Android lifecycle-aware work** — `lifecycleScope.launchWhenStarted` or `repeatOnLifecycle` runs coroutines only when the Activity/Fragment is in a specific lifecycle state, preventing crashes from updates to destroyed views.
- **ViewModel-scoped background work** — `viewModelScope.launch` automatically cancels when the ViewModel is cleared (e.g., the user navigates away), preventing memory leaks and wasted work.
- **Stream processing with Flow** — observing database changes (Room returns `Flow<List<T>>`), processing sensor data streams, or implementing typeahead search with debouncing.
- **Retry logic with exponential backoff** — coroutines make retry loops natural: `retry(3) { attemptNetworkCall() }` with `delay()` between attempts. No callback recursion needed.
- **Channel-based communication** — `Channel<T>` for producer-consumer patterns where multiple coroutines produce values and one or more consume them. Used for event buses, command queues, and inter-coroutine signaling.

## When NOT to Use

- **Simple synchronous code** — if your function does not perform I/O or long-running computation, do not wrap it in a coroutine. The overhead and complexity are unnecessary.
- **Blocking operations without `withContext`** — calling blocking Java/Android APIs (e.g., `Thread.sleep`, blocking HTTP clients) inside a coroutine does not make them non-blocking. Use non-blocking alternatives or wrap with `withContext(Dispatchers.IO)`.
- **When the team has no Kotlin experience** — coroutines require understanding of structured concurrency, dispatchers, exception propagation, and Flow. Without proper training, teams introduce subtle bugs (leaked coroutines, wrong dispatchers, swallowed exceptions).
- **In tight computational loops with strict latency requirements** — coroutine suspension/resumption adds ~50–200ns overhead. For sub-microsecond hot paths (real-time audio processing, high-frequency trading), use direct thread manipulation or native code.
- **When you need fine-grained thread pool control** — coroutines use shared dispatcher pools. You cannot set per-coroutine thread priorities, stack sizes, or thread-local storage. Use `ExecutorService` for these requirements.
- **Interoperating with Java code that expects `Future` or `CompletableFuture`** — while `kotlinx-coroutines-jdk8` provides bridges, the impedance mismatch between CompletableFuture's API and Kotlin's structured concurrency model causes confusion.

## Tradeoffs

| Dimension | Coroutines | RxJava |
|-----------|-----------|--------|
| **Readability** | Sequential, imperative style | Reactive chain with operators |
| **Learning curve** | Moderate (structured concurrency is intuitive) | Steep (130+ operators, backpressure, schedulers) |
| **Error handling** | Standard `try/catch` in sequential code | Error channel in the stream |
| **Backpressure** | Flow has built-in buffer and `collectLatest` | Complex (`onBackpressureBuffer`, `onBackpressureDrop`) |
| **Binary size** | ~1 MB (kotlinx-coroutines-core) | ~2 MB (RxJava2/RxJava3) |
| **Android integration** | `lifecycleScope`, `viewModelScope` built-in | Requires `RxAndroid`, `RxLifecycle` |
| **Cancellation** | Structured (parent cancels children) | Manual (`Disposable.dispose()`) |
| **Hot streams** | `StateFlow`, `SharedFlow` | `BehaviorSubject`, `PublishSubject` |

| Dimension | Coroutines | Threads |
|-----------|-----------|---------|
| **Memory per unit** | ~50 bytes (continuation object) | ~1 MB (stack) |
| **Max concurrent units** | Millions (limited by heap) | Hundreds (limited by memory) |
| **Creation cost** | Negligible (object allocation) | Expensive (OS syscall, stack allocation) |
| **Context switching** | Cooperative (at suspension points) | Preemptive (OS scheduler) |
| **Debugging** | Structured; coroutines appear in debuggers | Thread dumps; harder to trace async work |

## Alternatives

- **RxJava** — mature reactive library with a vast operator set. Still widely used in legacy Android codebases. Coroutines have largely replaced it for new development due to better readability and Android lifecycle integration.
- **ExecutorService / ThreadPoolExecutor** — Java's traditional thread pool. More control over thread configuration but verbose and error-prone for async composition.
- **Kotlin Flow** — technically part of coroutines, but as a distinct abstraction. Use Flow for streams of values; use `launch`/`async` for one-shot async operations.
- **WorkManager** — Android's API for deferrable, guaranteed background work. Use WorkManager for work that must complete even if the app is killed (e.g., uploading logs). Use coroutines for work tied to the app's lifecycle.
- **LiveData** — Android Architecture component for lifecycle-aware data holding. Simpler than Flow but lacks operators and composition. Flow with `.asLiveData()` bridges the gap.
- **Callbacks** — the baseline. Simple for one-off operations but does not compose. Coroutines replaced callbacks as the standard in modern Android.

## Failure Modes

1. **Coroutine leaks from fire-and-forget launch** — launching a coroutine in `GlobalScope.launch` that outlives its intended lifecycle, holding references and continuing to consume resources → never use `GlobalScope` in production. Use `viewModelScope`, `lifecycleScope`, or a custom scope tied to a specific lifecycle. `GlobalScope` should only be used for truly global, app-lifetime work (e.g., a singleton analytics sender).

2. **Blocking the main thread via improper dispatcher use** — calling a suspending function that performs CPU-intensive work or blocking I/O on `Dispatchers.Main`, freezing the UI for seconds → always wrap blocking or CPU-heavy work with `withContext(Dispatchers.IO)` or `withContext(Dispatchers.Default)`. Use kotlinx-lint to detect dispatcher violations at compile time.

3. **Exception swallowing in `launch`** — an exception in a `launch` coroutine propagates to the scope's `CoroutineExceptionHandler` and crashes the app if unhandled. Wrapping the entire body in `try/catch` silently suppresses the error → handle specific exceptions where they occur, and let unexpected exceptions propagate. Use a `CoroutineExceptionHandler` on the scope to log uncaught exceptions:
   ```kotlin
   val scope = CoroutineScope(SupervisorJob() + CoroutineExceptionHandler { _, e ->
       Timber.e(e, "Uncaught coroutine exception")
   })
   ```

4. **Race conditions on mutable shared state** — multiple coroutines concurrently modifying a `var` or `MutableList` without synchronization → coroutines on the same dispatcher can interleave at suspension points. Use `Mutex` for async-safe mutual exclusion, or isolate state to a single coroutine via a `Channel` (actor pattern). For simple cases, use `AtomicInteger`, `AtomicReference`, etc.

5. **`async` exception propagation to the parent** — exceptions in `async` are rethrown when `.await()` is called. If `.await()` is never called, the exception is silently swallowed. If the parent `coroutineScope` is used, the exception propagates immediately and cancels siblings → use `supervisorScope` if you want sibling coroutines to survive each other's failures. Always call `.await()` to surface exceptions.

6. **`StateFlow` missing initial values** — a `StateFlow` is created with an initial value, but collectors that start late miss intermediate emissions → `StateFlow` always replays the latest value to new collectors. If you need to replay multiple values, use `SharedFlow` with `replay = N`.

7. **`collectLatest` vs `collect` confusion** — `collectLatest` cancels the previous collection when a new value arrives, which is desired for search-type scenarios but causes data loss for events that must all be processed (e.g., analytics events) → use `collect` for event streams where every emission must be processed. Use `collectLatest` only when you want to abandon stale work.

8. **Dispatcher starvation under heavy load** — `Dispatchers.IO` and `Dispatchers.Default` share a thread pool (64 threads max). If 64 coroutines are blocked on I/O simultaneously, no new coroutines can run → this is rare but happens when wrapping blocking APIs. Use `newFixedThreadPoolContext(N, "custom-pool")` for isolation, or ensure all I/O is truly non-blocking.

9. **Cancellation not being cooperative** — a coroutine is cancelled, but the code inside ignores cancellation (e.g., a long computation loop that does not check `isActive`) → the coroutine continues running until completion, wasting resources → periodically check `ensureActive()` or `isActive` in long-running loops. Suspending functions like `delay()` and `withContext` automatically check for cancellation.

10. **Testing with real dispatchers causing flaky tests** — using `Dispatchers.Main` or `Dispatchers.IO` in unit tests introduces non-deterministic timing → inject `TestDispatcher` (e.g., `StandardTestDispatcher()`) and use `runTest { }` from `kotlinx-coroutines-test`. Call `scheduler.advanceUntilIdle()` to control execution order deterministically.

## Code Examples

### Concurrent API Calls with Error Handling

```kotlin
data class Dashboard(
    val user: User,
    val orders: List<Order>,
    val notifications: List<Notification>
)

suspend fun loadDashboard(userId: String): Dashboard = coroutineScope {
    // All three calls run concurrently
    val userDeferred = async { api.getUser(userId) }
    val ordersDeferred = async { api.getOrders(userId) }
    val notificationsDeferred = async { api.getNotifications(userId) }

    // awaitAll fails fast — if any call fails, all are cancelled
    Dashboard(
        user = userDeferred.await(),
        orders = ordersDeferred.await(),
        notifications = notificationsDeferred.await()
    )
}

// With supervisorScope, one failure doesn't cancel siblings:
suspend fun loadDashboardResilient(userId: String): Dashboard = supervisorScope {
    val userDeferred = async {
        try { api.getUser(userId) } catch (e: Exception) {
            User.anonymous
        }
    }
    val ordersDeferred = async {
        try { api.getOrders(userId) } catch (e: Exception) {
            emptyList()
        }
    }
    val notificationsDeferred = async {
        try { api.getNotifications(userId) } catch (e: Exception) {
            emptyList()
        }
    }

    Dashboard(
        user = userDeferred.await(),
        orders = ordersDeferred.await(),
        notifications = notificationsDeferred.await()
    )
}
```

### ViewModel with Structured Concurrency

```kotlin
class OrderViewModel(
    private val orderRepository: OrderRepository,
    private val savedStateHandle: SavedStateHandle
) : ViewModel() {

    private val _uiState = MutableStateFlow<OrderUiState>(OrderUiState.Loading)
    val uiState: StateFlow<OrderUiState> = _uiState.asStateFlow()

    init {
        // viewModelScope automatically cancels when ViewModel is cleared
        viewModelScope.launch {
            val orderId = savedStateHandle.get<String>("orderId")
                ?: run {
                    _uiState.value = OrderUiState.Error("Missing order ID")
                    return@launch
                }

            _uiState.value = OrderUiState.Loading
            try {
                val order = orderRepository.getOrder(orderId)
                _uiState.value = OrderUiState.Ready(order)
            } catch (e: HttpException) {
                _uiState.value = OrderUiState.Error("Network error: ${e.code()}")
            } catch (e: IOException) {
                _uiState.value = OrderUiState.Error("Check your connection")
            }
        }
    }

    fun retry() {
        // Re-launches the init logic; in practice, extract to a separate function
        viewModelScope.launch { /* same as init */ }
    }
}

sealed class OrderUiState {
    object Loading : OrderUiState()
    data class Ready(val order: Order) : OrderUiState()
    data class Error(val message: String) : OrderUiState()
}
```

### Flow with Debounce and Network Switch

```kotlin
class SearchViewModel(
    private val searchRepository: SearchRepository
) : ViewModel() {

    private val _query = MutableStateFlow("")
    val results: Flow<List<SearchResult>> = _query
        .debounce(300)           // Wait for typing to settle
        .filter { it.length >= 2 }
        .distinctUntilChanged()  // Skip duplicate queries
        .flatMapLatest { query ->  // Cancel previous search when query changes
            searchRepository.search(query)
                .flowOn(Dispatchers.IO)  // Run search on IO dispatcher
                .catch { e ->
                    emit(emptyList())
                    Log.e("Search", "Search failed", e)
                }
        }
        .stateIn(
            scope = viewModelScope,
            started = SharingStarted.WhileSubscribed(5_000), // Keep alive 5s after last subscriber
            initialValue = emptyList()
        )

    fun onQueryChanged(query: String) {
        _query.value = query
    }
}
```

### Retry with Exponential Backoff

```kotlin
suspend fun <T> withRetry(
    maxRetries: Int = 3,
    initialDelay: Long = 500,
    maxDelay: Long = 10_000,
    factor: Double = 2.0,
    block: suspend () -> T
): T {
    var currentDelay = initialDelay
    repeat(maxRetries) { attempt ->
        try {
            return block()
        } catch (e: Exception) {
            if (attempt == maxRetries - 1) throw e
            delay(currentDelay)
            currentDelay = (currentDelay * factor).toLong().coerceAtMost(maxDelay)
        }
    }
    throw IllegalStateException("Should not reach here")
}

// Usage
suspend fun fetchWithRetry(userId: String): User = withRetry(
    maxRetries = 3,
    initialDelay = 1_000
) {
    apiClient.getUser(userId)
}
```

### Unit Testing Coroutines

```kotlin
class OrderViewModelTest {
    @Test
    fun `loading order shows ready state`() = runTest {
        val mockRepo = FakeOrderRepository(
            orders = mapOf("ord-1" to Order("ord-1", "Pizza", 12.99))
        )
        val viewModel = OrderViewModel(mockRepo, SavedStateHandle(mapOf("orderId" to "ord-1")))

        // Advance past all coroutine work
        scheduler.advanceUntilIdle()

        val state = viewModel.uiState.value
        assertTrue(state is OrderUiState.Ready)
        assertEquals("Pizza", (state as OrderUiState.Ready).order.itemName)
    }
}
```

## Best Practices

- **Follow structured concurrency.** Every coroutine must have a scope. Use `viewModelScope`, `lifecycleScope`, or a custom scope. Never use `GlobalScope` except for app-lifetime singleton work.
- **Use `withContext` for dispatcher switches.** Do not launch new coroutines just to change dispatchers. `withContext(Dispatchers.IO) { ... }` is the idiomatic way to shift execution.
- **Prefer `suspend` functions over callbacks.** Transform callback-based APIs with `suspendCancellableCoroutine { continuation -> ... }` to expose them as suspending functions.
- **Use `StateFlow` instead of `LiveData` for new code.** `StateFlow` is a pure Kotlin construct, supports all Flow operators, and integrates with the entire coroutines ecosystem. Use `.asLiveData()` when you need to expose to legacy LiveData consumers.
- **Handle exceptions at the right level.** Use `try/catch` around specific operations that can fail. Use `CoroutineExceptionHandler` on the scope as a last-resort safety net. Do not catch `CancellationException` — it is how coroutines communicate cancellation.
- **Use `supervisorScope` or `SupervisorJob`** when sibling coroutines should not cancel each other. For example, loading three independent sections of a screen: if the "recommendations" section fails, the "product details" section should still display.
- **Name your coroutines for debugging.** Add `+ CoroutineName("FetchOrder")` to the context. In debug mode, coroutine names appear in logcat and thread dumps.
- **Use `runTest` and `TestDispatcher` for unit tests.** Never use real dispatchers in tests. `runTest` replaces the default dispatcher with a test dispatcher that you control deterministically.
- **Avoid mutable state shared across coroutines.** If you must share state, use `Mutex` or `AtomicReference`. Prefer passing state through `Channel` or `Flow` so ownership is clear.
- **Use `flatMapLatest` for search/typeahead scenarios.** It cancels the previous inner flow when a new value arrives, preventing race conditions where an older, slower request completes after a newer one.

## Related Topics

- [[Concurrency]]
- [[Kotlin]]
- [[Android]]
- [[Mobile MOC]]
- [[MobileArchitecture]]
- [[MobileTesting]]
- [[Flow]]
- [[StructuredConcurrency]]
- [[CoroutinesVsRxJava]]
