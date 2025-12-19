# AoC 2024 Day 23, Part 2 - Concise Prompt

## Problem

Find the largest clique (maximum set of fully interconnected computers) in the network. Return the password formed by their sorted names.

## Goal

Find the **maximum clique** - the largest subset where every pair of nodes is connected.

## Algorithm: Bron-Kerbosch

[Bron-Kerbosch](https://en.wikipedia.org/wiki/Bron–Kerbosch_algorithm)

The classic algorithm for finding maximum cliques:

```python
from collections import defaultdict

def solve(edges):
    # Build adjacency set
    graph = defaultdict(set)
    for line in edges:
        a, b = line.split('-')
        graph[a].add(b)
        graph[b].add(a)
    
    max_clique = []
    
    def bron_kerbosch(R, P, X):
        """
        R: current clique being built
        P: candidates that could extend the clique
        X: nodes already processed (excluded)
        """
        nonlocal max_clique
        
        if not P and not X:
            # R is a maximal clique
            if len(R) > len(max_clique):
                max_clique = R.copy()
            return
        
        # Pivot optimization: choose pivot from P ∪ X
        pivot = max(P | X, key=lambda v: len(graph[v] & P), default=None)
        
        for v in P - graph[pivot] if pivot else P.copy():
            bron_kerbosch(
                R | {v},
                P & graph[v],
                X & graph[v]
            )
            P = P - {v}
            X = X | {v}
    
    all_nodes = set(graph.keys())
    bron_kerbosch(set(), all_nodes, set())
    
    # Format password
    return ','.join(sorted(max_clique))
```

## Password Format

1. Sort node names alphabetically
2. Join with commas
3. No spaces

## Output

String (comma-separated sorted node names)
