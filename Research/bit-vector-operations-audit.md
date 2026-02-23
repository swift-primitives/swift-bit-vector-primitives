# Bit Vector Operations Audit

<!--
---
version: 1.0.0
last_updated: 2026-02-16
status: RECOMMENDATION
tier: 1
---
-->

## Context

Proactive audit of swift-bit-vector-primitives per [RES-012] Discovery.
**Scope**: Package-specific (swift-bit-vector-primitives).

This package has 65 source files across 5 variants (`Bit.Vector`, `Bit.Vector.Static`, `Bit.Vector.Bounded`, `Bit.Vector.Inline`, `Bit.Vector.Dynamic`) unified by `Bit.Vector.Protocol`. The protocol provides word-level abstraction with default implementations for shared bitmap operations (popcount, allFalse, allTrue, clearAll, setAll, popFirst). Each variant adds capabilities appropriate to its storage model.

## Question

Does swift-bit-vector-primitives provide the canonical operations expected of the Bit Vector ADT?

## Canonical Operations (ADT Reference)

| # | Operation | Expected Complexity | Description |
|---|-----------|-------------------|-------------|
| 1 | get(i) | O(1) | Read bit at position |
| 2 | set(i, bit) | O(1) | Write bit at position |
| 3 | push(bit) | O(1) amortized | Append bit |
| 4 | pop() | O(1) | Remove last bit |
| 5 | insert(i, bit) | O(n/w) | Insert at position (shift) |
| 6 | delete(i) | O(n/w) | Remove at position (shift) |
| 7 | append(other) | O(k/w) | Concatenate bit vectors |
| 8 | iterate | O(n) or O(n/w) | Visit all bits |
| 9 | count_ones / popcount | O(n/w) | Count set bits |
| 10 | count_zeros | O(n/w) | Count clear bits |
| 11 | set_range | O(k/w) | Set range of bits |
| 12 | clear_range | O(k/w) | Clear range of bits |
| 13 | ones iteration | O(n/w) | Iterate positions of set bits |
| 14 | zeros iteration | O(n/w) | Iterate positions of clear bits |
| 15 | any/all/none | O(n/w) | Aggregate predicates |
| 16 | count/size | O(1) | Number of bits |
| 17 | isEmpty | O(1) | Zero length? |

(n = number of bits, w = word size, k = range/append size)

## Current Operations Inventory

### Core Protocol (`Bit.Vector.Protocol`)

Defined in `Bit.Vector.Protocol.swift`. All 5 variants conform.

**Requirements** (4 + subscript):

| Requirement | Signature | Notes |
|-------------|-----------|-------|
| `bitCapacity` | `var bitCapacity: Bit.Index.Count { get }` | Total valid bit positions |
| `word(at:)` | `borrowing func word(at index: Int) -> UInt` | Read word at index |
| `setWord(at:to:)` | `mutating func setWord(at index: Int, to value: UInt)` | Write word at index |
| `subscript` | `subscript(index: Bit.Index) -> Bool { get set }` | Single-bit read/write (requirement due to compiler bug) |

**Default implementations** (in `Bit.Vector.Protocol+defaults.swift`):

| Operation | Signature | Category | Complexity |
|-----------|-----------|----------|------------|
| `wordCount` | `var wordCount: Int { get }` | Read-only | O(1) |
| `popcount` | `var popcount: Bit.Index.Count { get }` | Read-only | O(n/w) |
| `allFalse` | `var allFalse: Bool { get }` | Read-only | O(n/w) |
| `allTrue` | `var allTrue: Bool { get }` | Read-only | O(n/w) |
| `clearAll(_:)` | `static func clearAll(_ vector: inout Self)` | Mutating | O(n/w) |
| `setAll(_:)` | `static func setAll(_ vector: inout Self)` | Mutating | O(n/w) |
| `popFirst()` | `mutating func popFirst() -> Bit.Index?` | Mutating | O(n/w) per call |

**Property.View accessors** (on protocol, all variants):

| Accessor | Signature | Methods |
|----------|-----------|---------|
| `pop` | `var pop: Property<Bit.Vector.Pop, Self>.View` | `.first() -> Bit.Index?` |
| `set` | `var set: Property<Bit.Vector.Set, Self>.View` | `.all()` (sets all bits true) |
| `clear` | `var clear: Property<Bit.Vector.Clear, Self>.View` | `.all()` (clears all bits) |

### Variant: `Bit.Vector` (~Copyable, pointer-backed)

Infrastructure bitmap. Fixed-capacity, heap-allocated via `UnsafeMutablePointer<UInt>`.

**File: `Bit.Vector.swift`**

| Operation | Signature | Complexity |
|-----------|-----------|------------|
| `init(capacity:)` | `public init(capacity: Bit.Index.Count)` | O(n/w) |
| `subscript` | `public subscript(index: Bit.Index) -> Bool { get nonmutating set }` | O(1) |
| `isEmpty` | `public var isEmpty: Bool` (delegates to `allFalse`) | O(n/w) |
| `isFull` | `public var isFull: Bool` (delegates to `allTrue`) | O(n/w) |
| `capacity` | `public let capacity: Bit.Index.Count` | O(1) |
| `withUnsafeWords(_:)` | `public func withUnsafeWords<R>(_ body: (UnsafeBufferPointer<UInt>) -> R) -> R` | O(1) |
| `withUnsafeMutableWords(_:)` | `public func withUnsafeMutableWords<R>(_ body: (UnsafeMutableBufferPointer<UInt>) -> R) -> R` | O(1) |

**File: `Bit.Vector+take.swift`**

| Operation | Signature | Complexity |
|-----------|-----------|------------|
| `take()` | `public mutating func take() -> Bit.Vector` | O(1) |

**File: `Bit.Vector+ones.swift`**

| Operation | Signature | Return type |
|-----------|-----------|-------------|
| `ones` | `public var ones: Ones.View` | `Bit.Vector.Ones.View` (Sequence) |

**File: `Bit.Vector+zeros.swift`**

| Operation | Signature | Return type |
|-----------|-----------|-------------|
| `zeros` | `public var zeros: Zeros.View` | `Bit.Vector.Zeros.View` (Sequence) |

**Conformances**: `Bit.Vector.Protocol`, `@unchecked Sendable`, `~Copyable`

### Variant: `Bit.Vector.Static<let wordCount: Int>`

Full-capacity inline bitmap. No count tracking -- all `wordCount * UInt.bitWidth` bits are always valid.

**File: `Bit.Vector.Static.swift`**

| Operation | Signature | Complexity |
|-----------|-----------|------------|
| `init()` | `public init()` | O(w) |
| `capacity` | `public static var capacity: Bit.Index.Count` | O(1) |
| `subscript` | `public subscript(index: Bit.Index) -> Bool { get set }` | O(1) |
| `isEmpty` | `public var isEmpty: Bool` (delegates to `allFalse`) | O(n/w) |
| `isFull` | `public var isFull: Bool` (delegates to `allTrue`) | O(n/w) |

**File: `Bit.Vector.Static+ones.swift`**

| Operation | Signature | Return type |
|-----------|-----------|-------------|
| `ones` | `public var ones: Bit.Vector.Ones.Static<wordCount>` | Sequence of set-bit indices |

**File: `Bit.Vector.Static+zeros.swift`**

| Operation | Signature | Return type |
|-----------|-----------|-------------|
| `zeros` | `public var zeros: Bit.Vector.Zeros.Static<wordCount>` | Sequence of clear-bit indices |

**File: `Bit.Vector.Static+set.range.swift`** (via Property.View)

| Operation | Signature | Complexity |
|-----------|-----------|------------|
| `set.range(_:)` | `public func range(_ range: Swift.Range<Bit.Index>)` | O(k/w) |

**File: `Bit.Vector.Static+clear.range.swift`** (via Property.View)

| Operation | Signature | Complexity |
|-----------|-----------|------------|
| `clear.range(_:)` | `public func range(_ range: Swift.Range<Bit.Index>)` | O(k/w) |

**Conformances**: `Bit.Vector.Protocol`, `Sendable`

### Variant: `Bit.Vector.Bounded` (heap, fixed-capacity container)

Heap-allocated with `ContiguousArray<UInt>`. Has count tracking, throws on overflow.

**File: `Bit.Vector.Bounded.swift`**

| Operation | Signature | Complexity |
|-----------|-----------|------------|
| `init(capacity:)` | `public init(capacity: Bit.Index.Count)` | O(n/w) |
| `init(capacity:count:)` | `public init(capacity: Bit.Index.Count, count: Bit.Index.Count) throws(Error)` | O(n/w) |
| `init(capacity:_:)` | `public init<S: Sequence>(capacity: Bit.Index.Count, _ elements: S) throws(Error) where S.Element == Bool` | O(n) |
| `init(capacity:repeating:count:)` | `public init(capacity: Bit.Index.Count, repeating value: Bool, count: Bit.Index.Count) throws(Error)` | O(n/w) |
| `count` | `public var count: Bit.Index.Count` | O(1) |
| `isEmpty` | `public var isEmpty: Bool` (count-based) | O(1) |
| `isFull` | `public var isFull: Bool` (count vs capacity) | O(1) |
| `first` | `public var first: Bool?` | O(1) |
| `last` | `public var last: Bool?` | O(1) |
| `subscript` | `public subscript(index: Bit.Index) -> Bool { get set }` | O(1) |
| `get(_:)` | `public func get(_ index: Bit.Index) throws(Error) -> Bool` | O(1) |

**File: `Bit.Vector.Bounded+mutating.swift`**

| Operation | Signature | Complexity |
|-----------|-----------|------------|
| `set(_:)` | `public mutating func set(_ index: Bit.Index) throws(Error)` | O(1) |
| `clear(_:)` | `public mutating func clear(_ index: Bit.Index) throws(Error)` | O(1) |
| `toggle(_:)` | `public mutating func toggle(_ index: Bit.Index) throws(Error)` | O(1) |
| `setAll()` | `public mutating func setAll()` | O(n/w) |

**File: `Bit.Vector.Bounded+growth.swift`**

| Operation | Signature | Complexity |
|-----------|-----------|------------|
| `append(_: Bool)` | `public mutating func append(_ value: Bool) throws(Error)` | O(1) |
| `append(_: Bit)` | `public mutating func append(_ bit: Bit) throws(Error)` | O(1) |
| `popLast()` | `@discardableResult public mutating func popLast() -> Bool?` | O(1) |
| `removeLast()` | `public mutating func removeLast()` | O(1) |
| `removeAll()` | `public mutating func removeAll()` | O(n/w) |

**File: `Bit.Vector.Bounded+take.swift`**

| Operation | Signature | Complexity |
|-----------|-----------|------------|
| `take()` | `public mutating func take() -> Bit.Vector.Bounded` | O(1) |

**File: `Bit.Vector.Bounded+ones.swift`**

| Operation | Signature | Return type |
|-----------|-----------|-------------|
| `ones` | `public var ones: Bit.Vector.Ones.Bounded` | Sequence of set-bit indices |

**File: `Bit.Vector.Bounded.All.swift`** (via Property)

| Operation | Signature |
|-----------|-----------|
| `all.true` | `public var true: Bool` |
| `all.false` | `public var false: Bool` |

**File: `Bit.Vector.Bounded.Statistic.swift`** (via Property)

| Operation | Signature |
|-----------|-----------|
| `statistic.true` | `public var true: Bit.Index.Count` (popcount) |
| `statistic.false` | `public var false: Bit.Index.Count` (count - popcount) |

**File: `Bit.Vector.Bounded.Capacity.swift`** (via Property)

| Operation | Signature |
|-----------|-----------|
| `capacity.maximum` | `public var maximum: Bit.Index.Count` |
| `capacity.remaining` | `public var remaining: Bit.Index.Count` |

**Conformances**: `Bit.Vector.Protocol`, `Sendable`, `Equatable`, `Hashable`, `CustomStringConvertible`, `Swift.Sequence`

### Variant: `Bit.Vector.Inline<let wordCount: Int>` (inline, fixed-capacity container)

Stack-allocated with `InlineArray`. Has count tracking, throws on overflow.

**File: `Bit.Vector.Inline.swift`**

| Operation | Signature | Complexity |
|-----------|-----------|------------|
| `init()` | `public init()` | O(w) |
| `init(count:)` | `public init(count: Bit.Index.Count) throws(Error)` | O(w) |
| `init(repeating:count:)` | `public init(repeating value: Bool, count: Bit.Index.Count) throws(Error)` | O(w) |
| `count` | `public var count: Bit.Index.Count` | O(1) |
| `isEmpty` | `public var isEmpty: Bool` (count-based) | O(1) |
| `isFull` | `public var isFull: Bool` (count vs capacity) | O(1) |
| `first` | `public var first: Bool?` | O(1) |
| `last` | `public var last: Bool?` | O(1) |
| `subscript` | `public subscript(index: Bit.Index) -> Bool { get set }` | O(1) |
| `get(_:)` | `public func get(_ index: Bit.Index) throws(Error) -> Bool` | O(1) |

**File: `Bit.Vector.Inline+mutating.swift`**

| Operation | Signature | Complexity |
|-----------|-----------|------------|
| `set(_:)` | `public mutating func set(_ index: Bit.Index) throws(Error)` | O(1) |
| `clear(_:)` | `public mutating func clear(_ index: Bit.Index) throws(Error)` | O(1) |
| `toggle(_:)` | `public mutating func toggle(_ index: Bit.Index) throws(Error)` | O(1) |
| `setAll()` | `public mutating func setAll()` | O(n/w) |

**File: `Bit.Vector.Inline+growth.swift`**

| Operation | Signature | Complexity |
|-----------|-----------|------------|
| `append(_: Bool)` | `public mutating func append(_ value: Bool) throws(Error)` | O(1) |
| `append(_: Bit)` | `public mutating func append(_ bit: Bit) throws(Error)` | O(1) |
| `popLast()` | `@discardableResult public mutating func popLast() -> Bool?` | O(1) |
| `removeLast()` | `public mutating func removeLast()` | O(1) |
| `removeAll()` | `public mutating func removeAll()` | O(w) |

**File: `Bit.Vector.Inline.All.swift`** (via Property.View.Typed.Valued)

| Operation | Signature |
|-----------|-----------|
| `all.true` | `public var true: Bool` |
| `all.false` | `public var false: Bool` |

**File: `Bit.Vector.Inline.Statistic.swift`** (via Property.View.Typed.Valued)

| Operation | Signature |
|-----------|-----------|
| `statistic.true` | `public var true: Bit.Index.Count` |
| `statistic.false` | `public var false: Bit.Index.Count` |

**File: `Bit.Vector.Inline.Capacity.swift`** (via Property.View.Typed.Valued)

| Operation | Signature |
|-----------|-----------|
| `capacity.maximum` | `public var maximum: Bit.Index.Count` |
| `capacity.remaining` | `public var remaining: Bit.Index.Count` |

**Conformances**: `Bit.Vector.Protocol`, `Sendable`, `Equatable`, `Hashable`, `CustomStringConvertible`, `Swift.Sequence`

### Variant: `Bit.Vector.Dynamic` (heap, growable container)

Heap-allocated with `ContiguousArray<UInt>`. Growable. Append never throws.

**File: `Bit.Vector.Dynamic.swift`**

| Operation | Signature | Complexity |
|-----------|-----------|------------|
| `init()` | `public init()` | O(1) |
| `init(count:)` | `public init(count: Bit.Index.Count)` | O(n/w) |
| `init(repeating:count:)` | `public init(repeating value: Bool, count: Bit.Index.Count)` | O(n/w) |
| `init(repeating:count:)` | `public init(repeating bit: Bit, count: Bit.Index.Count)` | O(n/w) |
| `init(_:)` | `public init<S: Sequence>(_ elements: S) where S.Element == Bool` | O(n) |
| `init(_:)` | `public init<S: Sequence>(_ elements: S) where S.Element == Bit` | O(n) |
| `count` | `public var count: Bit.Index.Count` | O(1) |
| `isEmpty` | `public var isEmpty: Bool` (count-based) | O(1) |
| `first` | `public var first: Bool?` | O(1) |
| `last` | `public var last: Bool?` | O(1) |
| `subscript` | `public subscript(index: Bit.Index) -> Bool { get set }` | O(1) |
| `get(_:)` | `public func get(_ index: Bit.Index) throws(Error) -> Bool` | O(1) |

**File: `Bit.Vector.Dynamic+mutating.swift`**

| Operation | Signature | Complexity |
|-----------|-----------|------------|
| `set(_:)` | `public mutating func set(_ index: Bit.Index) throws(Error)` | O(1) |
| `clear(_:)` | `public mutating func clear(_ index: Bit.Index) throws(Error)` | O(1) |
| `toggle(_:)` | `public mutating func toggle(_ index: Bit.Index) throws(Error)` | O(1) |

**File: `Bit.Vector.Dynamic+growth.swift`**

| Operation | Signature | Complexity |
|-----------|-----------|------------|
| `append(_: Bool)` | `public mutating func append(_ value: Bool)` | O(1) amortized |
| `append(_: Bit)` | `public mutating func append(_ bit: Bit)` | O(1) amortized |
| `popLast()` | `@discardableResult public mutating func popLast() -> Bool?` | O(1) |
| `removeLast()` | `public mutating func removeLast()` | O(1) |
| `removeAll(keepingCapacity:)` | `public mutating func removeAll(keepingCapacity: Bool = false)` | O(n/w) or O(1) |
| `resize(to:fill:)` | `public mutating func resize(to newCount: Bit.Index.Count, fill: Bool = false)` | O(n/w) |

**File: `Bit.Vector.Dynamic+returning.swift`** (via Property.View)

| Operation | Signature |
|-----------|-----------|
| `toggle.returning(_:)` | `public func returning(_ index: Bit.Index) throws(Error) -> Bool` |
| `set.returning(_:)` | `public func returning(_ index: Bit.Index) throws(Error) -> Bool` |
| `clear.returning(_:)` | `public func returning(_ index: Bit.Index) throws(Error) -> Bool` |

**File: `Bit.Vector.Dynamic+ones.swift`** (via Property.View)

| Operation | Signature |
|-----------|-----------|
| `ones.forEach(_:)` | `public func forEach(_ body: (Bit.Index) -> Void)` |

**File: `Bit.Vector.Dynamic+zeros.swift`** (via Property.View)

| Operation | Signature |
|-----------|-----------|
| `zeros.forEach(_:)` | `public func forEach(_ body: (Bit.Index) -> Void)` |

**File: `Bit.Vector.Dynamic+conversions.swift`**

| Operation | Signature |
|-----------|-----------|
| `init(_: Bounded)` | `public init(_ bounded: Bit.Vector.Bounded)` |
| `init(_: Inline)` | `public init<let wordCount: Int>(_ inline: Bit.Vector.Inline<wordCount>)` |

**File: `Bit.Vector.Dynamic.All.swift`** (via Property)

| Operation | Signature |
|-----------|-----------|
| `all.true` | `public var true: Bool` |
| `all.false` | `public var false: Bool` |

**File: `Bit.Vector.Dynamic.Statistic.swift`** (via Property)

| Operation | Signature |
|-----------|-----------|
| `statistic.true` | `public var true: Bit.Index.Count` |
| `statistic.false` | `public var false: Bit.Index.Count` |

**Conformances**: `Bit.Vector.Protocol`, `Sendable`, `Equatable`, `Hashable`, `CustomStringConvertible`, `Swift.Sequence`

### Ones/Zeros Iteration Infrastructure

**Ones iteration** -- 3 backing sequence types, each with its own Iterator:

| Type | Backing | Used by | Conformances |
|------|---------|---------|--------------|
| `Bit.Vector.Ones.View` | `UnsafeMutablePointer<UInt>` | `Bit.Vector` | `Sequence.Protocol`, `Swift.Sequence` |
| `Bit.Vector.Ones.Static<N>` | `InlineArray<N, UInt>` | `Bit.Vector.Static` | `Sequence.Protocol`, `Swift.Sequence` |
| `Bit.Vector.Ones.Bounded` | `ContiguousArray<UInt>` | `Bit.Vector.Bounded` | `Sequence.Protocol`, `Swift.Sequence` |
| `Bit.Vector.Dynamic` | via Property.View | `Bit.Vector.Dynamic` | `ones.forEach(_:)` only |

All use Wegner/Kernighan (`w &= w &- 1`) for O(popcount) iteration.

**Zeros iteration** -- 3 backing sequence types:

| Type | Backing | Used by | Conformances |
|------|---------|---------|--------------|
| `Bit.Vector.Zeros.View` | `UnsafeMutablePointer<UInt>` | `Bit.Vector` | `Sequence.Protocol`, `Swift.Sequence` |
| `Bit.Vector.Zeros.Static<N>` | `InlineArray<N, UInt>` | `Bit.Vector.Static` | `Sequence.Protocol`, `Swift.Sequence` |
| `Bit.Vector.Dynamic` | via Property.View | `Bit.Vector.Dynamic` | `zeros.forEach(_:)` only |

Note: `Bounded` and `Inline` are **missing** zeros iteration.

### Set/Clear Range Operations

| Variant | `set.range(_:)` | `clear.range(_:)` |
|---------|:---------------:|:-----------------:|
| `Bit.Vector` | Via protocol (`set.all()`) | Via protocol (`clear.all()`) |
| `Bit.Vector.Static` | Yes | Yes |
| `Bit.Vector.Bounded` | No | No |
| `Bit.Vector.Inline` | No | No |
| `Bit.Vector.Dynamic` | No | No |

### Pop/Take Operations

| Variant | `popFirst()` | `popLast()` | `take()` |
|---------|:------------:|:-----------:|:--------:|
| `Bit.Vector` | Yes (protocol) | No (no count) | Yes |
| `Bit.Vector.Static` | Yes (protocol) | No (no count) | No |
| `Bit.Vector.Bounded` | Yes (protocol) | Yes | Yes |
| `Bit.Vector.Inline` | Yes (protocol) | Yes | No |
| `Bit.Vector.Dynamic` | Yes (protocol) | Yes | No |

### Growth Operations

| Variant | `append(_:)` | `removeLast()` | `removeAll()` | `resize(to:fill:)` |
|---------|:------------:|:--------------:|:-------------:|:-------------------:|
| `Bit.Vector` | No | No | No | No |
| `Bit.Vector.Static` | No | No | No | No |
| `Bit.Vector.Bounded` | Yes (throws) | Yes | Yes | No |
| `Bit.Vector.Inline` | Yes (throws) | Yes | Yes | No |
| `Bit.Vector.Dynamic` | Yes (infallible) | Yes | Yes (keepingCapacity) | Yes |

### Additional Operations (beyond canonical)

| Operation | Variants | Description |
|-----------|----------|-------------|
| `toggle(_:)` | Bounded, Inline, Dynamic | XOR single bit |
| `toggle.returning(_:)` | Dynamic | Toggle and return new value |
| `set.returning(_:)` | Dynamic | Set and return previous value |
| `clear.returning(_:)` | Dynamic | Clear and return previous value |
| `take()` | Vector, Bounded | Ownership transfer via swap |
| `statistic.true` / `.false` | Bounded, Inline, Dynamic | Count of true/false bits |
| `all.true` / `.false` | Bounded, Inline, Dynamic | Universality predicates (count-based) |
| `capacity.maximum` / `.remaining` | Bounded, Inline | Capacity introspection |
| `first` / `last` | Bounded, Inline, Dynamic | Element access |
| `get(_:)` (throwing) | Bounded, Inline, Dynamic | Bounds-checked read |
| `withUnsafeWords(_:)` | Vector | Word-level buffer access |
| `withUnsafeMutableWords(_:)` | Vector | Mutable word-level buffer access |
| Conversions (Dynamic from Bounded/Inline) | Dynamic | Variant conversion |
| `Swift.Sequence` conformance | Bounded, Inline, Dynamic | Full bit iteration via `for-in` |
| `Equatable` / `Hashable` | Bounded, Inline, Dynamic | Value semantics |
| `CustomStringConvertible` | Bounded, Inline, Dynamic | Debug output |

## Gap Analysis

### Present and Correctly Mapped

| Canonical Operation | Implementation | Variants | Notes |
|--------------------|----------------|----------|-------|
| **get(i)** | `subscript(index:) -> Bool { get }` | All 5 | O(1), protocol requirement |
| **set(i, bit)** | `subscript(index:) -> Bool { set }` | All 5 | O(1), protocol requirement |
| **push(bit)** | `append(_:)` | Bounded, Inline, Dynamic | Bounded/Inline throw on overflow; Dynamic grows |
| **pop()** | `popLast() -> Bool?` | Bounded, Inline, Dynamic | O(1), returns removed value |
| **iterate** | `Swift.Sequence` conformance | Bounded, Inline, Dynamic | O(n), full bit-by-bit iteration |
| **count_ones** | `popcount` | All 5 | O(n/w) via protocol default |
| **count_zeros** | `statistic.false` | Bounded, Inline, Dynamic | O(n/w), computed as count - popcount |
| **set_range** | `set.range(_:)` | Static | O(k/w) word-level |
| **clear_range** | `clear.range(_:)` | Static | O(k/w) word-level |
| **ones iteration** | `ones` property | All 5 | O(popcount) via Wegner/Kernighan |
| **zeros iteration** | `zeros` property | Vector, Static, Dynamic | O(zero-count) via complement + Wegner/Kernighan |
| **all** | `allTrue` / `all.true` | All 5 | Protocol: `allTrue`; counted: `all.true` |
| **none** | `allFalse` / `all.false` | All 5 | Protocol: `allFalse`; counted: `all.false` |
| **count/size** | `count` / `capacity` / `bitCapacity` | All 5 | O(1) |
| **isEmpty** | `isEmpty` | All 5 | O(1) for counted types; O(n/w) for bitmap types |

### Missing -- Should Add (Primitives Layer)

| # | Canonical Operation | Missing From | Priority | Rationale |
|---|-------------------|--------------|----------|-----------|
| 1 | **zeros iteration** | Bounded, Inline | Medium | Vector, Static, and Dynamic all have it. Bounded and Inline are the only gaps. Straightforward to add -- create `Bit.Vector.Zeros.Bounded` (like `Ones.Bounded`) and provide `zeros` on Inline via Property.View or a `Zeros.Static<N>`-like approach. |
| 2 | **set_range** | Vector, Bounded, Inline, Dynamic | Medium | Only Static has it. The word-level algorithm in `Static+set.range.swift` is generic over word storage -- it could be lifted to the protocol level or provided for each counted variant. Range-set is a fundamental bitmap operation used in allocation bitmaps, scheduling, etc. |
| 3 | **clear_range** | Vector, Bounded, Inline, Dynamic | Medium | Same as set_range. Only Static has it. Same lift opportunity. |
| 4 | **any** | All | Low | No dedicated `any` predicate (`!allFalse` or `popcount > .zero`). Currently expressible as `!allFalse` but a dedicated `any` is conventional in bit vector ADTs. Could be `var any: Bool { !allFalse }` on the protocol. |
| 5 | **toggle(_:)** | Vector, Static | Low | Bounded, Inline, Dynamic have it. Vector and Static lack it. XOR is a fundamental bit operation. Could be a protocol default. |
| 6 | **setAll()** (instance) | Vector, Static | Low | Protocol provides `static func setAll(_:)` and `set.all()` via Property.View. Bounded and Inline additionally have a direct `mutating func setAll()`. Vector and Static lack the instance method (but have it via Property.View). Consistency suggests adding it, but the Property.View path works. |

### Missing -- Intentionally Absent (Higher Layer)

| # | Canonical Operation | Rationale |
|---|-------------------|-----------|
| 1 | **insert(i, bit)** | O(n/w) shift operation. Not appropriate for primitives. Bit vectors at the primitives layer are packed storage, not general-purpose sequences. Insert-at-position requires shifting all subsequent bits, which is a composed operation better suited for Foundations layer (Layer 3). |
| 2 | **delete(i)** | O(n/w) shift operation. Same rationale as insert. |
| 3 | **append(other)** | Concatenation of two bit vectors requires word-aligned copy with bit-offset merging. This is a composed operation. Individual bit vectors can be built via repeated `append`, but bulk concatenation is Foundations-layer complexity. |
| 4 | **Bitwise operators** (AND, OR, XOR, NOT) | Pairwise bitwise operations between two bit vectors of potentially different sizes require alignment and capacity logic. These are composed operations. Within a single vector, `setAll`/`clearAll`/`toggle` serve the single-vector case. |

## Parity Matrix

Summary of which canonical operations exist on which variants:

| Operation | Vector | Static | Bounded | Inline | Dynamic |
|-----------|:------:|:------:|:-------:|:------:|:-------:|
| get(i) | Y | Y | Y | Y | Y |
| set(i, bit) | Y | Y | Y | Y | Y |
| push(bit) | -- | -- | Y | Y | Y |
| pop() | -- | -- | Y | Y | Y |
| insert(i) | -- | -- | -- | -- | -- |
| delete(i) | -- | -- | -- | -- | -- |
| append(other) | -- | -- | -- | -- | -- |
| iterate | -- | -- | Y | Y | Y |
| popcount | Y | Y | Y | Y | Y |
| count_zeros | -- | -- | Y | Y | Y |
| set_range | -- | Y | -- | -- | -- |
| clear_range | -- | Y | -- | -- | -- |
| ones iteration | Y | Y | Y | -- | Y |
| zeros iteration | Y | Y | -- | -- | Y |
| all/none | Y | Y | Y | Y | Y |
| any | -- | -- | -- | -- | -- |
| count/size | Y | Y | Y | Y | Y |
| isEmpty | Y | Y | Y | Y | Y |
| toggle(i) | -- | -- | Y | Y | Y |

Legend: Y = present, -- = absent

**Notable asymmetries**:
- ones iteration: missing on Inline
- zeros iteration: missing on Bounded and Inline
- set_range / clear_range: only on Static
- toggle: missing on Vector and Static
- iterate (Swift.Sequence): missing on Vector and Static (both are bitmap types, not containers)

## Outcome

**Status**: RECOMMENDATION

The package provides strong coverage of the canonical Bit Vector ADT. The 5-variant architecture correctly separates infrastructure bitmaps (Vector, Static) from container types (Bounded, Inline, Dynamic), and the `Bit.Vector.Protocol` unification eliminates the duplication documented in the prior research.

**Key findings**:

1. **14 of 17 canonical operations are present** across at least one variant. The 3 absent operations (insert, delete, append-other) are intentionally deferred to higher layers per the five-layer architecture.

2. **Parity gaps within the primitives layer** are the primary issue:
   - `zeros` iteration is missing on Bounded and Inline (but present on Vector, Static, Dynamic)
   - `ones` iteration is missing on Inline (but present on all others)
   - `set_range` / `clear_range` only exist on Static (should be available on all bitmap-capable variants)
   - `toggle` is missing on Vector and Static

3. **The protocol unification is working well**. `popcount`, `allFalse`, `allTrue`, `clearAll`, `setAll`, `popFirst`, and the Property.View accessors (`pop`, `set`, `clear`) are all shared via protocol defaults.

**Recommended next steps** (priority order):

1. Add `zeros` to Bounded and `ones`/`zeros` to Inline (medium priority -- completes iteration parity)
2. Lift `set.range` / `clear.range` to the protocol level or add to all variants (medium priority -- fundamental bitmap operation)
3. Add `any` to the protocol as `var any: Bool { !allFalse }` (low priority -- trivially derived)
4. Add `toggle` to Vector and Static via protocol default (low priority -- less commonly needed on bitmap types)

## References

- `swift-bit-vector-primitives/Research/bit-vector-protocol-unification.md` -- prior research on protocol unification
- `swift-bit-vector-primitives/Sources/Bit Vector Primitives/` -- all 65 source files audited
- `swift-institute/Documentation.docc/Five Layer Architecture.md` -- layer boundary rationale
