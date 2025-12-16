# AoC 2024 Day 12, Part 1 - Concise Prompt

## Problem

Find all connected regions on a grid. Calculate total fencing cost as sum of (area × perimeter) for each region.

## Definitions

- **Region:** Connected group of cells with same letter (4-directional connectivity)
- **Area:** Number of cells in the region
- **Perimeter:** Number of cell edges that border a different region or grid boundary

## Perimeter Calculation

For each cell in a region, count sides (0-4) that:
- Touch grid boundary, OR
- Touch a cell with a different letter

```
Each cell contributes: 4 - (number of same-letter neighbors)
```

## Algorithm

1. Parse grid
2. Find all regions using flood fill (BFS/DFS)
   - Track visited cells to avoid counting twice
   - Same letter can form multiple separate regions
3. For each region:
   - Area = count of cells
   - Perimeter = sum of exposed edges for all cells
   - Price = area × perimeter
4. Return sum of all region prices

## Flood Fill Pseudocode

```
for each unvisited cell (r, c):
    letter = grid[r][c]
    region_cells = BFS/DFS collecting all connected cells with same letter
    mark all as visited
    
    area = len(region_cells)
    perimeter = 0
    for each cell in region_cells:
        for each of 4 directions:
            if neighbor out of bounds OR neighbor has different letter:
                perimeter += 1
    
    total_price += area * perimeter
```

## Output

Single integer (total fencing price)
