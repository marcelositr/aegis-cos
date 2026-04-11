---
title: React Native
title_pt: React Native
layer: mobile
type: concept
priority: high
version: 1.0.0
tags:
  - Mobile
  - React Native
  - JavaScript
  - TypeScript
  - Cross-Platform
description: Cross-platform mobile development with React Native, components, and native modules.
description_pt: Desenvolvimento mobile multiplataforma com React Native, componentes e módulos nativos.
prerequisites:
  - Programming
  - JavaScript
estimated_read_time: 12 min
difficulty: intermediate
---

# React Native

## Description

React Native enables cross-platform mobile app development using JavaScript/TypeScript and React. It compiles to native components, providing near-native performance while sharing code between iOS and Android. Created by Facebook (Meta), it powers apps like Instagram, Facebook, and Airbnb.

React Native uses a JavaScript runtime (Hermes) to execute code and communicates with native components via a bridge. The architecture allows access to native APIs while maintaining a single codebase.

Key concepts:
- **Components** - Building blocks (View, Text, Image, etc.)
- **Props** - Parameters passed to components
- **State** - Internal component data
- **Hooks** - Reusable stateful logic
- **Native Modules** - Custom native code integration

## Purpose

**When React Native is valuable:**
- Building for both iOS and Android from one codebase
- Teams with JavaScript/React experience
- Rapid prototyping and iteration
- Apps not requiring heavy native customization

**When to consider native:**
- Performance-critical features (high-end gaming)
- Deep hardware integration
- Platform-specific UIs

## Rules

1. **Use functional components** - With hooks instead of class components
2. **Optimize renders** - Use React.memo, useMemo, useCallback
3. **Handle differences** - Platform-specific code when needed
4. **Test on real devices** - Emulators have limitations
5. **Manage native dependencies** - Choose stable packages

## Examples

### Basic Component Structure

```tsx
import React, { useState, useEffect } from 'react';
import { View, Text, TextInput, TouchableOpacity, FlatList, StyleSheet } from 'react-native';

// Main App Component
export default function App() {
  const [items, setItems] = useState<string[]>([]);
  const [inputValue, setInputValue] = useState('');

  const addItem = () => {
    if (inputValue.trim()) {
      setItems([...items, inputValue.trim()]);
      setInputValue('');
    }
  };

  const removeItem = (index: number) => {
    setItems(items.filter((_, i) => i !== index));
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>My List</Text>
      
      <View style={styles.inputContainer}>
        <TextInput
          style={styles.input}
          value={inputValue}
          onChangeText={setInputValue}
          placeholder="Add item..."
          placeholderTextColor="#999"
        />
        <TouchableOpacity style={styles.button} onPress={addItem}>
          <Text style={styles.buttonText}>Add</Text>
        </TouchableOpacity>
      </View>

      <FlatList
        data={items}
        keyExtractor={(_, index) => index.toString()}
        renderItem={({ item, index }) => (
          <View style={styles.item}>
            <Text style={styles.itemText}>{item}</Text>
            <TouchableOpacity onPress={() => removeItem(index)}>
              <Text style={styles.deleteText}>Delete</Text>
            </TouchableOpacity>
          </View>
        )}
        ListEmptyComponent={<Text style={styles.empty}>No items yet</Text>}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, padding: 20, backgroundColor: '#fff' },
  title: { fontSize: 24, fontWeight: 'bold', marginBottom: 20 },
  inputContainer: { flexDirection: 'row', marginBottom: 20 },
  input: { flex: 1, borderWidth: 1, borderColor: '#ccc', padding: 10, borderRadius: 8 },
  button: { backgroundColor: '#007AFF', padding: 12, borderRadius: 8, marginLeft: 10 },
  buttonText: { color: '#fff', fontWeight: 'bold' },
  item: { flexDirection: 'row', justifyContent: 'space-between', padding: 15, backgroundColor: '#f5f5f5', borderRadius: 8, marginBottom: 8 },
  itemText: { fontSize: 16 },
  deleteText: { color: '#FF3B30' },
  empty: { textAlign: 'center', color: '#999', marginTop: 40 },
});
```

### Custom Hook for Data Fetching

```tsx
import { useState, useEffect } from 'react';
import { ActivityIndicator, Text, View } from 'react-native';

interface UseFetchResult<T> {
  data: T | null;
  loading: boolean;
  error: string | null;
}

function useFetch<T>(url: string): UseFetchResult<T> {
  const [data, setData] = useState<T | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let mounted = true;

    async function fetchData() {
      try {
        const response = await fetch(url);
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        const json = await response.json();
        if (mounted) {
          setData(json);
          setError(null);
        }
      } catch (err) {
        if (mounted) {
          setError(err instanceof Error ? err.message : 'Unknown error');
        }
      } finally {
        if (mounted) setLoading(false);
      }
    }

    fetchData();

    return () => { mounted = false; };
  }, [url]);

  return { data, loading, error };
}

// Usage Component
function UserList() {
  const { data, loading, error } = useFetch<User[]>('https://api.example.com/users');

  if (loading) return <ActivityIndicator size="large" />;
  if (error) return <Text style={{ color: 'red' }}>Error: {error}</Text>;

  return (
    <View>
      {data?.map(user => (
        <Text key={user.id}>{user.name}</Text>
      ))}
    </View>
  );
}
```

### Navigation with React Navigation

```tsx
import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { Text, View } from 'react-native';

type RootStackParamList = {
  Main: undefined;
  Details: { userId: string };
};

type TabParamList = {
  Home: undefined;
  Profile: undefined;
  Settings: undefined;
};

const Stack = createNativeStackNavigator<RootStackParamList>();
const Tab = createBottomTabNavigator<TabParamList>();

// Tab Screens
function HomeScreen() {
  return (
    <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
      <Text>Home Tab</Text>
    </View>
  );
}

function ProfileScreen() {
  return (
    <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
      <Text>Profile Tab</Text>
    </View>
  );
}

// Stack Screen with Navigation
function DetailsScreen({ route }: { route: { params: { userId: string } } }) {
  return (
    <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
      <Text>User ID: {route.params.userId}</Text>
    </View>
  );
}

function MainTabs() {
  return (
    <Tab.Navigator>
      <Tab.Screen name="Home" component={HomeScreen} />
      <Tab.Screen name="Profile" component={ProfileScreen} />
    </Tab.Navigator>
  );
}

// Root Navigator
export default function App() {
  return (
    <NavigationContainer>
      <Stack.Navigator>
        <Stack.Screen name="Main" component={MainTabs} />
        <Stack.Screen name="Details" component={DetailsScreen} options={{ title: 'User Details' }} />
      </Stack.Navigator>
    </NavigationContainer>
  );
}
```

### State Management with Zustand

```tsx
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import AsyncStorage from '@react-native-async-storage/async-storage';

// Store Type
interface UserState {
  users: User[];
  selectedUser: User | null;
  isLoading: boolean;
  addUser: (user: User) => void;
  removeUser: (id: string) => void;
  selectUser: (user: User | null) => void;
  setLoading: (loading: boolean) => void;
}

interface User {
  id: string;
  name: string;
  email: string;
}

// Create Store with Persistence
const useUserStore = create<UserState>()(
  persist(
    (set) => ({
      users: [],
      selectedUser: null,
      isLoading: false,
      
      addUser: (user) => set((state) => ({ 
        users: [...state.users, user] 
      })),
      
      removeUser: (id) => set((state) => ({ 
        users: state.users.filter(u => u.id !== id),
        selectedUser: state.selectedUser?.id === id ? null : state.selectedUser
      })),
      
      selectUser: (user) => set({ selectedUser: user }),
      
      setLoading: (loading) => set({ isLoading: loading }),
    }),
    {
      name: 'user-storage',
      storage: createJSONStorage(() => AsyncStorage),
    }
  )
);

// Usage in Component
function UserList() {
  const { users, removeUser, selectUser } = useUserStore();
  
  return (
    <View>
      {users.map(user => (
        <TouchableOpacity 
          key={user.id} 
          onPress={() => selectUser(user)}
          onLongPress={() => removeUser(user.id)}
        >
          <Text>{user.name}</Text>
        </TouchableOpacity>
      ))}
    </View>
  );
}
```

### Native Module (iOS Bridge)

```tsx
import { NativeModules, Platform } from 'react-native';

// TypeScript Interface
interface CalendarModuleInterface {
  createEvent(title: string, date: string): Promise<string>;
  getEvents(startDate: string, endDate: string): Promise<CalendarEvent[]>;
}

interface CalendarEvent {
  id: string;
  title: string;
  date: string;
}

// Access Native Module
const { CalendarModule } = NativeModules;

// Wrapper Hook
function useCalendar() {
  const createEvent = async (title: string, date: string): Promise<string> => {
    if (Platform.OS === 'ios') {
      return CalendarModule.createEvent(title, date);
    }
    // Fallback for Android
    return `Event created: ${title} on ${date}`;
  };

  const getEvents = async (start: string, end: string): Promise<CalendarEvent[]> => {
    if (Platform.OS === 'ios') {
      return CalendarModule.getEvents(start, end);
    }
    return [];
  };

  return { createEvent, getEvents };
}

// Usage
function EventScreen() {
  const { createEvent } = useCalendar();
  
  const handleCreate = async () => {
    try {
      const eventId = await createEvent('Meeting', '2024-01-15');
      console.log('Created:', eventId);
    } catch (error) {
      console.error('Failed:', error);
    }
  };
  
  return <Button title="Add Event" onPress={handleCreate} />;
}
```

### Testing with Jest

```tsx
// __tests__/UserList.test.tsx
import React from 'react';
import { render, fireEvent, waitFor } from '@testing-library/react-native';
import UserList from '../UserList';

// Mock data
const mockUsers = [
  { id: '1', name: 'John', email: 'john@example.com' },
  { id: '2', name: 'Jane', email: 'jane@example.com' },
];

// Mock API
jest.mock('../api', () => ({
  fetchUsers: jest.fn().mockResolvedValue(mockUsers),
}));

describe('UserList', () => {
  it('renders user names', async () => {
    const { getByText } = render(<UserList />);
    
    await waitFor(() => {
      expect(getByText('John')).toBeTruthy();
      expect(getByText('Jane')).toBeTruthy();
    });
  });

  it('calls onDelete when delete pressed', async () => {
    const mockDelete = jest.fn();
    const { getByText } = render(
      <UserList users={mockUsers} onDelete={mockDelete} />
    );
    
    fireEvent.press(getByText('Delete'));
    
    expect(mockDelete).toHaveBeenCalledWith('1');
  });
});
```

## Anti-Patterns

### 1. Not Using Keys

```tsx
// BAD - Missing key
{items.map(item => <Text>{item.name}</Text>)}

// GOOD - Proper keys
{items.map(item => <Text key={item.id}>{item.name}</Text>)}
```

### 2. Inline Functions in Render

```tsx
// BAD - New function each render
<TouchableOpacity onPress={() => handlePress(item.id)}>

// GOOD - Stable reference
const handlePress = useCallback((id: string) => { ... }, []);
<TouchableOpacity onPress={handlePress}>
```

### 3. Not Unsubscribing

```tsx
// BAD - Memory leak
useEffect(() => {
  const subscription = someEvent.subscribe(callback);
  // No cleanup!
}, []);

// GOOD - Cleanup
useEffect(() => {
  const subscription = someEvent.subscribe(callback);
  return () => subscription.unsubscribe();
}, []);
```

## Failure Modes

- **Missing keys in lists** → rendering bugs → incorrect item updates → always provide stable unique keys in FlatList and map
- **Inline functions in render** → unnecessary re-renders → poor performance → use `useCallback` for stable function references
- **Not unsubscribing in useEffect** → memory leaks → crashes on unmount → return cleanup functions from effects
- **Bridge bottleneck** → excessive JS-native communication → UI jank → batch native calls and minimize bridge crossings
- **Not handling platform differences** → crashes on one OS → inconsistent quality → use Platform.OS checks and platform-specific files
- **Large bundle size** → slow app download → user abandonment → optimize assets, use Hermes, and enable code splitting
- **Unoptimized FlatList** → scrolling jank → poor UX → use `getItemLayout`, `initialNumToRender`, and `removeClippedSubviews`

## Best Practices

### Project Structure

```
src/
├── components/       # Reusable UI components
├── screens/          # Screen components
├── navigation/       # Navigation config
├── hooks/            # Custom hooks
├── services/         # API, storage services
├── store/            # State management
├── types/            # TypeScript types
├── utils/            # Helper functions
└── assets/           # Images, fonts
```

### Performance Tips

```tsx
// Use React.memo for expensive components
const ExpensiveComponent = React.memo(({ data }) => {
  // Only re-renders when data changes
  return <Text>{data.label}</Text>;
});

// Use FlatList for long lists
<FlatList
  data={largeData}
  keyExtractor={item => item.id}
  renderItem={({ item }) => <ListItem item={item} />}
  getItemLayout={(_, index) => ({ length: 50, offset: 50 * index, index })}
  initialNumToRender={10}
  maxToRenderPerBatch={10}
  windowSize={5}
  removeClippedSubviews={true}
/>
```

## Related Topics

- [[JavaScript]]
- [[TypeScript]]
- [[MobileArchitecture]]
- [[CrossPlatform]]
- [[MobileTesting]]
- [[React]]
- [[Redux]]
- [[APIDesign]]

## Additional Notes

**Navigation Libraries:**
- React Navigation (most popular)
- React Native Navigation (Wix)
- Router (Expo)

**State Management:**
- Zustand (simple, minimal)
- Redux Toolkit (full-featured)
- Jotai (atomic)
- Recoil (Facebook)

**Testing:**
- Jest (unit)
- React Native Testing Library (component)
- Detox (E2E)