---
title: Mobile Architecture
title_pt: Arquitetura Mobile
layer: mobile
type: concept
priority: high
version: 1.0.0
tags:
  - Mobile
  - Architecture
  - Patterns
  - Design
description: Mobile application architecture patterns including MVVM, Clean Architecture, and dependency injection.
description_pt: Padrões de arquitetura de aplicativos mobile incluindo MVVM, Arquitetura Limpa e injeção de dependência.
prerequisites:
  - Architecture
  - Mobile
estimated_read_time: 12 min
difficulty: intermediate
---

# Mobile Architecture

## Description

Mobile architecture defines how code is structured in mobile applications, balancing maintainability, testability, performance, and user experience. Modern mobile development typically follows patterns like MVVM (Model-View-ViewModel) combined with Clean Architecture principles.

Key patterns:
- **MVVM** - ViewModel as intermediary between View and Model
- **Clean Architecture** - Layered architecture with separation of concerns
- **Repository Pattern** - Abstract data sources
- **Dependency Injection** - Loose coupling via injected dependencies

## Purpose

**When architecture is critical:**
- Large, complex applications
- Team collaboration
- Testing requirements
- Long-term maintenance

## Examples

### MVVM Pattern

```kotlin
// Model (Data)
data class User(val id: String, val name: String, val email: String)

// ViewModel
class UserViewModel(private val repository: UserRepository) : ViewModel() {
    
    private val _uiState = MutableStateFlow<UiState>(UiState.Loading)
    val uiState: StateFlow<UiState> = _uiState
    
    fun loadUsers() {
        viewModelScope.launch {
            _uiState.value = UiState.Loading
            try {
                val users = repository.getUsers()
                _uiState.value = UiState.Success(users)
            } catch (e: Exception) {
                _uiState.value = UiState.Error(e.message ?: "Error")
            }
        }
    }
}

// View (SwiftUI/Compose equivalent)
@Composable
fun UserListScreen(viewModel: UserViewModel) {
    val state by viewModel.uiState.collectAsState()
    
    when (val s = state) {
        is UiState.Loading -> LoadingView()
        is UiState.Success -> UserList(s.users)
        is UiState.Error -> ErrorView(s.message)
    }
}
```

### Clean Architecture Layers

```
┌─────────────────────────────────────────────────────────┐
│                    UI Layer                             │
│  (Activities, Fragments, Composables, ViewControllers)  │
└─────────────────────────┬───────────────────────────────┘
                          │
┌─────────────────────────┴───────────────────────────────┐
│                  Domain Layer                           │
│    (Use Cases, Repository Interfaces, Entities)       │
└─────────────────────────┬───────────────────────────────┘
                          │
┌─────────────────────────┴───────────────────────────────┐
│                   Data Layer                            │
│  (Repository Implementations, Data Sources, DTOs)     │
└─────────────────────────────────────────────────────────┘
```

```kotlin
// Domain Layer - Use Case
class GetUserUseCase(private val repository: UserRepository) {
    suspend operator fun invoke(userId: String): Result<User> {
        return repository.getUserById(userId)
    }
}

// Domain Layer - Repository Interface
interface UserRepository {
    suspend fun getUsers(): List<User>
    suspend fun getUserById(id: String): User
    suspend fun saveUser(user: User)
    suspend fun deleteUser(id: String)
}

// Data Layer - Repository Implementation
class UserRepositoryImpl(
    private val remoteDataSource: UserRemoteDataSource,
    private val localDataSource: UserLocalDataSource
) : UserRepository {
    
    override suspend fun getUsers(): List<User> {
        return try {
            val remote = remoteDataSource.fetchUsers()
            localDataSource.saveUsers(remote)
            remote
        } catch (e: Exception) {
            localDataSource.getUsers() // Fallback to cache
        }
    }
}
```

### Dependency Injection

```kotlin
// Hilt (Android)
@HiltAndroidApp
class MyApplication

@HiltViewModel
class UserViewModel @Inject constructor(
    private val getUserUseCase: GetUserUseCase,
    private val saveUserUseCase: SaveUserUseCase
) : ViewModel()

// SwiftUI Injection (iOS)
class ServiceContainer {
    static let shared = ServiceContainer()
    let userRepository: UserRepository
    
    init() {
        self.userRepository = UserRepositoryImplementation()
    }
}

@MainActor
class ContentViewModel: ObservableObject {
    @Inject var repository: UserRepository  // Via environment
}
```

## Anti-Patterns

### 1. Massive ViewController/Activity

```kotlin
// BAD - God object with everything
class MainActivity: Activity() {
    // 2000 lines of code!
    // Network calls
    // Database queries
    // UI updates
    // Business logic
}

// GOOD - Separate concerns
class MainActivity {
    private val viewModel: MainViewModel by viewModels()
}
```

## Failure Modes

- **Massive ViewController/Activity** → untestable code → maintenance nightmare → separate concerns using MVVM or Clean Architecture
- **Direct UI-to-data access** → tight coupling → hard to test → route through ViewModel or UseCase layer
- **No dependency injection** → hardcoded dependencies → untestable components → inject dependencies via constructor or DI framework
- **State scattered across layers** → inconsistent UI state → rendering bugs → use unidirectional data flow with single source of truth
- **Blocking main thread** → frozen UI → ANR/crash → move all I/O and heavy computation to background dispatchers
- **Missing lifecycle handling** → memory leaks → resource waste → cancel subscriptions and clean up in lifecycle callbacks
- **No error state handling** → crashes on failure → poor UX → model errors as explicit UI states, not exceptions

## Best Practices

### State Management

```kotlin
// Unidirectional data flow
// Action -> ViewModel -> State -> View

sealed class UserAction {
    object LoadUsers : UserAction()
    data class DeleteUser(val id: String) : UserAction()
}

class UserViewModel : ViewModel() {
    private val _state = MutableStateFlow(UserState())
    
    fun processAction(action: UserAction) {
        when (action) {
            is UserAction.LoadUsers -> loadUsers()
            is UserAction.DeleteUser -> deleteUser(action.id)
        }
    }
}
```

## Related Topics

- [[iOSDevelopment]]
- [[AndroidDevelopment]]
- [[MVVM]]
- [[Hexagonal]]
- [[DependencyInjection]]
- [[Hexagonal]]
- [[DDD]]
- [[Modularity]]