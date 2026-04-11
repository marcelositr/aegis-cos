---
title: React
layer: mobile
type: concept
priority: high
version: 2.0.0
tags:
  - Mobile
  - ReactNative
  - Frontend
  - JavaScript
  - TypeScript
  - UI
  - ComponentArchitecture
description: A JavaScript library for building user interfaces with a component model, virtual DOM reconciliation, declarative rendering, and a rich ecosystem including React Native for mobile development.
---

# React

## Description

React is a JavaScript library for building user interfaces, developed by Meta (Facebook) and released in 2013. It introduced a declarative, component-based model where UI is described as a function of state (`UI = f(state)`), and React efficiently updates the DOM when state changes through a process called reconciliation.

Core concepts:
- **Components** — JavaScript/TypeScript functions (or classes) that return JSX describing the UI. Functional components with hooks are the modern standard; class components are legacy but still supported.
- **JSX** — a syntax extension that lets you write HTML-like markup inside JavaScript. Compiled to `React.createElement()` calls by Babel/TypeScript.
- **Virtual DOM** — React maintains an in-memory representation of the UI tree. When state changes, React creates a new virtual tree, diffs it against the previous tree, and applies only the necessary changes to the real DOM (reconciliation).
- **Hooks** — functions (`useState`, `useEffect`, `useMemo`, `useCallback`, `useRef`, `useContext`, `useReducer`) that let functional components manage state, lifecycle, context, and performance optimizations. Introduced in React 16.8 (2019).
- **Unidirectional data flow** — state flows down from parent to child via props. Events flow up from child to parent via callback props. This makes the data flow predictable and debuggable.
- **Reconciliation algorithm** — React's diffing algorithm uses heuristics (element type, `key` props) to determine what changed. Elements of different types are replaced; elements of the same type are updated. `key` props enable efficient reordering of lists.
- **React Native** — React's mobile rendering target. Instead of DOM elements, components render to native iOS and Android views. The component API is identical; only the primitives change (`<View>` instead of `<div>`, `<Text>` instead of `<p>`).

## When to Use

- **Complex, interactive user interfaces** — dashboards, data tables, real-time collaboration tools, form-heavy applications. React's component model and state management excel when the UI has many interacting parts.
- **Teams with JavaScript/TypeScript expertise** — React has the largest frontend ecosystem and the shallowest onboarding curve for JS developers. The component model is intuitive for anyone who has written HTML.
- **Applications requiring frequent UI iteration** — React's hot module replacement (HMR) and fast refresh provide sub-second feedback during development. The component model encourages small, testable, reusable units.
- **Cross-platform with React Native** — sharing component logic, state management, and business rules between web and mobile. The learning curve from React to React Native is small compared to learning Flutter or native Swift/Kotlin.
- **Server-rendered applications (SSR/SSG)** — React's hydration model (Next.js, Remix) enables server-side rendering for SEO and fast initial load, then hydrates into a client-side SPA. No other major UI framework has as mature an SSR ecosystem.
- **Design system implementation** — React's composition model and prop system are ideal for building reusable component libraries. Tools like Storybook integrate natively with React.

## When NOT to Use

- **Simple, static websites** — a marketing page, blog, or documentation site with minimal interactivity. A static site generator (Astro, Eleventy, Hugo) or plain HTML/CSS is simpler and faster.
- **Performance-critical real-time rendering** — data visualizations updating at 60 FPS, real-time audio/video processing, canvas-based games. React's reconciliation overhead and React Native's bridge latency are bottlenecks. Use Canvas, WebGL, or native rendering.
- **When the bundle size budget is tight** — React + ReactDOM is ~42 KB gzipped. For performance-critical mobile web in emerging markets, this is significant. Consider Preact (~3 KB), Svelte (~1.6 KB), or vanilla JS.
- **When the team has no JavaScript experience** — React requires understanding of JavaScript (closures, event loop, async/await), JSX, the hook dependency model, and the component lifecycle. If the team is primarily backend (Java, Python, Go), the learning investment is substantial.
- **Apps with minimal UI state** — a CRUD admin panel with simple forms and tables. A server-rendered framework (Rails, Django, Laravel with HTMX) provides the same functionality with less client-side complexity.
- **When you need fine-grained control over rendering timing** — React controls when and how it re-renders. If you need to manually control repaint timing (e.g., synchronizing with `requestAnimationFrame` for a custom animation engine), React's batched updates get in the way.

## Tradeoffs

| Dimension | React (Virtual DOM) | Svelte / Solid (Compile-time / Signals) |
|-----------|-------------------|----------------------------------------|
| **Runtime overhead** | Diffing + reconciliation on every state change | Direct DOM updates (no diffing) |
| **Bundle size** | ~42 KB (React + ReactDOM, gzipped) | ~2–5 KB (compiler output) |
| **Re-render control** | `React.memo`, `useMemo`, `useCallback` (manual) | Automatic (fine-grained reactivity) |
| **Developer experience** | Mature ecosystem, extensive tooling | Smaller ecosystem, growing rapidly |
| **Learning curve** | Hooks dependency rules, reconciliation model | Simpler mental model (reactive variables) |
| **SSR support** | Excellent (Next.js, Remix) | Emerging (SvelteKit, SolidStart) |

| Dimension | React | Angular |
|-----------|-------|---------|
| **Scope** | UI library (you choose routing, state management, HTTP client) | Full framework (built-in routing, HTTP, forms, DI, testing) |
| **Flexibility** | High — assemble your own stack | Low — Angular's way or the highway |
| **Learning curve** | Moderate (library is small, ecosystem is vast) | Steep (RxJS, decorators, modules, dependency injection) |
| **Performance** | Good (virtual DOM overhead) | Good (Ivy compiler optimizes templates) |
| **Enterprise adoption** | High | Very high (Java/C# teams prefer Angular's OOP model) |

## Alternatives

- **Vue.js** — progressive framework with a gentler learning curve than React. Single-file components (SFCs) combine template, logic, and styles. Reactivity system (signals-based in Vue 3) is more intuitive than hooks. Smaller ecosystem but excellent documentation.
- **Svelte** — compile-time framework that produces highly optimized vanilla JS. No virtual DOM, no runtime overhead. Excellent for small-to-medium apps. Ecosystem is smaller but growing fast.
- **Solid.js** — signals-based reactivity with JSX syntax. Performance rivals Svelte. Uses a mental model similar to React but without reconciliation overhead.
- **Angular** — full-featured framework with built-in DI, routing, forms, HTTP, and testing. Best for large enterprise teams that want a single, opinionated stack.
- **HTMX + server-rendered HTML** — for CRUD applications, admin panels, and content-heavy sites. HTMX enables interactivity (AJAX, WS, SSE) via HTML attributes, eliminating the need for a client-side framework.
- **Web Components** — browser-native custom elements with shadow DOM. Framework-agnostic and future-proof. Limited reactivity and tooling compared to React.

## Failure Modes

1. **Excessive re-renders from missing memoization** — a parent component re-renders, causing all child components to re-render even though their props have not changed. With 50+ components in a tree, this causes visible jank → wrap pure components with `React.memo`. Use `useCallback` for callback props and `useMemo` for computed values. Profile with React DevTools Profiler to identify unnecessary re-renders.

2. **Stale closures in `useEffect`** — an effect captures an outdated value of a variable because the dependency array omitted it. The effect runs with stale data, causing bugs that are hard to reproduce → include all referenced variables in the dependency array. The ESLint rule `react-hooks/exhaustive-deps` catches missing dependencies. If you intentionally want to skip a dependency, document why and use a ref (`useRef`) for mutable values that should not trigger re-runs.

3. **Infinite re-render loops** — calling `setState` inside the component body (not inside an event handler or effect) causes an infinite loop: render → setState → render → setState → crash → always call `setState` inside event handlers or `useEffect`. If you need to derive state from props, use `useMemo` instead of `useState`.

4. **Memory leaks from uncleaned effects** — a `useEffect` sets up a subscription, timer, or event listener but does not return a cleanup function. When the component unmounts, the listener persists and fires on a destroyed component, or retains the component in memory → always return a cleanup function from `useEffect`:
   ```tsx
   useEffect(() => {
     const subscription = dataSource.subscribe(handleData);
     return () => subscription.unsubscribe();
   }, [dataSource]);
   ```

5. **Missing `key` props causing state corruption** — rendering a list without `key` props (or using array index as key). When items are reordered, React reuses DOM nodes incorrectly, causing input fields to retain values from the wrong items → always use a stable, unique key (database ID): `<Item key={item.id} data={item} />`. Never use array index as key for reorderable or filterable lists.

6. **Prop drilling through 5+ levels** — passing a `user` prop through `App > Layout > Sidebar > UserProfile > Avatar` makes intermediate components aware of data they do not use → use `useContext` for globally needed state (theme, auth, locale) or a state management library (Zustand, Redux, Jotai) for application state. Context re-renders all consumers when the value changes, so scope it carefully.

7. **Hydration mismatches in SSR** — the server renders `<div>Hello</div>` but the client renders `<div>Hello, User</div>` because the client has access to user data that the server did not. React throws a hydration mismatch warning and falls back to client-side rendering → use conditional rendering with `useEffect` to ensure the client matches the server on first render. Suppress intentional mismatches with `suppressHydrationWarning` (sparingly). Ensure the server has the same data as the client (use `getServerSideProps` in Next.js).

8. **`useEffect` used as a lifecycle method** — treating `useEffect` like `componentDidMount` and `componentDidUpdate` leads to effects that run on every render with complex dependency arrays → think of `useEffect` as synchronizing React with an external system (browser API, subscription, network). If you are deriving state from props, use `useMemo`. If you are handling user actions, use event handlers. Reserve `useEffect` for actual side effects.

9. **Large bundle from importing heavy libraries** — importing `lodash` (71 KB) when only `lodash/debounce` (500 bytes) is needed. Importing `moment` (330 KB) instead of `date-fns` (4 KB) → use tree-shakeable imports: `import debounce from 'lodash/debounce'`. Use the `bundle-phobia` CLI or Webpack Bundle Analyzer to audit dependency sizes. Prefer small, focused libraries.

10. **Context causing unnecessary re-renders** — a `ThemeContext` with `{ theme, toggleTheme }` causes all consumers to re-render when either `theme` or `toggleTheme` changes. If `toggleTheme` is a new function on every render, all consumers re-render unnecessarily → split context into separate providers: `ThemeValueContext` and `ThemeDispatchContext`. Memoize the context value: `const value = useMemo(() => ({ theme, toggleTheme }), [theme, toggleTheme])`.

## Code Examples

### Custom Hook — Data Fetching with Cache

```tsx
import { useState, useEffect, useCallback, useRef } from 'react';

interface UseFetchResult<T> {
  data: T | null;
  isLoading: boolean;
  error: Error | null;
  refetch: () => void;
}

const cache = new Map<string, unknown>();

function useFetch<T>(url: string, options?: RequestInit): UseFetchResult<T> {
  const [data, setData] = useState<T | null>(() => cache.get(url) as T | null);
  const [isLoading, setIsLoading] = useState<boolean>(!cache.has(url));
  const [error, setError] = useState<Error | null>(null);
  const abortRef = useRef<AbortController | null>(null);

  const fetcher = useCallback(async () => {
    // Return cached data synchronously if available
    if (cache.has(url)) {
      setData(cache.get(url) as T);
      return;
    }

    abortRef.current?.abort();
    const controller = new AbortController();
    abortRef.current = controller;

    setIsLoading(true);
    setError(null);

    try {
      const response = await fetch(url, { ...options, signal: controller.signal });
      if (!response.ok) throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      const json = await response.json();
      cache.set(url, json);
      setData(json as T);
    } catch (err) {
      if (err instanceof Error && err.name !== 'AbortError') {
        setError(err);
      }
    } finally {
      setIsLoading(false);
    }
  }, [url, options]);

  useEffect(() => {
    fetcher();
    return () => { abortRef.current?.abort(); };
  }, [fetcher]);

  return { data, isLoading, error, refetch: fetcher };
}

// Usage
function UserProfile({ userId }: { userId: string }) {
  const { data: user, isLoading, error, refetch } = useFetch<User>(`/api/users/${userId}`);

  if (isLoading) return <SkeletonLoader />;
  if (error) return <ErrorMessage message={error.message} onRetry={refetch} />;
  if (!user) return null;

  return (
    <div>
      <h2>{user.name}</h2>
      <p>{user.email}</p>
    </div>
  );
}
```

### Performance Optimization with Memoization

```tsx
import { memo, useMemo, useCallback, useState } from 'react';

// Memoized child — only re-renders when props change
const ProductCard = memo(function ProductCard({
  product,
  onAddToCart,
  isSelected,
}: {
  product: Product;
  onAddToCart: (id: string) => void;
  isSelected: boolean;
}) {
  return (
    <div className={isSelected ? 'selected' : ''}>
      <h3>{product.name}</h3>
      <p>${product.price.toFixed(2)}</p>
      <button onClick={() => onAddToCart(product.id)}>Add to Cart</button>
    </div>
  );
});

// Parent component
function ProductList({ products, cartIds }: { products: Product[]; cartIds: Set<string> }) {
  const [sortField, setSortField] = useState<'name' | 'price'>('name');

  // Memoized sort — only recomputes when products or sortField change
  const sortedProducts = useMemo(() => {
    return [...products].sort((a, b) => {
      if (sortField === 'price') return a.price - b.price;
      return a.name.localeCompare(b.name);
    });
  }, [products, sortField]);

  // Stable callback reference
  const handleAddToCart = useCallback((id: string) => {
    console.log('Added to cart:', id);
    // Dispatch to cart store
  }, []);

  return (
    <div>
      <SortToggle field={sortField} onToggle={setSortField} />
      <div className="grid">
        {sortedProducts.map((product) => (
          <ProductCard
            key={product.id}
            product={product}
            onAddToCart={handleAddToCart}
            isSelected={cartIds.has(product.id)}
          />
        ))}
      </div>
    </div>
  );
}
```

### Error Boundary

```tsx
import { Component, ErrorInfo, ReactNode } from 'react';

interface Props {
  children: ReactNode;
  fallback?: ReactNode;
  onError?: (error: Error, info: ErrorInfo) => void;
}

interface State {
  hasError: boolean;
  error: Error | null;
}

class ErrorBoundary extends Component<Props, State> {
  state: State = { hasError: false, error: null };

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, info: ErrorInfo) {
    this.props.onError?.(error, info);
    // Log to error tracking service (Sentry, Datadog)
    console.error('ErrorBoundary caught:', error, info.componentStack);
  }

  render() {
    if (this.state.hasError) {
      return (
        this.props.fallback ?? (
          <div role="alert">
            <h2>Something went wrong</h2>
            <p>{this.state.error?.message}</p>
            <button onClick={() => this.setState({ hasError: false, error: null })}>
              Try Again
            </button>
          </div>
        )
      );
    }

    return this.props.children;
  }
}

// Usage
<ErrorBoundary onError={(error) => Sentry.captureException(error)}>
  <App />
</ErrorBoundary>
```

## Best Practices

- **Lift state up only as far as needed.** Keep state as close to its usage as possible. Do not hoist all state to a global store. Local state (`useState`) is the default; lift to context or a store only when multiple components need it.
- **Always include all dependencies in `useEffect` and `useMemo` dependency arrays.** The ESLint rule `react-hooks/exhaustive-deps` is your friend. If you intentionally want to skip a dependency, use a ref or document why.
- **Use `React.memo` strategically, not everywhere.** Profile first. Memoization adds comparison overhead on every render. Only memoize components that render expensive subtrees or receive stable props from frequently re-rendering parents.
- **Prefer composition over prop drilling.** If a prop passes through more than two intermediate components, use `useContext` or a state management library. But be aware that context triggers re-renders on all consumers.
- **Use Error Boundaries for graceful degradation.** Wrap feature-level components in `<ErrorBoundary>` so that a crash in one section does not bring down the entire app. Log errors to your monitoring service.
- **Co-locate state with its consumers.** If only one component reads a piece of state, it belongs in that component's `useState`. Do not preemptively put state in a global store.
- **Use TypeScript for component props.** `interface Props { user: User; onLogout: () => void }` documents the component's contract and catches prop mismatches at compile time.
- **Avoid side effects in the render phase.** The component body should be a pure function of props and state. Side effects belong in `useEffect` or event handlers.
- **Use `key` on list items with stable, unique identifiers.** Never use array index as key for lists that can be reordered, filtered, or have items inserted/deleted.
- **Debounce user input that triggers expensive operations.** Search input that fires API calls on every keystroke should be debounced: `useDebouncedValue(query, 300)`.

## Related Topics

- [[ReactNative]]
- [[Redux]]
- [[JavaScript]]
- [[TypeScript]]
- [[Mobile MOC]]
- [[MobileArchitecture]]
- [[FrontendArchitecture]]
- [[Quality MOC]]
- [[Testing MOC]]
