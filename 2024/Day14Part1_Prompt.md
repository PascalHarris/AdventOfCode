# AoC 2024 Day 14, Part 1 - Concise Prompt

## Problem

Simulate robots moving on a toroidal grid for 100 seconds. Calculate safety factor by counting robots in each quadrant and multiplying the counts.

## Input Format

```
p=x,y v=vx,vy
```

- `p=x,y` = initial position (x from left, y from top)
- `v=vx,vy` = velocity (tiles per second)

## Grid Size

- **Width: 101 tiles** (x: 0 to 100)
- **Height: 103 tiles** (y: 0 to 102)

## Movement Rules

- Robots move simultaneously each second
- Position wraps around edges (toroidal/modular arithmetic)
- Multiple robots can occupy the same tile

## Position After 100 Seconds

```
new_x = (px + vx * 100) mod 101
new_y = (py + vy * 100) mod 103
```

Handle negative modulo correctly (result should be non-negative).

## Quadrant Definition

Divide grid into 4 quadrants, excluding middle lines:
- Middle column: x = 50 (width 101 → middle at 101/2 = 50)
- Middle row: y = 51 (height 103 → middle at 103/2 = 51)

```
Quadrant 1 (top-left):     x < 50  AND y < 51
Quadrant 2 (top-right):    x > 50  AND y < 51
Quadrant 3 (bottom-left):  x < 50  AND y > 51
Quadrant 4 (bottom-right): x > 50  AND y > 51
```

Robots exactly on middle lines (x=50 or y=51) are **excluded**.

## Safety Factor

```
safety_factor = Q1_count * Q2_count * Q3_count * Q4_count
```

## Algorithm

1. Parse all robot positions and velocities
2. Calculate each robot's position after 100 seconds (with wrapping)
3. Count robots in each quadrant (exclude middle lines)
4. Return product of four quadrant counts

## Output

Single integer (safety factor after 100 seconds)
