---
title: Jetpack Compose
title_pt: Jetpack Compose
layer: mobile
type: concept
priority: high
version: 1.0.0
tags:
  - Mobile
  - Android
  - Kotlin
  - UI
  - Jetpack
description: Android's modern declarative UI toolkit for building native interfaces.
description_pt: toolkit de UI declarativo moderno do Android para construir interfaces nativas.
prerequisites:
  - KotlinProgramming
estimated_read_time: 12 min
difficulty: intermediate
---

# Jetpack Compose

## Description

Jetpack Compose is Android's modern toolkit for building native UI. It simplifies and accelerates UI development with less code, powerful tools, and intuitive Kotlin APIs. Compose is declarative, meaning you describe what the UI should look like for a given state, and the framework handles the rest.

Key concepts:
- **Composable functions** - Functions that describe UI
- **State** - Data that drives UI updates
- **Side effects** - Operations that happen outside composables
- **Material Design** - Built-in Material 3 components

## Purpose

**When Compose is valuable:**
- New Android projects
- Replacing legacy XML layouts
- Complex animations
- Rapid UI development

## Examples

### Basic Composable

```kotlin
@Composable
fun Greeting(name: String) {
    Text(text = "Hello, $name!")
}

@Composable
fun MyApp() {
    MaterialTheme {
        Greeting("World")
    }
}
```

### State and Events

```kotlin
@Composable
fun Counter() {
    var count by remember { mutableStateOf(0) }
    
    Column(
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            text = "Count: $count",
            style = MaterialTheme.typography.headlineMedium
        )
        
        Button(onClick = { count++ }) {
            Text("Increment")
        }
    }
}
```

### Lists

```kotlin
@Composable
fun UserList(users: List<User>) {
    LazyColumn {
        items(users, key = { it.id }) { user ->
            UserRow(user)
        }
    }
}

@Composable
fun UserRow(user: User) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { /* handle click */ }
            .padding(16.dp)
    ) {
        Image(
            painter = rememberAsyncImagePainter(user.avatar),
            contentDescription = null
        )
        Column {
            Text(user.name)
            Text(user.email, style = MaterialTheme.typography.bodySmall)
        }
    }
}
```

## Failure Modes

- **Recomposition loops from state changes** → state change triggers recomposition which changes state again → infinite loop and app freeze → ensure state changes are idempotent and do not trigger further state changes
- **Not using stable types for state** → unstable types cause unnecessary recompositions → performance degradation → annotate data classes with @Stable and use immutable types where possible
- **Side effects in composable body** → network calls or database writes in composable → executed on every recomposition → use LaunchedEffect, SideEffect, or DisposableEffect for side effects
- **Skipping remember for expensive operations** → recomputing on every composition → poor performance → use remember for expensive computations and rememberSaveable for state that survives configuration changes
- **Not handling configuration changes** → state lost on screen rotation → user loses input → use ViewModel or rememberSaveable to preserve state across configuration changes
- **Deeply nested composable hierarchy** → too many nested composables → recomposition performance issues → extract reusable composables and keep composition tree shallow
- **Missing content descriptions for accessibility** → images and icons without descriptions → screen readers cannot describe UI → provide contentDescription for all meaningful visual elements

## Anti-Patterns

### 1. Side Effects in Composable Body

**Bad:** Making network calls, database writes, or launching coroutines directly in the composable function body
**Why it's bad:** Composables can be recomposed at any time — the side effect executes repeatedly, causing duplicate API calls, data corruption, or infinite loops
**Good:** Use `LaunchedEffect`, `SideEffect`, or `DisposableEffect` for side effects — these are lifecycle-aware and execute only when their keys change

### 2. Recomposition Loops

**Bad:** A state change triggers a recomposition that changes the same state again, creating an infinite loop
**Why it's bad:** The app freezes or becomes unresponsive — the recomposition loop consumes 100% CPU and the UI never settles
**Good:** Ensure state changes are idempotent and do not trigger further state changes — use `LaunchedEffect` with proper keys to break the loop

### 3. Skipping remember for Expensive Operations

**Bad:** Recomputing expensive values (parsing JSON, formatting dates, creating objects) on every composition
**Why it's bad:** Every recomposition recalculates these values — scroll performance degrades, the UI becomes janky, and battery life suffers
**Good:** Use `remember` for expensive computations and `rememberSaveable` for state that must survive configuration changes like screen rotation

### 4. Unstable Types Causing Unnecessary Recompositions

**Bad:** Using mutable or unstable types as composable parameters, causing Compose to recompose even when the data has not changed
**Why it's bad:** Compose cannot determine if the parameter has actually changed, so it recomposes conservatively — performance degrades as the UI grows
**Good:** Annotate data classes with `@Stable` or `@Immutable`, use immutable types, and avoid passing mutable collections as composable parameters

## Related Topics

- [[Mobile MOC]]
- [[AndroidArchitecture]]
- [[Kotlin]]
- [[AndroidDataAndNetworking]]
- [[MobileArchitecture]]

## Best Practices

1. **Use stable types for state** - Annotate with @Stable
2. **Avoid recomposition loops** - Use proper state management
3. **Extract reusable composables** - Don't duplicate UI code
4. **Use remember for expensive operations** - Cache computations
5. **Follow Material Design guidelines** - Use Material 3 components