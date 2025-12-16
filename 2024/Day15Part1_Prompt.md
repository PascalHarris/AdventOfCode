# AoC 2024 Day 15, Part 1 - Concise Prompt

## Problem

Simulate a robot pushing boxes in a warehouse. After all moves, sum the GPS coordinates of all boxes.

## Input Format

```
##########
#..O..O.O#
#......O.#
#.OO..O.O#
#..O@..O.#
#O#..O...#
##########

<vv>^<v^>v>^vv^v...
```

- Grid section: warehouse map
- Move section: sequence of moves (ignore newlines)

## Grid Elements

- `#` = wall
- `.` = empty floor
- `O` = box
- `@` = robot

## Move Directions

- `^` = up (row - 1)
- `v` = down (row + 1)
- `<` = left (col - 1)
- `>` = right (col + 1)

## Movement Rules

1. Robot attempts to move in the specified direction
2. If target is empty (`.`): robot moves
3. If target is wall (`#`): nothing happens
4. If target is box (`O`):
   - Look in that direction for first non-box cell
   - If it's empty: push all boxes (robot moves, chain of boxes shifts by 1)
   - If it's wall: nothing happens (can't push boxes into wall)

## Box Pushing Logic

```
When robot at (r,c) moves direction (dr,dc) into box:
    Find first non-box cell in that direction
    If that cell is '.':
        Move box(es) by placing 'O' at that cell
        Robot moves to (r+dr, c+dc)
        Original robot position becomes '.'
    If that cell is '#':
        No movement
```

## GPS Coordinate

For a box at row `r`, column `c`:
```
GPS = 100 * r + c
```

(0-indexed from top-left corner)

## Algorithm

1. Parse grid and extract robot position
2. Parse all moves (concatenate lines, ignore whitespace)
3. For each move:
   - Calculate target position
   - Handle empty/wall/box cases as described
4. After all moves, sum GPS of all remaining boxes

## Output

Single integer (sum of all boxes' GPS coordinates)
