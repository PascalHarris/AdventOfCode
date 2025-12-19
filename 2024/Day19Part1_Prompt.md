# AoC 2024 Day 19, Part 1 - Concise Prompt

## Problem

Given a set of towel patterns and a list of designs, count how many designs can be formed by concatenating available patterns.

## Input Format

```
pattern1, pattern2, pattern3, ...

design1
design2
design3
...
```

- First line: comma-separated available patterns
- Blank line separator
- Remaining lines: designs to check

## Rules

- Each pattern can be used **unlimited times**
- Patterns must match exactly (no gaps, no overlaps)
- Order matters - patterns concatenate left to right

## Algorithm: Dynamic Programming

For each design, check if it can be formed:

```python
def can_form(design, patterns):
    n = len(design)
    dp = [False] * (n + 1)
    dp[0] = True  # empty string can be formed
    
    for i in range(1, n + 1):
        for pattern in patterns:
            plen = len(pattern)
            if i >= plen and dp[i - plen]:
                if design[i - plen:i] == pattern:
                    dp[i] = True
                    break  # optimization: found one way, enough for Part 1
    
    return dp[n]

# Count possible designs
count = sum(1 for design in designs if can_form(design, patterns))
```

## Output

Single integer (count of designs that can be formed)
