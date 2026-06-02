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

// MARK: - Sequence

extension Bit.Vector.Inline: Swift.Sequence {
    /// An iterator over all bits in the inline vector.
    public struct Iterator: Iterator_Primitive.Iterator.`Protocol`, IteratorProtocol, Sendable {
        @usableFromInline
        let storage: InlineArray<wordCount, UInt>

        @usableFromInline
        let count: Int

        @usableFromInline
        var index: Int

        @usableFromInline
        init(storage: InlineArray<wordCount, UInt>, count: Int) {
            self.storage = storage
            self.count = count
            self.index = 0
        }

        /// Advances to and returns the next bit, or `nil` when exhausted.
        @inlinable
        public mutating func next() -> Bool? {
            guard index < count else { return nil }
            let wordIndex = index / UInt.bitWidth
            let bitIndex = index % UInt.bitWidth
            let mask: UInt = 1 << bitIndex
            defer { index += 1 }
            return (storage[wordIndex] & mask) != 0
        }
    }

    /// Returns an iterator over the bits.
    @inlinable
    public func makeIterator() -> Iterator {
        Iterator(storage: _storage, count: Int(clamping: _count))
    }
}
