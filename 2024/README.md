# Using AI Prompts for Advent of Code: 2024

[Advent of Code 2024](https://adventofcode.com/2024) 

I like to solve Advent of Code with some obscure language each year - and this year I thought I'd try using AI Prompts. AIs are becoming more and more common - to the point where I think that we either need to learn how to use them or risk getting left behind. 

Using an AI assistant to help solve programming puzzles is an approach that trades traditional coding for precise problem specification. Other than that it requires an accurate understanding of the problem (in order to write an accurate prompt), it needs a different mindset than writing code yourself. So let's see how we get on.

## The Pros

### 1. It's Fun and Educational!
It requires the developer to solve the coding puzzle by articulating the problem so clearly that a machine can solve it, which could be useful for anyone who prefers the analytical side of programming more than the typing.

### 2. Instant Access to Algorithms and Data Structures
Through clear prompting, you get access to:

- **Optimized algorithms** without memorizing implementations
- **Hash maps, heaps, graphs** described naturally
- **Dynamic programming** patterns explained and applied
- **Regex and parsing** handled conversationally (and I hate regex, so this is a huge advantage for me)

### 3. Readable Problem Decomposition
Well-crafted prompts force you to understand the problem deeply:

```
1. Parse input into two separate lists
2. Build frequency map of right list
3. Sum: value × count for each left value
```

## The Cons

### 1. The Narrative Trap
Advent of Code problems are wrapped in charming stories that can confuse AI assistants:

- Elves, reindeer, and sleighs obscure the actual algorithm
- Multiple paragraphs of context before the real problem
- Examples buried in prose

**Solution:** Distill problems to pure algorithmic specifications. Strip the narrative, keep only: input format, transformation rules, output format.

### 2. Ambiguity Amplification
Subtle problem details that a human programmer would catch can be missed:

```
"pair up the smallest number in the left list with the smallest"
-- Does this mean sort both lists? Remove after pairing? 
-- The AI might assume incorrectly without explicit instruction.
```

**Workaround:** Include worked examples with intermediate steps. State assumptions explicitly.

### 3. Context Window Limitations
For multi-part problems or large inputs:

- Previous conversation context may be forgotten
- Large input data may need to be summarized or chunked
- Part 2 often builds on Part 1 in ways that require re-explanation

**Workarounds:**

- Keep prompts self-contained with all necessary context
- Reference specific line numbers or data ranges
- Restate key constraints from Part 1 when solving Part 2

### 4. Edge Case Blindness
AI solutions often work for examples but fail on edge cases:

```
-- Example works perfectly:
Input: [3,4,2,1,3,3] and [4,3,5,3,9,3]

-- But what about:
Empty lists? Single elements? Negative numbers?
Numbers larger than 2^31? Duplicate handling?
```

**Workaround:** Explicitly enumerate edge cases in your prompt. Ask "What assumptions are you making?" before running.

### 5. The "Almost Right" Problem
AI-generated code often looks correct but contains subtle bugs:

- Off-by-one errors in loops
- Integer vs. floating-point division
- Sorting stability assumptions
- 0-indexed vs. 1-indexed confusion

### 6. Verification Burden
Unlike writing code yourself, you must verify solutions you don't fully understand:

- Reading generated code takes time
- Debugging someone else's logic is harder
- False confidence from working examples

### 7. No Native Problem Memory
For puzzles that reference previous days or build on earlier concepts:

```
"This uses the same intcode computer from Day 9"
-- AI has no memory of your Day 9 implementation
-- Must re-specify or re-include previous code
```

**Workaround:** Maintain a personal library of reusable components. Include relevant prior code in prompts.

### 8. The Optimization Cliff
Initial solutions may be correct but computationally infeasible:

```
Prompt: "Find all pairs that sum to target"
Response: O(n²) nested loop solution
Reality: Input has 100,000 elements, needs O(n) hash approach
```

**Workaround:** Specify performance requirements upfront. Include input size in your prompt.

## Effective Prompting Patterns

### The Distillation Pattern
Strip narrative to pure algorithm:

```
**Problem:** Two columns of integers → sum of absolute 
differences after sorting both independently.
**Output:** Single integer
```

### The Example-First Pattern
Lead with concrete examples:

```
Input:     After sorting:    Result:
3   4      1   3            |1-3| = 2
4   3      2   3            |2-3| = 1
...        ...              Total: 11
```

### The Constraint Pattern
State boundaries explicitly:

```
- Input: up to 1000 lines
- Values: positive integers < 10^6
- Expected runtime: < 1 second
```

## Final Verdict

**Should you use AI prompts for Advent of Code?**

If you're looking to *learn programming* or *prove your skills*: **Probably not as your primary approach.** The joy of AoC is the struggle and the "aha!" moments that come from working through problems yourself.

If you enjoy problem decomposition, want to explore different solution approaches quickly, or are using it as a learning tool to understand algorithms: **It can be valuable!** Just be prepared to:

1. Invest time in clear, precise problem specification
2. Verify solutions thoroughly before submitting
3. Treat it as a collaboration, not a replacement for understanding
4. Accept that the learning happens in the prompting, not just the answer
