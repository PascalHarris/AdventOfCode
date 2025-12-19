# AoC 2024 Day 20, Part 1 - Concise Prompt

## Problem

On a racetrack with a single path from S to E, find how many "cheats" save at least 100 picoseconds. A cheat allows passing through walls for exactly 2 moves.

## Grid Elements

- `#` = wall
- `.` = track
- `S` = start (also track)
- `E` = end (also track)

## Rules

- **Exactly once** per race, disable collision for **up to 2 picoseconds**
- Must start and end on valid track
- Cheat = start on track → move through wall(s) → end on track
- Cheats are identified by (start_position, end_position)

## Algorithm

```python
# Step 1: BFS from S to get dist_from_start[pos]
# Step 2: BFS from E to get dist_to_end[pos]
# (Or just trace the single path and record distances)

normal_time = dist_from_start[E]

# Step 3: Find all cheats
cheats_saving_100 = 0

for each track cell A:
    for each track cell B where manhattan_distance(A, B) <= 2:
        # Cheat: walk to A normally, teleport to B (costs 2), walk to E
        cheat_time = dist_from_start[A] + manhattan_distance(A, B) + dist_to_end[B]
        saved = normal_time - cheat_time
        
        if saved >= 100:
            cheats_saving_100 += 1
```

## Distance Check

For cheat length of 2:
```python
def manhattan(a, b):
    return abs(a[0] - b[0]) + abs(a[1] - b[1])

# Valid cheat endpoints are within Manhattan distance 2
# This means: same cell (0), adjacent (1), or 2 steps away (2)
```

## Optimization

Since path is single/linear, can just walk the path once and record position → distance mapping.

```python
# Walk from S to E, recording distances
path = []  # ordered list of (pos, dist_from_start)
dist_from_start = {}
dist_to_end = {}

# Then for each pair of path positions within Manhattan distance 2,
# check if cheating saves time
```
```

## Output

Single integer (count of cheats saving at least 100 picoseconds)
