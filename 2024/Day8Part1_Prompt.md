# AoC 2024 Day 8, Part 1 - Concise Prompt

## Problem

Find all antinode positions created by pairs of same-frequency antennas. Count unique antinode locations within grid bounds.

## Grid Elements

- `.` = empty space
- `a-z`, `A-Z`, `0-9` = antennas (character = frequency)

## Antinode Rules

For each pair of antennas with the **same frequency**:
- An antinode appears where one antenna is **twice as far** as the other
- This creates exactly **2 antinodes per pair** (one on each side, extending the line)
- Antinodes can overlap with antennas or other antinodes
- Only count antinodes **within grid bounds**

## Antinode Calculation

For antennas at positions A and B:
```
diff = B - A
antinode1 = A - diff  (beyond A, away from B)
antinode2 = B + diff  (beyond B, away from A)
```

## Algorithm

1. Parse grid, group antenna positions by frequency
2. For each frequency with 2+ antennas:
   - For each pair of antennas, calculate both antinodes
   - Add antinodes within bounds to a set
3. Return size of antinode set

## Output

Single integer (count of unique antinode locations within bounds)
