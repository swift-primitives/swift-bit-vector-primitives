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
        let lastIndex = Bit.Index(Ordinal(range.upperBound.rawValue.rawValue &- 1))
        let endLoc = Bit.Pack<UInt>.Location(index: lastIndex, bitsPerWord: .bitsPerWord)
        let startWord = Int(bitPattern: startLoc.word)
        let startBit = Int(bitPattern: startLoc.bit)
        let endWord = Int(bitPattern: endLoc.word)
        let endBit = Int(bitPattern: endLoc.bit)

        let lowMask: UInt = ~0 << startBit
        let highMask: UInt = ~0 >> (UInt.bitWidth - 1 - endBit)

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
