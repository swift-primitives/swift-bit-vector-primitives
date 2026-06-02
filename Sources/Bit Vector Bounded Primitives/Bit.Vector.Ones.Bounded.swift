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
import Sequence_Primitives

extension Bit.Vector.Ones {
    // SAFETY: Safe by construction — backing storage is a stdlib
    // SAFETY: `ContiguousArray<UInt>` which is itself fully safe. `@safe`
    // SAFETY: documents that this type performs no unsafe operations.
    /// A sequence of set-bit indices for `Bit.Vector.Bounded`.
    ///
    /// Copies the `ContiguousArray` from the bounded vector so iteration does
    /// not alias mutable storage.
    ///
    /// Conforms to both `Sequence.Protocol` and `Swift.Sequence`, providing
    /// `forEach`, `map`, `filter`, `for-in`, and all stdlib sequence algorithms.
    @safe
    public struct Bounded: Copyable, Sendable {
        @usableFromInline
        let _storage: ContiguousArray<UInt>

        @usableFromInline
        let _capacity: Bit.Index.Count

        @inlinable
        package init(storage: ContiguousArray<UInt>, capacity: Bit.Index.Count) {
            self._storage = storage
            self._capacity = capacity
        }
    }
}

// MARK: - Sequence.Protocol

extension Bit.Vector.Ones.Bounded: Iterable {
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
        Iterator_Primitive.Iterator.Materializing(Iterator(storage: _storage, capacity: _capacity))
    }

    /// Returns an iterator over the set-bit indices.
    @inlinable
    public func makeIterator() -> Iterator {
        Iterator(storage: _storage, capacity: _capacity)
    }
}

// MARK: - Swift.Sequence

extension Bit.Vector.Ones.Bounded: Swift.Sequence {}
