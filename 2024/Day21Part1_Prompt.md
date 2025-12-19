# AoC 2024 Day 21, Part 1 - Concise Prompt

## Problem

Find the shortest sequence of button presses through a chain of 3 robots to type codes on a numeric keypad. Calculate sum of complexities.

## Keypad Layouts

**Numeric Keypad (door):**
```
+---+---+---+
| 7 | 8 | 9 |
+---+---+---+
| 4 | 5 | 6 |
+---+---+---+
| 1 | 2 | 3 |
+---+---+---+
    | 0 | A |
    +---+---+
Gap at bottom-left
```

**Directional Keypad (robots & you):**
```
    +---+---+
    | ^ | A |
+---+---+---+
| < | v | > |
+---+---+---+
Gap at top-left
```

## Chain of Control

```
You → Directional Keypad → Robot 1
Robot 1 → Directional Keypad → Robot 2  
Robot 2 → Directional Keypad → Robot 3
Robot 3 → Numeric Keypad → Door Code
```

- **3 layers of directional keypads** (you + 2 robots)
- **1 numeric keypad** (final robot)
- All arms start pointing at 'A'
- **Never pass over the gap** (causes panic)

## Movement Rules

- `^v<>` = move arm in that direction
- `A` = press the button currently aimed at
- Arm must never point at the gap

## Algorithm

### Step 1: Precompute Optimal Paths

For each keypad, precompute shortest paths between all button pairs that avoid the gap.

```python
# Numeric keypad positions
num_pos = {
    '7': (0,0), '8': (0,1), '9': (0,2),
    '4': (1,0), '5': (1,1), '6': (1,2),
    '1': (2,0), '2': (2,1), '3': (2,2),
                '0': (3,1), 'A': (3,2)
}
num_gap = (3, 0)

# Directional keypad positions
dir_pos = {
                '^': (0,1), 'A': (0,2),
    '<': (1,0), 'v': (1,1), '>': (1,2)
}
dir_gap = (0, 0)
```

### Step 2: Generate Move Sequences

To move from button A to button B:
- Calculate row/col differences
- Generate moves (e.g., `^^>` or `>^^`)
- Filter paths that cross the gap
- Choose path that minimizes expansion at next level

### Step 3: Recursive Expansion with Memoization

```python
@lru_cache
def min_length(sequence, depth):
    if depth == 0:
        return len(sequence)
    
    total = 0
    current = 'A'  # always start at A
    for target in sequence:
        moves = get_moves(current, target, keypad_type)
        # moves ends with 'A' to press the button
        total += min_length(moves, depth - 1)
        current = target
    
    return total
```

### Step 4: Calculate Complexity

```python
complexity = min_sequence_length * numeric_value_of_code
total = sum(complexity for each code)
```

- When choosing between equivalent-length paths (e.g., `>^^` vs `^^>`), prefer the one that expands shorter at the next level
- Common heuristic: prefer `<` before `^v`, prefer `^v` before `>`
- Always append `A` after movement to press the button

## Output

Single integer (sum of complexities for all codes)
