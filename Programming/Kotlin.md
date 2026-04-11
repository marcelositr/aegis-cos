---
title: Kotlin Programming
title_pt: Programação Kotlin
layer: programming
type: concept
priority: high
version: 1.0.0
tags:
  - Programming
  - Kotlin
  - Android
  - JVM
  - Language
description: Kotlin programming language fundamentals, syntax, and Android development integration.
description_pt: Fundamentos da linguagem Kotlin, sintaxe e integração com desenvolvimento Android.
prerequisites:
  - Programming
estimated_read_time: 15 min
difficulty: intermediate
---

# Kotlin Programming

## Description

Kotlin is a modern, statically-typed programming language developed by JetBrains, officially supported by Google for Android development since 2017. It runs on the JVM, can compile to JavaScript, and can also compile to native binaries. Kotlin is designed to be more concise, safe, and pragmatic than Java.

Key features:
- **Null safety** - Built-in null safety to prevent NPEs
- **Coroutines** - Native support for asynchronous programming
- **Extension functions** - Add functionality to existing classes
- **Smart casts** - Automatic type conversion
- **Data classes** - Automatic generation of boilerplate

## Purpose

**When Kotlin is valuable:**
- Android development (primary use case)
- Server-side development with Ktor/Spring
- Multiplatform mobile (Kotlin Multiplatform)
- Building safe, concise applications

## Rules

1. **Prefer val over var** - Immutability preferred
2. **Handle nulls properly** - Use safe calls and elvis operator
3. **Use data classes** - For objects holding data
4. **Leverage extension functions** - For clean APIs

## Examples

### Variables and Null Safety

```kotlin
// Immutable (preferred)
val name: String = "John"
val age = 30 // Type inference

// Mutable
var count = 0
count += 1

// Nullable
var nullable: String? = null
nullable = "value"

// Safe call
val length = nullable?.length // Returns null if nullable is null

// Elvis operator
val len = nullable?.length ?: 0 // Default if null

// Not null assertion (avoid!)
val len2 = nullable!!.length // Throws if null

// Safe cast
val str: String? = nullable as? String

// Late initialization
lateinit var lateInit: String
```

### Collections

```kotlin
// List
val list = listOf(1, 2, 3)
val mutableList = mutableListOf(1, 2, 3)

// Map
val map = mapOf("a" to 1, "b" to 2)
val mutableMap = mutableMapOf("a" to 1)

// Set
val set = setOf(1, 2, 3)

// Functional operations
val doubled = list.map { it * 2 }
val evens = list.filter { it % 2 == 0 }
val sum = list.reduce { acc, i -> acc + i }

// Destructuring
val (first, second) = list
```

### Functions

```kotlin
// Basic function
fun greet(name: String): String = "Hello, $name"

// Single expression
fun add(a: Int, b: Int) = a + b

// Default parameters
fun greet(name: String = "World") = "Hello, $name"

// Named arguments
greet(name = "John")

// Vararg
fun sum(vararg numbers: Int) = numbers.sum()

// Lambda
val add = { a: Int, b: Int -> a + b }

// Extension function
fun String.exclaim() = "$this!"

// Higher-order function
fun operate(a: Int, b: Int, op: (Int, Int) -> Int) = op(a, b)
operate(1, 2) { a, b -> a + b }
```

### Classes

```kotlin
// Data class
data class User(val id: String, val name: String, val email: String)

// Class with val/var
class Person(var name: String, val age: Int)

// Inheritance
open class Animal(val name: String) {
    open fun speak() = "..."
}

class Dog(name: String) : Animal(name) {
    override fun speak() = "Woof!"
}

// Object (singleton)
object Config {
    val apiKey = "key"
}

// Companion object (static-like)
class MyClass {
    companion object {
        fun create() = MyClass()
    }
}

// Interface
interface Clickable {
    fun click()
    fun showOff() = println("Clickable!") // Default implementation
}
```

### Coroutines

```kotlin
import kotlinx.coroutines.*

// Launch (fire and forget)
fun launchExample() {
    CoroutineScope(Dispatchers.Main).launch {
        val data = async { fetchData() }.await()
        updateUI(data)
    }
}

// Suspend function
suspend fun fetchData(): Data {
    return withContext(Dispatchers.IO) {
        api.getData()
    }
}

// Flow (reactive streams)
fun getUpdates(): Flow<Data> = flow {
    while (true) {
        emit(fetchData())
        delay(1000)
    }
}.flowOn(Dispatchers.IO)

// Collecting flow
fun observeData() {
    CoroutineScope(Dispatchers.Main).launch {
        getUpdates().collect { data ->
            updateUI(data)
        }
    }
}
```

### Control Flow

```swift
// When (powerful switch)
val result = when (x) {
    1 -> "one"
    2 -> "two"
    in 3..10 -> "between"
    is String -> "string"
    else -> "other"
}

// Ranges
for (i in 1..10) print(i)       // Inclusive
for (i in 1 until 10) print(i)  // Exclusive

// Lazy ranges
val lazy = generateSequence { it.next() }.take(10)
```

### Exception Handling

```kotlin
try {
    val result = risky()
} catch (e: Exception) {
    println(e.message)
} finally {
    cleanup()
}

// Try as expression
val result = try {
    parse(input)
} catch (e: Exception) {
    defaultValue
}
```

## Anti-Patterns

### 1. Using Non-Null Assertion

```kotlin
// BAD
val len = nullable!!.length

// GOOD
val len = nullable?.length ?: 0
```

### 2. Blocking Thread

```kotlin
// BAD - blocks thread
val data = fetchData() // On main thread!

// GOOD - use coroutines
suspend fun load() {
    val data = withContext(Dispatchers.IO) { fetchData() }
}
```

## Failure Modes

- **Non-null assertion (`!!`)** → NPE at runtime → crash → use safe calls (`?.`) and elvis operator (`?:`) instead
- **Blocking main thread** → ANR (App Not Responding) → frozen UI → use coroutines with appropriate Dispatchers for all I/O
- **Coroutine scope leaks** → background work continues after destruction → memory waste → cancel scopes in lifecycle callbacks
- **Improper exception handling** → silent failures → undetected errors → handle exceptions within coroutines using try/catch or `runCatching`
- **Mutable state in coroutines** → race conditions → data corruption → use `StateFlow` or `Mutex` for shared mutable state
- **Overusing `lateinit`** → UninitializedPropertyAccessException → crash → prefer nullable types or lazy delegation when possible
- **Not using data classes** → boilerplate errors → incorrect equals/hashCode → use data classes for value objects

## Best Practices

### Scope Functions

```kotlin
// let - transform
val result = nullable?.let { it.length }

// run - execute block
val result = service.run { fetch() }

// with - call on object
with(user) {
    name = "New"
    save()
}

// apply - configure object
val user = User().apply {
    name = "John"
    email = "john@example.com"
}

// also - additional actions
val list = mutableListOf(1).also {
    it.add(2)
    it.add(3)
}
```

## Related Topics

- [[AndroidDevelopment]]
- [[JetpackCompose]]
- [[Coroutines]]
- [[MVVM]]
- [[MobileArchitecture]]
- [[MobileTesting]]
- [[DependencyInjection]]
- [[DataStructures]]

## Additional Notes

**Kotlin Multiplatform:**
- Share code between platforms
- Native performance
- Growing ecosystem

**Key Libraries:**
- Kotlin Coroutines - Async
- Ktor - HTTP client/server
- Kotlin Serialization - JSON
- Arrow - Functional programming