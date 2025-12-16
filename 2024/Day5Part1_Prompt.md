# AoC 2024 Day 5, Part 1 - Concise Prompt

## Problem

Given ordering rules and page sequences, find sequences that satisfy all applicable rules, then sum their middle elements.

## Input Format

```
X|Y          ← Rules section: X must appear before Y (if both present)
...

a,b,c,d,e    ← Updates section: comma-separated page sequences
...
```

Sections separated by blank line.

## Rules

- Rule `X|Y` only applies if BOTH X and Y appear in the sequence
- A sequence is valid if all applicable rules are satisfied
- "Middle" = element at index `len/2` (0-indexed, integer division)

## Algorithm

1. Parse rules into set of (before, after) pairs
2. For each update sequence:
   - Check all pairs of pages: if rule exists for pair, verify order
   - If valid: add middle element to sum
3. Return sum

## Validation Check

For sequence `[a, b, c, d, e]`:
- For each pair (pages[i], pages[j]) where i < j:
  - If rule `pages[j]|pages[i]` exists → sequence is INVALID

## Output

Single integer (sum of middle elements from valid sequences)
