# AoC 2024 Day 23, Part 1 - Concise Prompt

## Problem

Find all triangles (sets of 3 mutually connected computers) in a network graph. Count those where at least one computer name starts with `t`.

## Input Format

```
aa-bb
bb-cc
...
```

Each line is an undirected edge between two computers.

## Goal

1. Find all triangles (cliques of size 3)
2. Count only those containing at least one node starting with `t`

## Algorithm

```python
from collections import defaultdict

def solve(edges):
    # Build adjacency set
    graph = defaultdict(set)
    for line in edges:
        a, b = line.split('-')
        graph[a].add(b)
        graph[b].add(a)
    
    nodes = list(graph.keys())
    triangles = set()
    
    # Find all triangles
    for a in nodes:
        for b in graph[a]:
            if b > a:  # Avoid duplicates
                for c in graph[a] & graph[b]:  # Common neighbors
                    if c > b:  # Avoid duplicates
                        triangles.add((a, b, c))
    
    # Count triangles with at least one 't' node
    count = 0
    for tri in triangles:
        if any(node.startswith('t') for node in tri):
            count += 1
    
    return count
```

## Key Points

- Triangles are unordered sets: {a,b,c} = {b,a,c}
- Use sorted ordering to avoid counting same triangle multiple times
- Edge is undirected: `a-b` means both can reach each other

## Output

Single integer (count of triangles with at least one 't' computer)
