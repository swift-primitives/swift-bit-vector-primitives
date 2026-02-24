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

import Sequence_Primitives_Core

extension Bit.Vector.Zeros {
    /// A sequence of clear-bit indices for `Bit.Vector.Bounded`.
    ///
    /// Copies the `ContiguousArray` from the bounded vector so iteration does
    /// not alias mutable storage. Complement of `Ones.Bounded`.
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

// MARK: - Word-Level Search

extension Bit.Vector.Zeros.Bounded {
    /// The first clear bit position below `max`, or `nil` if none.
    ///
    /// Word-level scanning: inverts each word and uses
    /// `trailingZeroBitCount` to find the lowest zero. O(words).
    ///
    /// - Parameter max: Upper bound (exclusive) on the bit position.
    @inlinable
    public func first(max: Bit.Index.Count) -> Bit.Index? {
        for i in 0..<_storage.count {
            let inverted = ~_storage[i]
            if inverted != 0 {
                let location = Bit.Pack<UInt>.Location(
                    word: .init(Ordinal(UInt(i))),
                    bit: .init(Affine.Discrete.Vector(inverted.trailingZeroBitCount))
                )
                let globalIndex = location.index(bitsPerWord: .bitsPerWord)
                guard globalIndex < max else { return nil }
                return globalIndex
            }
        }
        return nil
    }
}

// MARK: - Sequence.Protocol

extension Bit.Vector.Zeros.Bounded: Sequence.`Protocol` {
    public typealias Element = Bit.Index

    @inlinable
    public func makeIterator() -> Iterator {
        Iterator(storage: _storage, capacity: _capacity)
    }
}

// MARK: - Swift.Sequence

extension Bit.Vector.Zeros.Bounded: Swift.Sequence {
    /// Disambiguates `underestimatedCount` between the default provided by
    /// `Sequence.Protocol where Self: Copyable` and `Swift.Sequence`.
    @inlinable
    public var underestimatedCount: Int { 0 }
}
