# AoC 2024 Day 3, Part 1 - Concise Prompt

## Problem

Find all valid `mul(X,Y)` instructions in corrupted text and sum their products.

**Valid `mul` format:**
- Exactly: `mul(` + 1-3 digit number + `,` + 1-3 digit number + `)`
- No spaces, no extra characters
- Invalid examples: `mul(4*`, `mul(6,9!`, `mul ( 2 , 4 )`

## Algorithm

1. Use regex to find all matches of pattern: `mul\((\d{1,3}),(\d{1,3})\)`
2. For each match, multiply the two captured numbers
3. Sum all products

## Output

Single integer (sum of all valid multiplications)
