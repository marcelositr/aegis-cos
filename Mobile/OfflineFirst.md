---
title: Offline First
layer: mobile
type: concept
priority: high
version: 2.0.0
tags:
  - Mobile
  - Offline
  - Architecture
  - Sync
  - DataConsistency
  - ConflictResolution
description: An architecture pattern where applications are designed to work fully without network connectivity, using local storage as the primary data source and syncing with a remote server when connectivity is available.
---

# Offline First

## Description

Offline First is an application architecture where the local device is the primary data source, and the remote server is a synchronization target. The application reads from and writes to a local database, providing full functionality regardless of network connectivity. A background sync engine propagates local changes to the server and pulls remote changes when connectivity is restored.

Core components:
- **Local database** — SQLite, Room, Core Data, Realm, or an embedded store on the device. This is the single source of truth for the UI at all times.
- **Sync engine** — a background process that monitors the local database for changes (via triggers, observation APIs, or an outbox table) and propagates them to the server. Handles retry, conflict resolution, and backpressure.
- **Conflict resolution strategy** — the algorithm for reconciling divergent state when two devices modify the same data. Options include Last-Write-Wins (LWW), field-level merge, operational transforms, or CRDTs (Conflict-free Replicated Data Types).
- **Outbox pattern** — a dedicated table that queues pending writes. Each entry tracks the operation type, payload, retry count, and server response status. The sync engine processes the outbox FIFO (or by priority).
- **Connectivity awareness** — monitoring network state (WiFi, cellular, offline) to trigger or defer sync. Uses `ConnectivityManager` (Android), `NWPathMonitor` (iOS), or `navigator.onLine` (web).
- **Optimistic UI** — the UI reflects user actions immediately (writes succeed locally) without waiting for server confirmation. The user never sees a loading spinner for their own actions. Errors are surfaced asynchronously (e.g., "Message failed to send — tap to retry").

## When to Use

- **Field service and logistics apps** — delivery drivers, warehouse workers, utility inspectors who operate in basements, rural areas, or buildings with no signal. The app must function fully offline and sync when back in range.
- **Note-taking and document editors** — apps like Google Docs, Notion, or Apple Notes where users expect instant save and the ability to edit without connectivity. Conflict resolution handles concurrent edits from multiple devices.
- **Messaging and social apps** — WhatsApp, Signal, and iMessage queue outgoing messages locally and deliver them when online. Messages are stored locally for search and offline reading.
- **E-commerce and food delivery apps** — browsing the product catalog, building a cart, and even placing orders (queued locally) should work offline. The checkout completes when connectivity returns.
- **Travel and navigation apps** — offline maps, saved itineraries, boarding passes, and hotel confirmations must be accessible without signal. Google Maps and Airbnb are canonical examples.
- **Healthcare apps in low-connectivity settings** — patient intake, vital recording, and prescription lookup in rural clinics or developing regions. Data syncs when the device reaches a connected area.
- **Enterprise apps with compliance requirements** — apps that must remain functional during network outages (emergency response, military, aviation). Offline-first is a reliability requirement, not a nice-to-have.

## When NOT to Use

- **Real-time collaboration tools** — when multiple users edit the same document simultaneously and expect to see each other's changes in real-time (e.g., Figma, Google Sheets live mode). The latency of local-first + sync is incompatible with sub-second collaboration. Use WebSocket-based real-time protocols instead.
- **Simple content consumption apps** — news readers, video streaming, or podcast apps where the primary interaction is fetching and displaying server content. A simple cache (with offline read for cached items) is sufficient; full offline-first is overkill.
- **Security-critical apps requiring server validation** — banking transactions, identity verification, or authentication flows where every action must be validated by the server in real-time. You cannot defer a $10,000 wire transfer to an outbox.
- **Apps with highly dynamic, time-sensitive data** — stock trading dashboards, live sports scores, or auction platforms where data older than a few seconds is worthless. Offline state would be misleading.
- **When the team has no distributed systems experience** — offline-first introduces eventual consistency, conflict resolution, sync ordering, and debugging complexity that requires understanding of distributed systems concepts.
- **When storage constraints are extreme** — the local database stores a copy of all user-facing data. For data-heavy apps (photo libraries, video catalogs, large product catalogs), the on-device storage requirements may exceed available space.
- **When the business logic depends on server-side computation** — pricing engines, fraud detection, inventory allocation that must run on the server before the user sees a result. You cannot optimistically show a confirmed order if the server may reject it due to stock availability.

## Tradeoffs

| Dimension | Offline First | Online First (with caching) |
|-----------|--------------|---------------------------|
| **User experience offline** | Full functionality | Limited to cached data; writes fail |
| **Complexity** | High (sync engine, conflict resolution, outbox) | Low (cache + network fallback) |
| **Data freshness** | Eventually consistent; may show stale data | Real-time when online |
| **Storage** | Full dataset on device | Only cached items |
| **Development cost** | 2–4x more than online-first | Baseline |
| **Debugging** | Hard (race conditions, sync bugs, divergence) | Easier (single source of truth) |

| Dimension | LWW (Last-Write-Wins) | CRDTs |
|-----------|----------------------|-------|
| **Implementation complexity** | Low (compare timestamps) | High (specialized data structures) |
| **Conflict resolution** | Loses one writer's changes | Merges all changes |
| **Use case fit** | Simple fields (name, status, toggle) | Complex structures (lists, maps, nested objects) |
| **Storage overhead** | Minimal (one timestamp per field) | 2–10x metadata per element |
| **Convergence guarantee** | Timestamp sync required; clock skew causes errors | Mathematically guaranteed without coordination |

## Alternatives

- **Online-first with cache** — the default for most apps. Fetch from the network, cache responses locally, and serve cached data when offline. Writes fail without connectivity. Simpler but provides a degraded offline experience.
- **PWA with Service Worker caching** — web-based offline-first using Cache API and IndexedDB. Lower on-device capability than native but works across all platforms. See [[PWA]] for details.
- **Sync-as-a-Service** — third-party services that handle the sync layer: PowerSync, ElectricSQL, RxDB, CouchDB/PouchDB. They provide conflict resolution, real-time sync, and offline storage out of the box.
- **Event sourcing + replay** — store all user actions as events locally. When connectivity returns, replay events to the server. The server is the source of truth; the local event log is a projection. Used by apps like Linear and Slack.
- **Manual sync trigger** — the user explicitly pulls to refresh or taps a "sync" button. Simpler than automatic sync but places the burden on the user.

## Failure Modes

1. **Write-write conflicts with LWW losing data** — two devices edit the same field. Device A changes "status: pending" to "status: approved" at 10:00. Device B changes it to "status: rejected" at 10:01. LWW keeps "rejected" and silently discards "approved" → use field-level merge where possible (different fields on the same record can be merged). For the same field, detect conflicts and present a resolution UI to the user. Never silently discard a write in critical workflows.

2. **Clock skew corrupting LWW ordering** — Device A's clock is 5 minutes behind the server. Its write appears "older" than a write from Device B even though it was actually later → do not rely on device clocks for ordering. Use server-assigned logical timestamps (Lamport clocks) or vector clocks. If using LWW, use the server's `received_at` timestamp, not the device's `created_at`.

3. **Outbox ordering violations** — the outbox processes operations out of order: a "delete order" is processed before "update order", causing a server error because the update was applied to a now-deleted entity → the outbox must process operations in causal order. Use a single-threaded sync worker per entity type. Tag operations with a sequence number. For dependent operations (create → update → delete), use a single compound operation.

4. **Sync storm after connectivity restore** — 50,000 devices that were offline for 8 hours all reconnect simultaneously and flood the sync endpoint, causing a server-side outage → implement exponential backoff with jitter on the client. Use server-side rate limiting and request queuing. Batch multiple local changes into a single sync request (e.g., "sync all changes from sequence 4500 to 4567").

5. **Partial sync leaving inconsistent state** — the sync engine uploads 5 of 8 pending operations, then loses connectivity. The server has a partial view of the user's intent → use idempotent operations on the server. Each outbox entry has a client-side UUID. The server deduplicates by UUID. On reconnect, the client retries all unacknowledged entries. The server ignores already-processed entries.

6. **Schema drift between client and server** — the server adds a new required field to the `Order` model, but the client's local database does not have the column. Sync fails with a deserialization error → version your API and local schema together. The sync engine should handle unknown fields gracefully (ignore them) and missing fields with defaults. Implement a schema negotiation step during sync handshake.

7. **Local database growth without bounds** — the outbox accumulates failed operations, the history table grows with every change, and the device runs out of storage after 6 months → implement TTL policies for local data. Purge acknowledged outbox entries. Archive old history to the server and delete locally. Set a maximum local database size and evict the oldest synced data when the limit is reached.

8. **Optimistic UI showing invalid state** — the user creates an order with an invalid coupon code. The UI shows the discount locally, but the server rejects it. The UI now shows incorrect information without the user knowing → after the sync fails, revert the local state to the server's response and show a clear error message. Use a two-phase commit: apply the change locally with a "pending" visual indicator (e.g., greyed out). On server confirmation, switch to the "confirmed" indicator. On rejection, revert and explain why.

9. **Merge conflicts in list structures** — Device A adds item X to a list. Device B deletes item Y from the same list. A simple array merge cannot determine the correct result → use a CRDT for list structures (RGA, LSEQ, or Yjs). Alternatively, use an operation-based approach where each list mutation is tagged with the element's unique ID and the operation type (insert before/after, delete).

10. **Sync engine running on the wrong thread** — on Android, the sync worker runs on the main thread, blocking the UI during bulk sync. On iOS, it runs on a background thread that gets suspended when the app is backgrounded → use `WorkManager` (Android) for guaranteed background sync with retry. Use `BGTaskScheduler` (iOS) for background processing tasks. Both handle OS-level scheduling and battery optimization constraints.

## Code Examples

### Outbox Pattern with Room (Android)

```kotlin
@Entity(tableName = "sync_outbox")
data class OutboxEntry(
    @PrimaryKey val id: String = UUID.randomUUID().toString(),
    val operation: String,       // "CREATE", "UPDATE", "DELETE"
    val entityType: String,      // "order", "customer", etc.
    val entityId: String,
    val payload: String,         // JSON payload
    val sequenceNumber: Long,    // Causal ordering
    val retryCount: Int = 0,
    val createdAt: Long = System.currentTimeMillis()
)

@Dao
interface OutboxDao {
    @Query("SELECT * FROM sync_outbox ORDER BY sequenceNumber ASC")
    suspend fun getPendingEntries(): List<OutboxEntry>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(entry: OutboxEntry)

    @Query("DELETE FROM sync_outbox WHERE id = :id")
    suspend fun remove(id: String)

    @Query("UPDATE sync_outbox SET retryCount = retryCount + 1 WHERE id = :id")
    suspend fun incrementRetry(id: String)
}

// Sync worker
class SyncWorker(
    private val outboxDao: OutboxDao,
    private val apiClient: ApiClient,
    private val context: Context
) {
    suspend fun sync() = withContext(Dispatchers.IO) {
        val entries = outboxDao.getPendingEntries()

        for (entry in entries) {
            try {
                when (entry.operation) {
                    "CREATE" -> apiClient.create(entry.entityType, entry.payload)
                    "UPDATE" -> apiClient.update(entry.entityType, entry.entityId, entry.payload)
                    "DELETE" -> apiClient.delete(entry.entityType, entry.entityId)
                }
                outboxDao.remove(entry.id)
            } catch (e: HttpException) {
                if (e.code() == 409) {
                    // Conflict — server has different state
                    handleConflict(entry, e)
                } else if (e.code() in 500..599) {
                    // Server error — retry later
                    outboxDao.incrementRetry(entry.id)
                } else {
                    // Client error (4xx) — remove from outbox, notify user
                    outboxDao.remove(entry.id)
                    notifySyncError(entry, e)
                }
            } catch (e: IOException) {
                // Network error — abort sync, will retry later
                return@withContext
            }
        }
    }

    private suspend fun handleConflict(entry: OutboxEntry, e: HttpException) {
        // Fetch server version and merge
        val serverData = apiClient.get(entry.entityType, entry.entityId)
        val merged = mergeStrategy.merge(entry.payload, serverData)
        // Update local DB with merged result and re-queue
        // ...
    }
}
```

### Connectivity-Aware Sync (iOS/Swift)

```swift
import Network
import Combine

class SyncManager: ObservableObject {
    @Published var isOnline = false
    @Published var lastSyncTime: Date?

    private let monitor = NWPathMonitor()
    private let syncService: SyncServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    private let syncQueue = DispatchQueue(label: "com.app.sync")

    init(syncService: SyncServiceProtocol) {
        self.syncService = syncService

        monitor.pathUpdateHandler = { [weak self] path in
            self?.isOnline = path.status == .satisfied
            if path.status == .satisfied {
                self?.triggerSync()
            }
        }
        monitor.start(queue: syncQueue)
    }

    func triggerSync() {
        guard isOnline else { return }

        Task {
            do {
                try await syncService.syncPendingChanges()
                lastSyncTime = Date()
            } catch {
                // Log error; will retry on next connectivity event
                os_log("Sync failed: %{public}@", type: .error, error.localizedDescription)
            }
        }
    }
}
```

### Optimistic UI with Revert on Failure (React Native)

```tsx
function MessageInput({ channelId }: { channelId: string }) {
  const [draft, setDraft] = useState('');
  const { optimisticMessages, addOptimistic, confirmMessage, rejectMessage } = useChannelStore();

  const send = useCallback(async () => {
    if (!draft.trim()) return;

    const tempId = `temp-${Date.now()}`;
    const message = { id: tempId, text: draft, status: 'pending' as const };

    // Optimistic: show immediately
    addOptimistic(message);
    setDraft('');

    try {
      const serverMessage = await api.sendMessage(channelId, draft);
      // Confirm: replace temp ID with real server ID
      confirmMessage(tempId, serverMessage);
    } catch (error) {
      // Reject: show error and allow retry
      rejectMessage(tempId, error.message);
    }
  }, [draft, channelId]);

  return (
    <View>
      {optimisticMessages.map((msg) => (
        <MessageBubble
          key={msg.id}
          text={msg.text}
          status={msg.status} // 'pending' | 'sent' | 'error'
          onRetry={() => retrySend(msg)}
        />
      ))}
      <TextInput value={draft} onChangeText={setDraft} onSubmitEditing={send} />
    </View>
  );
}
```

## Best Practices

- **Design the local schema first, the API second.** The local database is your primary data model. The API is a synchronization detail. This inversion (compared to online-first) prevents API-driven design mistakes.
- **Use the outbox pattern for all writes.** Never write directly to the API. Every write goes to the outbox first, then the sync engine processes it. This guarantees that writes are never lost, even if the app crashes mid-request.
- **Make all server operations idempotent.** The server must handle duplicate requests gracefully. Use client-generated UUIDs for every operation. The server deduplicates by UUID and returns the same response for retries.
- **Implement exponential backoff with jitter.** On sync failure, wait `min(2^attempt * 1000ms + random_jitter, 30000ms)`. Jitter prevents thundering herd when many devices reconnect simultaneously.
- **Use vector clocks or server-assigned sequence numbers for ordering.** Never trust device clocks. Logical timestamps are the only reliable way to order events in a distributed system.
- **Test offline scenarios explicitly.** Use network link conditioners (iOS), Android Emulator's network throttling, or Charles Proxy to simulate offline, slow 3G, and intermittent connectivity. Write E2E tests for each scenario.
- **Show sync status to the user.** A small indicator ("Last synced: 2 min ago" or "3 messages pending") builds trust. Users should know when their data is not yet on the server.
- **Set local data TTLs.** Not all data needs to be stored forever. Cached product catalogs, old messages, and expired offers should be purged to prevent unbounded local storage growth.
- **Prefer append-only local writes.** Instead of updating a record, append a new version. The sync engine sends the full version history, and the server resolves to the latest state. This simplifies conflict resolution and provides an audit trail.
- **Use CRDTs for collaborative data structures.** If your app has shared lists, maps, or text documents, invest in a CRDT library (Yjs, Automerge, or a custom implementation). LWW will lose data in concurrent edit scenarios.

## Related Topics

- [[Mobile MOC]]
- [[MobileArchitecture]]
- [[Android]] — Android offline with Room
- [[iOS]] — iOS offline with Core Data/SwiftData
- [[PWA]] — Offline support via Service Workers
- [[Resilience]] — Resilience patterns for offline systems
- [[StateMachines]] — Sync state machine patterns
- [[Databases MOC]]
- [[Caching]] — Cache vs offline storage
- [[MessageQueues]] — Outbox pattern
- [[Consistency]] — Eventual consistency in offline mode
- [[DistributedTransactions]] — Sync as distributed transaction
- [[SchemaEvolution]] — Local database migrations
