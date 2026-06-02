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
    // SAFETY: Safe by construction — backing storage uses only stdlib
    // SAFETY: safe types; `@safe` documents that this type performs no
    // SAFETY: unsafe operations.
    /// A sequence of set-bit indices for `Bit.Vector.Static`.
    ///
    /// Copies the `InlineArray` from the static vector so iteration does not
    /// require a pointer into stack storage (which would dangle on temporaries).
    ///
    /// Conforms to both `Sequence.Protocol` and `Swift.Sequence`, providing
    /// `forEach`, `map`, `filter`, `for-in`, and all stdlib sequence algorithms.
    @safe
    public struct Static<let wordCount: Int>: Copyable, Sendable {
        @usableFromInline
        let _storage: InlineArray<wordCount, UInt>

        @inlinable
        package init(storage: InlineArray<wordCount, UInt>) {
            self._storage = storage
        }
    }
}

// MARK: - Sequence.Protocol

extension Bit.Vector.Ones.Static: Iterable {
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
        Iterator_Primitive.Iterator.Materializing(Iterator(storage: _storage))
    }

    /// Returns an iterator over the set-bit indices.
    @inlinable
    public func makeIterator() -> Iterator {
        Iterator(storage: _storage)
    }
}

// MARK: - Swift.Sequence

extension Bit.Vector.Ones.Static: Swift.Sequence {}
