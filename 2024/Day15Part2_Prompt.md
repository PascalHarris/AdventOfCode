# AoC 2024 Day 15, Part 2 - Concise Prompt

## Problem

Same as Part 1, but warehouse is doubled in width. Boxes are now 2 cells wide (`[]`). Simulate robot movement and sum GPS coordinates.

## Map Transformation

Before simulating, transform the original map:
- `#` → `##`
- `O` → `[]`
- `.` → `..`
- `@` → `@.`

## Grid Elements (after transformation)

- `#` = wall
- `.` = empty floor
- `[` = left half of box
- `]` = right half of box
- `@` = robot (still 1 cell)

## Movement Rules

### Horizontal Movement (left/right)
Same logic as Part 1:
- Find chain of boxes in move direction
- If empty space at end: shift everything
- If wall at end: no movement

### Vertical Movement (up/down) - CRITICAL
Wide boxes can push multiple boxes. Must use **flood-fill** to find ALL affected boxes.

When a box moves vertically, both halves (`[` and `]`) move together, and each half might contact different boxes above/below.

## Vertical Push Algorithm

```
def attempt_vertical_move(robot_pos, dr):
    # dr = -1 for up, +1 for down
    
    # Collect ALL cells that need to move (robot + all pushed boxes)
    to_check = [robot_pos]
    to_move = set()
    
    while to_check:
        (r, c) = to_check.pop()
        if (r, c) in to_move:
            continue
        to_move.add((r, c))
        
        nr, nc = r + dr, c
        target = grid[nr][nc]
        
        if target == '#':
            return False  # Blocked - entire move fails
        elif target == '[':
            to_check.append((nr, nc))      # left half
            to_check.append((nr, nc + 1))  # right half
        elif target == ']':
            to_check.append((nr, nc))      # right half
            to_check.append((nr, nc - 1))  # left half
        # if target == '.': nothing more to check from this cell
    
    # If we get here, move is possible
    # Move all cells in correct order (farthest first to avoid overwriting)
    
    if dr == -1:  # moving up - process top rows first
        for (r, c) in sorted(to_move, key=lambda x: x[0]):
            grid[r + dr][c] = grid[r][c]
            grid[r][c] = '.'
    else:  # moving down - process bottom rows first
        for (r, c) in sorted(to_move, key=lambda x: -x[0]):
            grid[r + dr][c] = grid[r][c]
            grid[r][c] = '.'
    
    return True
```

## Critical Implementation Details

1. **Include robot in to_move set** - robot moves with the boxes
2. **Process moves in correct order** - when moving up, move topmost cells first; when moving down, move bottommost cells first
3. **Both box halves move together** - when you find `[`, also add `]` at (r, c+1); when you find `]`, also add `[` at (r, c-1)
4. **Check target cells, not current cells** - look at where things are GOING, not where they are

## GPS Coordinate

For wide boxes, use the **left edge** (`[`) position:
```
GPS = 100 * row + col
```

Only count `[` characters, not `]`.

## Output

Single integer (sum of all boxes' GPS coordinates, using `[` positions only)
