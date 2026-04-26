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

extension Property.View where Tag == Bit.Vector.Clear, Base: Bit.Vector.`Protocol` & ~Copyable {
    /// Clears all bits in the given range to false.
    ///
    /// Uses word-level operations for O(wordCount) performance regardless
    /// of range size. An empty range is a no-op.
    ///
    /// - Parameter range: The half-open range of bit indices to clear.
    /// - Complexity: O(wordCount) — constant for fixed-size vectors.
    @inlinable
    public func range(_ range: Swift.Range<Bit.Index>) {
        guard range.upperBound > range.lowerBound else { return }

        let startLoc = Bit.Pack<UInt>.Location(index: range.lowerBound, bitsPerWord: .bitsPerWord)
        let endLoc = Bit.Pack<UInt>.Location(index: try! range.upperBound.predecessor.exact(), bitsPerWord: .bitsPerWord)
        let startBit = startLoc.bit.magnitude
        let endBit = endLoc.bit.magnitude

        let startWord = Int(bitPattern: startLoc.word)
        let endWord = Int(bitPattern: endLoc.word)

        let lowMask: UInt = ~0 << startBit
        let maxBitIndex = try! Bit.Pack<UInt>.bitWidth.subtract.exact(.one)
        let highShift = try! maxBitIndex.subtract.exact(endBit)
        let highMask: UInt = ~0 >> highShift

        if startWord == endWord {
            let current = unsafe base.value.word(at: startWord)
            unsafe base.value.setWord(at: startWord, to: current & ~(lowMask & highMask))
        } else {
            let startCurrent = unsafe base.value.word(at: startWord)
            unsafe base.value.setWord(at: startWord, to: startCurrent & ~lowMask)
            var w = startWord + 1
            while w < endWord {
                unsafe base.value.setWord(at: w, to: 0)
                w += 1
            }
            let endCurrent = unsafe base.value.word(at: endWord)
            unsafe base.value.setWord(at: endWord, to: endCurrent & ~highMask)
        }
    }
}
