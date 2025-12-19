# AoC 2024 Day 25, Part 1 - Concise Prompt

## Problem

Count how many lock/key pairs fit together (no column overlap).

## Input Format

Schematics separated by blank lines. Each is 7 rows × 5 columns.

**Lock:** Top row is `#####`, bottom row is `.....`
**Key:** Top row is `.....`, bottom row is `#####`

## Height Calculation

- **Lock heights:** Count `#` going down from top (excluding top row)
- **Key heights:** Count `#` going up from bottom (excluding bottom row)

```python
def parse_schematic(lines):
    is_lock = lines[0] == '#####'
    heights = []
    
    for col in range(5):
        count = sum(1 for row in range(7) if lines[row][col] == '#')
        heights.append(count - 1)  # exclude the solid row
    
    return is_lock, heights
```

## Fit Check

Lock and key fit if for all columns:
```
lock_height[i] + key_height[i] <= 5
```

(Available space is 5 pins, since total height is 7 minus the two solid rows)

## Algorithm

```python
def solve(schematics):
    locks = []
    keys = []
    
    for schema in schematics:
        is_lock, heights = parse_schematic(schema)
        if is_lock:
            locks.append(heights)
        else:
            keys.append(heights)
    
    count = 0
    for lock in locks:
        for key in keys:
            if all(lock[i] + key[i] <= 5 for i in range(5)):
                count += 1
    
    return count
```

## Output

Single integer (count of fitting lock/key pairs)
