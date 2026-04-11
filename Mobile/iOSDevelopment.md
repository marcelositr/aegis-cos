---
title: iOS Development
title_pt: Desenvolvimento iOS
layer: mobile
type: concept
priority: high
version: 1.0.0
tags:
  - Mobile
  - iOS
  - Swift
  - Apple
  - Development
description: iOS app development with Swift, SwiftUI, and Xcode including UIKit fundamentals.
description_pt: Desenvolvimento de apps iOS com Swift, SwiftUI e Xcode, incluindo fundamentos de UIKit.
prerequisites:
  - Programming
  - Mobile
estimated_read_time: 15 min
difficulty: intermediate
---

# iOS Development

## Description

iOS development involves creating applications for Apple devices including iPhone, iPad, Apple Watch, and Apple TV. The primary languages are Swift and Objective-C, with UIKit and SwiftUI as the main UI frameworks. iOS development requires macOS and Xcode, Apple's integrated development environment.

The iOS ecosystem provides robust APIs for camera, location, notifications, in-app purchases, and device integration. Apple's strict App Store review process ensures quality and security, requiring developers to follow Human Interface Guidelines.

Key components of iOS development:
- **Swift** - Modern, safe, fast programming language
- **SwiftUI** - Declarative UI framework (iOS 13+)
- **UIKit** - Traditional imperative UI framework
- **Xcode** - IDE with debugger, simulators, and Interface Builder
- **Core Data** - Object graph and persistence framework
- **Combine** - Reactive programming framework

## Purpose

**When iOS development is valuable:**
- Building native iPhone/iPad applications
- Creating apps requiring deep system integration
- ImplementingAR/VR experiences with ARKit
- Building watchOS and tvOS apps
- Publishing on Apple App Store

**When to consider alternatives:**
- Cross-platform suffices (React Native, Flutter)
- Web app meets requirements
- Android-only strategy

## Rules

1. **Follow Apple guidelines** - Human Interface Guidelines ensure consistency
2. **Use Swift** - Modern language with safety features
3. **Test on real devices** - Simulator has limitations
4. **Optimize for App Store** - ASO, screenshots, descriptions
5. **Handle permissions** - Request privacy permissions gracefully

## Examples

### Swift Basic Structure

```swift
import SwiftUI

// Main App Entry Point
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// Content View with State
struct ContentView: View {
    @State private var isLoading = false
    @State private var userName = ""
    @State private var items: [String] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if isLoading {
                    ProgressView("Loading...")
                } else {
                    List(items, id: \.self) { item in
                        Text(item)
                    }
                    
                    TextField("Enter name", text: $userName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    Button("Add Item") {
                        addItem()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            .navigationTitle("My App")
            .onAppear {
                fetchData()
            }
        }
    }
    
    private func addItem() {
        guard !userName.isEmpty else { return }
        items.append(userName)
        userName = ""
    }
    
    private func fetchData() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            items = ["Item 1", "Item 2", "Item 3"]
            isLoading = false
        }
    }
}
```

### UIKit Implementation

```swift
import UIKit

class ViewController: UIViewController {
    
    private let tableView = UITableView()
    private var items: [String] = []
    private let cellIdentifier = "Cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchData()
    }
    
    private func setupUI() {
        title = "My App"
        view.backgroundColor = .systemBackground
        
        // Setup Table View
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Navigation Bar Button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addItem)
        )
    }
    
    @objc private func addItem() {
        let alert = UIAlertController(title: "New Item", message: "Enter item name", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Item name"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            if let name = alert.textFields?.first?.text, !name.isEmpty {
                self?.items.append(name)
                self?.tableView.reloadData()
            }
        })
        present(alert, animated: true)
    }
    
    private func fetchData() {
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.items = ["Apple", "Banana", "Orange"]
            self?.tableView.reloadData()
        }
    }
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("Selected: \(items[indexPath.row])")
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}
```

### Networking with URLSession

```swift
import Foundation

// Network Manager
class NetworkManager {
    static let shared = NetworkManager()
    private let session = URLSession.shared
    
    private init() {}
    
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

enum NetworkError: Error {
    case invalidResponse
    case decodingError
    case networkError(Error)
}

// Usage with async/await
struct User: Codable {
    let id: Int
    let name: String
    let email: String
}

class UserService {
    func fetchUsers() async throws -> [User] {
        guard let url = URL(string: "https://api.example.com/users") else {
            throw NetworkError.invalidResponse
        }
        return try await NetworkManager.shared.fetchData(from: url)
    }
}

// In SwiftUI View
struct UserListView: View {
    @State private var users: [User] = []
    @State private var isLoading = false
    @State private var error: String?
    
    var body: some View {
        List(users) { user in
            VStack(alignment: .leading) {
                Text(user.name).font(.headline)
                Text(user.email).font(.subheadline).foregroundColor(.gray)
            }
        }
        .task {
            await loadUsers()
        }
    }
    
    private func loadUsers() async {
        isLoading = true
        do {
            users = try await UserService().fetchUsers()
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}
```

### Local Storage with UserDefaults

```swift
import Foundation

// UserDefaults Helper
class UserDefaultsHelper {
    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    // Keys
    private enum Keys {
        static let userToken = "user_token"
        static let userProfile = "user_profile"
        static let settings = "app_settings"
    }
    
    // Token
    var userToken: String? {
        get { defaults.string(forKey: Keys.userToken) }
        set { defaults.set(newValue, forKey: Keys.userToken) }
    }
    
    // Codable Objects
    func save<T: Encodable>(_ object: T, forKey key: String) {
        if let data = try? encoder.encode(object) {
            defaults.set(data, forKey: key)
        }
    }
    
    func load<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? decoder.decode(type, from: data)
    }
    
    // Clear all
    func clearAll() {
        let domain = Bundle.main.bundleIdentifier!
        defaults.removePersistentDomain(forName: domain)
    }
}

// User Profile Model
struct UserProfile: Codable {
    let id: String
    let name: String
    let email: String
    var isPremium: Bool
}

// Settings Model
struct AppSettings: Codable {
    var notificationsEnabled: Bool
    var darkModeEnabled: Bool
    var language: String
    
    static let `default` = AppSettings(
        notificationsEnabled: true,
        darkModeEnabled: false,
        language: "en"
    )
}

// Usage
let helper = UserDefaultsHelper()
let profile = UserProfile(id: "1", name: "John", email: "john@example.com", isPremium: true)
helper.save(profile, forKey: Keys.userProfile)

if let loadedProfile: UserProfile = helper.load(UserProfile.self, forKey: Keys.userProfile) {
    print("Loaded: \(loadedProfile.name)")
}
```

### Handling Permissions

```swift
import AVFoundation
import CoreLocation
import Photos

class PermissionManager {
    
    // Camera Permission
    func requestCameraPermission() async -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            return true
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .video)
        default:
            return false
        }
    }
    
    // Location Permission
    func requestLocationPermission() async -> Bool {
        let status = CLLocationManager().authorizationStatus
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            return true
        case .notDetermined:
            // Note: Requires CLLocationManager instance
            return await withCheckedContinuation { continuation in
                let manager = CLLocationManager()
                manager.requestWhenInUseAuthorization()
                // Check status after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    let newStatus = manager.authorizationStatus
                    continuation.resume(returning: newStatus == .authorizedWhenInUse)
                }
            }
        default:
            return false
        }
    }
    
    // Photo Library Permission
    func requestPhotoLibraryPermission() async -> Bool {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch status {
        case .authorized, .limited:
            return true
        case .notDetermined:
            return await PHPhotoLibrary.requestAuthorization(for: .readWrite) == .authorized
        default:
            return false
        }
    }
    
    // Check and Open Settings
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

// Permission UI in SwiftUI
struct PermissionView: View {
    let title: String
    let description: String
    let icon: String
    let action: () async -> Bool
    
    @State private var isGranted = false
    @State private var showSettings = false
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(.blue)
            
            Text(title)
                .font(.headline)
            
            Text(description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if isGranted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else {
                Button("Grant Permission") {
                    Task {
                        isGranted = await action()
                        if !isGranted {
                            showSettings = true
                        }
                    }
                }
            }
        }
        .padding()
        .alert("Permission Required", isPresented: $showSettings) {
            Button("Open Settings", action: { PermissionManager().openSettings() })
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please enable this permission in Settings")
        }
    }
}
```

## Anti-Patterns

### 1. Blocking Main Thread

```swift
// BAD - Network call on main thread
let data = try! Data(contentsOf: URL(string: "https://api.example.com")!)  // Blocks!

// GOOD - Use async/await or completion handlers
Task {
    let data = try await fetchData()
}
```

### 2. Not Handling Memory Correctly

```swift
// BAD - Strong reference cycle
class Parent {
    var child: Child?
}

class Child {
    var parent: Parent?  // Strong reference creates cycle!
}

// GOOD - Use weak/unowned
class Child {
    weak var parent: Parent?  // Breaks cycle
}
```

### 3. Ignoring Safe Area

```swift
// BAD - Content hidden by notch
VStack {
    Text("Hello")
    Text("World")
}

// GOOD - Respect safe area
VStack {
    Text("Hello")
    Text("World")
}
.ignoreSafeArea(edges: .bottom)  // Only when intentional
```

## Best Practices

### Architecture (MVVM)

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│    View     │ ──► │  ViewModel  │ ──► │    Model    │
│  (SwiftUI)  │ ◄── │   (State)   │ ◄── │   (Data)    │
└─────────────┘     └─────────────┘     └─────────────┘

View: UI only, observes ViewModel
ViewModel: Business logic, state management
Model: Data structures, persistence
```

### Asset Management

```swift
// Use system images
Image(systemName: "star.fill")

// Custom images
Image("my_image")  // Add to Assets.xcassets

// Adaptive images for different sizes
// In Assets.xcassets, add @1x, @2x, @3x variants
```

### Error Handling

```swift
// Use Result type
func fetchData() async -> Result<Data, Error> {
    do {
        let data = try await performRequest()
        return .success(data)
    } catch {
        return .failure(error)
    }
}

// Display errors in UI
if case .failure(let error) = result {
    Text(error.localizedDescription)
        .foregroundColor(.red)
}
```

## Failure Modes

- **Blocking main thread with network calls** → synchronous Data(contentsOf) on main thread → app freeze and watchdog termination → use async/await or completion handlers for all network operations
- **Strong reference cycles causing memory leaks** → parent-child or delegate patterns with strong references → memory never released → use weak references for delegates and unowned for non-optional relationships
- **Ignoring safe area layout** → content hidden behind notch or home indicator → poor user experience on modern devices → respect safe area insets and test on devices with notches
- **Not handling app lifecycle events** → background tasks not paused or saved → data loss when app is terminated → implement proper lifecycle handling with state preservation and restoration
- **Missing privacy permission descriptions** → accessing camera or location without Info.plist descriptions → app rejected by App Store → provide clear usage descriptions for all privacy-sensitive permissions
- **Hardcoded strings without localization** → user-facing text in code → impossible to translate → use NSLocalizedString or SwiftUI localization for all user-facing text
- **Not testing on real devices** → relying only on simulator → hardware-specific issues missed → test on real devices for camera, GPS, performance, and memory behavior

## Related Topics

- [[Swift]]
- [[SwiftUI]]
- [[MobileArchitecture]]
- [[MobileTesting]]
- [[MVVM]]
- [[Combine]]
- [[CoreData]]
- [[XCTest]]

## Additional Notes

**iOS Version Support:**
- SwiftUI requires iOS 13+
- Use iOS 15+ for modern APIs
- Check deployment target in Xcode

**Key Frameworks:**
- SwiftUI - Declarative UI
- UIKit - Traditional UI
- Combine - Reactive programming
- Core Data - Persistence
- ARKit - Augmented Reality
- CoreML - Machine Learning

**Testing:**
- XCTest for unit tests
- XCTest UI for UI tests
- Swift Testing (iOS 17+)