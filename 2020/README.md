# Using Objective-C for Advent of Code

[Advent of Code](https://adventofcode.com/)

I like to solve Advent of Code with some obscure or unusual approach each year — and this year I thought I'd try using Objective-C. Once the main language promoted by Apple (and NeXT) for macOS and iOS development, Objective-C has been superseded by Swift, leaving it in an interesting position: powerful, mature, and well-documented, but increasingly niche. It's a compiled language with access to the entire Foundation framework, and with a syntax that feels familiar to C developers. Let's see how we get on.

## The Pros

### 1. Blazing Fast Execution
As a compiled language, Objective-C produces native binaries:

- Computation-heavy puzzles run in milliseconds, not seconds
- No interpreter overhead or JIT warm-up time
- Predictable performance characteristics
- Easily handles puzzles that would timeout in scripting languages
- Very efficient in its use of memory (in the hands of a competent developer)

### 2. Foundation Framework Is Excellent
Apple's Foundation provides well-proven data structures:

- **NSMutableDictionary** and **NSMutableSet** for O(1) lookups
- **NSMutableArray** with fast enumeration
- **NSRegularExpression** for pattern matching
- **NSString** with comprehensive manipulation methods
- **NSDecimalNumber** for arbitrary-precision arithmetic
- **NSData** and **NSFileHandle** for efficient file I/O

### 3. Automatic Reference Counting (ARC)
Modern Objective-C handles memory management automatically:

- No manual `retain`/`release` in most cases
- Deterministic cleanup (unlike garbage collection)
- Minimal memory overhead for long-running solutions

### 4. Easy Command-Line Compilation
Single-file solutions compile trivially:

```bash
clang -framework Foundation -O2 solution.m -o solution
./solution < input.txt
```

No Xcode project required, no complex build systems.

### 5. Excellent Debugging Tools
LLDB and Instruments provide professional-grade debugging:

- Breakpoints with expression evaluation
- Memory profiling for tracking down leaks
- Time profiling for optimisation
- Address sanitiser for catching buffer overflows

### 6. C Compatibility
When Foundation isn't fast enough, just use pure C:

```objc
// Use C arrays for performance-critical inner loops
int grid[1000][1000] = {0};

// Or mix freely with Foundation
NSMutableArray *results = [NSMutableArray array];
for (int i = 0; i < 1000; i++) {
    [results addObject:@(grid[i][0])];
}
```

### 7. Verbose But Readable
Named parameters make code self-documenting:

```objc
NSRange range = [string rangeOfString:@"pattern"
                              options:NSRegularExpressionSearch
                                range:NSMakeRange(0, string.length)];
```

## The Cons

### 1. Verbosity Overload
Simple operations require significant boilerplate (although this does make the code nicely self-documenting):

```objc
// Reading a file into lines
NSString *content = [NSString stringWithContentsOfFile:@"input.txt"
                                              encoding:NSUTF8StringEncoding
                                                 error:nil];
NSArray *lines = [content componentsSeparatedByString:@"\n"];

// Compare to Python: open("input.txt").readlines()
```

**Workaround:** Build up a personal library of helper functions and macros.

### 2. Primitive Boxing Is Tedious
Foundation collections only hold objects, not primitives:

```objc
// Must wrap integers
[array addObject:@(someInt)];

// And unwrap to use
int value = [array[0] intValue];

// Arithmetic requires unwrapping
int sum = [a intValue] + [b intValue];
```

**Workaround:** Use C arrays for numeric grids, or create helper macros.

### 3. Square Bracket Soup
Nested method calls can become hard to read:

```objc
NSArray *numbers = [[[[content 
    stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
    componentsSeparatedByString:@"\n"]
    filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]]
    sortedArrayUsingSelector:@selector(compare:)];
```

**Workaround:** Break into multiple statements, or use dot notation where available.

### 4. Limited Modern Conveniences
Features common in newer languages are missing:

- No tuple types (use arrays or create structs)
- No optional chaining without explicit nil checks
- No string interpolation (`\(variable)` style)
- Pattern matching is limited to regex

### 5. Declining Community Support
As Swift dominates Apple development:

- Fewer Stack Overflow answers for modern questions
- Documentation increasingly assumes Swift
- Third-party libraries rarely support Objective-C only
- New Foundation APIs sometimes Swift-first
- As an Objective C developer, how long before Apple abandons it altogether?

## Effective Patterns for AoC in Objective-C

### The File Input Pattern
Standard puzzle input handling:

```objc
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSString *input = [NSString stringWithContentsOfFile:@"input.txt"
                                                    encoding:NSUTF8StringEncoding
                                                       error:nil];
        NSArray *lines = [input componentsSeparatedByCharactersInSet:
                          [NSCharacterSet newlineCharacterSet]];
        // Filter empty lines
        NSPredicate *notEmpty = [NSPredicate predicateWithFormat:@"length > 0"];
        lines = [lines filteredArrayUsingPredicate:notEmpty];
        
        // Solve puzzle...
    }
    return 0;
}
```

### The Coordinate Key Pattern
For grid-based puzzles, encode coordinates as strings:

```objc
NSMutableSet *visited = [NSMutableSet set];
NSString *key = [NSString stringWithFormat:@"%d,%d", x, y];
[visited addObject:key];

if ([visited containsObject:key]) {
    // Already visited
}
```

### The Fast Enumeration Pattern
Iterate efficiently over collections:

```objc
for (NSString *line in lines) {
    // Process each line
}

// With index
[lines enumerateObjectsUsingBlock:^(NSString *line, NSUInteger idx, BOOL *stop) {
    // Process with index available
}];
```

### The Regex Parsing Pattern
Extract values from structured input:

```objc
NSRegularExpression *regex = [NSRegularExpression 
    regularExpressionWithPattern:@"(\\d+),(\\d+) through (\\d+),(\\d+)"
                         options:0
                           error:nil];

NSTextCheckingResult *match = [regex firstMatchInString:line
                                                options:0
                                                  range:NSMakeRange(0, line.length)];
if (match) {
    int x1 = [[line substringWithRange:[match rangeAtIndex:1]] intValue];
    int y1 = [[line substringWithRange:[match rangeAtIndex:2]] intValue];
    // ...
}
```

### The C Array Performance Pattern
When Foundation is too slow:

```objc
// Use stack-allocated C array for fixed-size grids
static int grid[1000][1000];
memset(grid, 0, sizeof(grid));

// Much faster than NSMutableArray of NSMutableArrays
for (int y = 0; y < 1000; y++) {
    for (int x = 0; x < 1000; x++) {
        grid[y][x] += 1;
    }
}
```

## Final Verdict

**Should you use Objective-C for Advent of Code?**

If you want *concise code* or *modern language features*: **Probably not.** Swift will feel more natural and require less typing.

If you want *raw performance*, already know Objective-C from iOS/macOS development, or want to explore a historically significant language: **Absolutely yes!** Just be prepared to:

1. Write more boilerplate than you'd like
2. Build up helper functions for common operations
3. Drop down to C for performance-critical sections
4. Enjoy compilation speeds that put Swift to shame

The real strength of Objective-C for AoC is the combination of Foundation's robust data structures with C's raw performance. When you need a hash map for the algorithm but a tight C loop for the inner computation, Objective-C lets you have both in the same file.
