# AoC 2024 Day 13, Part 1 - Concise Prompt

## Problem

For each claw machine, find the minimum tokens to reach the prize location, or determine it's impossible. Sum tokens for all winnable prizes.

## Input Format

```
Button A: X+94, Y+34
Button B: X+22, Y+67
Prize: X=8400, Y=5400

(blank line between machines)
```

## Costs

- Button A: **3 tokens** per press
- Button B: **1 token** per press

## Constraints

- Each button pressed at most **100 times**
- Must land **exactly** on prize coordinates

## Mathematical Formulation

For each machine, solve for non-negative integers `a` and `b` (both ≤ 100):
```
a * Ax + b * Bx = Px
a * Ay + b * By = Py
```

Where:
- `(Ax, Ay)` = Button A movement
- `(Bx, By)` = Button B movement  
- `(Px, Py)` = Prize location

Cost = `3a + b`

## Algorithm

### Option 1: Brute Force (given ≤100 constraint)
```
for a in 0..100:
    for b in 0..100:
        if a*Ax + b*Bx == Px and a*Ay + b*By == Py:
            track minimum cost (3*a + b)
```

### Option 2: Linear Algebra
Solve 2x2 system using Cramer's rule:
```
a = (Px*By - Py*Bx) / (Ax*By - Ay*Bx)
b = (Ax*Py - Ay*Px) / (Ax*By - Ay*Bx)
```
Check: both are non-negative integers ≤ 100

## Output

Single integer (minimum total tokens to win all possible prizes)
