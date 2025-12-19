# AoC 2024 Day 18, Part 2 - Concise Prompt

## Problem

Find the first byte that, when it falls, makes the path from (0,0) to (70,70) impossible.

## Approach

Continue adding bytes one at a time after the first 1024. Find the first byte that blocks all paths.

## Algorithm Options

### Binary Search + BFS

Binary search on the number of bytes to find the cutoff point.

```python
def path_exists(corrupted_set, size=71):
    # BFS from (0,0) to (size-1, size-1)
    # Return True if path exists, False otherwise
    ...

def find_blocking_byte(bytes_list, size=71):
    lo, hi = 0, len(bytes_list)
    
    while lo < hi:
        mid = (lo + hi) // 2
        corrupted = set(bytes_list[:mid + 1])
        
        if path_exists(corrupted, size):
            lo = mid + 1
        else:
            hi = mid
    
    return bytes_list[lo]  # First blocking byte
```

## Grid Specifications

- **Size:** 71×71 (coordinates 0 to 70)
- **Start:** (0, 0)
- **End:** (70, 70)

## Output Format

Two integers separated by comma: `X,Y`

(No spaces, no parentheses, just the coordinates)

## Output

String in format `X,Y` (coordinates of first blocking byte)
