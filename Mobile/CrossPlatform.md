---
title: Cross-Platform Development
title_pt: Desenvolvimento Multiplataforma
layer: mobile
type: concept
priority: medium
version: 1.0.0
tags:
  - Mobile
  - Cross-Platform
  - React Native
  - Flutter
  - Strategy
description: Strategies for building mobile apps that target multiple platforms from a single codebase.
description_pt: Estratégias para construir apps mobile que atingir múltiplas plataformas a partir de um único código-fonte.
prerequisites:
  - Mobile
estimated_read_time: 10 min
difficulty: intermediate
---

# Cross-Platform Development

## Description

Cross-platform development aims to create mobile applications that work on multiple platforms (iOS, Android) from a single codebase. This approach reduces development time and cost but may involve trade-offs in performance and platform-specific features.

Options include:
- **React Native** - JavaScript/TypeScript with native components
- **Flutter** - Dart with custom rendering
- **Xamarin** - C# with native components
- **PWA** - Progressive Web Apps with limited mobile features

## Purpose

**When cross-platform is valuable:**
- Limited budget/resources
- Both iOS and Android required
- Simple to moderate UI requirements
- Faster time to market
- Team has web development background
- App doesn't require deep platform integration

**When to choose native instead:**
- Performance-critical applications (gaming, AR/VR, video editing)
- Apps requiring deep hardware integration (camera, Bluetooth, sensors)
- When platform-specific UI is required for user expectations
- When you need the latest platform features immediately
- When targeting enterprise with specific device requirements

**The key question:** Is the development cost savings of cross-platform greater than the potential performance/maintenance costs?

## Rules

1. **Separate platform-specific from shared code** - Business logic shared, UI platform-specific
2. **Use abstraction for native features** - Platform channels for native functionality
3. **Test on real devices** - Emulators don't show performance issues
4. **Plan for platform-specific bugs** - Different issues on iOS vs Android
5. **Consider long-term maintenance** - Framework updates can break code

## Examples

### Framework Comparison

| Framework | Language | Rendering | Performance | Learning Curve |
|-----------|----------|-----------|-------------|----------------|
| React Native | JavaScript/TS | Native | Good | Low |
| Flutter | Dart | Custom | Excellent | Medium |
| Xamarin | C# | Native | Good | Medium |
| PWA | HTML/JS/CSS | Web | Moderate | Low |

### Architecture Decision Tree

```
Need cross-platform?
  │
  ├─ Yes → Budget limited?
  │         ├─ Yes → PWA or React Native
  │         └─ No → Performance critical?
  │                   ├─ Yes → Flutter or Native
  │                   └─ No → React Native or Flutter
  │
  └─ No → iOS only → Swift/SwiftUI
          Android only → Kotlin/Jetpack Compose
```

## Failure Modes

- **Not separating platform-specific code** → broken builds on one platform → maintenance nightmare → isolate platform code behind abstractions
- **Ignoring platform UI conventions** → unnatural UX → poor user adoption → follow iOS Human Interface and Android Material Design guidelines
- **Testing only on emulators** → missing real device issues → production crashes → test on physical devices across OS versions
- **Framework dependency lock-in** → abandoned framework → stranded codebase → evaluate framework health and community before committing
- **Performance-critical features in shared layer** → poor performance → sluggish UX → implement performance-sensitive code natively
- **No offline strategy** → app unusable without network → poor UX → implement local caching and offline-first architecture
- **Ignoring platform-specific bugs** → issues on one platform only → inconsistent quality → test and fix issues per platform independently

## Anti-Patterns

### 1. Ignoring Platform UI Conventions

**Bad:** Building a single UI that looks identical on iOS and Android, ignoring each platform's design language
**Why it's bad:** Users expect iOS apps to follow Human Interface Guidelines and Android apps to follow Material Design — an app that looks "wrong" on either platform feels foreign and untrustworthy
**Good:** Follow platform-specific design guidelines — use platform-adaptive components or customize the shared UI to match each platform's expectations

### 2. Performance-Critical Features in Shared Layer

**Bad:** Implementing image processing, video encoding, or complex animations in the cross-platform framework's shared layer
**Why it's bad:** The abstraction layer adds overhead — performance-sensitive operations run significantly slower than native implementations, creating a sluggish user experience
**Good:** Implement performance-sensitive code natively using platform channels — share the business logic but keep the heavy lifting in native code

### 3. Framework Dependency Lock-In

**Bad:** Committing to a cross-platform framework without evaluating its long-term health, community size, and update frequency
**Why it's bad:** If the framework is abandoned or falls behind platform updates, you are stranded with a codebase that cannot be updated — migration to native is expensive
**Good:** Evaluate framework health before committing — check commit frequency, community size, backing organization, and the framework's track record of keeping up with platform releases

### 4. Testing Only on Emulators

**Bad:** Running all tests on emulators and simulators without testing on physical devices
**Why it's bad:** Emulators do not accurately represent real device performance, memory constraints, network conditions, or hardware-specific bugs — production crashes surprise the team
**Good:** Test on physical devices across OS versions and device tiers — emulators are useful for development, but real devices are essential for quality assurance

## Best Practices

### Code Sharing Strategy

```
Shared (80%):
- Business logic
- Data layer
- State management
- API clients
- Utility functions

Platform-specific (20%):
- UI components
- Navigation
- Platform APIs
- Native features
```

## Related Topics

- [[ReactNative]]
- [[MobileArchitecture]]
- [[MobileTesting]]
- [[Flutter]]
- [[Xamarin]]
- [[PWA]]
- [[APIDesign]]
- [[CiCd]]

## Key Takeaways

- Cross-platform development builds mobile apps for multiple platforms (iOS, Android) from a single codebase using frameworks like React Native or Flutter.
- Use when budget is limited, both platforms are required, UI requirements are simple to moderate, or the team has web development background.
- Do NOT use for performance-critical apps (gaming, AR/VR), apps needing deep hardware integration, or when platform-specific UI is essential.
- Key tradeoff: reduced development cost and faster time to market vs. potential performance limitations and platform-specific maintenance issues.
- Main failure mode: not separating platform-specific code from shared logic, leading to broken builds and maintenance nightmares on one platform.
- Best practice: share 80% (business logic, data layer, state management) and keep 20% platform-specific (UI components, native APIs, navigation).
- Related concepts: React Native, Flutter, Native Development, PWA, Mobile Architecture, Mobile Testing, Platform Channels.