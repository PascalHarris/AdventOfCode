# Using HTML5 for Advent of Code: 2015

[Advent of Code 2015](https://adventofcode.com/2015)

I like to solve Advent of Code with some obscure or unusual approach each year — and this year I thought I'd try using pure HTML5 with JavaScript. No Node.js, no npm packages, no build tools — just a single HTML file you can open in any browser. It's the most universally accessible programming environment imaginable, but is it actually good for competitive programming puzzles? Let's see how we get on.

## The Pros

### 1. Zero Setup Required
Literally anyone with a web browser can run your solutions:

- No installation, no dependencies, no PATH variables
- Works on Windows, Mac, Linux, ChromeOS, even phones
- Share solutions as a single file that just works
- Built-in syntax highlighting in any code editor

### 2. Excellent Interactive Debugging
Browser DevTools are genuinely world-class:

- **Console** for immediate feedback and REPL-style experimentation
- **Breakpoints** with variable inspection and call stack navigation
- **Performance profiling** to identify bottlenecks
- **Memory analysis** for tracking down leaks in long-running solutions

### 3. Visual Output for Free
Unlike terminal-based solutions, you can easily add:

- Progress indicators that don't block execution
- Visualisations of grid-based puzzles
- Interactive controls to step through algorithms
- Styled output that's actually pleasant to look at

### 4. Modern JavaScript Is Actually Good
ES6+ provides solid tools for puzzle-solving:

- **Sets and Maps** with O(1) lookup — essential for AoC
- **Destructuring** for clean coordinate handling: `const [x, y] = point`
- **Arrow functions** for concise callbacks
- **Template literals** for readable string building
- **BigInt** for arbitrary-precision integers when needed
- **Spread operator** for array manipulation

### 5. File Input via File Picker
The HTML5 File API makes input handling elegant:

```javascript
const reader = new FileReader();
reader.onload = (e) => solve(e.target.result);
reader.readAsText(file);
```

No hardcoded paths, no command-line arguments — just click, select, and solve.

### 6. Non-Blocking Computation
For intensive puzzles, you can yield to the UI:

```javascript
function processBatch() {
    // Do 10,000 iterations
    if (!done) setTimeout(processBatch, 0);
}
```

This keeps the browser responsive and allows progress updates — something that's surprisingly difficult in many languages.

## The Cons

### 1. No Native File System Access
You cannot simply read `input.txt` from the same directory:

- `fetch()` requires a web server due to CORS restrictions
- Local `file://` URLs are blocked for security
- Must use file picker or paste input manually

**Workaround:** Embrace the file picker — it's actually more user-friendly for sharing solutions with others.

### 2. Missing Standard Library Functions
Things you'd take for granted elsewhere require manual implementation:

- **MD5/SHA hashing** — Web Crypto API doesn't support MD5; need a pure JS implementation
- **Priority queues/heaps** — must implement yourself or find a library
- **Combinatorics** — no built-in permutations, combinations, etc.

**Workaround:** Build up a personal library of utility functions as you progress through puzzles.

### 3. Floating-Point Precision Issues
Large integer calculations can lose precision:

```javascript
9007199254740993 === 9007199254740992  // true (!)
```

**Workaround:** Use `BigInt` for numbers exceeding 2^53, but remember you can't mix BigInt with regular numbers without explicit conversion.

### 4. Single-Threaded Execution
Heavy computation blocks everything:

- UI freezes during long calculations
- No easy parallelisation without Web Workers
- Web Workers add complexity (separate files, message passing)

**Workaround:** Batch processing with `setTimeout` yields to the UI, but adds overhead and complexity.

### 5. String Immutability Performance
Building strings character-by-character is inefficient:

```javascript
// Slow: creates new string each iteration
for (let i = 0; i < 100000; i++) {
    result += chars[i];
}

// Fast: join array at the end
const parts = [];
for (let i = 0; i < 100000; i++) {
    parts.push(chars[i]);
}
result = parts.join('');
```

### 6. No Built-in Memoisation
For recursive dynamic programming solutions, you must implement your own caching:

```javascript
const memo = new Map();
function solve(state) {
    const key = JSON.stringify(state);
    if (memo.has(key)) return memo.get(key);
    const result = /* ... */;
    memo.set(key, result);
    return result;
}
```

### 8. Array Performance Gotchas
JavaScript arrays are objects, not contiguous memory:

- Sparse arrays can have surprising performance characteristics
- `Array(1000000)` doesn't actually allocate memory
- Typed arrays (`Uint32Array`, etc.) are faster but less flexible

## Effective Patterns for AoC in HTML5

### The File Picker Pattern
Standard input handling:

```javascript
document.getElementById('fileInput')
    .addEventListener('change', (e) => {
        const reader = new FileReader();
        reader.onload = (e) => solve(e.target.result.trim());
        reader.readAsText(e.target.files[0]);
    });
```

### The Coordinate Key Pattern
For grid-based puzzles, encode coordinates as strings:

```javascript
const visited = new Set();
visited.add(`${x},${y}`);
if (visited.has(`${nx},${ny}`)) { /* ... */ }
```

### The Batched Processing Pattern
Keep UI responsive during heavy computation:

```javascript
function mine(n = 1) {
    const batchEnd = n + 10000;
    while (n < batchEnd) {
        if (foundAnswer(n)) return displayResult(n);
        n++;
    }
    progressEl.textContent = `Checked ${n}...`;
    setTimeout(() => mine(n), 0);
}
```

### The Grid Parsing Pattern
Convert 2D text input to usable data:

```javascript
const grid = input.split('\n').map(line => line.split(''));
const height = grid.length;
const width = grid[0].length;
const get = (x, y) => grid[y]?.[x];
```

## Final Verdict

**Should you use HTML5 for Advent of Code?**

If you want *maximum performance* or access to *specialised algorithms*: **Probably not.** Python's standard library and C's speed will serve you better for the harder puzzles.

If you want *shareable, visual, universally-runnable solutions* that anyone can use without installing anything: **Absolutely yes!** Just be prepared to:

1. Implement some standard algorithms yourself (or find pure JS libraries)
2. Use the File API instead of direct file system access
3. Batch long-running computations to keep the UI responsive
4. Build up a utility library as you encounter common patterns (as with any programming language)

The real joy of HTML5 for AoC is the accessibility: your solutions become shareable web pages that anyone can run, visualise, and learn from.