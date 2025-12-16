# AoC 2024 Day 8, Part 2 - Concise Prompt

## Problem

Find all antinode positions along lines formed by pairs of same-frequency antennas. Antinodes now occur at **all grid positions** on the line (including antenna positions). Count unique antinode locations within grid bounds.

## Key Change from Part 1

- Part 1: Only 2 antinodes per pair (at specific distances)
- Part 2: **All collinear points** within grid bounds are antinodes (resonant harmonics)

## Antinode Rules

For each pair of antennas with the **same frequency**:
- Antinodes occur at **every grid position** exactly in line with both antennas
- This includes the antenna positions themselves
- Extend in both directions until leaving grid bounds

## Antinode Calculation

For antennas at positions A and B:
```
diff = B - A
// Extend from A backwards (away from B)
pos = A
while pos in bounds:
    add pos to antinodes
    pos = pos - diff

// Extend from A forwards (through B and beyond)
pos = A + diff
while pos in bounds:
    add pos to antinodes
    pos = pos + diff
```

## Algorithm

1. Parse grid, group antenna positions by frequency
2. For each frequency with 2+ antennas:
   - For each pair of antennas:
     - Calculate direction vector (diff)
     - Walk in both directions, adding all in-bounds positions
3. Return size of antinode set

## Output

Single integer (count of unique antinode locations within bounds)
