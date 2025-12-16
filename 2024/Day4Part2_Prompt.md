# AoC 2024 Day 4, Part 2 - Concise Prompt

## Problem

Count all X-shaped patterns where two "MAS" strings cross at the 'A'.

**Pattern structure (3×3):**
```
M.S    M.M    S.M    S.S
.A.    .A.    .A.    .A.
M.S    S.S    S.M    M.M
```

Each diagonal must spell "MAS" (forwards or backwards).

## Algorithm

1. Parse input into 2D character grid
2. For each cell containing 'A' (not on edges):
   - Check both diagonals for valid MAS/SAM
   - Diagonal 1: top-left to bottom-right
   - Diagonal 2: top-right to bottom-left
3. Count positions where BOTH diagonals are valid

## Valid Diagonal Check

For center at (r, c):
- Diagonal 1: grid[r-1][c-1], grid[r][c], grid[r+1][c+1] → "MAS" or "SAM"
- Diagonal 2: grid[r-1][c+1], grid[r][c], grid[r+1][c-1] → "MAS" or "SAM"

## Output

Single integer (count of X-MAS patterns)
