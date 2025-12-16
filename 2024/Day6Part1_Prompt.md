# AoC 2024 Day 6, Part 1 - Concise Prompt

## Problem

Simulate a guard walking on a grid until they exit. Count distinct positions visited.

## Grid Elements

- `.` = empty space
- `#` = obstacle
- `^` = guard starting position (facing up)

## Movement Rules

1. If obstacle directly ahead → turn right 90°
2. Otherwise → move forward one step
3. Repeat until guard exits grid bounds

## Direction Cycle

```
Up (0,-1) → Right (1,0) → Down (0,1) → Left (-1,0) → Up ...
```

Or as (row, col) deltas:
```
Up (-1,0) → Right (0,1) → Down (1,0) → Left (0,-1) → Up ...
```

## Algorithm

1. Parse grid, find guard start position and direction
2. Track visited positions in a set
3. Loop:
   - Add current position to visited set
   - Check cell ahead
   - If obstacle: turn right
   - Else if in bounds: move forward
   - Else: exit loop (guard left grid)
4. Return size of visited set

## Output

Single integer (count of distinct positions visited)
