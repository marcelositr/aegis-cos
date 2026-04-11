---
title: Android Development
title_pt: Desenvolvimento Android
layer: mobile
type: concept
priority: high
version: 1.0.0
tags:
  - Mobile
  - Android
  - Kotlin
  - Java
  - Development
description: Android app development with Kotlin, Jetpack Compose, and Android SDK.
description_pt: Desenvolvimento de apps Android com Kotlin, Jetpack Compose e Android SDK.
prerequisites:
  - Programming
  - Mobile
estimated_read_time: 15 min
difficulty: intermediate
---

# Android Development

## Description

Android development creates applications for devices running the Android operating system, including smartphones, tablets, watches, and TVs. The primary language is Kotlin, with Java as a legacy option. Android development uses Android Studio IDE, the Android SDK, and libraries from the Android Jetpack collection.

Android offers deep system integration with hardware capabilities, multiple UI form factors, and distribution through Google Play Store. The platform supports a wide range of device types and Android versions, requiring careful compatibility considerations.

Key components of Android development:
- **Kotlin** - Modern, concise, null-safe language
- **Jetpack Compose** - Declarative UI toolkit (Android 5.0+)
- **Android Views** - Traditional XML-based UI
- **Android Studio** - IDE with emulator and tools
- **Gradle** - Build system with dependency management
- **Android SDK** - APIs for device features

## Purpose

**When Android development is valuable:**
- Building native Android applications
- Creating apps for diverse Android devices
- Implementing IoT or embedded Android
- Publishing on Google Play Store
- Requiring deep hardware integration

**When to consider alternatives:**
- Cross-platform needs (React Native, Flutter)
- iOS-only strategy
- Web app sufficient

## Rules

1. **Support multiple Android versions** - Use compatibility libraries
2. **Handle device variations** - Screen sizes, hardware capabilities
3. **Follow Material Design** - Google's design system
4. **Optimize for performance** - Battery, memory constraints
5. **Use modern Android architecture** - MVVM, Clean Architecture

## Examples

### Kotlin Basic Structure

```kotlin
// Main Activity
package com.example.myapp

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.ui.Modifier
import com.example.myapp.ui.theme.MyAppTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MyAppTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    MainScreen()
                }
            }
        }
    }
}

// Composable Function
@Composable
fun MainScreen() {
    var name by remember { mutableStateOf("") }
    var items by remember { mutableStateOf(listOf<String>()) }
    
    Column(
        modifier = Modifier.padding(16.dp)
    ) {
        TextField(
            value = name,
            onValueChange = { name = it },
            label = { Text("Enter name") },
            modifier = Modifier.fillMaxWidth()
        )
        
        Button(
            onClick = {
                if (name.isNotBlank()) {
                    items = items + name
                    name = ""
                }
            },
            modifier = Modifier.padding(top = 8.dp)
        ) {
            Text("Add")
        }
        
        LazyColumn(
            modifier = Modifier.padding(top = 16.dp)
        ) {
            items(items) { item ->
                Text(text = item, modifier = Modifier.padding(vertical = 4.dp))
            }
        }
    }
}
```

### ViewModel and State Management

```kotlin
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

// Data Model
data class User(val id: String, val name: String, val email: String)

// UI State
sealed class UiState {
    object Loading : UiState()
    data class Success(val users: List<User>) : UiState()
    data class Error(val message: String) : UiState()
}

// ViewModel
class UserViewModel(private val repository: UserRepository) : ViewModel() {
    
    private val _uiState = MutableStateFlow<UiState>(UiState.Loading)
    val uiState: StateFlow<UiState> = _uiState
    
    init {
        loadUsers()
    }
    
    fun loadUsers() {
        viewModelScope.launch {
            _uiState.value = UiState.Loading
            try {
                val users = repository.getUsers()
                _uiState.value = UiState.Success(users)
            } catch (e: Exception) {
                _uiState.value = UiState.Error(e.message ?: "Unknown error")
            }
        }
    }
    
    fun addUser(name: String, email: String) {
        viewModelScope.launch {
            try {
                repository.addUser(User("", name, email))
                loadUsers() // Refresh list
            } catch (e: Exception) {
                _uiState.value = UiState.Error(e.message ?: "Failed to add user")
            }
        }
    }
}

// Factory for ViewModel
class UserViewModelFactory(private val repository: UserRepository) : ViewModelProvider.Factory {
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(UserViewModel::class.java)) {
            @Suppress("UNCHECKED_CAST")
            return UserViewModel(repository) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
}
```

### Navigation with Jetpack Navigation

```kotlin
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument

// Navigation Routes
sealed class Screen(val route: String) {
    object Home : Screen("home")
    object Detail : Screen("detail/{userId}") {
        fun createRoute(userId: String) = "detail/$userId"
    }
    object Settings : Screen("settings")
}

// Navigation Host
@Composable
fun AppNavigation() {
    val navController = rememberNavController()
    
    NavHost(navController = navController, startDestination = Screen.Home.route) {
        composable(Screen.Home.route) {
            HomeScreen(
                onUserClick = { userId ->
                    navController.navigate(Screen.Detail.createRoute(userId))
                },
                onSettingsClick = {
                    navController.navigate(Screen.Settings.route)
                }
            )
        }
        
        composable(
            route = Screen.Detail.route,
            arguments = listOf(navArgument("userId") { type = NavType.StringType })
        ) { backStackEntry ->
            val userId = backStackEntry.arguments?.getString("userId") ?: ""
            DetailScreen(userId = userId)
        }
        
        composable(Screen.Settings.route) {
            SettingsScreen()
        }
    }
}

// Home Screen
@Composable
fun HomeScreen(
    onUserClick: (String) -> Unit,
    onSettingsClick: () -> Unit
) {
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Users") },
                actions = {
                    IconButton(onClick = onSettingsClick) {
                        Icon(Icons.Default.Settings, contentDescription = "Settings")
                    }
                }
            )
        }
    ) { paddingValues ->
        // User list
        LazyColumn(modifier = Modifier.padding(paddingValues)) {
            items(users) { user ->
                ListItem(
                    headlineContent = { Text(user.name) },
                    supportingContent = { Text(user.email) },
                    modifier = Modifier.clickable { onUserClick(user.id) }
                )
            }
        }
    }
}
```

### Network Requests with Retrofit

```kotlin
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import retrofit2.http.GET
import retrofit2.http.Path
import retrofit2.http.Query

// API Service Interface
interface UserApiService {
    @GET("users")
    suspend fun getUsers(): List<UserDto>
    
    @GET("users/{id}")
    suspend fun getUserById(@Path("id") id: String): UserDto
    
    @GET("users")
    suspend fun searchUsers(@Query("q") query: String): List<UserDto>
}

// Data Transfer Object
data class UserDto(
    val id: String,
    val name: String,
    val email: String,
    val avatar: String?
)

// Retrofit Instance
object RetrofitClient {
    private const val BASE_URL = "https://api.example.com/"
    
    val retrofit: Retrofit = Retrofit.Builder()
        .baseUrl(BASE_URL)
        .addConverterFactory(GsonConverterFactory.create())
        .build()
    
    val userService: UserApiService = retrofit.create(UserApiService::class.java)
}

// Repository
class UserRepository {
    private val apiService = RetrofitClient.userService
    
    suspend fun getUsers(): List<User> {
        return apiService.getUsers().map { it.toUser() }
    }
    
    suspend fun getUserById(id: String): User {
        return apiService.getUserById(id).toUser()
    }
    
    private fun UserDto.toUser() = User(id, name, email)
}

// Usage in ViewModel
class UserViewModel(private val repository: UserRepository) : ViewModel() {
    private val _users = MutableStateFlow<List<User>>(emptyList())
    val users: StateFlow<List<User>> = _users
    
    fun loadUsers() {
        viewModelScope.launch {
            _users.value = repository.getUsers()
        }
    }
}
```

### Local Storage with Room

```kotlin
import androidx.room.*

// Entity
@Entity(tableName = "users")
data class UserEntity(
    @PrimaryKey val id: String,
    @ColumnInfo(name = "name") val name: String,
    @ColumnInfo(name = "email") val email: String,
    @ColumnInfo(name = "created_at") val createdAt: Long = System.currentTimeMillis()
)

// DAO (Data Access Object)
@Dao
interface UserDao {
    @Query("SELECT * FROM users ORDER BY created_at DESC")
    fun getAllUsers(): Flow<List<UserEntity>>
    
    @Query("SELECT * FROM users WHERE id = :id")
    suspend fun getUserById(id: String): UserEntity?
    
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertUser(user: UserEntity)
    
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(users: List<UserEntity>)
    
    @Delete
    suspend fun deleteUser(user: UserEntity)
    
    @Query("DELETE FROM users")
    suspend fun deleteAll()
    
    @Query("SELECT * FROM users WHERE name LIKE '%' || :query || '%'")
    fun searchUsers(query: String): Flow<List<UserEntity>>
}

// Database
@Database(entities = [UserEntity::class], version = 1, exportSchema = false)
abstract class AppDatabase : RoomDatabase() {
    abstract fun userDao(): UserDao
    
    companion object {
        @Volatile
        private var INSTANCE: AppDatabase? = null
        
        fun getDatabase(context: Context): AppDatabase {
            return INSTANCE ?: synchronized(this) {
                val instance = Room.databaseBuilder(
                    context.applicationContext,
                    AppDatabase::class.java,
                    "app_database"
                ).build()
                INSTANCE = instance
                instance
            }
        }
    }
}

// Repository with Local + Remote
class UserRepository(private val userDao: UserDao, private val api: UserApiService) {
    
    // Cache-first approach
    fun getUsers(): Flow<List<User>> = userDao.getAllUsers()
    
    suspend fun refreshUsers() {
        try {
            val remoteUsers = api.getUsers()
            userDao.insertAll(remoteUsers.map { it.toEntity() })
        } catch (e: Exception) {
            // Log error, keep cached data
        }
    }
    
    private fun UserDto.toEntity() = UserEntity(id, name, email)
    private fun UserEntity.toUser() = User(id, name, email)
}
```

### Background Work with WorkManager

```kotlin
import androidx.work.*
import java.util.concurrent.TimeUnit

// Worker Class
class SyncWorker(
    context: Context,
    params: WorkerParameters
) : CoroutineWorker(context, params) {
    
    override suspend fun doWork(): Result {
        return try {
            // Perform sync
            val repository = UserRepository(RetrofitClient.userService, AppDatabase.get(applicationContext).userDao())
            repository.refreshUsers()
            Result.success()
        } catch (e: Exception) {
            if (runAttemptCount < 3) {
                Result.retry()
            } else {
                Result.failure()
            }
        }
    }
    
    companion object {
        const val WORK_NAME = "sync_users_work"
        
        fun enqueuePeriodicWork(context: Context) {
            val constraints = Constraints.Builder()
                .setRequiredNetworkType(NetworkType.CONNECTED)
                .setRequiresBatteryNotLow(true)
                .build()
            
            val workRequest = PeriodicWorkRequestBuilder<SyncWorker>(
                6, TimeUnit.HOURS,
                15, TimeUnit.MINUTES // Flex interval
            )
                .setConstraints(constraints)
                .setBackoffCriteria(
                    BackoffPolicy.EXPONENTIAL,
                    WorkRequest.MIN_BACKOFF_MILLIS,
                    TimeUnit.MILLISECONDS
                )
                .build()
            
            WorkManager.getInstance(context)
                .enqueueUniquePeriodicWork(
                    WORK_NAME,
                    ExistingPeriodicWorkPolicy.KEEP,
                    workRequest
                )
        }
        
        fun enqueueOneTimeWork(context: Context) {
            val workRequest = OneTimeWorkRequestBuilder<SyncWorker>()
                .setConstraints(
                    Constraints.Builder()
                        .setRequiredNetworkType(NetworkType.CONNECTED)
                        .build()
                )
                .build()
            
            WorkManager.getInstance(context).enqueue(workRequest)
        }
    }
}
```

## Anti-Patterns

### 1. Blocking Main Thread

```kotlin
// BAD - Network on main thread
val users = fetchUsers() // Blocks UI!

// GOOD - Use coroutines
viewModelScope.launch {
    val users = repository.getUsers() // Runs on Dispatchers.IO
}
```

### 2. Memory Leaks with Context

```kotlin
// BAD - Holding Activity context
class MyClass {
    var activity: Activity? = null // Memory leak!
}

// GOOD - Use application context or weak reference
class MyClass(private val context: Context) {
    // Use context.applicationContext
}
```

### 3. Not Handling Configuration Changes

```kotlin
// BAD - Losing state on rotation
@Composable
fun MyScreen() {
    var counter = 0 // Lost on rotation!
}

// GOOD - Use ViewModel or remember with saveable
@Composable
fun MyScreen(viewModel: MyViewModel) {
    val counter by viewModel.counter.collectAsState()
}

@Composable
fun rememberWithSaveable() {
    var state by rememberSaveable { mutableStateOf("") } // Survives config changes
}
```

## Best Practices

### Architecture (MVVM + Clean Architecture)

```
┌─────────────────────────────────────────────────────────┐
│                      UI Layer                           │
│   Composable Functions, Activities, Fragments          │
└─────────────────────────┬───────────────────────────────┘
                          │
┌─────────────────────────┴───────────────────────────────┐
│                   Domain Layer                          │
│        Use Cases, Repository Interfaces                │
└─────────────────────────┬───────────────────────────────┘
                          │
┌─────────────────────────┴───────────────────────────────┐
│                    Data Layer                           │
│    Repository Implementations, Data Sources            │
└─────────────────────────────────────────────────────────┘
```

### Dependency Injection

```kotlin
// Using Hilt
@HiltAndroidApp
class MyApplication : Application()

@HiltViewModel
class UserViewModel @Inject constructor(
    private val repository: UserRepository
) : ViewModel()

@Composable
fun MyScreen(
    viewModel: UserViewModel = hiltViewModel()
) { }
```

### Proguard/R8 Minification

```kotlin
// build.gradle
android {
    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}
```

## Failure Modes

- **Blocking main thread with network or disk I/O** → synchronous calls on UI thread → ANR (Application Not Responding) dialogs → use coroutines with Dispatchers.IO for all blocking operations
- **Memory leaks from Activity context references** → holding Activity context in long-lived objects → memory never released → use ApplicationContext for long-lived objects and weak references for Activity
- **Not handling configuration changes** → state lost on screen rotation → user loses progress → use ViewModel with StateFlow or rememberSaveable to survive configuration changes
- **Missing permission handling** → accessing protected APIs without runtime permissions → security exceptions and crashes → request permissions at runtime with graceful degradation when denied
- **Hardcoded strings and resources** → strings embedded in code → impossible to localize → use string resources for all user-facing text and support multiple locales
- **Not targeting latest SDK** → app targets outdated SDK → missing security features and Play Store rejection → target latest SDK and handle deprecated APIs with compatibility checks
- **Background work without WorkManager** → using threads or services for background tasks → tasks killed by system → use WorkManager for reliable background work with constraints and retry logic

## Related Topics

- [[Kotlin]]
- [[MobileArchitecture]]
- [[MobileTesting]]
- [[MVVM]]
- [[Hexagonal]]
- [[DependencyInjection]]
- [[Coroutines]]
- [[Room]]

## Additional Notes

**Android Version Support:**
- Minimum SDK: 21 (Android 5.0)
- Target SDK: 34 (Android 14)
- Compile SDK: 34

**Key Libraries:**
- Jetpack Compose - UI
- Hilt - DI
- Room - Database
- Retrofit - Networking
- Coroutines - Async
- Coil - Images

**Testing:**
- JUnit for unit tests
- Espresso for UI tests
- MockK for mocking