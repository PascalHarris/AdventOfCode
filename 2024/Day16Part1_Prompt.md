# AoC 2024 Day 16, Part 1 - Concise Prompt

## Problem

Find the lowest-cost path through a maze from `S` to `E`, where moving forward costs 1 and turning costs 1000.

## Grid Elements

- `#` = wall
- `.` = open path
- `S` = start position (reindeer faces **East**)
- `E` = end position

## Movement Costs

- **Move forward** (in current direction): **1 point**
- **Rotate 90° (clockwise or counterclockwise)**: **1000 points**

## State

State = `(row, col, direction)`

Directions: North, East, South, West (or 0, 1, 2, 3)

## Algorithm: Dijkstra's Shortest Path

```
State: (row, col, direction)
Start: (start_row, start_col, EAST) with cost 0
Goal: reach (end_row, end_col) in any direction

Priority queue: [(cost, row, col, direction)]
Visited: set of (row, col, direction)

while queue not empty:
    cost, r, c, dir = pop minimum cost state
    
    if (r, c) is E:
        return cost
    
    if (r, c, dir) in visited:
        continue
    visited.add((r, c, dir))
    
    # Option 1: Move forward
    nr, nc = r + dr[dir], c + dc[dir]
    if grid[nr][nc] != '#':
        push (cost + 1, nr, nc, dir)
    
    # Option 2: Turn left (counterclockwise)
    new_dir = (dir - 1) % 4
    push (cost + 1000, r, c, new_dir)
    
    # Option 3: Turn right (clockwise)
    new_dir = (dir + 1) % 4
    push (cost + 1000, r, c, new_dir)
```

## Direction Vectors

```
       North (0): dr=-1, dc=0
West (3)                   East (1): dr=0, dc=1
       South (2): dr=1, dc=0
```

Or as arrays:
```
dr = [-1, 0, 1, 0]  # N, E, S, W
dc = [0, 1, 0, -1]  # N, E, S, W
```

## Output

Single integer (lowest possible score to reach E from S)
