# AoC 2024 Day 4, Part 1 - Concise Prompt

## Problem

Count all occurrences of "XMAS" in a 2D grid of letters.

**Directions:** horizontal, vertical, diagonal - forwards and backwards (8 directions total)

**Notes:**
- Words can overlap
- Count every occurrence

## Algorithm

1. Parse input into 2D character grid
2. For each cell containing 'X':
   - Check all 8 directions for "XMAS"
   - Directions: N, NE, E, SE, S, SW, W, NW (or as dx,dy pairs)
3. Count all valid matches

## Directions as (dx, dy)

```
(-1,-1) (-1,0) (-1,1)
 (0,-1)   X    (0,1)
 (1,-1)  (1,0) (1,1)
```

## Output

Single integer (count of "XMAS" occurrences)
