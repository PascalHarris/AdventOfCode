# AoC 2024 Day 5, Part 2 - Concise Prompt

## Problem

Find sequences that violate ordering rules, sort them correctly using the rules, then sum their middle elements.

## Input Format

```
X|Y          ← Rules section: X must appear before Y (if both present)
...

a,b,c,d,e    ← Updates section: comma-separated page sequences
...
```

Sections separated by blank line.

## Algorithm

1. Parse rules into set of (before, after) pairs
2. For each update sequence:
   - Check validity (Part 1 logic)
   - If INVALID:
     - Sort using rules as comparator
     - Add middle element of sorted sequence to sum
3. Return sum

## Sorting Approach

Use custom comparator based on rules:
- Compare(a, b): if rule `a|b` exists → a comes before b
- Compare(a, b): if rule `b|a` exists → b comes before a

This is a topological sort constrained to pages in the sequence.

## Output

Single integer (sum of middle elements from corrected invalid sequences)
