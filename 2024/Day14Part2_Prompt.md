# AoC 2024 Day 14, Part 2 - Concise Prompt

## Problem

Find the earliest time when robots arrange themselves into a Christmas tree pattern.

## Grid Size

- **Width: 101 tiles**
- **Height: 103 tiles**

## Challenge

The problem doesn't specify what the tree looks like. Must detect when robots form an unusual/organized pattern.

## Detection Strategies

### Strategy 1: Minimum Safety Factor
The tree likely has robots clustered together, not spread across quadrants. Find time with **lowest safety factor** (from Part 1).

### Strategy 2: Clustering Detection
Look for frames with high clustering:
- Count robots with neighbors (adjacent robots)
- Find frame with maximum adjacency count

### Strategy 3: Unique Positions
The tree might have all robots in unique positions (no overlaps):
- Find frame where number of unique positions = number of robots

### Strategy 4: Bounding Box / Variance
Look for frame with:
- Minimum variance in positions (tight clustering)
- Small bounding box containing most robots

### Strategy 5: Visual Inspection
Output frames to console/file and look for the tree manually.

## Algorithm

```
max_time = 101 * 103  # Pattern repeats after LCM(width, height)

best_time = 0
best_score = 0

for t in 0..max_time:
    positions = set of all robot positions at time t
    
    # Count robots with at least one neighbor
    clustered = 0
    for (x, y) in positions:
        for (dx, dy) in [(-1,0), (1,0), (0,-1), (0,1)]:
            if (x+dx, y+dy) in positions:
                clustered += 1
                break
    
    if clustered > best_score:
        best_score = clustered
        best_time = t

return best_time
```

## Position at Time t

```
x = (px + vx * t) mod 101
y = (py + vy * t) mod 103
```

## Output

Single integer (fewest seconds until Christmas tree appears)
