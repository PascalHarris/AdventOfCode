# AoC 2024 Day 18, Part 1 - Concise Prompt

## Problem

After the first 1024 bytes fall and corrupt memory locations, find the shortest path from (0,0) to (70,70).

## Input Format

```
X,Y
X,Y
...
```

Each line is a coordinate that becomes corrupted (in order of falling).

## Grid Specifications

- **Size:** 71×71 (coordinates 0 to 70 inclusive)
- **Start:** (0, 0) - top left
- **End:** (70, 70) - bottom right
- **Movement:** 4-directional (up, down, left, right)

## Setup

1. Parse all byte positions from input
2. Mark the **first 1024** positions as corrupted (`#`)
3. All other positions are safe (`.`)

## Algorithm: BFS Shortest Path

```python
from collections import deque

def solve(corrupted_set, size=71):
    start = (0, 0)
    end = (size - 1, size - 1)
    
    if start in corrupted_set or end in corrupted_set:
        return -1
    
    queue = deque([(0, 0, 0)])  # (x, y, steps)
    visited = {(0, 0)}
    
    while queue:
        x, y, steps = queue.popleft()
        
        if (x, y) == end:
            return steps
        
        for dx, dy in [(0, 1), (0, -1), (1, 0), (-1, 0)]:
            nx, ny = x + dx, y + dy
            
            if 0 <= nx < size and 0 <= ny < size:
                if (nx, ny) not in visited and (nx, ny) not in corrupted_set:
                    visited.add((nx, ny))
                    queue.append((nx, ny, steps + 1))
    
    return -1  # No path found

# Parse first 1024 bytes
corrupted = set()
for i, line in enumerate(input_lines):
    if i >= 1024:
        break
    x, y = map(int, line.split(','))
    corrupted.add((x, y))

print(solve(corrupted))
```

## Note

- Input coordinates are `X,Y` where X is column (horizontal) and Y is row (vertical)
- First 1024 bytes only (not all bytes in input)
- Grid is 71×71 for actual puzzle (0-70 range)

## Output

Single integer (minimum steps from (0,0) to (70,70) after 1024 bytes fall)
