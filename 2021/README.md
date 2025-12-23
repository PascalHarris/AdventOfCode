# Using Mathematica's Wolfram Language for Advent of Code

[Advent of Code](https://adventofcode.com/)

I like to solve Advent of Code with some obscure or unusual approach each year — and this year I thought I'd try using Mathematica's Wolfram Language. Originally designed for symbolic computation and mathematics, Wolfram has evolved into a remarkably broad programming language with built-in knowledge and algorithms for almost everything imaginable. Let's see how we get on.

## The Pros

### 1. Absurdly Rich Built-In Functionality
Wolfram Language has functions for nearly everything:

- **Graph theory** — `FindShortestPath`, `GraphDistance`, `ConnectedComponents`
- **Combinatorics** — `Permutations`, `Subsets`, `Tuples`, `IntegerPartitions`
- **Number theory** — `PrimeQ`, `Divisors`, `GCD`, `ChineseRemainder`
- **String manipulation** — `StringCases`, `StringReplace`, regex-like patterns
- **Geometry** — `ConvexHullMesh`, `RegionIntersection`, computational geometry primitives
- **Cryptography** — `Hash` supports MD5, SHA, and many more out of the box

For Advent of Code, this is incredibly powerful. Problems that require implementing Dijkstra's algorithm or MD5 hashing from scratch in other languages are one-liners in Wolfram.

### 2. Pattern Matching Is Magical
Wolfram's pattern matching is extraordinarily expressive:

```mathematica
(* Parse "move 3 from 1 to 5" *)
"move 3 from 1 to 5" // StringCases[
  "move " ~~ n:DigitCharacter.. ~~ " from " ~~ s:DigitCharacter ~~ " to " ~~ d:DigitCharacter :>
  {ToExpression[n], ToExpression[s], ToExpression[d]}
]

(* Destructure and transform lists *)
{a_, b_, c_} :> a + b + c
```

Complex parsing that would require regex and multiple transformation steps elsewhere often becomes a single elegant expression.

### 3. Functional Programming
The language is designed for functional programming:

- **Pure functions**: `# + 1 &` or `Function[x, x + 1]`
- **Mapping**: `Map`, `Apply`, `Thread`, `MapIndexed`
- **Folding**: `Fold`, `FoldList`, `NestWhile`, `FixedPoint`
- **Selection**: `Select`, `Cases`, `Pick`, `DeleteCases`

Chaining transformations with `//` (postfix notation) creates readable pipelines:

```mathematica
input // StringSplit[#, "\n"] & // Map[ToExpression] // Total
```

It's a great learning experience for an old C die-hard like me.

### 4. Built-In Visualisation
For grid-based puzzles, visualisation is trivial:

```mathematica
ArrayPlot[grid]
Graph[edges, VertexLabels -> "Name"]
ListAnimate[frames]  (* Animate your BFS exploration! *)
```

This makes debugging spatial puzzles delightful — you can see what's happening.

### 5. Arbitrary Precision Arithmetic
No integer overflow, ever:

```mathematica
2^1000  (* Works perfectly, returns all 302 digits *)
123456789012345678901234567890 * 987654321098765432109876543210  (* No problem *)
```

For puzzles involving large numbers or modular arithmetic, this eliminates an entire class of bugs.

### 6. Interactive Notebook Environment
Mathematica notebooks provide:

- Immediate feedback on every expression
- Rich formatting of results (matrices, graphs, images)
- Easy experimentation and iteration
- Documentation accessible with `?FunctionName`

### 7. Excellent String and List Handling
Operations that are verbose elsewhere are concise:

```mathematica
(* Split string into grid of characters *)
Characters /@ StringSplit[input, "\n"]

(* Transpose, rotate, flip *)
Transpose[grid]
Reverse[grid]        (* Flip vertically *)
Reverse /@ grid      (* Flip horizontally *)
RotateLeft[grid, n]  (* Cycle rows *)

(* Count occurrences *)
Counts[list]         (* Returns association: element -> count *)
```

## The Cons

### 1. Proprietary and Expensive
The elephant in the room:

- Mathematica usually requires an exceedingly expensive commercial license.  That said, Mathematica is also supplied with every Raspberry Pi - so get a cheap, perpetual, Mathematica license for a couple of tens of pounds, with a free computer thrown in!
- Free alternatives exist (Wolfram Engine, Wolfram Cloud free tier) but with limitations.

**Workaround:** Use a Raspberry Pi or the free Wolfram Engine with a Jupyter kernel, or the Wolfram Cloud free tier for experimentation.

### 2. Unconventional Syntax
If you're coming from C-family languages, Wolfram syntax is disorienting:

```mathematica
(* Function application uses square brackets *)
f[x, y]

(* Lists use curly braces *)
{1, 2, 3}

(* Assignment is = but equality testing is == or === *)
x = 5
If[x == 5, "yes", "no"]

(* Indexing is 1-based with double brackets *)
list[[1]]     (* First element *)
list[[-1]]    (* Last element *)
```

**Workaround:** Accept that you're learning a different paradigm. The payoff in expressiveness is worth it.

### 3. Performance Can Be Unpredictable
Wolfram prioritises flexibility over speed:

- Symbolic computation overhead for simple numeric operations
- Pattern matching can be slow on large data
- Some built-in functions are surprisingly inefficient

**Workarounds:**
- Use `Compile` for tight numeric loops
- Prefer vectorised operations over explicit loops
- Use `Association` (hash maps) for O(1) lookups instead of searching lists

```mathematica
(* Slow: *)
Do[result = f[i], {i, 1000000}]

(* Fast: *)
cf = Compile[{{n, _Integer}}, (* body *)];
cf[1000000]
```

### 4. Error Messages Are Cryptic
When things go wrong, Wolfram's error messages are often unhelpful:

```
Part::partw: Part 5 of {1,2,3} does not exist.
(* Okay, but WHERE in my code? *)

StringCases::strse: String or list of strings expected at position 1 in StringCases[Null, ...].
(* Which input caused Null? Who knows! *)
```

**Workaround:** Liberal use of `Echo` for debugging, and break complex expressions into smaller pieces.

### 5. 1-Based Indexing Traps
Coming from 0-indexed languages, off-by-one errors abound:

```mathematica
list[[0]]     (* Returns the HEAD of the expression, not the first element! *)
list[[1]]     (* First element *)
```

Grid coordinates and modular arithmetic require constant mental adjustment.

### 6. Mutable State Is Awkward
Wolfram discourages mutation, which is usually good but occasionally painful:

```mathematica
(* No easy "update dictionary at key" syntax *)
assoc = <|"a" -> 1|>;
assoc["a"] = 2;          (* This works but feels un-Wolfram *)
assoc = <|assoc, "a" -> 2|>;  (* More idiomatic but creates new object *)
```

For puzzles requiring lots of state updates, the functional approach can feel forced.

### 7. No Easy Standalone Executables
You can't easily distribute solutions as runnable programs:

- Recipients need Mathematica or Wolfram Engine installed
- No simple "compile to binary" option
- Notebook format isn't universally readable (no matter - save as Wolfram Language (.wl) files instead)

### 8. Limited Community for Competitive Programming
While Mathematica has a devoted user base:

- Fewer AoC solutions posted in Wolfram than Python or JavaScript
- Stack Overflow coverage skews toward mathematical applications
- Niche tricks and idioms are less documented
- It's hard to get help on solutions!

## Effective Patterns for AoC in Wolfram

### The File Input Pattern
Standard puzzle input handling:

```mathematica
input = Import["input.txt", "String"] // StringTrim;
lines = StringSplit[input, "\n"];
(* Or for numeric input: *)
numbers = ToExpression /@ lines;
```

### The Grid Pattern
For 2D puzzle grids:

```mathematica
grid = Characters /@ StringSplit[input, "\n"];
{height, width} = Dimensions[grid];

(* Access with 1-based coordinates *)
grid[[row, col]]

(* Find positions of specific characters *)
Position[grid, "#"]
```

### The Graph Pattern
For pathfinding puzzles:

```mathematica
edges = {1 -> 2, 2 -> 3, 3 -> 4, 1 -> 4};
g = Graph[edges];

FindShortestPath[g, 1, 4]
GraphDistance[g, 1, 4]
ConnectedComponents[g]
```

### The Memoisation Pattern
For dynamic programming:

```mathematica
solve[args_] := solve[args] = (* expensive computation *)

(* The pattern solve[args_] := solve[args] = ... caches results automatically *)
```

### The State Evolution Pattern
For simulations:

```mathematica
step[state_] := (* compute next state *)
result = Nest[step, initialState, 100];  (* Run 100 steps *)

(* Or until a condition is met: *)
result = NestWhile[step, initialState, !terminationQ[#] &];

(* Keep all intermediate states: *)
allStates = NestList[step, initialState, 100];
```

### The Coordinate Neighbours Pattern
For grid traversal:

```mathematica
neighbors4 = {{-1, 0}, {1, 0}, {0, -1}, {0, 1}};
neighbors8 = Tuples[{-1, 0, 1}, 2] // DeleteCases[{0, 0}];

getNeighbors[{r_, c_}] := {r, c} + # & /@ neighbors4
```

### The Parsing Pattern
For structured input:

```mathematica
(* Regex-style extraction *)
StringCases["Game 1: 3 blue, 4 red", 
  "Game " ~~ id:DigitCharacter.. ~~ ": " ~~ rest__ :> {ToExpression[id], rest}]

(* Split and convert *)
StringSplit["1,2,3,4", ","] // ToExpression  (* {1, 2, 3, 4} *)
```

## Final Verdict

**Should you use Wolfram Language for Advent of Code?**

If you want *maximum accessibility* or *minimal cost*: **Probably not.**, and for the reasons discussed above (but seriously, just get yourself a Raspberry Pi!).

If you want *elegant solutions*, enjoy *functional programming*, or want to leverage *unmatched built-in algorithms*: **Absolutely yes!** Just be prepared to:

1. Invest time learning the unconventional syntax
2. Use `Compile` or vectorised operations when performance matters
3. Build up fluency with the pattern-matching system

The real joy of Wolfram for AoC is how often a puzzle that sounds complex — "find the shortest path through a weighted graph" or "compute the MD5 hash until you find one starting with five zeroes" — becomes a single function call. When the language has a built-in for exactly what you need, it feels like cheating. When it doesn't, you have one of the most expressive functional languages ever designed to build your solution.
