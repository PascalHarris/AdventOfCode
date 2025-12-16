# AoC 2024 Day 3, Part 2 - Concise Prompt

## Problem

Find all valid `mul(X,Y)` instructions in corrupted text, but only sum products when multiplication is **enabled**.

**Instructions:**
- `mul(X,Y)` - multiply X and Y (1-3 digits each, no spaces)
- `do()` - enables future `mul` instructions
- `don't()` - disables future `mul` instructions

**Rules:**
- `mul` starts **enabled**
- Only the most recent `do()` or `don't()` applies
- Disabled `mul` instructions are ignored

## Algorithm

1. Use regex to find all matches of: `mul\((\d{1,3}),(\d{1,3})\)`, `do\(\)`, `don't\(\)`
2. Process matches in order of appearance
3. Track enabled state (starts `true`)
4. On `do()`: set enabled = true
5. On `don't()`: set enabled = false
6. On `mul(X,Y)`: if enabled, add X × Y to sum

## Output

Single integer (sum of enabled multiplications)
