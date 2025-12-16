# AoC 2024 Day 10, Part 2 - Concise Prompt

## Problem

Find all trailheads (height 0) and calculate how many **distinct paths** lead from each to any height-9 position. Sum all trailhead ratings.

## Key Change from Part 1

- Part 1: Count distinct **destinations** (unique `9` positions reachable)
- Part 2: Count distinct **paths** (different routes, even to same `9`)

## Grid Elements

- `0-9` = height at position
- Trailhead = any position with height `0`

## Trail Rules

- Start at height `0`, end at height `9`
- Each step must increase height by exactly `1`
- Only 4-directional movement (up, down, left, right - no diagonals)

## Rating

- **Trailhead rating** = count of distinct valid paths from trailhead to any `9`
- Different paths to the same `9` count separately

## Algorithm

1. Parse grid into 2D height array
2. Find all positions with height `0` (trailheads)
3. For each trailhead:
   - Count all distinct paths to any `9`
   - Use DFS with path counting (or memoized recursion)
   - Rating = total number of paths found
4. Return sum of all trailhead ratings

## Path Counting (Recursive)

```
countPaths(r, c):
    h = grid[r][c]
    if h == 9: return 1
    
    total = 0
    for each neighbor (nr, nc) in 4 directions:
        if in bounds AND grid[nr][nc] == h + 1:
            total += countPaths(nr, nc)
    return total
```

Can memoize by position since path count from any position is fixed.

## Output

Single integer (sum of all trailhead ratings)
