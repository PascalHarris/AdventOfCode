# AoC 2024 Day 12, Part 2 - Concise Prompt

## Problem

Find all connected regions on a grid. Calculate total fencing cost as sum of (area × **number of sides**) for each region.

## Key Change from Part 1

- Part 1: Perimeter = count of individual edge segments
- Part 2: Sides = count of **straight fence sections** (contiguous edges count as 1 side)

## Definitions

- **Region:** Connected group of cells with same letter (4-directional connectivity)
- **Area:** Number of cells in the region
- **Side:** One continuous straight section of fence (any length)

## Counting Sides

A side is a maximal straight line segment of fence. Equivalent approaches:

### Approach 1: Count Corners
Number of sides = Number of corners. For each cell in region, check for corners:

**Outer corners** (convex) - cell is in region, two adjacent orthogonal neighbors are NOT:
```
.X    X.    ..    ..
X.    .X    X.    .X
```

**Inner corners** (concave) - cell is in region, two adjacent orthogonal neighbors ARE, but diagonal between them is NOT:
```
XX    XX    X.    .X
X.    .X    XX    XX
(diagonal missing from region)
```

Count all corners across all cells in region = number of sides.

### Approach 2: Scan Edges
For each direction (top/bottom/left/right):
- Collect all boundary edges facing that direction
- Group into contiguous horizontal or vertical lines
- Count groups

## Algorithm

1. Parse grid, find all regions using flood fill
2. For each region:
   - Area = count of cells
   - Sides = count corners (or scan edges)
   - Price = area × sides
3. Return sum of all region prices

## Corner Counting per Cell

```
For cell (r,c) in region:
    For each pair of orthogonal directions (e.g., UP+LEFT, UP+RIGHT, DOWN+LEFT, DOWN+RIGHT):
        n1 = neighbor in first direction
        n2 = neighbor in second direction
        diag = diagonal neighbor
        
        # Outer corner: both neighbors outside region
        if n1 not in region AND n2 not in region:
            corners += 1
        
        # Inner corner: both neighbors in region, diagonal not
        if n1 in region AND n2 in region AND diag not in region:
            corners += 1
```

## Output

Single integer (total fencing price using sides)
