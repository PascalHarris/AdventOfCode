# AoC 2024 Day 9, Part 2 - Concise Prompt

## Problem

Compact a disk by moving **whole files** (not individual blocks) to leftmost available space, then calculate checksum.

## Input Format

Same as Part 1: single line of digits representing alternating file lengths and free space lengths.

```
2333133121414131402
→ 00...111...2...333.44.5555.6666.777.888899
```

## Key Change from Part 1

- Part 1: Move individual blocks one at a time
- Part 2: Move **entire files** as contiguous units

## Compaction Rules

1. Process files in **decreasing file ID order** (highest ID first)
2. For each file, find the **leftmost** free space span that can fit the entire file
3. If suitable space exists **to the left** of the file's current position → move entire file there
4. If no suitable space to the left → file stays in place
5. Each file is considered for moving **exactly once**

## Checksum Calculation

Same as Part 1:
```
checksum = Σ (position × file_id) for all file blocks
```

Free space positions (`.`) contribute 0.

## Algorithm

1. Parse input, track files as (id, start_pos, length) and free spans as (start_pos, length)
2. Process files from highest ID to lowest:
   - Find leftmost free span with length ≥ file length AND start_pos < file start_pos
   - If found: move file to that span, update free space tracking
3. Calculate checksum based on final positions

## Output

Single integer (filesystem checksum)
