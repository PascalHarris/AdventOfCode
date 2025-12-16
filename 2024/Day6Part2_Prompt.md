# AoC 2024 Day 6, Part 2 - Concise Prompt

## Problem

Count positions where adding a single obstacle causes the guard to loop forever (never exit).

## Constraints

- Can only add ONE new obstacle
- Cannot place obstacle at guard's starting position
- Obstacle causes a loop if guard revisits same (position + direction)

## Algorithm

1. Parse grid, find guard start position
2. (Optimization) First run Part 1 to get all visited positions - only test obstacles on the guard's original path
3. For each candidate position (empty cells on original path, not start):
   - Temporarily add obstacle
   - Simulate guard movement
   - Track visited states as (row, col, direction)
   - If state repeats → loop detected → count it
   - If guard exits grid → no loop
   - Remove temporary obstacle
4. Return count of positions that cause loops

## Loop Detection

```
visited_states = set of (row, col, direction)

while true:
    state = (row, col, direction)
    if state in visited_states → LOOP FOUND
    add state to visited_states
    
    if next position is out of bounds → NO LOOP (guard exits)
    if obstacle ahead → turn right
    else → move forward
```

## Output

Single integer (count of positions where adding obstacle creates a loop)
