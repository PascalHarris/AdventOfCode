# AoC 2024 Day 16, Part 2 - Concise Prompt

## Problem

Find all tiles that are part of ANY optimal path from `S` to `E`. Count unique tile positions.

## Approach

Run Dijkstra to find optimal cost, then find all states on any optimal path.

## Algorithm: Dijkstra + Backtracking

### Step 1: Dijkstra (Forward)

Run Dijkstra from start, recording:
- `dist[r][c][dir]` = minimum cost to reach state (r, c, dir)

```
Start: (start_row, start_col, EAST) with cost 0
```

### Step 2: Find Optimal Cost

```
optimal = min(dist[end_row][end_col][dir] for all directions)
```

### Step 3: Backtrack to Find All Optimal Tiles

Work backwards from end states with optimal cost. A state (r, c, dir) is on an optimal path if:

1. It can reach the end with total cost = optimal
2. There exists a valid predecessor that is also on an optimal path

**Method A: Reverse Dijkstra**

Run Dijkstra backwards from E (in all directions):
- `rdist[r][c][dir]` = minimum cost to reach E from state (r, c, dir)

A tile (r, c) is on an optimal path if for ANY direction:
```
dist[r][c][dir] + rdist[r][c][dir] == optimal
```

**Method B: BFS Backtrack from End**

```
# Start from all optimal end states
queue = [(end_row, end_col, dir) for dir where dist[end][dir] == optimal]
on_optimal_path = set()

while queue:
    (r, c, dir) = queue.pop()
    on_optimal_path.add((r, c))
    
    current_cost = dist[r][c][dir]
    
    # Check predecessor: moved forward to get here
    pr, pc = r - dr[dir], c - dc[dir]
    if grid[pr][pc] != '#' and dist[pr][pc][dir] == current_cost - 1:
        queue.append((pr, pc, dir))
    
    # Check predecessor: turned to get here
    for prev_dir in [(dir + 1) % 4, (dir - 1) % 4]:
        if dist[r][c][prev_dir] == current_cost - 1000:
            queue.append((r, c, prev_dir))
```

### Step 4: Count Unique Tiles

Count unique (row, col) positions in on_optimal_path set.

## Key Points

- Multiple optimal paths may exist
- A tile counts once even if on multiple optimal paths
- Include both S and E tiles
- State includes direction: same tile with different directions = different states

## Output

Single integer (count of unique tiles on any optimal path)
