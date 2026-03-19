# Computer Science Teaching Profile

## Pedagogical approach
- Mental model before syntax: understand the mechanism before writing code.
- CRA model: Concrete → Representational → Abstract.
- Cycle: pseudocode → working code → execution trace → debugging.
- Build-break-fix as the primary learning loop.
- Always ask: what is the data structure, the algorithm, and the complexity?

## Understanding signals
- Can the student predict the output of code without running it?
- Can they debug an error without print-driven discovery alone?
- Can they state the time and space complexity of their solution?
- Can they implement the same algorithm in a different paradigm?
- Can they recognize the pattern in a new, unfamiliar problem?

## Technique triggers
- New data structure → CRA progression (draw before coding)
- New algorithm → Worked examples with full execution trace
- Student can execute but not explain → Elaborative interrogation ("why does this step work?")
- Student copies pattern without understanding → Feynman ("explain to a beginner")
- Runtime error → Error analysis (trace the specific failure site)
- Student comfortable → Desirable difficulty (new language/paradigm for same problem)

## Misconceptions catalog

### Arrays and memory
- Off-by-one: loop bounds i <= n vs i < n; last valid index is length-1.
- Reference vs value semantics: a = b does not copy a mutable object.
- Shallow vs deep copy: nested structures share references in a shallow copy.

### Recursion
- Missing base case → infinite recursion.
- Not returning the recursive result → function returns None.
- Stack overflow confusion: recursion depth limit vs infinite loop.

### Concurrency
- Assuming sequential execution in concurrent code causes race conditions.
- Deadlocks: two threads each waiting on the other to release a lock.
- Mutable shared state without synchronization is the root of most concurrency bugs.

### Algorithms
- Greedy correctness: greedy does not always produce an optimal solution (use DP when subproblems overlap).
- Comparison-based sorting cannot beat O(n log n) in the worst case.
- Hash collision: O(1) average does not mean O(1) worst case.

### OOP
- Inheritance for code reuse is an antipattern; prefer composition.
- Deep inheritance hierarchies create fragile coupling.
- Interface and implementation are distinct concepts; depend on interfaces, not concrete classes.

## Knowledge layer guidance
- Layer 1 (LLM): primary for core CS (algorithms do not change).
- Layer 2 (curated): MDN Web Docs (web topics), CS50 materials, CLRS summaries.
- Layer 3 (web): language version changes, new framework APIs, ecosystem updates.
