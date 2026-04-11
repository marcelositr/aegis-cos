---
title: Graph Theory
layer: foundations
type: concept
priority: high
version: 2.0.0
tags:
  - Foundations
  - Graphs
  - Algorithms
  - Networks
description: The study of graphs as mathematical structures: traversal, shortest paths, connectivity, flow, and coloring -- with direct applications in systems engineering.
---

# Graph Theory

## Description

A graph G = (V, E) consists of vertices V and edges E connecting pairs of vertices. Graph theory provides the mathematical foundation and algorithmic toolkit for solving problems involving networks, dependencies, routing, scheduling, and resource allocation.

Core algorithm families:

| Family | Key Algorithms | Typical Use Case |
|---|---|---|
| Traversal | BFS, DFS, iterative deepening | Connectivity, component analysis, topological sort |
| Shortest path | Dijkstra, Bellman-Ford, Floyd-Warshall, A* | Routing, network latency optimization, pathfinding |
| Minimum spanning tree | Kruskal, Prim, Boruvka | Network design, clustering, approximate TSP |
| Maximum flow | Ford-Fulkerson, Edmonds-Karp, Dinic | Bandwidth allocation, bipartite matching, scheduling |
| Strong connectivity | Kosaraju, Tarjan | Deadlock detection, SCC analysis |
| Bipartite matching | Hopcroft-Karp, Hungarian | Job assignment, resource allocation |
| Coloring | Greedy coloring, Welsh-Powell | Register allocation, scheduling, frequency assignment |

Graph representation tradeoffs:
- **Adjacency matrix:** O(1) edge lookup, O(V^2) space. Best for dense graphs (|E| ~ |V|^2) or when you need to check edge existence frequently.
- **Adjacency list:** O(degree(v)) iteration, O(V + E) space. Best for sparse graphs (|E| << |V|^2), which is the common case in production systems.
- **Compressed Sparse Row (CSR):** Cache-friendly, ideal for static graphs in numerical computing (PageRank, graph neural networks).

## Purpose

**When to use:**
- Dependency resolution: package managers (apt, pip, npm) use topological sort on the dependency DAG. Cycle detection catches circular dependencies.
- Network routing: OSPF uses Dijkstra's algorithm; BGP uses path-vector (a variant). Every packet routed on the internet traverses a shortest-path computation.
- Social network analysis: connected components for community detection, betweenness centrality for influence ranking, PageRank for importance.
- Build systems: Make, Bazel, and Turborepo model build targets as a DAG. Parallel execution is determined by topological levels.
- Deadlock detection: wait-for graphs in databases and OS. A cycle = deadlock. Tarjan's SCC algorithm detects it in O(V + E).
- Compiler optimization: register allocation via graph coloring (interference graph), instruction scheduling via DAG, data-flow analysis on control-flow graphs.
- Recommendation systems: bipartite graphs of user-item interactions; random walks for embedding generation (node2vec, DeepWalk).
- Fraud detection: anomaly detection via graph metrics (sudden changes in degree distribution, newly connected components).

**When NOT to use:**
- When your data has no relational structure -- a flat list or hash table is simpler and faster.
- When a simple formula or closed-form solution exists (e.g., "find the max" is O(n) linear scan, not a graph problem).
- When the graph is small and static and you're only doing point lookups -- a precomputed hash table is faster than running BFS every query.
- When you need real-time sub-millisecond responses on a graph with billions of edges and cannot afford specialized graph databases (Neo4j, TigerGraph) -- a general-purpose BFS in Python won't cut it.
- When the problem is really about statistical correlation, not structure -- use statistical learning, not graph algorithms.

## Tradeoffs

| Problem | Algorithm | Time | Space | When to prefer |
|---|---|---|---|---|
| Unweighted shortest path | BFS | O(V + E) | O(V) | All edges have equal weight |
| Weighted shortest path (non-negative) | Dijkstra (binary heap) | O((V + E) log V) | O(V) | Road networks, latency routing |
| Weighted shortest path (negative edges) | Bellman-Ford | O(VE) | O(V) | Currency arbitrage, financial flows |
| All-pairs shortest path | Floyd-Warshall | O(V^3) | O(V^2) | Small dense graphs (V < 500) |
| All-pairs shortest path | Johnson's | O(V^2 log V + VE) | O(V^2) | Sparse graphs, V up to ~5000 |
| Approximate shortest path | A* with admissible heuristic | Depends on heuristic | O(V) | Pathfinding in games, robotics |
| MST | Kruskal | O(E log E) | O(V) | Sparse graphs, easy to implement |
| MST | Prim (Fibonacci heap) | O(E + V log V) | O(V) | Dense graphs, theoretical optimum |
| Max flow | Dinic | O(V^2 E) | O(V) | General case; fast in practice |
| Max flow (unit capacities) | Dinic | O(E * min(V^(2/3), E^(1/2))) | O(V) | Bipartite matching, scheduling |

## Alternatives

- **Tabular/database queries:** When you only need "find all neighbors of X" and nothing more complex, a simple adjacency table in PostgreSQL or Redis is sufficient.
- **Vector embeddings + similarity search:** For recommendation and similarity problems, embedding-based approaches (FAISS, HNSW) often outperform graph-based methods on large datasets.
- **Constraint solvers:** For scheduling and assignment problems, SAT/SMT solvers or ILP (Gurobi, CBC) can be more expressive than graph algorithms.
- **Simulation/Monte Carlo:** When you need probabilistic answers about graph processes (e.g., epidemic spread), simulation is often more practical than exact analytical methods.
- **Machine learning on graphs:** GNNs (GraphSAGE, GAT) for learning representations when hand-crafted graph features are insufficient.

## Failure Modes

1. **Using recursion on large graphs causing stack overflow:** DFS on a graph with 100K nodes in a line triggers stack overflow (default Python recursion limit is 1000). **Mitigation:** Use iterative DFS with an explicit `collections.deque` stack. In languages like C++ or Rust, the stack is typically 8MB -- a path of depth 100K will overflow. Always use iterative for production code.

2. **Dijkstra with negative edge weights producing wrong results:** Dijkstra greedily selects the closest unvisited node and never reconsiders. Negative edges invalidate this assumption. **Mitigation:** Use Bellman-Ford (detects negative cycles too) or Johnson's algorithm for all-pairs. Always validate edge weights: `assert all(w >= 0 for w in edge_weights)`.

3. **Incorrect adjacency list mutation during traversal:** Modifying the graph while iterating over neighbors causes skipped nodes or double-processing. Example: removing edges during BFS. **Mitigation:** Iterate over a snapshot: `for neighbor in list(graph[node])` in Python. Or collect mutations and apply after traversal.

4. **Floyd-Warshall O(V^3) on large graphs:** V=10,000 means 10^12 operations -- minutes to hours. **Mitigation:** Use Floyd-Warshall only for V < 500. For larger graphs, run V instances of Dijkstra (O(V * (V+E) log V)) or use Johnson's algorithm. Profile before choosing.

5. **Integer overflow in shortest-path accumulation:** In Bellman-Ford with many edges, the accumulated distance can exceed 2^31. **Mitigation:** Use 64-bit integers (`long` in Java/C++, `i64` in Rust) for distance. Initialize to `INT64_MAX // 2` (not `INT64_MAX`) to avoid overflow in `dist[u] + weight` checks.

6. **Disconnected graph assumptions:** Assuming the graph is connected when it's not. BFS from node 0 won't reach nodes in other components. **Mitigation:** Run BFS/DFS from every unvisited node to find all connected components. Document whether your algorithm assumes connectivity.

7. **Using the wrong graph representation for the workload:** Adjacency matrix on a sparse social network graph (1M nodes, 10M edges) wastes 1TB of memory (1M^2 * 1 byte). Adjacency list uses ~80MB. **Mitigation:** Profile edge density. If |E| < |V|^2 / 10, use adjacency list. For static graphs used in numerical computation, use CSR.

## Code Examples

### Example 1: Topological Sort with Cycle Detection (Build System)

```python
from collections import deque, defaultdict

def topological_sort_with_levels(graph: dict[str, list[str]]) -> tuple[list[list[str]], bool]:
    """
    Topological sort that also assigns parallel execution levels.
    Used by build systems (Make, Bazel) to schedule parallel builds.
    
    graph: adjacency list where graph[v] = list of dependencies of v
           (edges point from v to its dependencies)
    
    Returns: (levels, has_cycle)
      levels[i] = list of nodes that can be built in parallel at level i
      has_cycle = True if circular dependency detected
    
    Time: O(V + E), Space: O(V + E)
    """
    # Build reverse graph (who depends on me) and in-degree count
    in_degree = defaultdict(int)
    dependents = defaultdict(list)  # if A depends on B, dependents[B] includes A
    all_nodes = set(graph.keys())
    
    for node, deps in graph.items():
        all_nodes.update(deps)
        for dep in deps:
            dependents[dep].append(node)
            in_degree[node] += 1
    
    # Initialize: nodes with no dependencies
    queue = deque([n for n in all_nodes if in_degree[n] == 0])
    levels = []
    processed = 0
    
    while queue:
        # All nodes in current level can run in parallel
        level = list(queue)
        levels.append(level)
        processed += len(level)
        
        next_queue = deque()
        for node in level:
            for dependent in dependents[node]:
                in_degree[dependent] -= 1
                if in_degree[dependent] == 0:
                    next_queue.append(dependent)
        queue = next_queue
    
    has_cycle = processed < len(all_nodes)
    return levels, has_cycle


# Real-world example: Python package dependencies
deps = {
    "myapp": ["flask", "sqlalchemy", "requests"],
    "flask": ["werkzeug", "jinja2"],
    "sqlalchemy": ["greenlet"],
    "requests": ["urllib3", "certifi"],
    "werkzeug": [],
    "jinja2": ["markupsafe"],
    "greenlet": [],
    "urllib3": [],
    "certifi": [],
    "markupsafe": [],
}

levels, has_cycle = topological_sort_with_levels(deps)
assert not has_cycle
for i, level in enumerate(levels):
    print(f"Level {i} (parallel): {sorted(level)}")
# Level 0: ['certifi', 'greenlet', 'markupsafe', 'urllib3']
# Level 1: ['jinja2', 'requests', 'sqlalchemy', 'werkzeug']
# Level 2: ['flask']
# Level 3: ['myapp']

# Cycle detection test
cyclic_deps = {
    "A": ["B"],
    "B": ["C"],
    "C": ["A"],  # Cycle: A -> B -> C -> A
}
_, has_cycle = topological_sort_with_levels(cyclic_deps)
assert has_cycle
```

### Example 2: Dijkstra's Algorithm with Path Reconstruction

```python
import heapq
from collections import defaultdict

def dijkstra(graph: dict[str, dict[str, float]], source: str) -> tuple[dict[str, float], dict[str, str | None]]:
    """
    Dijkstra's shortest path with path reconstruction.
    
    graph: adjacency list with weights, graph[u] = {v: weight, ...}
    source: starting node
    
    Returns: (distances, predecessors)
      distances[v] = shortest distance from source to v
      predecessors[v] = previous node on shortest path to v
    
    Time: O((V + E) log V) with binary heap
    Space: O(V)
    
    Requires: all edge weights >= 0
    """
    distances = defaultdict(lambda: float('inf'))
    predecessors = {source: None}
    distances[source] = 0
    visited = set()
    
    # Min-heap: (distance, node)
    heap = [(0, source)]
    
    while heap:
        dist_u, u = heapq.heappop(heap)
        
        if u in visited:
            continue
        visited.add(u)
        
        for v, weight in graph.get(u, {}).items():
            assert weight >= 0, f"Negative weight {weight} on edge {u}->{v}. Use Bellman-Ford."
            new_dist = dist_u + weight
            if new_dist < distances[v]:
                distances[v] = new_dist
                predecessors[v] = u
                heapq.heappush(heap, (new_dist, v))
    
    return dict(distances), predecessors


def reconstruct_path(predecessors: dict[str, str | None], source: str, target: str) -> list[str]:
    """Reconstruct path from source to target using predecessor map."""
    if target not in predecessors:
        return []
    
    path = []
    current = target
    while current is not None:
        path.append(current)
        current = predecessors.get(current)
    path.reverse()
    
    if path[0] != source:
        return []  # target not reachable
    return path


# Real-world: road network
road_graph = {
    "A": {"B": 4, "C": 2},
    "B": {"C": 1, "D": 5},
    "C": {"D": 8, "E": 10},
    "D": {"E": 2},
    "E": {},
}

distances, predecessors = dijkstra(road_graph, "A")
assert distances == {"A": 0, "B": 4, "C": 2, "D": 9, "E": 11}

path = reconstruct_path(predecessors, "A", "E")
assert path == ["A", "C", "B", "D", "E"]  # Not A->C->E (cost 12) but A->C->B->D->E (cost 11)
```

### Example 3: Tarjan's Strongly Connected Components (Deadlock Detection)

```python
def tarjan_scc(graph: dict[str, list[str]]) -> list[list[str]]:
    """
    Tarjan's algorithm for finding strongly connected components.
    Used for deadlock detection: each SCC of size > 1 in a wait-for
    graph represents a potential deadlock cycle.
    
    Time: O(V + E), Space: O(V)
    
    Returns: list of SCCs, each SCC is a list of nodes
    """
    index_counter = [0]
    stack = []
    on_stack = set()
    index = {}
    lowlink = {}
    sccs = []
    
    def strongconnect(v):
        index[v] = index_counter[0]
        lowlink[v] = index_counter[0]
        index_counter[0] += 1
        stack.append(v)
        on_stack.add(v)
        
        for w in graph.get(v, []):
            if w not in index:
                strongconnect(w)
                lowlink[v] = min(lowlink[v], lowlink[w])
            elif w in on_stack:
                lowlink[v] = min(lowlink[v], index[w])
        
        # If v is a root node, pop the SCC
        if lowlink[v] == index[v]:
            scc = []
            while True:
                w = stack.pop()
                on_stack.discard(w)
                scc.append(w)
                if w == v:
                    break
            sccs.append(scc)
    
    for v in graph:
        if v not in index:
            strongconnect(v)
    
    return sccs


# Deadlock detection in a database wait-for graph
# Process A waits for B, B waits for C, C waits for A => deadlock
wait_for_graph = {
    "A": ["B"],
    "B": ["C"],
    "C": ["A"],
    "D": ["E"],
    "E": ["D"],
    "F": [],  # Not waiting on anything
}

sccs = tarjan_scc(wait_for_graph)
deadlocks = [scc for scc in sccs if len(scc) > 1]
assert len(deadlocks) == 2
assert set(deadlocks[0]) == {"A", "B", "C"}
assert set(deadlocks[1]) == {"D", "E"}
print(f"Deadlocks detected: {deadlocks}")
# Resolution: abort one transaction in each SCC
```

### Example 4: Bipartite Matching with Hopcroft-Karp (Job Assignment)

```python
from collections import deque

def hopcroft_karp(graph: dict[str, set[str]], left_nodes: set[str], right_nodes: set[str]) -> dict[str, str]:
    """
    Hopcroft-Karp algorithm for maximum bipartite matching.
    
    graph: adjacency list from left to right nodes
    left_nodes: set of nodes on the left side
    right_nodes: set of nodes on the right side
    
    Returns: matching as dict mapping left_node -> right_node
    
    Time: O(E * sqrt(V)), Space: O(V)
    """
    matching = {}  # right_node -> left_node (reverse mapping)
    dist = {}
    
    def bfs():
        queue = deque()
        for u in left_nodes:
            if u not in {v for v in matching.values()}:
                dist[u] = 0
                queue.append(u)
            else:
                dist[u] = float('inf')
        dist[None] = float('inf')
        
        while queue:
            u = queue.popleft()
            if dist[u] < dist[None]:
                for v in graph.get(u, set()):
                    if dist.get(matching.get(v), float('inf')) == float('inf'):
                        dist[matching.get(v)] = dist[u] + 1
                        queue.append(matching.get(v))
        return dist[None] != float('inf')
    
    def dfs(u):
        if u is None:
            return True
        for v in graph.get(u, set()):
            if dist.get(matching.get(v), float('inf')) == dist[u] + 1:
                if dfs(matching.get(v)):
                    matching[v] = u
                    return True
        dist[u] = float('inf')
        return False
    
    while bfs():
        for u in left_nodes:
            if u not in {v for v in matching.values()}:
                dfs(u)
    
    # Convert to left->right mapping
    return {u: v for v, u in matching.items()}


# Job assignment: workers -> tasks they can perform
capabilities = {
    "Alice": {"design", "test", "deploy"},
    "Bob": {"test", "review"},
    "Charlie": {"design", "review", "deploy"},
}

workers = set(capabilities.keys())
tasks = {"design", "test", "deploy", "review"}

matching = hopcroft_karp(capabilities, workers, tasks)
print(f"Optimal assignment: {matching}")
assert len(matching) == 3  # All 3 workers assigned
assert len(set(matching.values())) == 3  # All different tasks
```

## Best Practices

- **Always validate inputs:** Check for negative weights before running Dijkstra. Check for self-loops and parallel edges if your algorithm doesn't handle them.
- **Use iterative implementations for production code.** Recursive DFS/BFS is elegant but will stack-overflow on real-world graph sizes.
- **Choose the right representation:** Adjacency lists for sparse graphs, adjacency matrices only for dense graphs or when O(1) edge lookup is critical.
- **Use appropriate sentinel values:** Initialize distances to `float('inf')` or `INT64_MAX // 2`, not `INT64_MAX` (to avoid overflow on addition).
- **Profile before optimizing:** On small graphs (V < 1000), the difference between BFS and Dijkstra is negligible. Optimize only when measurements show graph traversal is a bottleneck.
- **Document graph assumptions:** Is the graph directed or undirected? Weighted or unweighted? Connected or disconnected? Allow cycles? These determine which algorithms are applicable.
- **Consider incremental updates:** If the graph changes frequently, recomputing from scratch is wasteful. Use dynamic graph algorithms (dynamic SSSP, incremental SCC) when update frequency is high.

## Related Topics

- [[Algorithms]] -- Graph algorithms as a core algorithmic paradigm
- [[DataStructures]] -- Graph representations (adjacency list, matrix, CSR)
- [[BigO]] -- Complexity analysis of graph algorithms
- [[Databases]] -- Graph databases, dependency graphs in migrations
- [[Architecture]] -- System architecture as a dependency graph; microservice communication topology
- [[Performance]] -- Cache-friendly graph traversal; CSR format for numerical computing
- [[DynamicProgramming]] -- DP on trees and DAGs (e.g., tree DP for subtree problems)
- [[Searching]] -- BFS and DFS as search strategies
- [[Principles/KISS]] -- Start with the simplest graph algorithm that solves the problem
- [[Network]] -- Network topology as a graph; routing algorithms
