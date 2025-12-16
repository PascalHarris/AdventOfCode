# AoC 2024 Day 11, Part 2 - Concise Prompt

## Problem

Same as Part 1, but simulate **75 blinks** instead of 25. Count total stones.

Naive simulation won't work—stones grow exponentially (trillions+ after 75 blinks). 

**Solution:** Stone order doesn't matter for counting. Track **counts per unique value** using a frequency map.

## Transformation Rules (same as Part 1)

1. **If stone = 0** → becomes `1`
2. **If stone has even number of digits** → splits into two stones (left/right halves)
3. **Otherwise** → stone value × 2024

## Optimized Algorithm

```
counts = {stone_value: count} for initial stones

repeat 75 times:
    new_counts = empty map
    for each (value, count) in counts:
        if value == 0:
            new_counts[1] += count
        else if even_digits(value):
            left, right = split(value)
            new_counts[left] += count
            new_counts[right] += count
        else:
            new_counts[value * 2024] += count
    counts = new_counts

return sum of all counts
```

## Why This Works

- Many stones converge to the same values
- Instead of tracking each stone individually, track how many stones have each value
- Each transformation step processes unique values, not individual stones
- Memory stays bounded by number of unique values (not total stones)

## Output

Single integer (count of stones after 75 blinks)
