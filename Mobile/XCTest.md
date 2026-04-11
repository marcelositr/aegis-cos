---
title: XCTest
layer: mobile
type: concept
priority: high
version: 2.0.0
tags:
  - Mobile
  - iOS
  - Testing
  - XCTest
  - UnitTesting
  - UITesting
  - Apple
description: Apple's native testing framework for unit tests, performance tests, and UI automation tests in iOS, macOS, watchOS, and tvOS applications.
---

# XCTest

## Description

XCTest is Apple's built-in testing framework for all Apple platforms. It provides three testing paradigms:

1. **Unit tests** — test individual classes and functions in isolation. Run at native speed with no app launch. Use mocks and stubs for dependencies. Subclass `XCTestCase` and use `XCTAssert` macros.
2. **Performance tests** — measure execution time of code blocks using `measure { }`. XCTest runs the block 10 times, computes baseline, and fails if the new run exceeds the baseline by more than 10% (configurable). Integrated with Xcode's performance test reports.
3. **UI tests** — automate the app's UI using `XCUIApplication`, `XCUIElement`, and `XCUIElementQuery`. Launches the app in a simulator or device, interacts with UI elements by accessibility identifiers, and asserts on UI state. Runs in a separate process from the app.

Core components:
- **XCTestCase** — the base class for test classes. Each `test...` method is a test case. `setUp()` runs before each test; `tearDown()` runs after. `setUpWithError()` and `tearDownWithError()` support throwing errors.
- **XCTAssert macros** — `XCTAssertTrue`, `XCTAssertEqual`, `XCTAssertNil`, `XCTAssertThrowsError`, `XCTAssertNoThrow`, `XCTUnwrap`, `XCTFail`. Each takes an optional message parameter.
- **XCTExpectFailure** — marks a test as expected to fail, useful for TDD when writing the test before the implementation.
- **XCTestExpectation** — for testing asynchronous code. Create an expectation, fulfill it in the async callback, and wait with a timeout: `waitForExpectations(timeout: 5)`.
- **XCUIApplication** — the test proxy for the app under test. Launches the app in a separate process. `app.launch()` and `app.terminate()`.
- **XCUIElement** — a query for a UI element: `app.buttons["Submit"]`, `app.tables.cells["order-42"]`. Queries are lazy — the element is not resolved until an action or assertion is performed.
- **XCUIElementQuery** — the mechanism for finding elements: `app.descendants(matching: .button)`, `app.staticTexts.containing(NSPredicate(format: "label BEGINSWITH 'Order'"))`.

## When to Use

- **All iOS/macOS projects** — XCTest is the default testing framework. It is built into Xcode, requires no dependencies, and integrates with Xcode's test navigator, CI, and code coverage tools.
- **Unit testing business logic** — ViewModels, use cases, repositories, network parsers, data transformers, validators, and formatters. These are pure Swift classes with no UIKit/AppKit dependencies and are ideal for fast, deterministic unit tests.
- **Performance regression testing** — critical code paths (JSON parsing, image processing, database queries, encryption) should have performance tests with baselines. CI can fail builds if performance regresses beyond a threshold.
- **UI smoke testing** — launch the app, navigate to each major screen, and verify it renders without crashing. This catches missing assets, broken navigation, and runtime layout errors.
- **Accessibility testing** — UI tests verify that elements have accessibility identifiers, labels, and hints. `XCTAssertTrue(app.buttons["Submit"].exists)` doubles as an accessibility check.
- **Integration testing with test hosts** — tests that require the full app environment (Core Data stack, Keychain, UserDefaults) can run with a test host (`Host Application` in the test target settings). This provides the real app delegate and dependency graph.

## When NOT to Use

- **Snapshot/visual regression testing** — XCTest does not compare screenshots. Use Point-Free's `SnapshotTesting` or `iOSSnapshotTestCase` for pixel-perfect UI verification.
- **Property-based testing** — XCTest does not generate random inputs and verify invariants. Use `SwiftCheck` or `Issue` for property-based testing alongside XCTest.
- **BDD-style tests** — XCTest's `XCTAssert` model is not designed for Given/When/Then syntax. Use `Quick`/`Nimble` if your team prefers BDD.
- **Network-level integration testing** — XCTest can make real network calls, but it lacks built-in mock server capabilities. Use `OHHTTPStubs` or `Mockingbird` to stub network responses.
- **Cross-platform test suites** — XCTest is Apple-only. If you share code with Android (Kotlin Multiplatform), use `kotlin.test` for the shared module and XCTest for the iOS-specific module.
- **Fuzzing or security testing** — XCTest is not designed for adversarial input testing. Use `libFuzzer` or specialized security testing tools.

## Tradeoffs

| Dimension | XCTest Unit Tests | XCTest UI Tests |
|-----------|------------------|----------------|
| **Speed** | Fast (100–1000 tests/sec) | Slow (1–5 tests/sec) |
| **Determinism** | High (no timing dependencies) | Low (UI rendering timing, animations) |
| **Setup cost** | Low (instantiate class, inject mocks) | High (launch app, navigate to screen) |
| **Value** | Catches logic bugs, regressions | Catches integration bugs, broken flows |
| **Maintenance** | Low (tests implementation details) | High (breaks when UI changes) |
| **CI cost** | Negligible (seconds) | Significant (minutes per test) |

| Dimension | XCTest | Quick/Nimble |
|-----------|--------|-------------|
| **Syntax** | `XCTAssertEqual(actual, expected)` | `expect(actual).to(equal(expected))` |
| **BDD support** | None | Built-in (`describe`, `context`, `it`) |
| **Async testing** | `XCTestExpectation` | `toEventually`, `waitUntil` |
| **Xcode integration** | Native | Requires framework setup |
| **Learning curve** | Low (familiar to all iOS devs) | Moderate (new DSL) |

| Dimension | XCTest UI Tests | XCUIScreen (screenshot tests) | SnapshotTesting |
|-----------|----------------|-----------------------------|----------------|
| **Visual verification** | Manual assertions on element properties | Screenshot comparison | Screenshot comparison with diff |
| **Speed** | Slow | Moderate | Moderate |
| **Platform** | Simulators + devices | Simulators | Simulators (Point-Free library) |
| **Maintenance** | High (element queries break) | High (reference images need updates) | High (reference images need updates) |

## Alternatives

- **Quick + Nimble** — BDD-style testing framework built on top of XCTest. Adds `describe`/`context`/`it` blocks and `expect(...).to(...)` matchers. Useful for teams that want readable test specifications.
- **SnapshotTesting** (Point-Free) — screenshot-based testing for views, view controllers, and SwiftUI views. Detects visual regressions that XCTest's assertions miss.
- **Tulsi / xcodebuild** — command-line test execution for CI. Not a testing framework but the mechanism for running XCTest suites in CI pipelines.
- **Firebase Test Lab / AWS Device Farm** — cloud-based device farms that run XCTest UI tests on real devices. Catches device-specific bugs that simulators miss.
- **Mockingbird** — Swift mock generation framework. Generates mock implementations of protocols at compile time. Reduces manual mock boilerplate in XCTest.
- **Cuckoo** — another Swift mock generation framework. Supports classes and protocols. Used as an alternative to Mockingbird.

## Failure Modes

1. **Flaky UI tests from timing assumptions** — a UI test taps a button immediately after the screen appears, but the button's data has not loaded yet. The test taps an empty cell or the wrong element → use `XCTWaiter` with expectations for specific UI states: `let exists = NSPredicate(format: "exists == 1")`. `expectation(for: exists, evaluatedWith: app.buttons["Submit"])`. `waitForExpectations(timeout: 10)`. Alternatively, use `app.buttons["Submit"].waitForExistence(timeout: 10)`.

2. **Test interdependencies causing cascading failures** — Test A creates a Core Data record. Test B assumes the record exists. When Test A is disabled or runs after Test B, Test B fails → each test must be independent. Reset all state in `setUp()`: delete Core Data stores, clear UserDefaults, reset singletons. Never rely on test execution order.

3. **Slow test suite from unnecessary app launches** — a unit test suite launches the full app (`XCUIApplication().launch()`) for every test method, adding 3–5 seconds per test → unit tests should not launch the app. They should instantiate classes directly. Only UI tests need `XCUIApplication`. Separate unit tests and UI tests into different test targets.

4. **Brittle element queries breaking on minor UI changes** — a UI test finds an element by label: `app.buttons["Submit Order"]`. A design change updates the text to "Place Order", and the test fails → always use `accessibilityIdentifier` instead of label text: `button.accessibilityIdentifier = "submit_order_button"`. Identifiers are stable across localization and design changes.

5. **Memory leaks in test targets from retained singletons** — a singleton (e.g., analytics tracker) is configured in `setUp()` but never reset. Each test adds observers or accumulates data, and the test process runs out of memory after 200 tests → reset singletons in `tearDown()`. Use dependency injection so that tests can provide fresh instances. If singletons are unavoidable, provide a `reset()` method for tests.

6. **XCTestExpectation timeout masking real failures** — a test waits for an async callback with `waitForExpectations(timeout: 30)`. The callback never fires (due to a bug), and the test times out after 30 seconds, reporting "Asynchronous wait failed" instead of the actual bug → set realistic timeouts (2–5 seconds for unit tests). In the timeout handler, log the state of the system to aid debugging. Use `XCTFail("Expected callback within 5s")` on timeout.

7. **Code coverage skew from test host inclusion** — enabling code coverage with a test host includes the app delegate, scene delegate, and all ViewControllers in coverage, even though unit tests do not exercise them. Coverage reports show 30% instead of the actual 70% for tested code → configure code coverage to exclude specific files: `Gather coverage for` → `Some targets` → select only the testable targets. Exclude generated code (generated mocks, SwiftUI preview code).

8. **UI tests failing on different simulator sizes** — a UI test scrolls to an element that is visible on an iPhone 15 simulator but not on an iPhone SE simulator. The scroll action fails because the element is off-screen on the smaller device → use `app.cells["order-42"].swipeUp()` or `app.cells["order-42"].tap()` which auto-scrolls to the element. Avoid hardcoded scroll distances. Test on the smallest supported device size.

9. **Performance test baseline drift** — a performance test's baseline was set on an M1 MacBook Pro. Running the same test on an Intel Mac causes consistent failures because the Intel machine is slower → set baselines on the CI machine, not local machines. Use `XCTMeasureOptions` to configure the number of iterations and standard deviation tolerance. Store baselines in source control and update them deliberately.

10. **SwiftUI view testing limitations** — XCTest UI tests interact with SwiftUI views through accessibility queries, but SwiftUI generates dynamic accessibility identifiers for some components (e.g., `ForEach` items). The identifiers change between runs → assign explicit `accessibilityIdentifier` to every interactive SwiftUI element: `.accessibilityIdentifier("order_row_\(order.id)")`. For SwiftUI unit testing, test the ViewModel (not the view) and verify state changes. Use `SnapshotTesting` for visual verification of SwiftUI views.

## Code Examples

### Unit Test with Mocks

```swift
import XCTest
@testable import MyApp

final class OrderViewModelTests: XCTestCase {
    var viewModel: OrderViewModel!
    var mockRepository: MockOrderRepository!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockRepository = MockOrderRepository()
        viewModel = OrderViewModel(repository: mockRepository, orderId: "ord-42")
    }

    override func tearDownWithError() throws {
        viewModel = nil
        mockRepository = nil
        try super.tearDownWithError()
    }

    func test_loadingOrder_populatesState() async {
        // Given
        let expectedOrder = Order(id: "ord-42", itemName: "Pizza", total: 14.99, status: .pending)
        mockRepository.orderResult = .success(expectedOrder)

        // When
        await viewModel.loadOrder()

        // Then
        switch viewModel.uiState {
        case .ready(let order):
            XCTAssertEqual(order.itemName, "Pizza")
            XCTAssertEqual(order.total, 14.99)
        default:
            XCTFail("Expected .ready state, got \(viewModel.uiState)")
        }
    }

    func test_loadingFailedOrder_showsError() async {
        // Given
        mockRepository.orderResult = .failure(NetworkError.unauthorized)

        // When
        await viewModel.loadOrder()

        // Then
        switch viewModel.uiState {
        case .error(let message):
            XCTAssertEqual(message, "Unauthorized")
        default:
            XCTFail("Expected .error state, got \(viewModel.uiState)")
        }
    }

    func test_validOrderForm_enablesSubmitButton() {
        // Given
        viewModel.itemName = "Burger"
        viewModel.quantityText = "3"

        // Then
        XCTAssertTrue(viewModel.isSubmitEnabled)
    }

    func test_emptyItemName_disablesSubmitButton() {
        viewModel.itemName = ""
        viewModel.quantityText = "3"

        XCTAssertFalse(viewModel.isSubmitEnabled)
    }
}
```

### Async Test with XCTestExpectation

```swift
func test_fetchOrders_returnsResults() {
    let expectation = self.expectation(description: "Orders fetched")
    var fetchedOrders: [Order] = []
    var fetchError: Error?

    let apiClient = OrderAPIClient()
    apiClient.fetchOrders { result in
        switch result {
        case .success(let orders):
            fetchedOrders = orders
        case .failure(let error):
            fetchError = error
        }
        expectation.fulfill()
    }

    waitForExpectations(timeout: 10) { error in
        if let error = error {
            XCTFail("Expectation timed out: \(error)")
            return
        }
    }

    XCTAssertNil(fetchError)
    XCTAssertGreaterThan(fetchedOrders.count, 0)
    XCTAssertEqual(fetchedOrders[0].id, "ord-1")
}

// Modern async/await style (iOS 15+)
func test_fetchOrders_async() async throws {
    let apiClient = OrderAPIClient()
    let orders = try await apiClient.fetchOrders()

    XCTAssertGreaterThan(orders.count, 0)
    XCTAssertEqual(orders[0].id, "ord-1")
}
```

### UI Test

```swift
import XCTest

final class OrderFlowUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false // Stop on first failure
        app = XCUIApplication()

        // Reset app state before each test
        app.launchArguments = ["--uitesting", "--reset-data"]
        app.launchEnvironment = ["UITEST_MODE": "true"]
        app.launch()
    }

    func test_createOrder_flow() {
        // Given: on home screen
        XCTAssertTrue(app.buttons["create_order_button"].waitForExistence(timeout: 5))

        // When: tap create order
        app.buttons["create_order_button"].tap()

        // Then: order form appears
        XCTAssertTrue(app.textFields["item_name_field"].waitForExistence(timeout: 5))

        // When: fill form
        app.textFields["item_name_field"].tap()
        app.textFields["item_name_field"].typeText("Pizza Margherita")

        app.textFields["quantity_field"].tap()
        app.textFields["quantity_field"].typeText("2")

        // When: submit
        app.buttons["submit_order_button"].tap()

        // Then: confirmation screen
        let confirmationPredicate = NSPredicate(format: "label CONTAINS 'Order created'")
        let confirmationExpectation = expectation(
            for: confirmationPredicate,
            evaluatedWith: app.staticTexts.firstMatch,
            handler: nil
        )
        waitForExpectations(timeout: 10)
    }

    func test_orderList_displaysOrders() {
        // Navigate to orders tab
        app.tabBars["MainTabBar"].buttons["Orders"].tap()

        // Verify orders are displayed
        XCTAssertTrue(app.tables["orders_table"].waitForExistence(timeout: 5))

        let firstCell = app.tables["orders_table"].cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.exists)
        XCTAssertTrue(firstCell.staticTexts.matching(NSPredicate(format: "label BEGINSWITH 'Order'")).firstMatch.exists)
    }
}
```

### Performance Test

```swift
func test_jsonParsing_performance() {
    let jsonData = loadFixtureData("orders_1000.json")

    measure(
        metrics: [
            XCTClockMetric(),
            XCTCPUMetric(),
            XCTMemoryMetric(),
        ],
        block: {
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                _ = try decoder.decode([Order].self, from: jsonData)
            } catch {
                XCTFail("Decoding failed: \(error)")
            }
        }
    )
}

func test_coreDataFetch_performance() {
    let context = PersistenceController.shared.viewContext

    measure {
        let request: NSFetchRequest<Order> = Order.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        request.fetchLimit = 100

        do {
            _ = try context.fetch(request)
        } catch {
            XCTFail("Fetch failed: \(error)")
        }
    }
}
```

### Testing SwiftUI ViewModel

```swift
@MainActor
final class SearchViewModelTests: XCTestCase {
    func test_searchEmptiesResults_whenNoQuery() async {
        let mockAPI = MockSearchAPIClient(results: [])
        let viewModel = SearchViewModel(apiClient: mockAPI)

        viewModel.query = ""

        // The ViewModel should not make an API call for empty query
        XCTAssertEqual(mockAPI.callCount, 0)
        XCTAssertEqual(viewModel.results, [])
    }

    func test_searchPopulatesResults_whenQueryProvided() async {
        let mockResults = [
            SearchResult(id: "1", title: "Swift Programming"),
            SearchResult(id: "2", title: "SwiftUI Essentials"),
        ]
        let mockAPI = MockSearchAPIClient(results: mockResults)
        let viewModel = SearchViewModel(apiClient: mockAPI)

        viewModel.query = "Swift"

        // Wait for async search to complete
        let expectation = expectation(description: "Results loaded")
        let cancellable = viewModel.$results
            .dropFirst()
            .sink { _ in expectation.fulfill() }

        await fulfillment(of: [expectation], timeout: 5)
        cancellable.cancel()

        XCTAssertEqual(viewModel.results.count, 2)
        XCTAssertEqual(viewModel.results[0].title, "Swift Programming")
    }
}
```

## Best Practices

- **Separate unit tests and UI tests into different targets.** Unit tests run fast and should execute on every commit. UI tests are slow and should run on a schedule (nightly or pre-release). Different targets enable different CI configurations.
- **Use `@MainActor` for tests that touch UIKit/AppKit or SwiftUI ViewModels.** Many UI components require main-thread execution. Annotating the test class with `@MainActor` ensures all test methods run on the main thread.
- **Make every test independent.** Never rely on the side effects of a previous test. Reset all state in `setUp()`: clear databases, reset singletons, delete files, clear notifications.
- **Use accessibility identifiers for UI test queries.** `accessibilityIdentifier` is stable across localization, design changes, and OS versions. It is also a free accessibility check — if an element has no identifier, VoiceOver users cannot find it either.
- **Set `continueAfterFailure = false` in UI tests.** When a UI test fails, the app state is unpredictable. Continuing after failure causes cascading failures that obscure the root cause.
- **Mock at the protocol level, not the class level.** Define protocols for your dependencies (`OrderRepositoryProtocol`, `APIClientProtocol`) and generate mocks. This enables testing without the real implementation and without subclassing.
- **Use `XCTSkip` for environment-dependent tests.** `try XCTSkipIfUIDevice(.pad, "Feature not available on iPad")` gracefully skips tests that do not apply to the current environment.
- **Profile test execution time.** Run `xcodebuild test -scheme MyApp -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:MyAppTests | grep "Test Case"` to identify slow tests. Optimize or split slow tests.
- **Use `@testable import` to access `internal` members.** This is the standard way to test implementation details without exposing them publicly. Do not make members `public` just for testing.
- **Run tests on CI with the same configuration as local development.** Use the same Xcode version, SDK, and simulator. Differences in tooling cause "works on my machine" test failures.

## Related Topics

- [[Mobile MOC]]
- [[MobileTesting]]
- [[Testing MOC]]
- [[Quality MOC]]
- [[Swift]]
- [[iOSArchitecture]]
- [[TDD]]
- [[ContinuousIntegration]]
