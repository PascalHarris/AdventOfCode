# AoC 2024 Day 20, Part 2 - Concise Prompt

## Problem

Same as Part 1, but cheats can now last up to **20 picoseconds** instead of 2. Count cheats saving at least 100 picoseconds.

## Key Change from Part 1

- Part 1: Cheat duration ≤ 2 (Distance ≤ 2)
- Part 2: Cheat duration ≤ **20** (Distance ≤ 20)

## Rules

- **Exactly once** per race, disable collision for **up to 20 picoseconds**
- Must start and end on valid track
- Cheat identified by (start_position, end_position) - path doesn't matter
- Cheat cost = Manhattan distance between start and end

## Algorithm

Same as Part 1, just increase the distance threshold:

```python
# Step 1: Compute dist_from_start[pos] for all track cells
# Step 2: Compute dist_to_end[pos] for all track cells

normal_time = dist_from_start[E]

# Step 3: Find all cheats with Manhattan distance ≤ 20
cheats_saving_100 = 0

for each track cell A:
    for each track cell B where manhattan_distance(A, B) <= 20:
        cheat_cost = manhattan_distance(A, B)
        cheat_time = dist_from_start[A] + cheat_cost + dist_to_end[B]
        saved = normal_time - cheat_time
        
        if saved >= 100:
            cheats_saving_100 += 1
```

For each track cell A, only check cells B within distance 20:

```python
for A in track_cells:
    ax, ay = A
    for dx in range(-20, 21):
        for dy in range(-20 + abs(dx), 21 - abs(dx)):  # constrain to diamond
            bx, by = ax + dx, ay + dy
            B = (bx, by)
            if B in track_cells:
                cheat_dist = abs(dx) + abs(dy)
                # ... check if this cheat saves >= 100
```

## Important Notes

- Cheats are uniquely identified by (start, end) positions
- Different paths through walls to same endpoint = same cheat
- Unused cheat time is lost (can't be saved)
- Cheat must end on track

## Output

Single integer (count of cheats saving at least 100 picoseconds)
