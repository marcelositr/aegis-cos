---
title: Room Persistence Library
layer: mobile
type: concept
priority: high
version: 2.0.0
tags:
  - Mobile
  - Android
  - Database
  - SQLite
  - Persistence
  - Jetpack
description: Android's SQLite abstraction layer providing compile-time SQL verification, boilerplate reduction, LiveData/Flow integration, and structured migration support for local data persistence.
---

# Room Persistence Library

## Description

Room is part of Android Jetpack and serves as an abstraction layer over SQLite. It addresses the pain points of raw SQLite: verbose boilerplate code, runtime SQL syntax errors, manual cursor parsing, and the lack of compile-time query validation. Room generates the SQLite implementation at compile time from annotated interfaces and data classes.

Core components:
- **Entity** — a Kotlin data class annotated with `@Entity` that represents a database table. Each property maps to a column. Supports primary keys, indices, foreign keys, and relationships.
- **DAO (Data Access Object)** — an interface or abstract class annotated with `@Dao` that declares database operations. Methods are annotated with `@Query`, `@Insert`, `@Update`, or `@Delete`. Room generates the implementation at compile time.
- **Database** — an abstract class annotated with `@Database` that extends `RoomDatabase`. It defines the database configuration (version, entities, export schema) and provides access to DAOs. Room generates the implementation.
- **Type Converters** — functions annotated with `@TypeConverter` that map custom types (e.g., `Date`, `enum`, `List<String>`) to and from SQLite-compatible types (INTEGER, TEXT, REAL).
- **Relations** — `@Relation` and `@ForeignKey` annotations enable one-to-many and many-to-many relationships. Room does not support JOIN queries in the traditional ORM sense; instead, it uses embedded queries with `@Relation` to populate nested objects.
- **Flow/LiveData integration** — `@Query` methods can return `Flow<List<T>>` or `LiveData<List<T>>`, which automatically re-emit when the underlying data changes. This is Room's observation mechanism, powered by SQLite's `InvalidationTracker`.

**Under the hood:** Room generates Java code at compile time. The generated implementation classes (`YourDatabase_Impl`, `YourDao_Impl`) contain the actual SQLite statements and cursor parsing logic. Schema JSON is exported to `schemas/` directory for migration validation.

## When to Use

- **Local data storage in Android apps** — caching API responses, storing user-generated content, managing app state that persists across process death. Room is the officially recommended Android persistence solution.
- **Apps requiring offline support** — Room provides a local database that the app reads from regardless of network state. Combined with a sync engine, it enables [[OfflineFirst]] architectures.
- **Data that needs to be observed** — Room's `Flow`/`LiveData` return types automatically notify observers when data changes. Ideal for UI that reacts to database updates (lists, detail screens, dashboards).
- **Complex queries with compile-time validation** — Room validates SQL syntax at compile time. A typo in a column name or table reference is caught during compilation, not at runtime. This is a significant advantage over raw `SQLiteDatabase.query()`.
- **Migration-controlled schema evolution** — Room requires explicit `Migration` objects for schema changes between versions. This forces developers to think about data migration and prevents accidental data loss.
- **Apps using Paging 3** — Room integrates directly with Android's Paging library. `PagingSource` implementations are generated from `@Query` methods with `LIMIT`/`OFFSET`, enabling efficient lazy-loaded lists.

## When NOT to Use

- **Simple key-value data** — `DataStore` (preferences) or `SharedPreferences` (legacy) is sufficient for storing settings, flags, and small configuration values. Room adds significant boilerplate for this use case.
- **When you need advanced SQL features** — Room does not support CTEs (`WITH` clauses), window functions (`ROW_NUMBER()`, `RANK()`), or `GROUP_CONCAT` with custom separators in a type-safe way. Use raw SQLite via `SupportSQLiteDatabase` or a library like SQLDelight.
- **Cross-platform applications** — Room is Android-only (with JVM support for testing). If your app also runs on iOS, use a cross-platform solution (Realm, SQLite with a shared schema, or a sync engine).
- **High-throughput write scenarios** — inserting 10,000+ records per second (sensor data, event logging). Room's abstraction layer adds overhead. Use raw SQLite with `INSERT OR REPLACE` in a transaction, or a specialized time-series database.
- **When compile-time code generation is undesirable** — Room's annotation processor (KSP or kapt) adds 10–30 seconds to build times and generates thousands of lines of code. If build speed is critical, consider SQLDelight (generates less code) or raw SQLite.
- **Apps with highly dynamic schemas** — Room requires a fixed schema defined at compile time. If your data model is user-defined or changes at runtime (dynamic forms, EAV patterns), Room is the wrong tool. Store JSON in a TEXT column and parse at runtime.

## Tradeoffs

| Dimension | Room | SQLDelight |
|-----------|------|-----------|
| **API style** | Annotation-based (`@Query`, `@Insert`) | SQL-first (write `.sq` files, generate Kotlin) |
| **Compile-time validation** | SQL syntax validated | Full SQL grammar validated (including migrations) |
| **Multi-platform** | Android + JVM only | Android, iOS, JVM, JS (via Kotlin Multiplatform) |
| **Advanced SQL** | Limited (no CTEs, no window functions in type-safe API) | Full SQL support (CTEs, window functions, custom SQL) |
| **Boilerplate** | Moderate (entities, DAOs, database class) | Low (just write SQL) |
| **Build time overhead** | 10–30s (KSP/kapt) | 5–15s (SQLDelight compiler) |
| **Observation** | Built-in (Flow/LiveData) | Built-in (Flow) |

| Dimension | Room | Raw SQLite (`SQLiteOpenHelper`) |
|-----------|------|-------------------------------|
| **Boilerplate** | Low (annotations generate code) | High (manual cursor parsing, ContentValues) |
| **Compile-time safety** | SQL validated at compile time | Runtime errors only |
| **Async queries** | Built-in (`suspend` functions) | Manual (wrap with coroutines) |
| **Observation** | Built-in (`Flow`/`LiveData`) | Manual (implement `ContentObserver`) |
| **Migration** | Structured (`Migration` objects) | Manual (`execSQL` in `onUpgrade`) |
| **Control** | Abstracted (limited to Room's API) | Full control over SQL and database config |

## Alternatives

- **SQLDelight** — write SQL in `.sq` files and generate type-safe Kotlin APIs. Supports Kotlin Multiplatform (Android, iOS, desktop, web). Better SQL coverage than Room.
- **Realm** — a mobile-first database with a custom storage engine (not SQLite). Simpler API, faster performance, and cross-platform. Adds ~5–8 MB to the app binary.
- **ObjectBox** — a NoSQL object database for Android. Extremely fast (faster than Room for most operations). Stores objects directly without mapping. Less community adoption.
- **DataStore (Preferences)** — for key-value data. Async, type-safe, and supports transactions. Not a relational database but replaces `SharedPreferences`.
- **Raw SQLite via `SupportSQLiteOpenHelper`** — full control over SQL, indexes, and database configuration. Maximum boilerplate. Use when Room's abstraction is too limiting.

## Failure Modes

1. **Database access on the main thread** — Room throws `IllegalStateException` if you query the database from the main thread without allowing main thread queries (which is disabled by default). Even with `allowMainThreadQueries()`, this causes ANRs (Application Not Responding) on large queries → always use Room's coroutine support: `suspend` functions in DAOs automatically run on a background thread. Call them from a `viewModelScope.launch { }` coroutine. For Flow-returning queries, Room handles threading internally.

2. **Missing migration for schema changes** — adding a column to an entity without providing a `Migration` from version N to N+1 causes the app to crash on launch with `IllegalStateException: Room cannot verify the data integrity` → every schema change requires a version bump and a `Migration` object. For simple changes (adding/dropping columns), use `fallbackToDestructiveMigration()` during development, but never in production. Write migrations and test them with the oldest supported schema version.

3. **N+1 query problem with `@Relation`** — fetching a list of `User` entities with a `@Relation` to their `Post` entities causes Room to execute 1 query for users + N queries for posts (one per user). With 500 users, this is 501 queries → use `@Transaction` with a custom `@Query` that performs a JOIN and maps the result manually, or use `@RewriteQueriesToDropUnusedColumns` to optimize. For large datasets, paginate with `PagingSource`.

4. **Memory leak from unclosed Flow observers** — a `Flow<List<T>>` from a DAO is collected in a coroutine that is never cancelled. The `InvalidationTracker` holds a reference to the observer, preventing garbage collection → use `lifecycleScope.launchWhenStarted` or `repeatOnLifecycle(STARTED)` to collect Flow only when the UI is visible. In ViewModels, use `stateIn` with an appropriate `SharingStarted` policy to manage the lifecycle.

5. **Foreign key violations silently passing** — by default, Room does not enforce foreign key constraints. You can insert an `Order` with a `userId` that does not exist in the `User` table → enable foreign keys in the database configuration: `@Database(entities = [...], version = 1, exportSchema = true)` and override `createOpenHelper`:
   ```kotlin
   override fun onCreate(db: SupportSQLiteDatabase) {
       super.onCreate(db)
       db.execSQL("PRAGMA foreign_keys=ON")
   }
   ```

6. **Large query results causing OOM** — fetching 100,000 rows into a `List<Entity>` loads all objects into memory simultaneously, triggering `OutOfMemoryError` → use `PagingSource` with `PagingDataAdapter` for lazy loading. Room generates the `PagingSource` from queries with `LIMIT`/`OFFSET`. Set `pageSize = 50` for typical lists. Alternatively, use `@Query` with `LIMIT` and `OFFSET` manually.

7. **TypeConverter nullability issues** — a `@TypeConverter` that converts `Date?` to `Long?` returns `null` for a non-nullable column. Room inserts `NULL` into a `NOT NULL` column, causing a `SQLiteConstraintException` → ensure type converters handle nullability correctly. Annotate converter functions with appropriate nullability: `@TypeConverter fun fromTimestamp(value: Long?): Date? = value?.let { Date(it) }`.

8. **Database corruption from abrupt process termination** — the app is killed while writing to the database (force close, low memory kill), leaving the SQLite file in a corrupted state. Subsequent launches fail with `SQLiteException: database disk image is malformed` → enable WAL (Write-Ahead Logging) mode for better crash resilience: `roomDatabase().openHelper.writableDatabase.enableWriteAheadLogging()`. Room enables WAL by default since version 2.2. On corruption, catch the exception, delete the database file, and recreate it.

9. **Index missing on frequently queried columns** — querying `WHERE status = 'pending'` on a table with 50,000 rows performs a full table scan, taking 200+ ms → add `@Entity(indices = [Index(value = ["status"])])`. Verify with `EXPLAIN QUERY PLAN` that the index is used. Monitor query performance with `SELECT * FROM sqlite_stat1` after collecting statistics.

10. **DAO method signature mismatch** — a `@Query("SELECT * FROM users WHERE id = :id")` returns `Flow<User?>` but the DAO method is declared as `fun getUser(id: String): Flow<User>` (non-nullable). When the user does not exist, Room emits `null`, causing a `NullPointerException` in the collector → match the DAO return type to the query's nullability. If the query may return no rows, use `Flow<T?>`. Use `firstOrNull()` for one-shot queries that may not find a match.

## Code Examples

### Complete Room Setup

```kotlin
// Entity
@Entity(tableName = "orders", indices = [Index(value = ["status"]), Index(value = ["userId"])])
data class Order(
    @PrimaryKey val id: String,
    val userId: String,
    val itemName: String,
    val total: Double,
    val status: OrderStatus,
    val createdAt: Long, // milliseconds since epoch
    val updatedAt: Long
)

enum class OrderStatus { PENDING, PROCESSING, SHIPPED, DELIVERED }

// DAO
@Dao
interface OrderDao {
    @Query("SELECT * FROM orders WHERE userId = :userId ORDER BY createdAt DESC")
    fun getOrdersByUser(userId: String): Flow<List<Order>>

    @Query("SELECT * FROM orders WHERE id = :orderId")
    suspend fun getOrderById(orderId: String): Order?

    @Query("SELECT * FROM orders WHERE status = :status LIMIT :limit OFFSET :offset")
    suspend fun getOrdersByStatus(
        status: OrderStatus,
        limit: Int = 50,
        offset: Int = 0
    ): List<Order>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertOrder(order: Order)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertOrders(orders: List<Order>)

    @Update
    suspend fun updateOrder(order: Order)

    @Query("UPDATE orders SET status = :status, updatedAt = :now WHERE id = :orderId")
    suspend fun updateOrderStatus(orderId: String, status: OrderStatus, now: Long = System.currentTimeMillis())

    @Query("DELETE FROM orders WHERE status = 'DELIVERED' AND updatedAt < :cutoffDate")
    suspend fun deleteOldDeliveredOrders(cutoffDate: Long)

    @Query("SELECT COUNT(*) FROM orders WHERE status = :status")
    fun countOrdersByStatus(status: OrderStatus): Flow<Int>
}

// Database
@Database(
    entities = [Order::class, User::class, OrderItem::class],
    version = 3,
    exportSchema = true
)
@TypeConverters(Converters::class)
abstract class AppDatabase : RoomDatabase() {
    abstract fun orderDao(): OrderDao
    abstract fun userDao(): UserDao

    companion object {
        @Volatile private var INSTANCE: AppDatabase? = null

        fun getInstance(context: Context): AppDatabase =
            INSTANCE ?: synchronized(this) {
                INSTANCE ?: Room.databaseBuilder(
                    context.applicationContext,
                    AppDatabase::class.java,
                    "app-database"
                )
                .addMigrations(MIGRATION_1_2, MIGRATION_2_3)
                .build()
                    .also { INSTANCE = it }
            }
    }
}

// Type Converters
object Converters {
    @TypeConverter
    @JvmStatic
    fun fromOrderStatus(status: OrderStatus): String = status.name

    @TypeConverter
    @JvmStatic
    fun toOrderStatus(name: String): OrderStatus = OrderStatus.valueOf(name)

    @TypeConverter
    @JvmStatic
    fun fromTimestamp(value: Long?): Date? = value?.let { Date(it) }

    @TypeConverter
    @JvmStatic
    fun dateToTimestamp(date: Date?): Long? = date?.time
}
```

### Migration

```kotlin
val MIGRATION_2_3 = object : Migration(2, 3) {
    override fun migrate(database: SupportSQLiteDatabase) {
        // Add a new column with a default value
        database.execSQL("ALTER TABLE orders ADD COLUMN discountPercent REAL NOT NULL DEFAULT 0.0")

        // Create a new table
        database.execSQL(
            """
            CREATE TABLE IF NOT EXISTS order_notes (
                id TEXT NOT NULL PRIMARY KEY,
                orderId TEXT NOT NULL,
                note TEXT NOT NULL,
                createdAt INTEGER NOT NULL,
                FOREIGN KEY (orderId) REFERENCES orders(id) ON DELETE CASCADE
            )
            """
        )
        database.execSQL("CREATE INDEX IF NOT EXISTS index_order_notes_orderId ON order_notes(orderId)")
    }
}
```

### Repository Pattern with Room + Network

```kotlin
class OrderRepository(
    private val orderDao: OrderDao,
    private val apiClient: OrderApi
) {
    /**
     * Returns a Flow that emits the local orders list and re-emits when the database changes.
     * Triggers a network refresh in the background.
     */
    fun getOrdersStream(userId: String): Flow<List<Order>> = flow {
        // Emit local data immediately
        orderDao.getOrdersByUser(userId).collect { localOrders ->
            emit(localOrders)
        }
    }.onStart {
        // Refresh from network in background
        refreshOrders(userId)
    }

    suspend fun refreshOrders(userId: String) {
        try {
            val remoteOrders = apiClient.getOrders(userId)
            orderDao.insertOrders(remoteOrders.map { it.toEntity() })
        } catch (e: IOException) {
            // Network unavailable — local data still available
            Timber.w(e, "Failed to refresh orders from network")
        }
    }

    suspend fun createOrder(order: Order) {
        orderDao.insertOrder(order)
        // Optimistic: already in DB. Sync to server in background.
        try {
            val created = apiClient.createOrder(order.toDto())
            // Update local with server-assigned fields
            orderDao.updateOrder(created.toEntity())
        } catch (e: Exception) {
            // Mark as pending sync
            Timber.e(e, "Failed to sync order to server")
        }
    }
}
```

### Unit Testing Room DAOs

```kotlin
class OrderDaoTest {
    private lateinit var db: AppDatabase
    private lateinit var orderDao: OrderDao

    @Before
    fun setUp() {
        val context = ApplicationProvider.getApplicationContext<Context>()
        db = Room.inMemoryDatabaseBuilder(context, AppDatabase::class.java)
            .allowMainThreadQueries() // OK for tests
            .build()
        orderDao = db.orderDao()
    }

    @After
    fun tearDown() {
        db.close()
    }

    @Test
    fun insertAndFetchOrder() = runTest {
        val order = Order(
            id = "ord-1",
            userId = "usr-42",
            itemName = "Pizza Margherita",
            total = 14.99,
            status = OrderStatus.PENDING,
            createdAt = 1700000000L,
            updatedAt = 1700000000L
        )

        orderDao.insertOrder(order)
        val fetched = orderDao.getOrderById("ord-1")

        assertNotNull(fetched)
        assertEquals(order.itemName, fetched?.itemName)
        assertEquals(order.total, fetched?.total)
    }

    @Test
    fun ordersByUser_returnsOnlyMatchingUser() = runTest {
        orderDao.insertOrders(listOf(
            Order("ord-1", "usr-1", "Item A", 10.0, OrderStatus.PENDING, 1L, 1L),
            Order("ord-2", "usr-2", "Item B", 20.0, OrderStatus.PENDING, 2L, 2L),
        ))

        val user1Orders = orderDao.getOrdersByUser("usr-1").first()
        assertEquals(1, user1Orders.size)
        assertEquals("ord-1", user1Orders[0].id)
    }
}
```

## Best Practices

- **Always use coroutines with Room.** Declare DAO methods as `suspend` functions or returning `Flow<T>`. Room automatically executes them on background threads. Never use `allowMainThreadQueries()` in production.
- **Export schemas for migration validation.** Set `exportSchema = true` in `@Database` and configure the schema output directory in `build.gradle.kts`: `ksp { arg("room.schemaLocation", "$projectDir/schemas") }`. Commit schema JSON files to version control. Room validates them during compilation.
- **Write migrations for every schema change.** Increment the `version` number and add a `Migration` object. Test migrations from the oldest supported version to the current version. Never use `fallbackToDestructiveMigration()` in production — it deletes all user data.
- **Use indices on frequently queried columns.** Any column used in a `WHERE`, `ORDER BY`, or `JOIN` clause with more than 1,000 rows benefits from an index. Verify with `EXPLAIN QUERY PLAN`.
- **Use the Repository pattern.** Do not expose Room DAOs directly to ViewModels or UI components. A repository abstracts the data source (local + remote) and provides a clean API: `fun getOrdersStream(): Flow<List<Order>>`.
- **Use `OnConflictStrategy.REPLACE` judiciously.** It performs a `DELETE` + `INSERT`, which triggers Flow observers even if the data has not changed. Use `OnConflictStrategy.IGNORE` to skip duplicates or `OnConflictStrategy.ABORT` to fail on conflict.
- **Batch insert/update/delete operations.** `suspend fun insertOrders(orders: List<Order>)` runs in a single transaction, which is 10–100x faster than inserting one at a time. Room automatically wraps list operations in a transaction.
- **Keep entities simple.** Do not put business logic in entity classes. They should be data holders with minimal behavior. Use separate domain classes or use cases for business logic.
- **Test DAOs with an in-memory database.** `Room.inMemoryDatabaseBuilder` creates a fast, isolated database for unit tests. Do not mock DAOs — test the real Room-generated implementation.
- **Monitor database size in production.** Use `PRAGMA page_count` and `PRAGMA page_size` to check database size. Implement periodic cleanup of old data (e.g., delete delivered orders older than 90 days).

## Related Topics

- [[Mobile MOC]]
- [[Android]]
- [[Databases MOC]]
- [[DatabaseOptimization]]
- [[SQLite]]
- [[OfflineFirst]]
- [[Coroutines]]
- [[MobileArchitecture]]
- [[SchemaEvolution]]
