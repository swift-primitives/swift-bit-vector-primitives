// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-primitives open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

public import Iterator_Chunk_Primitives
public import Iterator_Primitive
public import Sequence_Primitives

// MARK: - Sequence.Protocol

extension Bit.Vector.Ones.View: Iterable {
    /// The element type.
    public typealias Element = Bit.Index

    /// The iterator type for `Iterable` conformance.
    @_implements(Iterable,Iterator)
    public typealias IterableIterator = Iterator_Primitive.Iterator.Materializing<Iterator>

    /// Returns an iterator over the set-bit indices.
    @inlinable
    @_lifetime(borrow self)
    @_implements(Iterable,makeIterator())
    public borrowing func iterableMakeIterator() -> Iterator_Primitive.Iterator.Materializing<Iterator> {
        Iterator_Primitive.Iterator.Materializing(Iterator(view: self))
    }

    /// Returns an iterator over the set-bit indices.
    @inlinable
    public func makeIterator() -> Iterator {
        Iterator(view: self)
    }
}

// MARK: - forEach
//
// Not `Swift.Sequence`: `View` is `~Escapable` (issue swift-primitives/
// swift-bit-vector-primitives#3), and `Swift.Sequence`'s `Self` requirement
// does not suppress `Escapable`, so a `~Escapable` type cannot conform.
// `forEach` is declared directly on the concrete type instead — every
// existing call site already used `.ones.forEach { ... }`, never a generic
// `Sequence`-constrained call, so this is source-compatible.

extension Bit.Vector.Ones.View {
    /// Forces closure inlining during mandatory SIL passes by declaring
    /// `forEach` directly on the concrete type with `@inline(always)`.
    ///
    /// Without this, the generic `Iterable.forEach` default (which is
    /// `@inlinable` but not `@inline(always)`) leaves closures as separate
    /// `partial_apply` SIL entities. In class deinits with `~Copyable` generic
    /// parameters, the `partial_apply` captures `self` with
    /// `ForwardingConsume` semantics, and CopyPropagation cannot track the
    /// lifetime — causing a crash.
    @inline(always)
    @inlinable
    public func forEach(_ body: (Bit.Index) -> Void) {
        var iterator: Iterator = makeIterator()
        while let element = iterator.next() {
            body(element)
        }
    }
}
