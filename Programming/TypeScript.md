---
title: TypeScript
title_pt: TypeScript
layer: programming
type: concept
priority: high
version: 1.0.0
tags:
  - Programming
  - TypeScript
  - JavaScript
  - Types
description: TypeScript for type-safe JavaScript development with interfaces, generics, and advanced types.
description_pt: TypeScript para desenvolvimento JavaScript com segurança de tipos, interfaces e tipos avançados.
prerequisites:
  - JavaScript
estimated_read_time: 12 min
difficulty: intermediate
---

# TypeScript

## Description

TypeScript is JavaScript with static type checking. It adds optional types, interfaces, enums, and other features that help catch errors during development rather than at runtime. TypeScript compiles to plain JavaScript and works with any JavaScript runtime.

## Purpose

**When TypeScript is valuable:**
- Large codebases
- Team collaboration
- Better IDE support
- Catching errors early

## Examples

### Basic Types

```typescript
// Primitive types
let name: string = 'John';
let age: number = 30;
let active: boolean = true;

// Arrays
let numbers: number[] = [1, 2, 3];
let strings: Array<string> = ['a', 'b'];

// Any and unknown
let anything: any = 1;      // No type checking
let something: unknown = 1;  // Type checking, need assertion

// Void and null
function log(msg: string): void {
    console.log(msg);
}
let empty: void = undefined;

// Type alias
type ID = string | number;
let userId: ID = 'abc123';
```

### Interfaces and Types

```typescript
interface User {
    id: string;
    name: string;
    email: string;
    age?: number;  // Optional
    readonly created: Date;  // Read-only
}

type Status = 'active' | 'inactive' | 'pending';

interface APIResponse<T> {
    data: T;
    status: number;
    message?: string;
}

// Extending interfaces
interface Admin extends User {
    role: 'admin' | 'superadmin';
}

// Type intersection
type ExtendedUser = User & { permissions: string[] };
```

### Functions

```typescript
// Typed parameters and return
function add(a: number, b: number): number {
    return a + b;
}

// Arrow function with types
const multiply = (a: number, b: number): number => a * b;

// Optional parameters
function greet(name: string, greeting?: string) {
    return greeting ? `${greeting}, ${name}!` : `Hello, ${name}!`;
}

// Rest parameters
function sum(...numbers: number[]): number {
    return numbers.reduce((a, b) => a + b, 0);
}

// Function types
type MathOperation = (a: number, b: number) => number;

const operation: MathOperation = (a, b) => a + b;
```

### Generics

```typescript
// Generic function
function identity<T>(value: T): T {
    return value;
}

const num = identity(42);      // T is number
const str = identity('hello'); // T is string

// Generic interface
interface Repository<T> {
    find(id: string): Promise<T | null>;
    save(item: T): Promise<void>;
    delete(id: string): Promise<void>;
}

// Generic constraints
interface HasId {
    id: string;
}

function findById<T extends HasId>(items: T[], id: string): T | undefined {
    return items.find(item => item.id === id);
}

// Default type
interface Response<T = string> {
    data: T;
    status: number;
}
```

### Classes

```typescript
class Animal {
    constructor(public name: string) {}
    
    speak(): void {
        console.log(`${this.name} makes a sound`);
    }
}

class Dog extends Animal {
    constructor(name: string, public breed: string) {
        super(name);
    }
    
    override speak(): void {
        console.log(`${this.name} barks`);
    }
}

// Access modifiers
class Counter {
    private count = 0;
    
    public increment(): void {
        this.count++;
    }
    
    public getCount(): number {
        return this.count;
    }
}

// Abstract class
abstract class Shape {
    abstract area(): number;
}
```

### Advanced Types

```typescript
// Union types
type StringOrNumber = string | number;

// Literal types
type Direction = 'north' | 'south' | 'east' | 'west';

// Type guards
function isString(value: unknown): value is string {
    return typeof value === 'string';
}

// Conditional types
type NonNullable<T> = T extends null | undefined ? never : T;

// Mapped types
type Readonly<T> = {
    readonly [P in keyof T]: T[P];
};

type Optional<T> = {
    [P in keyof T]?: T[P];
};

// Utility types
type PartialUser = Partial<User>;
type RequiredUser = Required<User>;
type PickUser = Pick<User, 'id' | 'name'>;
type OmitUser = Omit<User, 'email'>;
```

## Anti-Patterns

### 1. Using any

```typescript
// BAD
function process(data: any): any {
    return data.value;
}

// GOOD
function process(data: { value: string }): string {
    return data.value;
}
```

### 2. Missing return types

```typescript
// BAD
function compute(a, b) {
    return a + b;
}

// GOOD - explicit types
function compute(a: number, b: number): number {
    return a + b;
}
```

## Failure Modes

- **Overusing `any` type** → type system bypassed → runtime errors slip through → use `unknown` or specific types instead of `any`
- **Missing return types** → implicit `any` returns → unexpected types for consumers → always declare explicit return types on exported functions
- **Type assertion abuse (`as`)** → false type safety → runtime crashes → prefer type guards and narrowing over force assertions
- **Excessive type complexity** → unreadable types → developer confusion → simplify types, extract complex types into named aliases
- **Not enabling strict mode** → null/undefined errors → runtime crashes → enable `strict: true` in tsconfig from project start
- **Interface vs type confusion** → inconsistent patterns → maintenance difficulty → use interfaces for object shapes, types for unions
- **Generic constraints too loose** → incorrect usage at compile time → runtime errors → constrain generics with `extends` to required interfaces

## Related Topics

- [[JavaScript]]
- [[ReactNative]]
- [[APIDesign]]
- [[StaticAnalysis]]
- [[Linting]]
- [[CodeQuality]]
- [[Testing]]
- [[NodeJS]]

## Best Practices

1. **Enable strict mode** - catch more errors at compile time
2. **Avoid any** - use unknown or specific types
3. **Use explicit return types** - for functions, especially exported ones
4. **Prefer interfaces over type aliases** - for object shapes
5. **Use utility types** - Partial, Required, Pick, Omit for flexibility