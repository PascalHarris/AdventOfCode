# AoC 2024 Day 13, Part 2 - Concise Prompt

## Problem

Same as Part 1, but add `10000000000000` to both X and Y prize coordinates. No limit on button presses.

## Key Changes from Part 1

- Prize coordinates offset by `+10000000000000` on both axes
- **No 100-press limit** — brute force is impossible
- Must use linear algebra to solve directly

## Mathematical Formulation

For each machine, solve for non-negative integers `a` and `b`:
```
a * Ax + b * Bx = Px + 10000000000000
a * Ay + b * By = Py + 10000000000000
```

Cost = `3a + b`

## Solution: Cramer's Rule

Given system:
```
a * Ax + b * Bx = Px'
a * Ay + b * By = Py'
```

Where `Px' = Px + 10000000000000`, `Py' = Py + 10000000000000`

Determinant: `det = Ax * By - Ay * Bx`

If `det ≠ 0`:
```
a = (Px' * By - Py' * Bx) / det
b = (Ax * Py' - Ay * Px') / det
```

## Validation

Solution is valid only if:
1. `det` divides evenly (both `a` and `b` are integers)
2. `a ≥ 0` and `b ≥ 0`

If valid: cost = `3*a + b`
If invalid: machine is unwinnable (contributes 0)

## Algorithm

```
OFFSET = 10000000000000
total = 0

for each machine:
    Px' = Px + OFFSET
    Py' = Py + OFFSET
    
    det = Ax * By - Ay * Bx
    if det == 0: continue  # parallel, skip (or check special case)
    
    a_num = Px' * By - Py' * Bx
    b_num = Ax * Py' - Ay * Px'
    
    if a_num % det != 0 or b_num % det != 0: continue
    
    a = a_num // det
    b = b_num // det
    
    if a >= 0 and b >= 0:
        total += 3 * a + b

return total
```

## Important

Use integer arithmetic throughout — numbers are very large (~10^13).

## Output

Single integer (minimum total tokens to win all possible prizes)
