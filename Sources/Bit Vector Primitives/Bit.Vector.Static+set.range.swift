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
        let startRaw = Int(bitPattern: range.lowerBound.rawValue.rawValue)
        let endRaw = Int(bitPattern: range.upperBound.rawValue.rawValue)
        guard endRaw > startRaw else { return }

        let bitsPerWord = UInt.bitWidth
        let startWord = startRaw / bitsPerWord
        let startBit = startRaw % bitsPerWord
        let lastBit = endRaw - 1
        let endWord = lastBit / bitsPerWord
        let endBit = lastBit % bitsPerWord

        let lowMask: UInt = ~0 << startBit
        let highMask: UInt = ~0 >> (bitsPerWord - 1 - endBit)

        if startWord == endWord {
            unsafe base.pointee._storage[startWord] |= (lowMask & highMask)
        } else {
            unsafe base.pointee._storage[startWord] |= lowMask
            for w in (startWord + 1)..<endWord {
                unsafe base.pointee._storage[w] = ~0
            }
            unsafe base.pointee._storage[endWord] |= highMask
        }
    }
}
