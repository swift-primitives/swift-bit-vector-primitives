# Bit Vector Protocol Unification

<!--
---
version: 1.1.0
last_updated: 2026-02-12
status: RECOMMENDATION
tier: 2
---
-->

## Context

`Bit.Vector` has 5 variants (Vector, Bounded, Static, Inline, Dynamic) that share conceptual operations but implement them independently. This creates:

1. **API gaps**: `pop.first()` exists only on base `Bit.Vector` — not on Bounded, Static, Inline, or Dynamic. When `Buffer.Slab.Header` moved from `Bit.Vector` to `Bit.Vector.Bounded`, consume files broke because `pop.first()` was unavailable.

2. **Implementation duplication**: `popcount`, `isEmpty`, `isFull`, `ones`, `subscript`, `clearAll`/`setAll`, and `take` are reimplemented in each variant with near-identical word-scanning logic.

3. **Semantic drift**: `isEmpty` means "all bits false" on Vector/Static but means "_count == .zero" on Bounded/Inline/Dynamic. Consumers (Slab.Header) must work around this.

**Trigger**: Buffer-primitives compilation failure after switching `Slab.Header.bitmap` from `Bit.Vector` to `Bit.Vector.Bounded`. The immediate fix required rewriting consume logic because `Bit.Vector.Bounded` lacked `pop.first()`. This is symptomatic of a deeper problem.

## Question

How should common bit-vector operations be shared across all 5 variants to eliminate duplication and prevent API gaps?

## Constraints

| Constraint | Impact |
|-----------|--------|
| `Bit.Vector` is `~Copyable` | Protocol Self must support `~Copyable` — Swift 6 noncopyable generics are still maturing |
| `Bit.Vector.Static<N>` has value generic | Protocol conformance for generic types works, but associated types may complicate |
| `ones` returns different types per variant | Associated type or generic return needed |
| Property.View pattern (`pop`, `set`, `clear`) | Requires mutable pointer access (`&self`) — protocol must enable this |
| All variants store bits in `UInt` words | Common implementation backbone exists at word level |
| Some operations are variant-specific | `append`/`popLast` only on counted types; `resize` only on Dynamic |
| Consumers use concrete types, not generics | Main benefit is deduplication, not generic consumer code |

## Analysis

### Option A: `Bit.Vector.Protocol` — Full Protocol

Define a protocol with all shared operations as requirements.

```swift
extension Bit.Vector {
    public protocol `Protocol`: ~Copyable {
        subscript(index: Bit.Index) -> Bool { get set }
        var popcount: Bit.Index.Count { get }
        var isEmpty: Bool { get }
        var isFull: Bool { get }
        // ... ones, take, pop.first, etc.
    }
}
```

**Advantages**:
- Clean abstraction — each variant conforms, gets shared behavior
- Enables generic consumer code (`func foo<V: Bit.Vector.Protocol>`)
- Follows existing Swift Institute protocol patterns (Sequence.Consume.Protocol, etc.)

**Disadvantages**:
- `~Copyable` protocol conformance has compiler limitations (existential boxes, protocol extensions with mutating methods)
- `ones` returns different types per variant — needs an associated type or erased return
- `pop.first()` uses Property.View pattern requiring `&self` pointer — hard to express in protocol
- All 5 variants would need explicit conformance declarations
- Protocol witness tables add overhead for `@inlinable` code

### Option B: Word-Access Abstraction

All variants store bits in `UInt` words. Provide a minimal word-access protocol, then implement all derived operations as protocol extensions.

```swift
extension Bit.Vector {
    public protocol WordAccessible: ~Copyable {
        var wordCount: Int { get }
        var bitCapacity: Bit.Index.Count { get }
        subscript(wordAt index: Int) -> UInt { get set }
    }
}

extension Bit.Vector.WordAccessible {
    // All derived operations implemented ONCE:
    public var popcount: Bit.Index.Count { ... }
    public var isEmpty: Bool { ... }
    public var isFull: Bool { ... }
    public subscript(index: Bit.Index) -> Bool { get { ... } set { ... } }
    public var ones: Bit.Vector.Ones<Self> { ... }
    // pop.first() via mutating extension
}
```

**Advantages**:
- Minimal conformance burden — each variant only provides word access (3 requirements)
- All derived operations implemented once in protocol extension
- `popcount`, `isEmpty`, `isFull`, `ones`, `pop.first`, `zeros` all derived from word access
- No associated type complexity for return types
- Generic `Ones<Base>` iterator works for all conforming types

**Disadvantages**:
- Word-level subscript must be efficient — protocol witness overhead could hurt for `@inlinable`
- Still faces `~Copyable` protocol limitations
- Less expressive API surface at the protocol level
- Consumers rarely need to abstract over "any word-accessible bitmap"

### Option C: Static Methods on Shared Namespace

Instead of a protocol, provide static functions on `Bit.Vector` that operate on word buffers directly. Each variant calls these from its own methods.

```swift
extension Bit.Vector {
    @inlinable
    public static func popcount(
        words: UnsafeBufferPointer<UInt>,
        capacity: Bit.Index.Count
    ) -> Bit.Index.Count { ... }

    @inlinable
    public static func popFirst(
        words: UnsafeMutableBufferPointer<UInt>,
        capacity: Bit.Index.Count
    ) -> Bit.Index? { ... }

    @inlinable
    public static func ones(
        words: UnsafeBufferPointer<UInt>,
        capacity: Bit.Index.Count
    ) -> Bit.Vector.Ones.View { ... }
}
```

Each variant's methods delegate:

```swift
extension Bit.Vector.Bounded {
    @inlinable
    public var popcount: Bit.Index.Count {
        _storage.withUnsafeBufferPointer { words in
            Bit.Vector.popcount(words: words, capacity: _capacity)
        }
    }
}
```

**Advantages**:
- Zero protocol overhead — all `@inlinable`, direct word access
- No `~Copyable` protocol complications
- Each variant keeps its own API surface (no forced uniformity)
- Shared implementation without shared abstraction
- Works today with no compiler limitations
- Each variant can still have its own `isEmpty` semantics if needed

**Disadvantages**:
- Each variant still declares its own `popcount`, `isEmpty`, etc. (thin wrappers, but still N declarations)
- No generic consumer code possible
- No protocol conformance to check at compile time
- Maintenance burden: adding a new operation requires N wrapper declarations

### Option D: Macro-Based Code Generation

Use Swift macros to generate the duplicated methods.

```swift
@BitVectorOperations
public struct Bounded: Sendable { ... }
```

**Advantages**:
- Zero runtime overhead
- Single source of truth for operation implementations
- Can generate variant-specific specializations

**Disadvantages**:
- Swift macros add build complexity and are harder to debug
- Macros are not widely used in Swift Institute packages
- Generated code is harder to read and review
- Macro dependencies add weight to the package

### Option E: Status Quo with Targeted Additions

Keep the current approach. When a variant lacks an operation, add it to that variant.

**Advantages**:
- No architectural changes needed
- Each addition is small and reviewable
- No compiler limitation concerns

**Disadvantages**:
- Duplication continues to grow (currently ~5x for each new operation)
- Semantic drift persists (isEmpty means different things)
- Every new consumer requirement may trigger compilation failures in other packages
- No systematic way to ensure API parity

## Comparison

| Criterion | A: Protocol | B: Word-Access | C: Static Methods | D: Macros | E: Status Quo |
|-----------|:-----------:|:--------------:|:-----------------:|:---------:|:-------------:|
| Eliminates duplication | Full | Full | Partial (wrappers remain) | Full | No |
| ~Copyable compatibility | Risky | Risky | Safe | Safe | N/A |
| @inlinable performance | Witness overhead | Witness overhead | Zero overhead | Zero overhead | Zero overhead |
| Complexity to implement | High | Medium | Low | High | None |
| API parity enforcement | Compile-time | Compile-time | Manual | Compile-time | Manual |
| Generic consumer code | Yes | Yes | No | No | No |
| Semantic consistency | Enforced | Enforced | Opt-in | Enforced | Uncontrolled |
| Compiler maturity risk | High | High | None | Medium | None |

## Recommendation

**Option C (Static Methods)** for the immediate term, with **Option B (Word-Access)** as the long-term target when `~Copyable` protocol support matures.

### Rationale

1. **Option C solves the acute problem now**: `pop.first()` can be implemented once as `Bit.Vector.popFirst(words:capacity:)` and called from every variant's wrapper. Same for `ones`, `isEmpty`, `isFull`, `popcount`, `clearAll`, `setAll`.

2. **No compiler risk**: Static methods with `UnsafeBufferPointer<UInt>` avoid all `~Copyable` protocol limitations. Every variant already has word-level access internally (`_storage`, `_words`, `InlineArray`).

3. **Zero performance cost**: `@inlinable` static methods with buffer pointer args compile to the same code as hand-written implementations.

4. **Thin wrapper declarations are acceptable**: Each variant still declares `var popcount`, `func pop.first()`, etc., but the body is a single delegation call. This is ~3 lines per operation per variant vs ~10-20 lines of duplicated logic.

5. **Path to Option B**: When `~Copyable` protocols stabilize, the static methods become the default implementations of a `WordAccessible` protocol extension. The migration is additive — existing API doesn't change.

### Implementation Sketch

**Phase 1: Core static operations** (in `Bit Vector Primitives Core` or similar):

```swift
extension Bit.Vector {
    /// Counts set bits across word storage.
    @inlinable
    public static func popcount(
        words: UnsafeBufferPointer<UInt>
    ) -> Bit.Index.Count {
        var total: UInt = 0
        for word in words { total += UInt(word.nonzeroBitCount) }
        return Bit.Index.Count(Cardinal(total))
    }

    /// Removes and returns the index of the lowest set bit (Wegner/Kernighan).
    @inlinable
    public static func popFirst(
        words: UnsafeMutableBufferPointer<UInt>,
        capacity: Bit.Index.Count
    ) -> Bit.Index? {
        for i in words.indices {
            let word = words[i]
            if word != 0 {
                let bit = word.trailingZeroBitCount
                words[i] = word & (word &- 1)
                let globalIndex = Bit.Index.Count(UInt(i * UInt.bitWidth)) + Bit.Index.Count(UInt(bit))
                let index = globalIndex.map(Ordinal.init)
                guard index < capacity else { return nil }
                return index
            }
        }
        return nil
    }

    /// Whether all bits are false.
    @inlinable
    public static func allFalse(
        words: UnsafeBufferPointer<UInt>
    ) -> Bool {
        for word in words { if word != 0 { return false } }
        return true
    }

    /// Whether all bits (up to capacity) are true.
    @inlinable
    public static func allTrue(
        words: UnsafeBufferPointer<UInt>,
        capacity: Bit.Index.Count
    ) -> Bool {
        // Check full words are all-ones, last word has correct mask
        ...
    }
}
```

**Phase 2: Variant wrappers** — Each variant adds thin delegating implementations:

```swift
extension Bit.Vector.Bounded {
    @inlinable
    public var pop: Property<Bit.Vector.Pop, Self>.View {
        mutating _read {
            yield unsafe Property<Bit.Vector.Pop, Self>.View(&self)
        }
    }
}

extension Property.View where Tag == Bit.Vector.Pop, Base == Bit.Vector.Bounded {
    @inlinable
    public func first() -> Bit.Index? {
        base.pointee._storage.withUnsafeMutableBufferPointer { words in
            Bit.Vector.popFirst(words: words, capacity: base.pointee._capacity)
        }
    }
}
```

**Phase 3: Parity audit** — Ensure all 5 variants expose:
- `subscript(index:)` get/set
- `popcount`
- `isEmpty` (popcount-based: "all bits false")
- `isFull` (popcount-based: "all bits true up to capacity")
- `ones` (iterator over set bits)
- `zeros` (iterator over clear bits)
- `pop.first()` (destructive lowest-bit extraction)
- `take()` (ownership transfer)
- `clear.all()` / `set.all()` (bulk mutation)

**Counted types** (Bounded, Inline, Dynamic) additionally expose `count`, `append`, `popLast`, etc. These are NOT shared — they're intrinsic to the counted-vector semantic.

### Semantic Clarification

The parity audit should establish clear terminology:

| Property | Meaning | All variants |
|----------|---------|:------------:|
| `popcount` | Number of true bits | Yes |
| `isEmpty` | All bits are false (`popcount == .zero`) | Yes |
| `isFull` | All bits are true up to capacity | Yes |
| `count` | Number of appended bit positions | Counted types only |

This resolves the semantic drift where `isEmpty` and `isFull` mean different things on counted vs. fixed types.

## Next Steps

1. Implement Phase 1 static methods in `swift-bit-vector-primitives`
2. Add `pop.first()` to `Bit.Vector.Bounded` (and all other variants) via Phase 2 wrappers
3. Update buffer-primitives consume files to use `pop.first()` instead of linear scan
4. Conduct parity audit (Phase 3) across all variants
5. Track `~Copyable` protocol evolution for eventual Option B migration

## References

- `swift-buffer-primitives/Sources/Buffer Slab Primitives/Buffer.Slab+Consume.swift` — trigger for this research
- `swift-bit-vector-primitives/Sources/Bit Vector Primitives/Bit.Vector+pop.swift` — existing `pop.first()` on base Vector
- `swift-buffer-primitives/Research/buffer-variant-parity-analysis.md` — prior art on API parity analysis
