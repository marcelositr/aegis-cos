---
title: JavaScript
title_pt: JavaScript
layer: programming
type: concept
priority: high
version: 1.0.0
tags:
  - Programming
  - JavaScript
  - Web
  - Language
description: JavaScript programming language fundamentals for web and Node.js development.
description_pt: Fundamentos da linguagem JavaScript para desenvolvimento web e Node.js.
prerequisites:
  - Programming
estimated_read_time: 12 min
difficulty: beginner
---

# JavaScript

## Description

JavaScript is the programming language of the web, running in browsers and on servers via Node.js. It supports multiple paradigms: procedural, object-oriented, and functional programming. ECMAScript (ES6+) modernized the language with classes, modules, arrow functions, and async/await.

## Purpose

**When JavaScript is valuable:**
- Web development (frontend)
- Server-side with Node.js
- Mobile apps (React Native, etc.)
- Automation and tooling

## Examples

### Variables

```javascript
// Modern declarations
const name = 'John';      // Immutable
let count = 0;           // Mutable

// Types
const str = 'string';
const num = 42;
const bool = true;
const arr = [1, 2, 3];
const obj = { key: 'value' };
const empty = null;
let unknown;             // undefined

// Type checking
typeof str === 'string'
Array.isArray(arr)
```

### Functions

```javascript
// Function declaration
function greet(name) {
    return `Hello, ${name}!`;
}

// Arrow functions
const greetArrow = (name) => `Hello, ${name}!`;

const add = (a, b) => a + b;

// Default parameters
function greet(name = 'World') {
    return `Hello, ${name}!`;
}

// Rest parameters
function sum(...numbers) {
    return numbers.reduce((a, b) => a + b, 0);
}
```

### Arrays

```javascript
const arr = [1, 2, 3, 4, 5];

// Map, filter, reduce
const doubled = arr.map(n => n * 2);
const evens = arr.filter(n => n % 2 === 0);
const sum = arr.reduce((acc, n) => acc + n, 0);

// Find
const found = arr.find(n => n > 3);

// Spread
const copy = [...arr];
const merged = [...arr, 6, 7];
```

### Objects

```javascript
const user = {
    name: 'John',
    age: 30,
    greet() {
        return `Hi, I'm ${this.name}`;
    }
};

// Destructuring
const { name, age } = user;

// Spread
const updated = { ...user, age: 31 };

// Object.keys/values/entries
Object.keys(user);
Object.values(user);
```

### Async

```javascript
// Promise
fetch('https://api.example.com')
    .then(res => res.json())
    .then(data => console.log(data))
    .catch(err => console.error(err));

// Async/await
async function fetchData() {
    try {
        const res = await fetch('https://api.example.com');
        const data = await res.json();
        return data;
    } catch (err) {
        console.error(err);
    }
}

// Promise.all for parallel
const [users, posts] = await Promise.all([
    fetchUsers(),
    fetchPosts()
]);
```

### Classes

```javascript
class Animal {
    constructor(name) {
        this.name = name;
    }
    
    speak() {
        console.log(`${this.name} makes a sound`);
    }
}

class Dog extends Animal {
    speak() {
        console.log(`${this.name} barks`);
    }
}
```

## Anti-Patterns

### 1. Using var

```javascript
// BAD
var name = 'John';

// GOOD
const name = 'John'; // or let if mutable
```

### 2. Not handling null/undefined

```javascript
// BAD
const len = obj.prop.nested.length;

// GOOD
const len = obj?.prop?.nested?.length ?? 0;
```

## Failure Modes

- **Using `var` instead of `const`/`let`** → hoisting bugs → unexpected variable scope → always use `const` or `let` for block scoping
- **Not handling null/undefined** → TypeError crashes → application failures → use optional chaining (`?.`) and nullish coalescing (`??`)
- **Unhandled Promise rejections** → silent failures → uncaught exceptions → always chain `.catch()` or wrap `await` in try/catch
- **Mutating objects/arrays directly** → unexpected side effects → state corruption → use spread operator or immutable patterns
- **Callback hell** → unreadable async code → maintenance nightmare → prefer async/await over nested callbacks
- **Global variable pollution** → naming collisions → unpredictable behavior → use modules and avoid implicit globals
- **Not using strict mode** → silent errors → subtle bugs → enable `'use strict'` or use ES modules which are strict by default

## Related Topics

- [[TypeScript]]
- [[ReactNative]]
- [[NodeJS]]
- [[APIDesign]]
- [[REST]]
- [[WebSockets]]
- [[Testing]]
- [[CiCd]]

## Best Practices

1. **Use const/let, avoid var** - Block scoping prevents bugs
2. **Use optional chaining (?.) and nullish coalescing (??)** - Safe property access
3. **Prefer async/await over callbacks** - Cleaner async code
4. **Use strict mode** - Catch more errors
5. **Avoid global variables** - Use modules instead