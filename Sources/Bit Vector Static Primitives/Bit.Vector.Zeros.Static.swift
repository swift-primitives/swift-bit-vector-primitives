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
    /// A sequence of clear-bit indices for `Bit.Vector.Static`.
    ///
    /// Copies the `InlineArray` from the static vector so iteration does not
    /// require a pointer into stack storage (which would dangle on temporaries).
    ///
    /// Conforms to both `Sequence.Protocol` and `Swift.Sequence`, providing
    /// `forEach`, `map`, `filter`, `for-in`, and all stdlib sequence algorithms.
    ///
    /// - Note: Iterates all zero bits in the full `wordCount * UInt.bitWidth`
    ///   range, including padding bits beyond logical capacity. Callers using
    ///   this with a logical capacity smaller than the storage capacity must
    ///   ensure at least one zero exists within the logical range before
    ///   relying on `.first`.
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

// MARK: - Word-Level Search

extension Bit.Vector.Zeros.Static {
    /// The first clear bit position below `max`, or `nil` if none.
    ///
    /// Word-level scanning: inverts each word and uses
    /// `trailingZeroBitCount` to find the lowest zero. O(words).
    ///
    /// - Parameter max: Upper bound (exclusive) on the bit position.
    @inlinable
    public func first(max: Bit.Index.Count) -> Bit.Index? {
        for i in 0..<wordCount {
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

extension Bit.Vector.Zeros.Static: Sequence.`Protocol` {
    public typealias Element = Bit.Index

    @inlinable
    public func makeIterator() -> Iterator {
        Iterator(storage: _storage)
    }
}

// MARK: - Swift.Sequence

extension Bit.Vector.Zeros.Static: Swift.Sequence {
    /// Disambiguates `underestimatedCount` between the default provided by
    /// `Sequence.Protocol where Self: Copyable` and `Swift.Sequence`.
    @inlinable
    public var underestimatedCount: Int { 0 }
}
