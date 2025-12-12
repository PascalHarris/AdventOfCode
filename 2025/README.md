# Using AppleScript for Advent of Code: 2025

[Advent of Code 2025](https://adventofcode.com/2025) 

I like to solve Advent of Code with some obscure language each year - and this year I thought of several options including 68000 assembly language (I think I'm a bit too rusty for all but the simplest puzzles) and HyperTalk. For a while, HyperTalk (the programming language used by HyperCard) was the most appealling option, but the thought of the length of time required for a vintage Mac to crunch its way through an Advent of Code puzzle put me off the idea. Which only left one obscure option in my mind…

AppleScript. AppleScript is a close relation to HyperTalk, and is designed to script all applications on MacOS. It's the most powerful desktop operating system automation language that I can think of - but it is neither designed for, nor very good at, heavy data manipulation. So let's see how we get on.

## The Pros

### 1. It's Fun and Unique!
Let's be honest — there's a certain charm to solving coding puzzles in a language that was designed for automating Mac applications, not competitive programming. If you enjoy a challenge AppleScript definitely makes things interesting.

### 2. Excellent macOS Integration
- Built-in file dialogs (`choose file`) make input handling easy
- Native `display dialog` for showing results
- No installation required on any Mac newer than about 1993

### 3. Access to Objective-C via AppleScript-ObjC Bridge
This is genuinely powerful. Through the `use framework "Foundation"` directive, you get access to:

- **NSDecimalNumber** for arbitrary-precision arithmetic (essential for large numbers)
- **NSMutableArray** and **NSMutableDictionary** for O(1) indexed access and hash maps
- **NSSortDescriptor** for efficient sorting
- **NSRegularExpression** for pattern matching
- **NSTask** for running external programs

### 4. Readable Syntax
AppleScript's English-like syntax can make certain algorithms quite readable:

```applescript
repeat with child in childList
    set totalPaths to totalPaths + countPaths(child)
end repeat
```

## The Cons

### 1. Reserved Word Minefield 🚨
AppleScript has an enormous number of reserved words that will cause cryptic errors:

- `result` — Cannot use as a variable name
- `number`, `numbers` — Reserved
- `count` — Conflicts with the `count` command
- `end` — Reserved (problematic in dictionary keys)
- `launch` — Requires escaping as `|launch|()` when calling Objective-C methods
- `return` inside certain blocks can cause "Expected expression but found command name"

**Workaround:** Constantly rename variables (`result` → `resultVal`, `numbers` → `numList`, `count` → `cnt`) and escape method names with pipes.

### 2. Integer Overflow with No Warning
AppleScript silently converts large integers to scientific notation:

```applescript
set x to 97813 * 50305
-- Returns 4.921445065E+9 instead of 4921445065
```

**Workaround:** Use `NSDecimalNumber` for any multiplication that might exceed ~10^9, which adds significant verbosity.

### 3. Abysmal Performance
Native AppleScript is extraordinarily slow for computational tasks:

- Nested loops over thousands of items can take minutes or time out
- List operations are O(n) for indexed access in many cases
- No native bitwise operators

**Workarounds:**

- Use `NSMutableArray` instead of native lists for O(1) access
- Implement bit operations manually (`bitXor`, `bitAnd` handlers)
- For truly intensive computation, compile and run Objective-C programs via `NSTask`

### 4. NSString/Text Coercion Nightmares
Converting between NSString objects and AppleScript text is fragile:

```applescript
-- This often fails:
set myText to someNSString as text

-- This sometimes works:
set myText to (someNSString's stringByTrimmingCharactersInSet:(current application's NSCharacterSet's whitespaceCharacterSet())) as text

-- This is more reliable:
set myText to (someNSArray as list)
```

**Workaround:** Convert NSArrays to AppleScript lists early, avoid round-tripping between NSString and text.

### 5. Limited Data Structures
No native support for:

- Sets (use `NSMutableSet`)
- Hash maps (use `NSMutableDictionary`)
- Queues, stacks, heaps (implement yourself or use Foundation classes)

### 6. Cryptic Error Messages
Errors like "Can't make «class ocid» id «data optr0000000048BF430302000000» into type text" give you almost no information about what went wrong or where.

### 7. No Native Bitwise Operations
For puzzles involving XOR, AND, OR on bits (common in AoC), you must implement these yourself:

```applescript
on bitXor(a, b)
    set xorResult to 0
    set place to 1
    repeat while a > 0 or b > 0
        if (a mod 2) is not (b mod 2) then
            set xorResult to xorResult + place
        end if
        set a to a div 2
        set b to b div 2
        set place to place * 2
    end repeat
    return xorResult
end bitXor
```

### 8. The 2^n Gotcha
The `^` operator returns a real number, not an integer:

```applescript
set x to 2 ^ 10  -- Returns 1024.0, not 1024
```

**Workaround:** Write a custom `powerOf2` handler using multiplication.

## Final Verdict

**Should you use AppleScript for Advent of Code?**

If you're looking for the *fastest* or *easiest* path to solutions: **No.** Python, JavaScript, and traditional compiled languages will serve you far better.

If you enjoy unique challenges, want to deeply understand the macOS scripting ecosystem, or just want bragging rights for solving puzzles in an unconventional language: **Absolutely yes!** Just be prepared to:

1. Lean heavily on the Foundation framework
2. Occasionally shell out to compiled Objective-C for performance-critical sections
3. Maintain a mental list of reserved words to avoid
4. Exercise patience with cryptic errors