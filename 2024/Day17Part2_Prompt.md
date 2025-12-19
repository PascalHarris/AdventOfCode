# AoC 2024 Day 17, Part 2 - Concise Prompt

## Problem

Find the lowest initial value for register A such that the program outputs a copy of itself (a quine).

## Goal

Find minimum `A` where:
```
run_program(A, B=0, C=0) == program
```

## Algorithm: Recursive/BFS Search

Work backwards - find A values that produce the program in reverse:

```python
def find_A(program):
    # Each iteration outputs one value and divides A by 8
    # So we need len(program) iterations
    # Build A 3 bits at a time
    
    def search(target_output, current_A):
        if not target_output:
            return current_A  # Found valid A
        
        # Try adding 3 bits (0-7) to build next portion of A
        for bits in range(8):
            test_A = current_A * 8 + bits
            if test_A == 0:
                continue
            
            output = simulate_one_iteration(test_A)
            if output == target_output[-1]:
                result = search(target_output[:-1], test_A)
                if result is not None:
                    return result
        
        return None
    
    return search(program, 0)
```

## Important Notes

- The answer is typically very large (10^15+ range)
- Must analyze program to solve efficiently
- Solution builds A incrementally, 3 bits at a time
- Multiple valid A values may exist; find the minimum

## Output

Single integer (lowest positive A that makes program output itself)
