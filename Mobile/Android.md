---
title: Android
title_pt: Desenvolvimento Android
layer: mobile
type: concept
priority: high
version: 2.0.0
tags:
  - Mobile
  - Android
  - Architecture
  - Kotlin
  - MVVM
description: Complete Android development guide — architecture (MVVM + Clean Architecture), data layer (Retrofit, Room, WorkManager), and UI (Jetpack Compose).
description_pt: Guia completo de desenvolvimento Android — arquitetura (MVVM + Clean Architecture), camada de dados (Retrofit, Room, WorkManager) e UI (Jetpack Compose).
prerequisites:
  - "[[Kotlin]]"
  - "[[MobileArchitecture]]"
estimated_read_time: 20 min
difficulty: advanced
---

# Android

## Description

Android development combines Kotlin language features, Jetpack libraries, and architecture patterns. The modern stack uses **Jetpack Compose** for UI, **MVVM + Clean Architecture** for structure, **Coroutines/Flow** for async, **Retrofit** for networking, and **Room** for local storage.

**Key layers:**
- **UI Layer** — Composables, Activities, Fragments (displays data, handles user input)
- **Domain Layer** — Use cases, business logic, repository interfaces (pure Kotlin, no Android deps)
- **Data Layer** — Repository implementations, data sources (Room, Retrofit, DataStore)

## Architecture: MVVM + Clean Architecture

```
┌─────────────────────────────────────────────────────────┐
│                      UI Layer                           │
│   Composable Functions, Activities, Fragments          │
│   Observes StateFlow from ViewModel                     │
└─────────────────────────┬───────────────────────────────┘
                          │ StateFlow / Events
┌─────────────────────────┴───────────────────────────────┐
│                   Domain Layer                          │
│   ViewModel (UI state management)                       │
│   Use Cases (optional, for complex business logic)      │
│   Repository Interfaces (contracts)                     │
└─────────────────────────┬───────────────────────────────┘
                          │ implements
┌─────────────────────────┴───────────────────────────────┐
│                    Data Layer                           │
│   Repository Implementations                            │
│   Data Sources: Room, Retrofit, DataStore               │
└─────────────────────────────────────────────────────────┘
```

### ViewModel and State Management

```kotlin
sealed class UiState<out T> {
    object Loading : UiState<Nothing>()
    data class Success<T>(val data: T) : UiState<T>()
    data class Error(val message: String) : UiState<Nothing>()
}

@HiltViewModel
class UserViewModel @Inject constructor(
    private val repository: UserRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow<UiState<List<User>>>(UiState.Loading)
    val uiState: StateFlow<UiState<List<User>>> = _uiState

    fun loadUsers() {
        viewModelScope.launch {
            _uiState.value = UiState.Loading
            try {
                _uiState.value = UiState.Success(repository.getUsers())
            } catch (e: Exception) {
                _uiState.value = UiState.Error(e.message ?: "Unknown error")
            }
        }
    }
}
```

### Dependency Injection with Hilt

```kotlin
@HiltAndroidApp
class MyApplication : Application()

@Module
@InstallIn(SingletonComponent::class)
object AppModule {
    @Provides @Singleton
    fun provideRetrofit(): Retrofit = Retrofit.Builder()
        .baseUrl("https://api.example.com/")
        .addConverterFactory(GsonConverterFactory.create())
        .build()
}

@AndroidEntryPoint
class MainActivity : ComponentActivity() {
    private val viewModel: UserViewModel by viewModels()
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent { UserScreen(uiState = viewModel.uiState.collectAsState().value) }
    }
}
```

## Data and Networking

### Retrofit — API Layer

```kotlin
interface UserApiService {
    @GET("users") suspend fun getUsers(): List<UserDto>
    @GET("users/{id}") suspend fun getUserById(@Path("id") id: String): UserDto
    @POST("users") suspend fun createUser(@Body user: CreateUserRequest): UserDto
}

val retrofit = Retrofit.Builder()
    .baseUrl("https://api.example.com/")
    .client(OkHttpClient.Builder()
        .addInterceptor { chain ->
            chain.request().newBuilder()
                .addHeader("Authorization", "Bearer ${getToken()}")
                .build().let { chain.proceed(it) }
        }
        .connectTimeout(30, TimeUnit.SECONDS)
        .readTimeout(30, TimeUnit.SECONDS)
        .build())
    .addConverterFactory(GsonConverterFactory.create())
    .build()
```

### Room — Local Database

```kotlin
@Entity(tableName = "users")
data class UserEntity(
    @PrimaryKey val id: String,
    @ColumnInfo(name = "name") val name: String,
    @ColumnInfo(name = "email") val email: String
)

@Dao
interface UserDao {
    @Query("SELECT * FROM users ORDER BY name") fun getAll(): Flow<List<UserEntity>>
    @Insert(onConflict = OnConflictStrategy.REPLACE) suspend fun insert(user: UserEntity)
}

@Database(entities = [UserEntity::class], version = 1)
abstract class AppDatabase : RoomDatabase() {
    abstract fun userDao(): UserDao
}
```

### Repository Pattern (Cache-First)

```kotlin
class UserRepository(
    private val userDao: UserDao,
    private val api: UserApiService
) {
    fun getUsers(): Flow<List<User>> = userDao.getAll()
        .map { it.map { e -> e.toUser() } }
        .onEach {
            try { api.getUsers().map { userDao.insert(it.toEntity()) } }
            catch (_: Exception) { /* serve cached data */ }
        }
}
```

### WorkManager — Background Tasks

```kotlin
class SyncWorker(ctx: Context, params: WorkerParameters) : CoroutineWorker(ctx, params) {
    override suspend fun doWork(): Result = try {
        // sync logic
        Result.success()
    } catch (e: Exception) {
        if (runAttemptCount < 3) Result.retry() else Result.failure()
    }
}
```

## UI: Jetpack Compose

```kotlin
@Composable
fun UserScreen(uiState: UiState<List<User>>) {
    when (uiState) {
        is UiState.Loading -> CircularProgressIndicator()
        is UiState.Success -> UserList(uiState.data)
        is UiState.Error -> Text("Error: ${uiState.message}")
    }
}

@Composable
fun UserList(users: List<User>) {
    LazyColumn {
        items(users) { user ->
            UserCard(user)
        }
    }
}
```

## Anti-Patterns

### 1. God Activity
**Bad:** Activity with 2000+ lines doing UI, networking, database, business logic
**Good:** MVVM — Activity handles UI only, ViewModel handles state, Repository handles data

### 2. Passing Context Everywhere
**Bad:** `MyClass(activity)` → memory leak on rotation
**Good:** Use `applicationContext` or Hilt for DI

### 3. Blocking Main Thread
**Bad:** Database or network call on main thread → ANR (Application Not Responding)
**Good:** `suspend` functions + coroutines on `Dispatchers.IO`

### 4. No Offline Support
**Bad:** App unusable without network
**Good:** Cache-first repository, show cached data + "refreshing" indicator

### 5. Direct Database Access from UI
**Bad:** Activity calls Room DAO directly → no caching, no error handling
**Good:** Repository pattern — abstracts data source, handles caching and errors

## Failure Modes

- **ViewModel holds Activity reference** → memory leak → OOM crash → use `viewModelScope`, never hold Activity refs
- **No error handling in ViewModel** → UI shows nothing → confused users → always catch and surface errors to UI state
- **Blocking main thread** → ANR → system kills app → all I/O on `Dispatchers.IO`
- **Hilt misconfiguration** → dependency not provided → crash at startup → verify all modules installed
- **Database migration missing** → app crashes on update → provide migrations or `fallbackToDestructiveMigration`
- **Network timeout** → user waits forever → set connect/read timeouts, show loading state
- **WorkManager constraints not met** → background work never runs → monitor work status, provide manual sync option
- **Cache stale** → user sees old data → implement TTL, force refresh option
- **API response changed** → parsing fails → use DTOs, handle unknown fields gracefully

## Tradeoffs

| Decision | Option A | Option B | When to Choose |
|----------|----------|----------|----------------|
| UI | Jetpack Compose | XML + View system | Compose for new projects, XML for maintenance of existing |
| DI | Hilt | Manual/Koin | Hilt for large teams, Koin for simplicity |
| Storage | Room | DataStore/SharedPreferences | Room for relational, DataStore for key-value |
| Background | WorkManager | Coroutines/Service | WorkManager for guaranteed, Coroutines for in-app |
| Architecture | MVVM + Clean | MVI | MVVM is standard, MVI for complex state machines |

## When NOT to Use Android Native

- **Cross-platform team with limited Android expertise** → consider Flutter or React Native
- **Simple content app** → consider PWA
- **Heavy ML/compute** → offload to backend or use platform-specific native modules

## Best Practices

1. **Follow Clean Architecture** — domain layer has zero Android dependencies
2. **Use StateFlow for UI state** — single source of truth, observable
3. **Cache-first data loading** — show local data immediately, refresh from network
4. **Set timeouts on all network calls** — 30s connect, 30s read minimum
5. **Use Hilt for DI** — compile-time safety, lifecycle awareness
6. **Handle configuration changes** — ViewModel survives rotation, use `rememberSaveable`
7. **Test with coroutines** — `runTest`, `TestDispatcher`, advance time
8. **Use ProGuard/R8** — shrink and obfuscate for release builds

## Related Topics

- [[Kotlin]] — Kotlin language features
- [[JetpackCompose]] — Declarative UI for Android
- [[MobileArchitecture]] — Cross-platform architecture patterns
- [[MobileTesting]] — Android testing strategies
- [[Concurrency]] — Coroutines and structured concurrency
- [[Hexagonal]] — Layer separation principles
- [[DependencyInjection]] — Hilt, Dagger patterns
- [[REST]] — API design for Retrofit
- [[Caching]] — Cache strategies
- [[SchemaEvolution]] — Room database migrations