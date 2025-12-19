# AoC 2024 Day 24, Part 2 - Concise Prompt

## Problem

The circuit should compute `x + y = z` (binary addition). Exactly 4 pairs of gate outputs are swapped. Find and report the 8 swapped wire names.

## Binary Adder Structure

A correct ripple-carry adder for bit `i` looks like:

```
For bit 0:
  z00 = x00 XOR y00
  c00 = x00 AND y00  (carry out)

For bit i > 0:
  sum_i = x_i XOR y_i
  z_i = sum_i XOR c_{i-1}
  carry_and = x_i AND y_i
  carry_prop = sum_i AND c_{i-1}
  c_i = carry_and OR carry_prop
```

## Detection Strategy

### Pattern Matching

Check each bit position for correct adder structure:

```python
def find_swaps(gates):
    swapped = set()
    
    # Build lookup: output -> gate info
    output_to_gate = {}  # wire -> (in1, op, in2)
    
    for bit in range(num_bits):
        x_wire = f"x{bit:02d}"
        y_wire = f"y{bit:02d}"
        z_wire = f"z{bit:02d}"
        
        # Find gates that should exist
        # Check if z_wire has correct structure
        # If not, identify which outputs are wrong
```

## Algorithm Outline

```python
def solve(gates):
    swapped = []
    
    # 1. Parse all gates
    # 2. For each bit position, verify adder structure
    # 3. Identify outputs that violate expected patterns
    # 4. Match up swapped pairs
    
    # Return sorted, comma-joined wire names
    return ','.join(sorted(swapped))
```

## Output Format

8 wire names, sorted alphabetically, comma-separated:
```
aaa,bbb,ccc,ddd,eee,fff,ggg,hhh
```

## Output

String (sorted comma-separated wire names)
