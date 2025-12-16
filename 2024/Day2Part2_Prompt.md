# AoC 2024 Day 2, Part 2 - Concise Prompt

## Problem

Count how many rows (reports) are "safe" with a dampener. A report is safe if:

1. It passes the safety check (Part 1 rules), OR
2. Removing any single element makes it pass the safety check

**Safety check (from Part 1):**
- All adjacent differences have the same sign (all increasing OR all decreasing)
- Each adjacent difference has absolute value between 1 and 3 (inclusive)

## Algorithm

1. Parse each line as a list of integers
2. For each report:
   - If safe by Part 1 rules → count it
   - Else, try removing each element one at a time; if any removal makes it safe → count it
3. Return total count

## Output

Single integer (count of safe reports with dampener)
