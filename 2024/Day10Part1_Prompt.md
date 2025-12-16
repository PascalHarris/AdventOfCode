# AoC 2024 Day 10, Part 1 - Concise Prompt

## Problem

Find all trailheads (height 0) and calculate how many distinct height-9 positions are reachable from each via valid hiking trails. Sum all trailhead scores.

## Grid Elements

- `0-9` = height at position
- Trailhead = any position with height `0`

## Trail Rules

- Start at height `0`, end at height `9`
- Each step must increase height by exactly `1`
- Only 4-directional movement (up, down, left, right - no diagonals)

## Scoring

- **Trailhead score** = count of distinct `9` positions reachable via any valid trail
- Multiple paths to the same `9` count as 1

## Algorithm

1. Parse grid into 2D height array
2. Find all positions with height `0` (trailheads)
3. For each trailhead:
   - BFS/DFS to find all reachable `9` positions
   - Only follow edges where next height = current height + 1
   - Score = count of unique `9` positions found
4. Return sum of all trailhead scores

## BFS/DFS Logic

```
From position (r, c) with height h:
  For each neighbor (nr, nc) in 4 directions:
    If in bounds AND grid[nr][nc] == h + 1:
      Continue search from (nr, nc)
    If grid[nr][nc] == 9:
      Add (nr, nc) to reachable nines set
```

## Output

Single integer (sum of all trailhead scores)
