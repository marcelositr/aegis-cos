---
title: Swift Programming
title_pt: Programação Swift
layer: programming
type: concept
priority: high
version: 1.0.0
tags:
  - Programming
  - Swift
  - Apple
  - iOS
  - Language
description: Swift programming language fundamentals, syntax, and iOS development integration.
description_pt: Fundamentos da linguagem Swift, sintaxe e integração com desenvolvimento iOS.
prerequisites:
  - Programming
estimated_read_time: 15 min
difficulty: intermediate
---

# Swift Programming

## Description

Swift is Apple's modern programming language, introduced in 2014 as a replacement for Objective-C. It combines the performance of compiled languages with the safety and expressiveness of modern languages. Swift is used for iOS, macOS, watchOS, tvOS, and server-side development.

Swift's key features include:
- **Safety** - Optional types, automatic memory management
- **Speed** - Optimized for performance
- **Expressiveness** - Closures, generics, protocol-oriented
- **Interoperability** - Works with Objective-C

## Purpose

**When Swift is valuable:**
- iOS/macOS development
- Server-side with SwiftNIO
- Systems programming
- Building safe, fast applications

## Rules

1. **Prefer let over var** - Immutable by default
2. **Use optionals properly** - Handle nil safely
3. **Leverage protocols** - Protocol-oriented design
4. **Avoid force unwrapping** - Use optional binding

## Examples

### Variables and Constants

```swift
// Constants - preferred
let name = "John"
let age: Int = 30

// Variables - when mutation needed
var count = 0
count += 1

// Optionals
var optional: String? = nil
optional = "value"

// Force unwrap (avoid!)
let unwrapped: String = optional!  // Dangerous!

// Safe unwrap
if let value = optional {
    print(value)
}

// Optional binding shorthand
if let value = optional {
    print(value)
}

// Nil coalescing
let safeValue = optional ?? "default"

// Guard let
func process(_ value: String?) {
    guard let value = value else {
        print("No value")
        return
    }
    print(value)
}
```

### Collections

```swift
// Array
var numbers = [1, 2, 3]
numbers.append(4)
let first = numbers[0]

// Array methods
let doubled = numbers.map { $0 * 2 }
let evens = numbers.filter { $0 % 2 == 0 }
let sum = numbers.reduce(0) { $0 + $1 }

// Dictionary
var scores = ["Alice": 100, "Bob": 95]
scores["Charlie"] = 90

for (name, score) in scores {
    print("\(name): \(score)")
}

// Set
var uniqueNumbers = Set<Int>()
uniqueNumbers.insert(1)
uniqueNumbers.contains(1)
```

### Control Flow

```swift
// If-else
if age >= 18 {
    print("Adult")
} else {
    print("Minor")
}

// Switch (powerful pattern matching)
switch day {
case "Saturday", "Sunday":
    print("Weekend")
case let d where d.hasSuffix("day"):
    print("Other day")
default:
    print("Weekday")
}

// For loops
for i in 1...5 {
    print(i)
}

for item in items {
    print(item)
}

// While
while !done {
    // process
}

// Do-while (repeat)
repeat {
    // execute once
} while condition
```

### Functions

```swift
// Basic function
func greet(name: String) -> String {
    return "Hello, \(name)!"
}

// External and internal parameter names
func greet(person name: String) -> String {  // person=external, name=internal
    return "Hello, \(name)!"
}

// Default parameters
func greet(_ name: String = "World") -> String {
    return "Hello, \(name)!"
}

// Variadic parameters
func sum(_ numbers: Int...) -> Int {
    return numbers.reduce(0, +)
}

// Closure
let add: (Int, Int) -> Int = { $0 + $1 }

// Trailing closure
numbers.map { $0 * 2 }
numbers.map { number in
    number * 2
}
```

### Classes and Structs

```swift
// Struct - value type
struct Person {
    var name: String
    var age: Int
    
    func introduce() -> String {
        return "I'm \(name), \(age) years old"
    }
}

// Class - reference type
class Animal {
    var name: String
    
    init(name: String) {
        self.name = name
    }
    
    func speak() {
        print("...")
    }
}

// Inheritance
class Dog: Animal {
    override func speak() {
        print("Woof!")
    }
}

// Protocol
protocol Printable {
    func printDescription()
}

extension String: Printable {
    func printDescription() {
        print(self)
    }
}
```

### Error Handling

```swift
// Define errors
enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
}

// Throwing function
func fetchData() throws -> Data {
    guard let url = URL(string: "https://api.example.com") else {
        throw NetworkError.invalidURL
    }
    
    let data = try Data(contentsOf: url)
    guard !data.isEmpty else {
        throw NetworkError.noData
    }
    
    return data
}

// Handle errors
do {
    let data = try fetchData()
    print(data)
} catch NetworkError.invalidURL {
    print("Invalid URL")
} catch {
    print("Other error: \(error)")
}

// Try? - returns optional
let data = try? fetchData()
```

### Async/Await

```swift
// Async function
func fetchUsers() async throws -> [User] {
    let url = URL(string: "https://api.example.com/users")!
    let (data, _) = try await URLSession.shared.data(from: url)
    return try JSONDecoder().decode([User].self, from: data)
}

// Call async function
Task {
    do {
        let users = try await fetchUsers()
        print(users)
    } catch {
        print(error)
    }
}

// Parallel execution
async let users = fetchUsers()
let posts = await fetchPosts()
// Use both when ready
```

### Generics

```swift
// Generic function
func swap<T>(_ a: inout T, _ b: inout T) {
    let temp = a
    a = b
    b = temp
}

// Generic struct
struct Stack<Element> {
    var items: [Element] = []
    
    mutating func push(_ item: Element) {
        items.append(item)
    }
    
    mutating func pop() -> Element? {
        return items.popLast()
    }
}

// Generic constraint
func process<T: Numeric>(values: [T]) -> T {
    return values.reduce(0, +)
}
```

## Anti-Patterns

### 1. Force Unwrapping

```swift
// BAD
let value = optional!

// GOOD
if let value = optional {
    // use value
}
```

### 2. Any Type

```swift
// BAD - loses type safety
var anything: Any = "string"
anything = 42

// GOOD - use generics or protocols
```

### 3. Force Cast

```swift
// BAD
let value = someValue as! String

// GOOD
if let value = someValue as? String {
    // use value
}
```

## Failure Modes

- **Force unwrapping optionals** → runtime crash → app termination → use optional binding (`if let`) or nil coalescing (`??`)
- **Force casting (`as!`)** → type mismatch crash → app crash → use conditional casting (`as?`) with optional binding
- **Retain cycles in closures** → memory leak → growing memory usage → capture `self` as `[weak self]` in closures
- **Blocking main thread** → frozen UI → poor UX → move network and I/O to background with async/await or DispatchQueue
- **Using `Any` type** → lost type safety → runtime errors → use generics or protocols for type-safe abstraction
- **Not handling errors properly** → silent failures → undetected bugs → use `do/catch` or `try?` with nil checks
- **Value vs reference type confusion** → unexpected mutations → data corruption → prefer structs for data, classes for identity

## Best Practices

### Protocol-Oriented Design

```swift
protocol Drawable {
    func draw()
}

struct Circle: Drawable {
    var radius: Double
    func draw() { /* ... */ }
}

struct Square: Drawable {
    var side: Double
    func draw() { /* ... */ }
}

func drawAll<T: Drawable>(_ items: [T]) {
    items.forEach { $0.draw() }
}
```

### Memory Management

```swift
// Use weak to prevent retain cycles
class Parent {
    var child: Child?
}

class Child {
    weak var parent: Parent?  // Prevents cycle
}

// Use [weak self] in closures
class MyClass {
    func doSomething() {
        someAsyncCall { [weak self] in
            self?.handleResult()
        }
    }
}
```

## Related Topics

- [[iOSDevelopment]]
- [[SwiftUI]]
- [[MobileArchitecture]]
- [[MobileTesting]]
- [[Combine]]
- [[CoreData]]
- [[MVVM]]
- [[DependencyInjection]]

## Additional Notes

**Swift Versions:**
- Swift 5.9+ for modern features
- Backward compatibility via deployment targets

**Key Frameworks:**
- Foundation - Core utilities
- UIKit - iOS UI
- SwiftUI - Declarative UI
- Combine - Reactive