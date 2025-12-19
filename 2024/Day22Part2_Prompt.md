# AoC 2024 Day 22, Part 2 - Concise Prompt

## Problem

Find the 4-change sequence that maximizes total bananas across all buyers. Each buyer sells at the **first** occurrence of the sequence.

## Definitions

- **Price:** `secret % 10` (ones digit)
- **Change:** difference between consecutive prices
- **Sequence:** 4 consecutive changes (e.g., `-2,1,-1,3`)

## Rules

- Generate 2000 secrets per buyer (2000 price changes)
- Each buyer sells **once** at the **first** occurrence of your chosen sequence
- If sequence never occurs for a buyer, get 0 bananas from them
- Same sequence used for all buyers
- Goal: maximize total bananas

## Algorithm

```python
from collections import defaultdict

def solve(initial_secrets):
    # Track total bananas for each possible 4-change sequence
    sequence_totals = defaultdict(int)
    
    for initial in initial_secrets:
        # Generate all 2001 prices (initial + 2000 more)
        prices = []
        secret = initial
        prices.append(secret % 10)
        
        for _ in range(2000):
            secret = next_secret(secret)
            prices.append(secret % 10)
        
        # Calculate changes
        changes = [prices[i+1] - prices[i] for i in range(len(prices)-1)]
        
        # For this buyer, find first occurrence of each 4-change sequence
        seen = set()
        for i in range(len(changes) - 3):
            seq = (changes[i], changes[i+1], changes[i+2], changes[i+3])
            if seq not in seen:
                seen.add(seq)
                # Price at position i+4 (after 4 changes)
                price = prices[i + 4]
                sequence_totals[seq] += price
    
    # Return maximum total
    return max(sequence_totals.values())
```

## Change Values

Changes range from -9 to +9 (price goes from 0-9).

Possible sequences: approximately 19^4 ≈ 130,000 combinations.

## Output

Single integer (maximum bananas obtainable)
