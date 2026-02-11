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

extension Property.View where Tag == Bit.Vector.Set {
    /// Sets all bits in the given range to true.
    ///
    /// Uses word-level operations for O(wordCount) performance regardless
    /// of range size. An empty range is a no-op.
    ///
    /// - Parameter range: The half-open range of bit indices to set.
    /// - Complexity: O(wordCount) — constant for fixed-size vectors.
    @inlinable
    public func range<let wordCount: Int>(
        _ range: Swift.Range<Bit.Index>
    ) where Base == Bit.Vector.Static<wordCount> {
        guard range.upperBound > range.lowerBound else { return }

        let startLoc = Bit.Pack<UInt>.Location(index: range.lowerBound, bitsPerWord: .bitsPerWord)
        let endLoc = Bit.Pack<UInt>.Location(index: try! range.upperBound.predecessor.exact(), bitsPerWord: .bitsPerWord)
        let startBit = startLoc.bit.magnitude
        let endBit = endLoc.bit.magnitude

        let lowMask: UInt = ~0 << startBit
        let maxBitIndex = try! Bit.Pack<UInt>.bitWidth.subtract.exact(.one)
        let highShift = try! maxBitIndex.subtract.exact(endBit)
        let highMask: UInt = ~0 >> highShift

        if startLoc.word == endLoc.word {
            unsafe base.pointee._storage[startLoc.word] |= (lowMask & highMask)
        } else {
            unsafe base.pointee._storage[startLoc.word] |= lowMask
            var w = startLoc.word + Index<UInt>.Count.one
            while w < endLoc.word {
                unsafe base.pointee._storage[w] = ~0
                w = w + Index<UInt>.Count.one
            }
            unsafe base.pointee._storage[endLoc.word] |= highMask
        }
    }
}
