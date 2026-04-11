---
title: Redux
layer: mobile
type: concept
priority: high
version: 2.0.0
tags:
  - Mobile
  - ReactNative
  - StateManagement
  - JavaScript
  - TypeScript
  - UnidirectionalDataFlow
description: A predictable state container for JavaScript applications using a single immutable state tree, pure reducers, and a unidirectional data flow pattern.
---

# Redux

## Description

Redux is a state management library for JavaScript applications, based on the Flux architecture and Elm's state management model. It enforces three principles:

1. **Single source of truth** — the entire application state is stored in a single immutable object tree (the store).
2. **State is read-only** — the only way to change state is by dispatching an action (a plain object describing what happened).
3. **Changes are made with pure functions** — reducers are pure functions that take the previous state and an action, and return the next state.

Data flow is strictly unidirectional: `dispatch(action) → reducer(prevState, action) → nextState → UI re-render`. This makes state changes predictable, traceable, and debuggable (time-travel debugging is possible because every state transition is a pure function of the previous state and an action).

Core concepts:
- **Store** — holds the state tree. Created with `configureStore()` (Redux Toolkit) or `createStore()` (legacy). Exposes `dispatch`, `getState`, and `subscribe`.
- **Actions** — plain objects with a `type` field and optional payload: `{ type: 'cart/addItem', payload: { id: 'prod-1', qty: 2 } }`.
- **Reducers** — pure functions `(state, action) => newState`. Must not contain side effects (no API calls, no `Date.now()`, no mutations). Split into slice reducers for maintainability.
- **Selectors** — functions that derive data from the state tree: `selectCartTotal = (state) => state.cart.items.reduce(...)`. Used with `useSelector` in React components.
- **Middleware** — functions that intercept actions before they reach the reducer. Used for logging, crash reporting, and async logic (thunks, sagas).
- **Redux Toolkit (RTK)** — the official, recommended way to write Redux. Provides `configureStore`, `createSlice`, `createAsyncThunk`, and Immer integration (allows "mutating" state in reducers).

**RTK Query** — a data-fetching and caching layer built into Redux Toolkit. Replaces manual thunk-based API calls with auto-generated hooks (`useGetUserQuery`, `useUpdateUserMutation`) that handle loading states, caching, deduplication, and invalidation.

## When to Use

- **Complex state shared across many components** — when 10+ components read and write overlapping pieces of state (e.g., a multi-step form with cross-step validation, shared filters across multiple data grids, or a real-time collaboration tool with many interacting features).
- **Frequent state changes with complex update logic** — when the state transition logic is more complex than a simple `setState`. Reducers centralize update logic, making it testable and traceable.
- **Time-travel debugging is needed** — Redux DevTools enables stepping through every state transition. Critical for debugging complex bugs in production (with action/reducer logging).
- **Large React Native apps with shared business logic** — when the same state (user profile, cart, preferences) is consumed by both the React Native mobile app and a React web app. The Redux store is framework-agnostic.
- **Undo/redo functionality** — because state transitions are pure and sequential, implementing undo/redo is a matter of maintaining a history stack. Libraries like `redux-undo` provide this out of the box.
- **Teams that benefit from explicit state documentation** — every action type and reducer is a documented contract. New team members can understand the entire state machine by reading the action types and reducer logic.

## When NOT to Use

- **Simple applications with local state** — a to-do app, a settings page, or a form with 3 fields. `useState` and `useReducer` are sufficient. Redux adds boilerplate and cognitive overhead that is not justified.
- **State that is purely UI-local** — whether a modal is open, the current tab index, or a text input's value. These belong in the component's `useState`. Putting them in Redux couples UI state to the global store, making refactoring harder.
- **When the team is not familiar with Redux concepts** — actions, reducers, selectors, middleware, normalization, and Immer. The learning curve is significant. If the team has not used Redux before, start with React Context + `useReducer` and graduate to Redux only when needed.
- **When you need fine-grained re-render control** — Redux's `useSelector` re-renders the component when the selected value changes (by reference equality). For deeply nested state with frequent partial updates, you need to carefully memoize selectors. Zustand or Jotai provide finer-grained subscription by default.
- **When RTK Query already solves your problem** — if your primary use case is data fetching and caching (API responses), RTK Query alone (without manual Redux state) may be sufficient. You do not need a full Redux store if all your state is server state.
- **Performance-critical applications with high-frequency state updates** — Redux's action dispatch → reducer → subscriber notification pipeline adds ~1–5ms per dispatch. For state updates at 60 FPS (animations, gesture tracking), this is too slow. Use refs or local state.
- **When server state management is the primary concern** — if most of your app's state is fetched from an API (user profiles, lists, details), use React Query, SWR, or RTK Query instead of Redux. These libraries handle caching, background refetching, and optimistic updates natively.

## Tradeoffs

| Dimension | Redux + RTK | React Context + useReducer |
|-----------|-------------|--------------------------|
| **Boilerplate** | Moderate (slices, actions, selectors) | Low (context provider + reducer) |
| **DevTools** | Redux DevTools (time-travel, action log) | No built-in DevTools |
| **Middleware** | Rich ecosystem (thunks, sagas, logger) | Manual (wrap dispatch) |
| **Re-render control** | `useSelector` with reference equality check | Context value change re-renders all consumers |
| **Async logic** | `createAsyncThunk`, RTK Query | Manual (effects in reducer or wrapper) |
| **Bundle size** | ~10 KB (Redux + RTK, gzipped) | 0 KB (built into React) |
| **Learning curve** | Moderate | Low |

| Dimension | Redux | Zustand |
|-----------|-------|---------|
| **API surface** | Large (store, actions, reducers, selectors, middleware) | Minimal (`create`, `set`, `get`) |
| **Boilerplate** | Higher (slices, action types) | Minimal (one store object) |
| **DevTools** | Redux DevTools (excellent) | Zustand DevTools (basic) |
| **Middleware** | Extensive | Simple (middleware functions) |
| **Re-render granularity** | Per-selector subscription | Per-selector subscription (same) |
| **Ecosystem maturity** | Very mature (since 2015) | Growing (since 2019) |
| **Team adoption** | Industry standard for large apps | Popular in startups and smaller teams |

| Dimension | Redux | React Query / TanStack Query |
|-----------|-------|----------------------------|
| **Primary use case** | Client state (UI state, form state, business logic) | Server state (API data, caching, sync) |
| **Async handling** | Manual (thunks) or RTK Query | Built-in (queries, mutations, prefetch) |
| **Caching** | Manual (you implement it) | Automatic (stale-while-revalidate) |
| **Deduplication** | Manual | Automatic (same query = one request) |
| **Background refetch** | Manual | Automatic (on focus, reconnect, interval) |

## Alternatives

- **React Context + useReducer** — built into React. Sufficient for small-to-medium apps. No additional dependencies. The re-render problem (all context consumers re-render) limits scalability.
- **Zustand** — minimal state management with a simple API (`create((set) => ({ count: 0, inc: () => set((s) => ({ count: s.count + 1 })) })`)). No boilerplate, no providers. Gaining significant traction as a Redux replacement.
- **Jotai** — atomic state management. Each atom is an independent piece of state. Components subscribe to specific atoms, enabling fine-grained re-render control. Inspired by Recoil.
- **MobX** — observable-based reactive state management. Less boilerplate than Redux (no actions or reducers — just mutate observables). Automatic re-render tracking. Good for teams that prefer OOP.
- **React Query / TanStack Query** — for server state. Handles caching, background refetching, pagination, and optimistic updates. Often used alongside Zustand or Context for client state.
- **Redux Toolkit (RTK Query)** — Redux's built-in solution for server state. If you are already using Redux, RTK Query is the natural choice for API data. If you are not using Redux, prefer React Query.

## Failure Modes

1. **Selector returning new references on every call** — `useSelector(state => ({ user: state.user.name, cart: state.cart.count }))` creates a new object on every dispatch, causing the component to re-render on every action in the entire app → return primitive values or memoized objects from selectors. Use multiple `useSelector` calls: `const name = useSelector(s => s.user.name); const count = useSelector(s => s.cart.count)`. Or use Reselect (`createSelector`) for computed selectors.

2. **Mutating state directly in reducers** — `state.items.push(newItem)` mutates the existing state. Redux compares references and sees no change, so the UI does not update → with Redux Toolkit (Immer), direct mutations are allowed and converted to immutable updates. With raw Redux, you must return a new object: `return { ...state, items: [...state.items, newItem] }`. Never mix mutation and immutability in the same reducer.

3. **Putting all state in Redux** — modal open/close, form field values, and temporary UI flags end up in the global store. The Redux devtools show 200 actions for opening a dialog → keep local UI state in `useState`. Only put state in Redux when it is shared across multiple unrelated components or needs to persist across navigation.

4. **Async side effects in reducers** — calling an API inside a reducer, or using `Date.now()`, `Math.random()`, or `console.log` in a reducer. Reducers must be pure functions — given the same state and action, they must always return the same result → move side effects to middleware (thunks, sagas) or to the component (event handlers). Reducers should only compute the next state.

5. **Normalized state corruption** — storing the same entity in multiple places: `state.posts[1]` and `state.user.posts[0]` reference the same post. Updating one does not update the other, causing inconsistent UI → normalize state like a database: store entities by ID in a flat map (`state.entities.posts[1]`), and reference them by ID in lists (`state.user.posts = [1, 5, 12]`). Use Redux Toolkit's `createEntityAdapter` for automatic normalization.

6. **Missing RTK Query cache invalidation** — after creating a new order via mutation, the order list query still shows stale data because the cache was not invalidated → use RTK Query's `invalidatesTags` on mutations: `invalidatesTags: [{ type: 'Order', id: 'LIST' }]`. Or dispatch `api.util.invalidateTags(['Order'])` manually after a thunk-based mutation.

7. **Middleware ordering causing silent failures** — placing a custom logging middleware after the error-handling middleware means errors are logged after being caught, losing the original stack trace. Or placing a thunk middleware after a serialization middleware that strips function references → middleware order matters. RTK's `configureStore` sets up the correct order by default. If adding custom middleware, insert it before the error handler.

8. **Large serialized state on startup** — hydrating the Redux store from `AsyncStorage` or `localStorage` on app launch takes 500ms because the persisted state is 2 MB (including cached API responses) → persist only the minimal state needed for startup (auth token, user preferences, feature flags). Exclude cached API data, temporary UI state, and large data arrays from persistence. Use `redux-persist` with a `transforms` whitelist.

9. **Thunk not handling loading and error states** — a `createAsyncThunk` dispatches `pending`, `fulfilled`, and `rejected` actions, but the reducer only handles `fulfilled`. The loading spinner never disappears on error, and the error message is never shown → handle all three action types in `extraReducers`:
   ```ts
   builder
     .addCase(fetchUser.pending, (state) => { state.status = 'loading'; })
     .addCase(fetchUser.fulfilled, (state, action) => { state.status = 'succeeded'; state.data = action.payload; })
     .addCase(fetchUser.rejected, (state, action) => { state.status = 'failed'; state.error = action.error.message; });
   ```

10. **Circular dependency between slices** — the `cartSlice` imports from the `productSlice` reducer, and the `productSlice` imports from the `cartSlice`. This causes a runtime error during module resolution → slices should not import each other. If one slice needs data from another, use a selector in the component or create a shared `select` module that imports from both slices. The dependency graph should be: `components → selectors → slices`.

## Code Examples

### Redux Toolkit Slice with Async Thunk

```ts
import { createSlice, createAsyncThunk, PayloadAction } from '@reduxjs/toolkit';

interface Order {
  id: string;
  items: OrderItem[];
  total: number;
  status: 'pending' | 'processing' | 'shipped' | 'delivered';
}

interface OrderState {
  orders: Record<string, Order>;
  orderIds: string[];
  status: 'idle' | 'loading' | 'succeeded' | 'failed';
  error: string | null;
}

const initialState: OrderState = {
  orders: {},
  orderIds: [],
  status: 'idle',
  error: null,
};

export const fetchOrders = createAsyncThunk<Order[], void, { rejectValue: string }>(
  'orders/fetchOrders',
  async (_, { rejectWithValue }) => {
    const response = await fetch('/api/orders');
    if (!response.ok) return rejectWithValue(`Failed to fetch: ${response.status}`);
    return response.json();
  }
);

const orderSlice = createSlice({
  name: 'orders',
  initialState,
  reducers: {
    updateOrderStatus: (
      state,
      action: PayloadAction<{ orderId: string; status: Order['status'] }>
    ) => {
      const order = state.orders[action.payload.orderId];
      if (order) order.status = action.payload.status;
    },
  },
  extraReducers: (builder) => {
    builder
      .addCase(fetchOrders.pending, (state) => {
        state.status = 'loading';
        state.error = null;
      })
      .addCase(fetchOrders.fulfilled, (state, action) => {
        state.status = 'succeeded';
        for (const order of action.payload) {
          state.orders[order.id] = order;
          if (!state.orderIds.includes(order.id)) {
            state.orderIds.push(order.id);
          }
        }
      })
      .addCase(fetchOrders.rejected, (state, action) => {
        state.status = 'failed';
        state.error = action.payload ?? 'Unknown error';
      });
  },
});

export const { updateOrderStatus } = orderSlice.actions;
export const selectOrders = (state: { orders: OrderState }) =>
  state.orderIds.map((id) => state.orders[id]);
export const selectOrderById = (id: string) => (state: { orders: OrderState }) =>
  state.orders[id] ?? null;

export default orderSlice.reducer;
```

### RTK Query for API State

```ts
import { createApi, fetchBaseQuery } from '@reduxjs/toolkit/query/react';

export const api = createApi({
  reducerPath: 'api',
  baseQuery: fetchBaseQuery({ baseUrl: '/api' }),
  tagTypes: ['Order', 'User'],
  endpoints: (builder) => ({
    getOrders: builder.query<Order[], void>({
      query: () => '/orders',
      providesTags: [{ type: 'Order', id: 'LIST' }],
    }),
    getOrderById: builder.query<Order, string>({
      query: (id) => `/orders/${id}`,
      providesTags: (result, error, id) => [{ type: 'Order', id }],
    }),
    createOrder: builder.mutation<Order, NewOrder>({
      query: (body) => ({ url: '/orders', method: 'POST', body }),
      invalidatesTags: [{ type: 'Order', id: 'LIST' }],
    }),
    updateOrder: builder.mutation<Order, { id: string; status: string }>({
      query: ({ id, ...body }) => ({ url: `/orders/${id}`, method: 'PATCH', body }),
      invalidatesTags: (result, error, { id }) => [
        { type: 'Order', id },
        { type: 'Order', id: 'LIST' },
      ],
    }),
  }),
});

export const {
  useGetOrdersQuery,
  useGetOrderByIdQuery,
  useCreateOrderMutation,
  useUpdateOrderMutation,
} = api;
```

### Store Configuration

```ts
import { configureStore } from '@reduxjs/toolkit';
import { setupListeners } from '@reduxjs/toolkit/query';
import orderReducer from './orderSlice';
import { api } from './api';

export const store = configureStore({
  reducer: {
    orders: orderReducer,
    [api.reducerPath]: api.reducer,
  },
  middleware: (getDefaultMiddleware) =>
    getDefaultMiddleware().concat(api.middleware),
});

setupListeners(store.dispatch);

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;
```

## Best Practices

- **Use Redux Toolkit, not raw Redux.** RTK eliminates 80% of Redux boilerplate with `createSlice`, `configureStore`, and Immer integration. The Redux core team recommends RTK as the default.
- **Separate server state from client state.** Use RTK Query or React Query for API data. Use Redux slices for UI state, form state, and business logic. Do not mix them.
- **Normalize state like a database.** Store entities by ID in flat maps. Reference them by ID in arrays. Use `createEntityAdapter` for automatic CRUD operations on normalized state.
- **Keep selectors fast and memoized.** Return primitive values from `useSelector`. For derived data, use Reselect (`createSelector`) to memoize computations. Avoid returning new object references.
- **Handle all three async states.** Every `createAsyncThunk` dispatches `pending`, `fulfilled`, and `rejected`. Handle all three in your reducer to avoid stuck loading states and swallowed errors.
- **Use RTK Query's cache invalidation.** Define `tagTypes` and use `providesTags`/`invalidatesTags` to keep queries in sync with mutations. This is far more maintainable than manual refetching.
- **Do not put everything in Redux.** Local UI state (form fields, toggle states, modal open/close) belongs in `useState`. Only global, shared, or persistent state belongs in Redux.
- **Test reducers as pure functions.** Reducers are the easiest part of Redux to test: `expect(reducer(initialState, action)).toEqual(expectedState)`. Test every action type, including the default case.
- **Use TypeScript for action payloads and state.** `PayloadAction<{ id: string; qty: number }>` documents the expected payload and catches type mismatches at compile time.
- **Log actions in development.** Redux DevTools is essential. In production, log critical actions (errors, mutations, auth events) to your monitoring service. Do not log every action — it is noisy and expensive.

## Related Topics

- [[React]]
- [[ReactNative]]
- [[Mobile MOC]]
- [[MobileArchitecture]]
- [[StateManagementPatterns]]
- [[FrontendArchitecture]]
- [[JavaScript]]
- [[TypeScript]]
