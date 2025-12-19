# AoC 2024 Day 22, Part 1 - Concise Prompt

## Problem

Simulate pseudorandom number generation for each buyer. Sum the 2000th generated secret number for all buyers.

## Input

List of initial secret numbers, one per line.

## Secret Number Evolution

Each step transforms the secret number through 3 operations:

```python
def next_secret(secret):
    # Step 1: multiply by 64, mix, prune
    secret = ((secret * 64) ^ secret) % 16777216
    
    # Step 2: divide by 32 (floor), mix, prune
    secret = ((secret // 32) ^ secret) % 16777216
    
    # Step 3: multiply by 2048, mix, prune
    secret = ((secret * 2048) ^ secret) % 16777216
    
    return secret
```

## Operations

- **Mix:** XOR value into secret (`secret = value ^ secret`)
- **Prune:** Modulo 16777216 (`secret = secret % 16777216`)

Note: 16777216 = 2^24

## Bitwise Equivalent

```python
def next_secret(s):
    s = ((s << 6) ^ s) & 0xFFFFFF   # * 64, mix, prune
    s = ((s >> 5) ^ s) & 0xFFFFFF   # // 32, mix, prune
    s = ((s << 11) ^ s) & 0xFFFFFF  # * 2048, mix, prune
    return s
```

## Algorithm

```python
def get_2000th(initial):
    secret = initial
    for _ in range(2000):
        secret = next_secret(secret)
    return secret

total = sum(get_2000th(s) for s in initial_secrets)
```

## Output

Single integer (sum of 2000th secret numbers)
