---
title: Progressive Web Apps
layer: mobile
type: concept
priority: high
version: 2.0.0
tags:
  - Mobile
  - Web
  - PWA
  - ServiceWorker
  - Offline
  - WebApp
description: Web applications that use service workers, web app manifests, and modern web APIs to deliver native-app-like experiences: offline support, push notifications, background sync, and installability.
---

# Progressive Web Apps

## Description

Progressive Web Apps (PWAs) are web applications enhanced with a set of technologies that bridge the gap between web and native apps. The three core technologies are:

1. **Service Workers** — a script that runs in the background (separate from the web page) and intercepts network requests, enabling caching, offline support, push notifications, and background sync. Service workers are event-driven, have no DOM access, and persist across page navigations.
2. **Web App Manifest** — a JSON file that defines the app's name, icons, theme colors, display mode (`standalone`, `fullscreen`, `minimal-ui`), and orientation. Enables the "Add to Home Screen" prompt and makes the PWA launch like a native app (no browser chrome).
3. **HTTPS** — all PWA features require a secure context. The only exception is `localhost` for development.

Additional capabilities:
- **Push Notifications** — via the Push API and Notification API. The server sends a push message via a push service (FCM on Chrome, APNs on Safari). The service worker receives it and displays a system notification, even when the app is closed.
- **Background Sync** — the `sync` event defers actions until connectivity is available. Used for sending queued form submissions, chat messages, or analytics when the user regains connectivity.
- **Periodic Background Sync** — `periodicsync` wakes up the service worker at intervals (controlled by the browser) to fetch fresh content. Available on Chrome for Android.
- **Web Share API** — triggers the native share sheet, enabling PWAs to share content like native apps.
- **File System Access API** — read/write files on the user's device (desktop PWAs).
- **WebAPK (Android)** — Chrome generates a lightweight APK that wraps the PWA, enabling it to appear in the app launcher, Play Store listing, and Android settings.

**Installability criteria (Chrome):**
- Valid web app manifest with `name`, `short_name`, `icons` (192px and 512px), and `start_url`.
- Service worker with a `fetch` event handler.
- Served over HTTPS.
- Meets the engagement heuristic (user has visited at least twice, with at least 5 minutes between visits).

## When to Use

- **Extending reach without app store friction** — PWAs are discoverable via search, shareable via URL, and installable without app store approval. Ideal for media companies, e-commerce, and content platforms that want to reduce user acquisition costs.
- **Emerging market audiences** — PWAs download ~10x less data than native apps (2 MB vs 20 MB) and work on low-end devices. Twitter Lite, Uber, and Ola have seen 2–4x increases in engagement from PWA versions in emerging markets.
- **Offline content access** — news sites, recipe apps, travel guides, and documentation that users need to access without connectivity. Service workers cache the app shell and content for offline reading.
- **Push notification re-engagement** — e-commerce flash sales, breaking news alerts, and order status updates. Push notifications increase return visits by 3–10x compared to web-only engagement.
- **Cross-platform internal tools** — company dashboards, admin panels, and CRUD tools that need to work on any device (desktop, tablet, phone) without maintaining separate native apps.
- **Companion apps for existing services** — when you already have a responsive website and want to add installability and offline support without rebuilding in React Native or Flutter.
- **Rapid iteration cycles** — PWAs update instantly on the server. No app store review process. Fix a bug, deploy, and all users get the fix on their next load.

## When NOT to Use

- **Hardware-intensive features** — BLE (Bluetooth Low Energy), NFC, advanced camera controls, ARKit/ARCore, background location tracking, health sensors. Web APIs for these are limited or unavailable on most browsers. Use native apps.
- **Apps requiring deep OS integration** — widgets, lock screen controls, Siri/Google Assistant shortcuts, clipboard access, contacts integration, calendar write access. These require native platform APIs.
- **iOS-critical experiences** — Safari on iOS restricts PWA capabilities: no push notifications (until iOS 16.4 with limited support), no background sync, no periodic sync, storage capped at ~7 days without user interaction (ITP), no WebAPK. If your primary audience is iOS users and you need these features, build native.
- **Games and media-rich apps** — WebGL and WebAssembly enable impressive web-based games, but performance, memory management, and distribution are far inferior to native. Use Unity, Unreal, or native game frameworks.
- **Payment processing requiring native SDKs** — Apple Pay and Google Pay work on the web, but in-app purchase (IAP) for digital goods on iOS requires StoreKit, which is unavailable to PWAs. If your monetization depends on IAP, you need a native app.
- **When you need guaranteed background execution** — service workers are woken up by the browser at its discretion. You cannot guarantee that a background sync will run within a specific time window. Native apps have more reliable background execution APIs.
- **Enterprise apps requiring MDM distribution** — Mobile Device Management systems deploy native apps via MAM/MDM policies. PWA deployment via MDM is immature and unsupported by most MDM vendors.

## Tradeoffs

| Dimension | PWA | Native App |
|-----------|-----|-----------|
| **Distribution** | URL, search engines, home screen install | App stores (Apple, Google) |
| **Install friction** | Low (tap "Add to Home Screen") | Higher (open store, download, install) |
| **Update model** | Instant (server deploy) | App store review + user update |
| **Offline support** | Service worker cache (app shell + content) | Full local database |
| **Push notifications** | Limited on iOS, full on Android | Full on both platforms |
| **Performance** | Good (limited by browser engine) | Best (direct hardware access) |
| **Storage limits** | ~50–100 MB (varies by browser; iOS purges after 7 days of inactivity) | Full device storage |
| **Discoverability** | Search engines + URL sharing | App store search + featured placement |
| **Monetization** | Stripe, PayPal (no IAP) | In-app purchases (30% store cut) |
| **Development cost** | Single codebase (web) | iOS + Android (or cross-platform) |

| Dimension | PWA | React Native / Flutter |
|-----------|-----|----------------------|
| **Codebase** | One (HTML/CSS/JS) | One (JSX or Dart) |
| **Offline** | Service worker (complex to debug) | Local database (mature tools) |
| **Install prompt** | Browser-controlled | App store install |
| **Performance** | Browser-limited | Near-native |
| **Ecosystem** | Entire web ecosystem (npm, web APIs) | Mobile-specific packages |
| **Debugging** | Chrome DevTools (excellent) | Platform debuggers (good) |

## Alternatives

- **Responsive web app (no PWA features)** — a well-designed mobile website without service workers or installability. Simpler but lacks offline support, push, and the native-like install experience.
- **Native app** — the gold standard for performance, feature access, and user trust. Required for hardware features, deep OS integration, and app store distribution.
- **React Native / Flutter** — cross-platform native apps that provide native performance and broader API access while maintaining a single codebase. Higher development cost than PWA but better capabilities.
- **TWA (Trusted Web Activity)** — a Chrome feature that wraps a PWA in an Android app shell and publishes it to the Play Store. Combines PWA development with Play Store distribution. Requires Digital Asset Links verification.
- **Capacitor / Cordova** — wrap a web app in a native shell and provide JavaScript bridges to native APIs. Gives PWAs access to camera, geolocation, file system, and push notifications with minimal native code.

## Failure Modes

1. **Service worker caching stale content indefinitely** — a `CacheFirst` strategy caches `index.html` and never fetches the new version after a deployment. Users see a broken or outdated app → never use `CacheFirst` for `index.html`. Use `NetworkFirst` or `StaleWhileRevalidate` for the app shell. Implement a versioning scheme: include a build hash in the cache name (`app-shell-v2.3.1`), and activate the new cache only after the new service worker installs and claims clients.

2. **Service worker update not activating** — the new service worker enters the `waiting` state because old tabs still control pages. Users never get the update until they close all tabs → call `self.skipWaiting()` in the `install` event and `clients.claim()` in the `activate` event to immediately take control. Alternatively, show an in-app update prompt ("A new version is available. Reload?") using the `controllerchange` event.

3. **iOS Safari purging PWA data after 7 days** — if the user does not open the PWA for 7 days, Safari deletes all service worker registrations and cached data (ITP policy). The user opens the PWA and finds an empty cache → design for cache misses. Always fetch from the network when the cache is empty. Show a loading state, not an error. Use IndexedDB for critical user data (it is exempt from ITP in some cases, but do not rely on this).

4. **Push notification permission denial** — the browser prompts for notification permission on first visit. The user denies, and the PWA can never ask again → do not prompt on first visit. Explain the value first ("Get notified about order updates") and prompt after the user has engaged with the app. On denial, provide an in-app notification fallback (bell icon with badge).

5. **Manifest misconfiguration preventing installation** — the `start_url` points to a 404, icons are missing or wrong size, or `display` is set to `browser` instead of `standalone`. The "Add to Home Screen" prompt never fires → validate the manifest with Lighthouse (`Audits > Progressive Web App`). Test the install flow on Chrome for Android and Safari for iOS manually.

6. **Background sync not firing on iOS** — the `sync` API is not supported in Safari. Background sync events never fire on iOS, and queued actions are never sent → detect iOS Safari and fall back to sending queued actions on the next page load. Use `navigator.serviceWorker.ready` to check if the sync API is available.

7. **Service worker fetch handler breaking passthrough requests** — the `fetch` event handler catches all requests, including third-party API calls, analytics pings, and font loads. A bug in the handler returns `undefined` for non-cached requests, breaking the app → only intercept requests you intend to cache. For all other requests, return `fetch(event.request)` immediately. Use a routing library (Workbox Router) to define explicit routes.

8. **Cache storage quota exceeded** — the service worker caches every page a user visits, eventually hitting the browser's storage quota (typically 50–100 MB on mobile). New cache writes fail silently → implement a cache size limit. Use Workbox's `ExpirationPlugin` with `maxEntries` and `maxAgeSeconds`. Monitor the `quotaexceeded` event and purge the oldest entries.

9. **Mixed content blocking in production** — the PWA is served over HTTPS but makes HTTP requests to an API or loads HTTP images. The browser blocks mixed content, and the app breaks in production → ensure all resource URLs are HTTPS. Use protocol-relative URLs (`//api.example.com/data`) or enforce HTTPS via Content-Security-Policy headers. Test in production with a staging environment.

10. **Install prompt not appearing on iOS** — Safari does not fire a programmatic install prompt. Users must manually tap "Share > Add to Home Screen," which most do not know → add an inline banner in the app explaining how to install ("Tap the Share icon, then 'Add to Home Screen'"). Use the `beforeinstallprompt` event (Chrome only) to show a custom install button. Track install prompt impressions and conversions.

## Code Examples

### Service Worker with Workbox (Recommended)

```javascript
// sw.js — using Workbox (build step via workbox-webpack-plugin or workbox-cli)
import { precacheAndRoute } from 'workbox-precaching';
import { registerRoute } from 'workbox-routing';
import { StaleWhileRevalidate, CacheFirst, NetworkFirst } from 'workbox-strategies';
import { ExpirationPlugin } from 'workbox-expiration';
import { BackgroundSyncPlugin } from 'workbox-background-sync';

// Precache app shell (injected by build tool)
precacheAndRoute(self.__WB_MANIFEST);

// App shell: network first, fall back to cache
registerRoute(
  ({ request }) => request.mode === 'navigate',
  new NetworkFirst({
    cacheName: 'pages',
    plugins: [
      new ExpirationPlugin({ maxEntries: 50, maxAgeSeconds: 30 * 24 * 60 * 60 }),
    ],
  })
);

// API calls: stale while revalidate
registerRoute(
  ({ url }) => url.pathname.startsWith('/api/'),
  new StaleWhileRevalidate({
    cacheName: 'api-cache',
    plugins: [
      new ExpirationPlugin({ maxEntries: 100, maxAgeSeconds: 5 * 60 }),
    ],
  })
);

// Static assets (images, fonts): cache first
registerRoute(
  ({ request }) => request.destination === 'image' || request.destination === 'font',
  new CacheFirst({
    cacheName: 'static-assets',
    plugins: [
      new ExpirationPlugin({ maxEntries: 200, maxSizeMBS: 50 }),
    ],
  })
);

// Queue failed POST requests for background sync
const bgSyncPlugin = new BackgroundSyncPlugin('api-queue', {
  maxRetentionTime: 24 * 60, // 24 hours
});

registerRoute(
  ({ url }) => url.pathname.startsWith('/api/') && url.pathname !== '/api/health',
  new NetworkFirst({
    plugins: [bgSyncPlugin],
  }),
  'POST'
);
```

### Web App Manifest

```json
{
  "name": "ShopEasy — Online Marketplace",
  "short_name": "ShopEasy",
  "description": "Browse, order, and track deliveries",
  "start_url": "/?utm_source=pwa",
  "scope": "/",
  "display": "standalone",
  "orientation": "any",
  "theme_color": "#1a73e8",
  "background_color": "#ffffff",
  "categories": ["shopping"],
  "icons": [
    {
      "src": "/icons/icon-192.png",
      "sizes": "192x192",
      "type": "image/png",
      "purpose": "any"
    },
    {
      "src": "/icons/icon-512.png",
      "sizes": "512x512",
      "type": "image/png",
      "purpose": "any maskable"
    }
  ],
  "shortcuts": [
    {
      "name": "My Orders",
      "short_name": "Orders",
      "url": "/orders",
      "icons": [{ "src": "/icons/orders.png", "sizes": "96x96" }]
    },
    {
      "name": "Search",
      "short_name": "Search",
      "url": "/search",
      "icons": [{ "src": "/icons/search.png", "sizes": "96x96" }]
    }
  ]
}
```

### Push Notification Handling

```javascript
// In service worker
self.addEventListener('push', (event) => {
  const data = event.data?.json() ?? {};
  const title = data.title ?? 'New notification';
  const options = {
    body: data.body ?? '',
    icon: '/icons/icon-192.png',
    badge: '/icons/badge-96.png',
    data: { url: data.url ?? '/' },
    actions: [
      { action: 'view', title: 'View' },
      { action: 'dismiss', title: 'Dismiss' },
    ],
    tag: data.tag ?? 'default', // Collapse notifications with same tag
    renotify: true,
  };

  event.waitUntil(self.registration.showNotification(title, options));
});

self.addEventListener('notificationclick', (event) => {
  event.notification.close();

  if (event.action === 'view') {
    event.waitUntil(
      clients.matchAll({ type: 'window', includeUncontrolled: true }).then((clientList) => {
        // Focus existing tab or open new one
        for (const client of clientList) {
          if (client.url.includes(event.notification.data.url)) {
            return client.focus();
          }
        }
        return clients.openWindow(event.notification.data.url);
      })
    );
  }
});
```

### Service Worker Registration with Update Prompt

```javascript
// In the main app
if ('serviceWorker' in navigator) {
  window.addEventListener('load', async () => {
    const registration = await navigator.serviceWorker.register('/sw.js');

    // Detect new service worker waiting
    registration.addEventListener('updatefound', () => {
      const newWorker = registration.installing;
      newWorker.addEventListener('statechange', () => {
        if (newWorker.state === 'installed' && navigator.serviceWorker.controller) {
          // New SW installed, old one still controlling — show update prompt
          showUpdateBanner(() => {
            newWorker.postMessage({ type: 'SKIP_WAITING' });
          });
        }
      });
    });
  });

  // Listen for new service worker taking control
  navigator.serviceWorker.addEventListener('controllerchange', () => {
    // Reload to activate the new service worker
    window.location.reload();
  });
}

// In service worker
self.addEventListener('message', (event) => {
  if (event.data?.type === 'SKIP_WAITING') {
    self.skipWaiting();
  }
});
```

## Best Practices

- **Use Workbox for service worker management.** It provides production-tested caching strategies, background sync, and routing. Do not write raw service worker `fetch` handlers unless you have specific requirements Workbox cannot meet.
- **Cache the app shell with `precacheAndRoute`.** The HTML, CSS, JS, and icons that make up your app should be precached during the build step. This enables instant load on repeat visits, even offline.
- **Use `NetworkFirst` for HTML pages and `CacheFirst` for immutable assets (hashed filenames).** Pages change frequently; hashed assets never change until the hash changes.
- **Include `maskable` icons in your manifest.** Android adaptive icons require maskable icons (icon content centered with safe area). Without them, the icon may be cropped on some Android launchers.
- **Set a meaningful `start_url` with analytics tracking.** `"/?utm_source=pwa"` lets you measure PWA engagement separately from web traffic.
- **Implement a custom install prompt.** The browser's `beforeinstallprompt` event (Chrome) lets you show a native-looking install button in your UI. This converts 2–5x better than the default browser prompt.
- **Test offline with Chrome DevTools.** Open DevTools > Application > Service Workers > check "Offline". Test every page and interaction. Lighthouse's PWA audit catches common misconfigurations.
- **Handle iOS limitations gracefully.** Detect iOS Safari and hide features that do not work (push, background sync). Show install instructions instead of relying on the browser prompt.
- **Use IndexedDB for user data, Cache API for assets.** The Cache API is designed for HTTP responses (HTML, CSS, JS, images). User-generated data, form drafts, and application state belong in IndexedDB (via libraries like idb or localForage).
- **Monitor PWA-specific metrics.** Track install prompt impressions, install conversions, service worker activation rate, cache hit ratio, and push notification opt-in rate. These metrics measure PWA health separately from general web analytics.

## Related Topics

- [[Mobile MOC]]
- [[OfflineFirst]]
- [[CrossPlatform]]
- [[ServiceWorkers]]
- [[Caching]]
- [[WebPerformance]]
- [[MobileArchitecture]]
