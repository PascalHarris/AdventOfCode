# AoC 2024 Day 11, Part 1 - Concise Prompt

## Problem

Simulate stone transformations for 25 blinks. Count total stones after all blinks.

## Input Format

Space-separated integers on a single line:
```
125 17
```

## Transformation Rules (applied in order, first match wins)

1. **If stone = 0** → becomes `1`
2. **If stone has even number of digits** → splits into two stones:
   - Left stone = left half of digits
   - Right stone = right half of digits
   - No leading zeros kept (e.g., `1000` → `10` and `0`)
3. **Otherwise** → stone value × 2024

## Rules Applied Per Blink

All stones transform **simultaneously** based on their current values.

## Examples

Single blink on `0 1 10 99 999`:
```
0    → 1           (rule 1)
1    → 2024        (rule 3: 1 × 2024)
10   → 1, 0        (rule 2: even digits, split)
99   → 9, 9        (rule 2: even digits, split)
999  → 2021976     (rule 3: 999 × 2024)

Result: 1 2024 1 0 9 9 2021976
```

## Digit Splitting Logic

```
num = 1000 (4 digits, even)
str = "1000"
left  = "10" → 10
right = "00" → 0
```

## Algorithm

1. Parse input into list of stone values
2. Repeat 25 times:
   - Apply transformation rules to each stone
   - Build new list (stones may split into two)
3. Return length of final list

## Output

Single integer (count of stones after 25 blinks)
