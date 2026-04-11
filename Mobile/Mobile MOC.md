---
title: Mobile MOC
title_pt: Mobile — Mapa de Conteúdo
layer: mobile
type: index
version: 2.0.0
tags:
  - Mobile
  - MOC
  - Index
description: Navigation hub for mobile development platforms, architectures, and testing.
description_pt: Hub de navegação para plataformas de desenvolvimento mobile, arquiteturas e testes.
---

# Mobile MOC

## Native Platforms

- [[Android]] — Complete Android development: architecture, data, UI, testing
- [[iOS]] — Complete iOS development: architecture, data, UI, testing

## UI Frameworks

- [[JetpackCompose]] — Modern declarative UI toolkit for Android
- [[SwiftUI]] — Declarative UI framework for Apple platforms

## Cross-Platform

- [[CrossPlatform]] — Building apps that run on multiple platforms from a single codebase
- [[ReactNative]] — JavaScript-based cross-platform framework using React
- [[Flutter]] — Dart-based cross-platform framework with custom rendering
- [[React]] — Component-based UI library, foundation for React Native
- [[Redux]] — Predictable state container (used with React/React Native)

## Architecture & Testing

- [[MobileArchitecture]] — Architectural patterns for mobile constraints
- [[MobileTesting]] — Testing strategies for mobile-specific challenges
- [[XCTest]] — iOS unit and UI testing framework

## Data & Offline

- [[OfflineFirst]] — Apps designed to work fully without network connectivity
- [[Room]] — Android SQLite abstraction with compile-time checks
- [[CoreData]] — iOS object graph and persistence framework
- [[PWA]] — Progressive Web Apps as mobile alternative

## Reactive & Async

- [[Coroutines]] — Kotlin structured concurrency
- [[Combine]] — Swift reactive programming framework

## Reasoning Path

1. Choose platform: [[Android]] vs [[iOS]] vs [[CrossPlatform]]
2. Build UI: [[JetpackCompose]] (Android) or [[SwiftUI]] (iOS) or [[Flutter]]/[[ReactNative]] (cross-platform)
3. Architect: [[MobileArchitecture]] → handle lifecycle, offline, state
4. Data: [[OfflineFirst]] → local storage + sync engine
5. Test: [[MobileTesting]] → device fragmentation, UI, integration

## Cross-Domain Links

- [[Android]] → [[Kotlin]] → [[Coroutines]] → [[JetpackCompose]]
- [[iOS]] → [[Swift]] → [[SwiftUI]] → [[Combine]]
- [[CrossPlatform]] → [[ReactNative]] → [[JavaScript]] → [[TypeScript]]
- [[MobileArchitecture]] → [[DesignPatterns]] → [[DDD]]
- [[MobileTesting]] → [[E2ETesting]] → [[CiCd]]
- [[CrossPlatform]] → [[APIDesign]] → [[REST]]
- [[OfflineFirst]] → [[Resilience]] → [[StateMachines]] → [[Caching]]
- [[CrossPlatform]] → [[Partitioning]] → multi-tenant data