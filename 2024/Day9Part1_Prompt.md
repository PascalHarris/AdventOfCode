# AoC 2024 Day 9, Part 1 - Concise Prompt

## Problem

Compact a disk by moving individual blocks from right to left, then calculate checksum.

## Input Format

Single line of digits representing alternating file lengths and free space lengths:
```
2333133121414131402
↑↑↑↑↑↑↑↑↑...
│││││││││
││││││││└─ file 9 length (2)
│││││││└── free space (0)
││││││└─── file 8 length (4)
...etc (alternating: file, free, file, free, ...)
```

## Expansion

Convert dense format to block representation:
- Files get sequential IDs starting at 0
- `.` represents free space

```
2333133121414131402
→ 00...111...2...333.44.5555.6666.777.888899
```

## Compaction Rules

Move blocks **one at a time** from rightmost file block to leftmost free space:
1. Find leftmost `.` (free space)
2. Find rightmost file block (non-`.`)
3. Swap them
4. Repeat until no gaps between file blocks

```
0..111....22222
02.111....2222.
022111....222..
0221112...22...
02211122..2....
022111222......
```

## Checksum Calculation

```
checksum = Σ (position × file_id) for all file blocks
```

Skip free space positions (they should all be at the end after compaction).

## Algorithm

1. Parse input, expand to block array (use -1 or None for free space)
2. Two-pointer compaction:
   - left pointer starts at 0
   - right pointer starts at end
   - Move left to find free space, right to find file block
   - Swap until pointers meet
3. Calculate checksum: sum of (index × file_id) for non-empty blocks

## Output

Single integer (filesystem checksum)
