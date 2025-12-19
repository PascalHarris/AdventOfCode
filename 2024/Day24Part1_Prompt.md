# AoC 2024 Day 24, Part 1 - Concise Prompt

## Problem

Simulate a circuit of logic gates. Compute the decimal value formed by all `z` wires (z00 is LSB).

## Input Format

```
x00: 1
x01: 0
y00: 1

a AND b -> c
d XOR e -> f
g OR h -> z00
```

- Section 1: Initial wire values (`wire: 0` or `wire: 1`)
- Blank line separator
- Section 2: Gate definitions (`input1 OP input2 -> output`)

## Gates

| Gate | Output |
|------|--------|
| AND  | 1 if both inputs are 1, else 0 |
| OR   | 1 if either input is 1, else 0 |
| XOR  | 1 if inputs differ, else 0 |

## Algorithm

```python
def solve(initial_values, gates):
    wires = dict(initial_values)  # wire_name -> value
    
    # Parse gates: [(in1, op, in2, out), ...]
    pending = list(gates)
    
    while pending:
        made_progress = False
        remaining = []
        
        for in1, op, in2, out in pending:
            if in1 in wires and in2 in wires:
                a, b = wires[in1], wires[in2]
                
                if op == 'AND':
                    wires[out] = a & b
                elif op == 'OR':
                    wires[out] = a | b
                elif op == 'XOR':
                    wires[out] = a ^ b
                
                made_progress = True
            else:
                remaining.append((in1, op, in2, out))
        
        pending = remaining
        
        if not made_progress and pending:
            raise Exception("Stuck - circular dependency?")
    
    # Collect z wires and form binary number
    z_wires = sorted([w for w in wires if w.startswith('z')], reverse=True)
    binary = ''.join(str(wires[w]) for w in z_wires)
    
    return int(binary, 2)
```

## Output

Single integer (decimal value from z wires, z00 is LSB)
