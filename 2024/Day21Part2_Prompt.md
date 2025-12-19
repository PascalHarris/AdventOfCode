# AoC 2024 Day 21, Part 2 - Concise Prompt

## Problem

Same as Part 1, but with **25 directional keypad robots** instead of 2. Find sum of complexities.

## Key Change from Part 1

- Part 1: You → 2 robots → numeric keypad (3 directional layers)
- Part 2: You → **25 robots** → numeric keypad (**26 directional layers**)

## Chain of Control

```
You → Directional Keypad → Robot 1 → ... → Robot 25 → Numeric Keypad
```

With 25 layers, sequence lengths grow astronomically. Must use memoization to avoid recomputation.

## Algorithm: Recursive with Memoization

```python
from functools import lru_cache

# Precompute optimal move sequences between buttons for each keypad

@lru_cache(maxsize=None)
def min_presses(from_btn, to_btn, depth, is_numeric=False):
    """Minimum presses to move from from_btn to to_btn and press it."""
    
    if depth == 0:
        # At your level: just count the moves + 'A' press
        return len(get_moves(from_btn, to_btn)) + 1
    
    # Get all valid move sequences from from_btn to to_btn
    move_options = get_all_paths(from_btn, to_btn, is_numeric)
    
    best = float('inf')
    for moves in move_options:
        # Each move sequence ends at button, then press 'A'
        sequence = moves + 'A'
        
        # Expand this sequence through the next layer
        cost = 0
        current = 'A'
        for btn in sequence:
            cost += min_presses(current, btn, depth - 1, is_numeric=False)
            current = btn
        
        best = min(best, cost)
    
    return best

def solve_code(code, num_robots=25):
    """Find minimum presses to type a code with num_robots directional robots."""
    total = 0
    current = 'A'
    
    for btn in code:
        # First layer: numeric keypad
        total += min_presses_numeric(current, btn, num_robots)
        current = btn
    
    return total
```

Instead of expanding full sequences, memoize the cost of each button-to-button transition at each depth:

```python
@lru_cache(maxsize=None)
def cost(from_btn, to_btn, depth):
    """Cost to go from from_btn to to_btn and press it, at given depth."""
```

The state space is small:
- ~5-6 buttons on directional keypad
- ~12 buttons on numeric keypad  
- 26 depth levels
- ~5×5×26 + 12×12×1 = ~800 states total

## Path Selection

When multiple paths exist (e.g., `>^^` vs `^^>`), try all and take minimum. With memoization, this is efficient.

Common heuristic that often works:
- Prefer `<` moves first (leftmost)
- Prefer `v` before `>`
- But must verify with actual expansion

## Complexity Calculation

Same as Part 1:
```
complexity = min_sequence_length × numeric_value_of_code
total = sum(complexity for each code)
```

## Output

Single integer (sum of complexities for all codes with 25 robot layers)
