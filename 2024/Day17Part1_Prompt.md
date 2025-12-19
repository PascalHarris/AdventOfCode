# AoC 2024 Day 17, Part 1 - Concise Prompt

## Problem

Simulate a 3-bit computer and collect all output values.

## Input Format

```
Register A: 729
Register B: 0
Register C: 0

Program: 0,1,5,4,3,0
```

## Computer Specification

- **Registers:** A, B, C (arbitrary integers)
- **Program:** list of 3-bit numbers (0-7)
- **Instruction Pointer (IP):** starts at 0, increments by 2 after each instruction (except jumps)
- **Halt:** when IP goes past end of program

## Operand Types

**Literal operand:** value is the operand itself (0-7)

**Combo operand:**
- 0-3 → literal values 0-3
- 4 → value of register A
- 5 → value of register B
- 6 → value of register C
- 7 → reserved (won't appear)

## Instructions

| Opcode | Name | Operation |
|--------|------|-----------|
| 0 | adv | A = A // (2 ^ combo) |
| 1 | bxl | B = B XOR literal |
| 2 | bst | B = combo % 8 |
| 3 | jnz | if A ≠ 0: IP = literal (no IP += 2) |
| 4 | bxc | B = B XOR C (operand ignored) |
| 5 | out | output (combo % 8) |
| 6 | bdv | B = A // (2 ^ combo) |
| 7 | cdv | C = A // (2 ^ combo) |

## Algorithm

```
ip = 0
output = []

while ip < len(program):
    opcode = program[ip]
    operand = program[ip + 1]
    
    combo = operand if operand < 4 else [A, B, C][operand - 4]
    
    if opcode == 0:    # adv
        A = A // (2 ** combo)
    elif opcode == 1:  # bxl
        B = B ^ operand
    elif opcode == 2:  # bst
        B = combo % 8
    elif opcode == 3:  # jnz
        if A != 0:
            ip = operand
            continue   # skip ip += 2
    elif opcode == 4:  # bxc
        B = B ^ C
    elif opcode == 5:  # out
        output.append(combo % 8)
    elif opcode == 6:  # bdv
        B = A // (2 ** combo)
    elif opcode == 7:  # cdv
        C = A // (2 ** combo)
    
    ip += 2

return ','.join(map(str, output))
```

## Output

String of comma-separated output values
