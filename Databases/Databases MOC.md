---
title: Databases MOC
title_pt: Bancos de Dados — Mapa de Conteúdo
layer: databases
type: index
version: 1.0.0
tags:
  - Databases
  - MOC
  - Index
description: Navigation hub for database technologies, optimization, and caching strategies.
description_pt: Hub de navegação para tecnologias de banco de dados, otimização e estratégias de caching.
---

# Databases MOC

## Database Technologies

- [[SQL]] — Relational database management with structured query language
- [[NoSQL]] — Non-relational databases for flexible, scalable data storage

## Optimization & Performance

- [[DatabaseOptimization]] — Techniques for improving query performance and database efficiency
- [[Caching]] — Storing frequently accessed data in fast-access memory layers

## Reasoning Path

1. Choose technology: [[SQL]] vs [[NoSQL]] based on consistency, scalability, and query needs
2. Optimize: [[DatabaseOptimization]] → indexing, query tuning, connection pooling
3. Accelerate: [[Caching]] → cache strategies, invalidation, TTL

## Cross-Domain Links

- [[SQL]] → [[SQLInjection]] → [[InputValidation]]
- [[SQL]] → [[CQRS]] → [[EventSourcing]]
- [[NoSQL]] → [[DistributedSystems]] → [[CAPTheorem]]
- [[DatabaseOptimization]] → [[PerformanceOptimization]] → [[PerformanceProfiling]]
- [[Caching]] → [[PerformanceOptimization]] → [[HTTP]] (cache headers)
- [[Caching]] → [[Microservices]] → [[APIDesign]]
- [[SQL]] + [[NoSQL]] → [[DDD]] → [[DomainModeling]]
