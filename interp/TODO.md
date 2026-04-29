# TODO


### Interpreter / Execution 
- Shorten Overall Code Length - Seems Excessive for a Small Language


### Execution Efficiency
 - Execution Speed Benchmark Framework
 - Execuion Memory Metrics Report
 - AST Visualisation
 - Memory Visualisation
 

### Loop syntax — DONE
- `~{ body }` — infinite loop block; repeats until `\` is executed
- `\` — break/escape; lexically scoped to enclosing `~{ }`, parse-time enforced
- `!` — logical NOT (prefix unary); `!x`, `!!(x)` etc.
- `\` inside a callable defined inside `~{ }` is a parse error (loop_depth_ reset on callable entry)
- `BreakSignal` C++ exception thrown by `\`, caught at `~{ }` boundary (mirrors `ReturnSignal`)

```
~{ ? !cond { \ }  body }     // while
~{ body  ? !cond { \ } }     // do-while
~{ body }                     // infinite
```

### Bare block `{ }` as zero-arg callable (COULD LATER)
- A `{ body }` in expression position with no leading param list is sugar for `() { body }`
- Makes `func_name = { code }` a callable, invoked as `func_name()`
- Currently `{ }` is always parsed as a hash literal — parser needs to distinguish

### Lazy boolean operators `&` and `|`
- Add `&` (logical AND) and `|` (logical OR) as proper infix operators
- `a & b` desugars to `? a { b } { 0 }` — short-circuits, no call-frame overhead
- `a | b` desugars to `? a { 1 } { b }` — short-circuits
- Precedence: `|` below `&`, both below `!`, above comparison
- Replaces the `logic.and` / `logic.or` callable workaround for hot paths

### Tail-call optimisation (TCO)
- The interpreter currently uses the C++ call stack for recursion
- Deep recursion (e.g. `range(1, 10000)`) will stack overflow
- Options: trampoline in `call_callable`, or explicit continuation passing
- Intentionally deferred — only needed if large recursion depths become a use case

### Enforce immutability at runtime (MUST LATER)
- `DeclStmt` already carries `is_mutable` flag but the interpreter does not enforce it
- `set()` on an immutable binding should throw `RuntimeError`
- Requires tracking mutability in `Environment` alongside the value

### Output / stdio design (decide and implement)

Current `printf_s`/`printf_i` are problematic. Type already encoded in the name, format string adds no value. Three options to choose from:

  1. **Simple:** bind `puts(str)` for strings + a thin C wrapper `print_int(int)` — callers never see a format string
  2. **Better:** full varargs `printf(fmt, ...)` FFI support — useful when padding/alignment/precision matter
  3. **Current:** `printf_i("%d\n", n)` style — neither simple nor powerful. Fix this.

### Localisation — three-layer architecture

VO has no reserved words and symbol-only syntax, making it uniquely suited to full natural-language localisation. The goal is to separate three concerns cleanly:

```
1. Source (community symbols) → symbol table → canonical AST
2. Canonical AST → interpreter
3. Interpreter errors → error template table → community-language diagnostics
```

**Layer 1 — Configurable symbol table (lexer)**
- Move operator mappings out of the hardcoded lexer into an external table (JSON or similar)
- Communities remap any canonical symbol to any UTF-8 glyph (e.g. `?` → `если`, `:=` → `≔`)
- Loaded at startup; falls back to built-in defaults if absent
- Decide which symbols are fixed structural delimiters (braces, parens, comma) vs remappable

**Layer 2 — UTF-8 support (lexer + runtime)**
- Lexer currently treats source as raw bytes; multi-byte sequences may be mishandled
- Identifiers may contain UTF-8 characters (non-ASCII variable/function names)
- String literals preserve UTF-8 content correctly
- Line/column tracking counts Unicode codepoints, not bytes
- Operator glyphs in the symbol table may themselves be multi-byte
- Approach: decode source to codepoints before lexing, or UTF-8-aware character classification

**Layer 3 — Error message templates (runtime)**
- Externalise all `RuntimeError` and `ParseError` strings into a template table
- Templates must support:
  - Argument reordering (Arabic, Japanese, Turkish word order)
  - Gender agreement metadata
  - Plural forms (Russian 4 forms, Arabic 6 forms)
  - RTL/LTR direction hints
- Consider Mustache-style templates for community accessibility
- Library options: mstch, kainjow/mustache, or std::format (C++20)


### Visitor-style dispatch (refactor)
- Replace `dynamic_cast` chains in `Interpreter::eval` / `Interpreter::exec` with a proper visitor pattern
- Introduce AST visitor interfaces for expressions and statements
- Add `accept(...)` methods to all AST node types
- Migrate incrementally, keep behaviour parity with existing tests
- Remove dynamic-cast chains once all nodes dispatch through visitors
- Goal: clearer extension path and stronger compile-time coverage when adding AST nodes
- Intentionally deferred until feature set is more stable