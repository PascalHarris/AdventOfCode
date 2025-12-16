# AoC 2024 Day 2, Part 1 - Concise Prompt

## Problem

Count how many rows (reports) are "safe". A report is safe if:

1. All adjacent differences have the same sign (all increasing OR all decreasing)
2. Each adjacent difference has absolute value between 1 and 3 (inclusive)

## Algorithm

1. Parse each line as a list of integers
2. For each report, compute adjacent differences
3. Safe if: all differences same sign AND all `1 ≤ |diff| ≤ 3`
4. Count safe reports

## Output

Single integer (count of safe reports)
