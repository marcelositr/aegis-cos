---
layer: foundation
type: naming-conventions
priority: critical
read_order: 6
version: 1.0.0
tags:
  - naming
  - conventions
  - clean-code
  - patterns
---

# Naming

## Overview

Defines naming conventions for consistent, readable code.

## General Rules

| Rule | Apply To | Example |
|------|----------|---------|
| Descriptive | All names | `calculateTotal()` not `calc()` |
| Pronounceable | All names | `userAccount` not `usrAcct` |
| Searchable | All names | `maxRetries` not `x` |
| No magic | Values | `MAX_SIZE = 100` not `100` |

## Type-Based Naming

### Variables

| Type | Convention | Example |
|------|------------|---------|
| Boolean | is/has/can/should + predicate | `isValid`, `hasAccess` |
| Number | units or purpose prefix | `fileCount`, `timeoutMs` |
| String | noun or description | `userName`, `errorMessage` |
| Array | plural noun | `users`, `errors` |
| Object | noun | `config`, `handler` |

### Functions/Methods

| Type | Convention | Example |
|------|------------|---------|
| Action | verb + object | `validateInput()`, `sendMessage()` |
| Query | noun or question | `getUser()`, `isComplete()` |
| Predicate | is/has/can + condition | `isEnabled`, `canProceed()` |
| Event | past tense or on + event | `onClick()`, `didValidate()` |
| Factory | create + noun | `createValidator()`, `buildResponse()` |

### Classes

| Type | Convention | Example |
|------|------------|---------|
| Entity | Noun | `User`, `Order`, `Agent` |
| Service | Noun + Service | `ValidationService` |
| Handler | Noun + Handler | `ErrorHandler` |
| Manager | Noun + Manager | `TaskManager` |
| Interface | I + noun or able | `IValidator`, `Runnable` |
| Abstract | Abstract + noun | `AbstractAgent` |

### Constants

| Type | Convention | Example |
|------|------------|---------|
| Config | SCREAMING_SNAKE | `MAX_RETRIES`, `API_KEY` |
| Enum values | SCREAMING_SNAKE | `Status.PENDING` |
| True constants | SCREAMING_SNAKE | `PI = 3.14` |

## Case Styles

| Style | Use Case | Example |
|-------|----------|---------|
| camelCase | Variables, functions | `getUserById` |
| PascalCase | Classes, interfaces | `ValidationResult` |
| SCREAMING_SNAKE | Constants | `MAX_FILE_SIZE` |
| kebab-case | File names (markdown) | `naming-conventions.md` |
| snake_case | Python, DB columns | `user_id`, `created_at` |

## Naming Anti-Patterns

| Anti-pattern | Instead | Why |
|--------------|---------|-----|
| `data`, `info` | Specific noun | Too vague |
| `temp`, `tmp` | Descriptive purpose | Temporary is lazy |
| `x`, `y`, `z` | Purpose | Meaningless |
| Hungarian notation | Standard types | Redundant |
| Single letter (except loop) | Descriptive | Unclear |

## Portuguese

### Visão Geral

Define convenções de nome para código consistente e legível.

### Regras Gerais

| Regra | Aplicar A | Exemplo |
|-------|-----------|---------|
| Descritivo | Todos nomes | `calcularTotal()` não `calc()` |
| Pronunciável | Todos nomes | `nomeUsuario` não `nmUsr` |
| Buscável | Todos nomes | `maxTentativas` não `x` |
| Sem magia | Valores | `MAX_TAMANHO = 100` não `100` |

## Related

- [[knowledge/md/foundation/Size]]
- [[knowledge/md/foundation/Complexity]]
- [[knowledge/md/foundation/DesignLaws]]