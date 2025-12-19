# AoC 2024 Day 19, Part 2 - Concise Prompt

## Problem

Count the **total number of ways** to form all designs using available patterns. Sum the counts for all designs.

## Key Change from Part 1

- Part 1: Can the design be formed? (yes/no)
- Part 2: **How many ways** can each design be formed? (count all arrangements)

## Algorithm: Dynamic Programming (Count Ways)

```python
def count_ways(design, patterns):
    n = len(design)
    dp = [0] * (n + 1)
    dp[0] = 1  # one way to form empty string
    
    for i in range(1, n + 1):
        for pattern in patterns:
            plen = len(pattern)
            if i >= plen and design[i - plen:i] == pattern:
                dp[i] += dp[i - plen]
    
    return dp[n]

# Sum ways for all designs
total = sum(count_ways(design, patterns) for design in designs)
```

## Key Difference from Part 1

```python
# Part 1: Stop at first solution
if dp(pos + length):
    return True

# Part 2: Count ALL solutions
total += dp(pos + length)
```

## Note

Numbers can get very large - ensure you're using appropriate integer types.

## Output

Single integer (sum of number of ways for all designs)
