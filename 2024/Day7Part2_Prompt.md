# AoC 2024 Day 7, Part 2 - Concise Prompt

## Problem

For each equation, determine if inserting `+`, `*`, or `||` (concatenate) operators between numbers can produce the target value. Sum the target values of all solvable equations.

## Input Format

```
target: n1 n2 n3 ...
```

## Rules

- Operators: `+` (add), `*` (multiply), `||` (concatenate)
- Concatenate: joins digits, e.g., `12 || 345 = 12345`
- Evaluate strictly left-to-right (no precedence)
- Numbers cannot be rearranged
- Try all combinations of operators

## Algorithm

1. Parse each line into target and list of numbers
2. For each equation with n numbers:
   - Try all 3^(n-1) combinations of operators
   - Evaluate left-to-right
   - If any combination equals target → equation is valid
3. Sum targets of all valid equations

## Concatenation Implementation

```
a || b = int(str(a) + str(b))
// or: a || b = a * 10^(digits in b) + b
```

## Output

Single integer (sum of target values from solvable equations)
