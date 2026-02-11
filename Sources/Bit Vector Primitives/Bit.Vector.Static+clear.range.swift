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

import Property_Primitives

extension Property.View where Tag == Bit.Vector.Clear {
    /// Clears all bits in the given range to false.
    ///
    /// Uses word-level operations for O(wordCount) performance regardless
    /// of range size. An empty range is a no-op.
    ///
    /// - Parameter range: The half-open range of bit indices to clear.
    /// - Complexity: O(wordCount) — constant for fixed-size vectors.
    @inlinable
    public func range<let wordCount: Int>(
        _ range: Swift.Range<Bit.Index>
    ) where Base == Bit.Vector.Static<wordCount> {
        guard range.upperBound > range.lowerBound else { return }

        let startLoc = Bit.Pack<UInt>.Location(index: range.lowerBound, bitsPerWord: .bitsPerWord)
        let endLoc = Bit.Pack<UInt>.Location(index: try! range.upperBound.predecessor.exact(), bitsPerWord: .bitsPerWord)
        let startBit = Int(bitPattern: startLoc.bit)
        let endBit = Int(bitPattern: endLoc.bit)

        let lowMask: UInt = ~0 << startBit
        let highMask: UInt = ~0 >> (UInt.bitWidth - 1 - endBit)

        if startLoc.word == endLoc.word {
            unsafe base.pointee._storage[startLoc.word] &= ~(lowMask & highMask)
        } else {
            unsafe base.pointee._storage[startLoc.word] &= ~lowMask
            var w = startLoc.word + Index<UInt>.Count.one
            while w < endLoc.word {
                unsafe base.pointee._storage[w] = 0
                w = w + Index<UInt>.Count.one
            }
            unsafe base.pointee._storage[endLoc.word] &= ~highMask
        }
    }
}
