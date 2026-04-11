---
title: iOS
title_pt: Desenvolvimento iOS
layer: mobile
type: concept
priority: high
version: 2.0.0
tags:
  - Mobile
  - iOS
  - Architecture
  - Swift
  - MVVM
description: Complete iOS development guide — architecture (MVVM with SwiftUI/UIKit), data layer (URLSession, SwiftData, Core Data), networking, and state management.
description_pt: Guia completo de desenvolvimento iOS — arquitetura (MVVM com SwiftUI/UIKit), camada de dados (URLSession, SwiftData, Core Data), rede e gerenciamento de estado.
prerequisites:
  - "[[Swift]]"
  - "[[MobileArchitecture]]"
estimated_read_time: 20 min
difficulty: advanced
---

# iOS

## Description

Modern iOS development combines **Swift** language features, **SwiftUI** (or UIKit) for UI, **async/await** for concurrency, **URLSession** for networking, and **SwiftData/Core Data** for persistence. The recommended architecture is **MVVM** with observable state.

**Key layers:**
- **View Layer** — SwiftUI Views or UIKit ViewControllers (displays data, handles input)
- **ViewModel Layer** — State management, business logic, data transformation
- **Model Layer** — Data structures, persistence, network services

## Architecture: MVVM

### SwiftUI + @Observable (iOS 17+)

```swift
@Observable
class UserViewModel {
    var users: [User] = []
    var isLoading = false
    var error: String?
    private let service = UserService()

    func loadUsers() async {
        isLoading = true
        defer { isLoading = false }
        do { users = try await service.fetchUsers() }
        catch { self.error = error.localizedDescription }
    }
}

struct UserListView: View {
    @State private var viewModel = UserViewModel()
    var body: some View {
        List(viewModel.users) { user in
            VStack(alignment: .leading) {
                Text(user.name).font(.headline)
                Text(user.email).font(.subheadline).foregroundColor(.gray)
            }
        }
        .overlay {
            if viewModel.isLoading { ProgressView() }
            if let error = viewModel.error {
                ContentUnavailableView("Error", systemImage: "exclamationmark.triangle", description: Text(error))
            }
        }
        .task { await viewModel.loadUsers() }
    }
}
```

### UIKit + Combine (legacy)

```swift
class UserViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var isLoading = false
    @Published var error: String?
    private let service = UserService()

    func loadUsers() {
        isLoading = true
        Task {
            do { users = try await service.fetchUsers() }
            catch { self.error = error.localizedDescription }
            isLoading = false
        }
    }
}

class UserListViewController: UIViewController {
    private let viewModel = UserViewModel()
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.$users.sink { [weak self] users in
            self?.users = users; self?.tableView.reloadData()
        }.store(in: &cancellables)
        viewModel.loadUsers()
    }
}
```

## Data and Networking

### URLSession with async/await

```swift
class NetworkManager {
    private let session = URLSession.shared

    func fetchData<T: Decodable>(from url: URL) async throws -> T {
        let (data, response) = try await session.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(T.self, from: data)
    }
}

enum NetworkError: Error { case invalidResponse, decodingError(Swift.Error), networkError(Swift.Error) }

class UserService {
    private let networkManager = NetworkManager()
    private let baseURL = URL(string: "https://api.example.com")!

    func fetchUsers() async throws -> [User] {
        try await networkManager.fetchData(from: baseURL.appendingPathComponent("users"))
    }
}
```

### SwiftData (iOS 17+) — Modern Persistence

```swift
import SwiftData

@Model
class User {
    var id: String; var name: String; var email: String; var createdAt: Date
    init(id: String = UUID().uuidString, name: String, email: String) {
        self.id = id; self.name = name; self.email = email; self.createdAt = Date()
    }
}

@main struct MyApp: App {
    var body: some Scene {
        WindowGroup { ContentView() }.modelContainer(for: [User.self])
    }
}

struct UserListView: View {
    @Query(sort: \User.createdAt, order: .reverse) var users: [User]
    @Environment(\.modelContext) private var modelContext
    var body: some View {
        List(users) { user in
            VStack(alignment: .leading) {
                Text(user.name).font(.headline)
                Text(user.email).font(.subheadline).foregroundColor(.gray)
            }
        }
        .toolbar { Button("Add") { modelContext.insert(User(name: "New", email: "new@test.com")) } }
    }
}
```

### UserDefaults for Settings

```swift
@propertyWrapper
struct UserDefault<T> {
    let key: String; let defaultValue: T
    var wrappedValue: T {
        get { UserDefaults.standard.object(forKey: key) as? T ?? defaultValue }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
}

struct AppSettings {
    @UserDefault(key: "darkMode", defaultValue: false) static var darkMode: Bool
}
```

## Anti-Patterns

### 1. Massive View Controller
**Bad:** ViewController with 2000+ lines doing UI, networking, parsing, logic
**Good:** MVVM — ViewController handles UI only, ViewModel handles logic

### 2. Strong Reference Cycles
**Bad:** `class Child { var parent: Parent! }` → memory leak
**Good:** Use `weak` or `unowned` for back-references

### 3. Blocking Main Thread
**Bad:** `Data(contentsOf: url)` on main thread → app freeze → watchdog kills app
**Good:** Always use `async/await` or `URLSession.dataTask`

### 4. Ignoring Safe Area
**Bad:** Content hidden behind notch or home indicator
**Good:** Use `.safeAreaInset` or respect safe area layout guides

### 5. No Offline Support
**Bad:** App crashes with no network → unusable
**Good:** Cache responses locally, show cached data + "offline" indicator

## Failure Modes

- **ViewModel retains View** → memory leak → app grows until killed → use `weak` references, `[weak self]` in closures
- **No error handling** → UI shows empty state → confused users → always surface errors to UI
- **Main thread blocked** → watchdog timeout → app terminated by iOS → all I/O with `async/await`
- **State not @Published/@Observable** → UI doesn't update → stale data → verify property wrappers
- **Not handling app lifecycle** → background tasks interrupted → data loss → use `BGTaskScheduler`, save state
- **Network timeout** → user waits forever → set timeouts, show loading + retry
- **Core Data/SwiftData migration missing** → app crashes on update → provide migration mappings
- **Permission denied** → feature broken → graceful fallback, guide user to Settings
- **Background task expired** → work incomplete → use `BGTaskScheduler` for deferrable work, `URLSession.background` for uploads

## Tradeoffs

| Decision | Option A | Option B | When to Choose |
|----------|----------|----------|----------------|
| UI | SwiftUI | UIKit | SwiftUI for iOS 15+, UIKit for complex custom UI or legacy |
| Persistence | SwiftData | Core Data | SwiftData for iOS 17+, Core Data for complex relationships/legacy |
| Networking | URLSession async/await | Combine/URLSession | async/await for simplicity, Combine for reactive streams |
| Architecture | MVVM | MVC/TCA | MVVM is standard, TCA (Composable Architecture) for complex state |
| Settings | UserDefaults | Keychain | UserDefaults for non-sensitive, Keychain for secrets/tokens |

## When NOT to Use iOS Native

- **Cross-platform team, limited Swift expertise** → consider Flutter or React Native
- **Simple content app** → consider PWA
- **Heavy ML/compute** → offload to backend or use native ML frameworks (CoreML)

## Best Practices

1. **Use MVVM with @Observable** (iOS 17+) or `ObservableObject` (older)
2. **Always use async/await** for networking — no blocking calls on main thread
3. **Cache-first loading** — show local data, refresh from network in background
4. **Set timeouts** on URLSession — default is 60s, too long for UX
5. **Use SwiftData** for new projects on iOS 17+, Core Data for older targets
6. **Store secrets in Keychain** — never UserDefaults or UserDefaults
7. **Handle app lifecycle** — save state on background, restore on foreground
8. **Respect Safe Area** — use `.safeAreaInset` modifiers
9. **Use `weak self`** in all closures that capture self
10. **Test with `XCTest`** — unit tests for ViewModel logic, UI tests for flows

## Related Topics

- [[Swift]] — Swift language features
- [[SwiftUI]] — Declarative UI for iOS
- [[MobileArchitecture]] — Cross-platform architecture patterns
- [[MobileTesting]] — iOS testing strategies
- [[Concurrency]] — Swift async/await, actors
- [[REST]] — API design for networking
- [[Caching]] — Cache strategies
- [[SchemaEvolution]] — Core Data/SwiftData migrations
- [[SecureCoding]] — Keychain for secrets