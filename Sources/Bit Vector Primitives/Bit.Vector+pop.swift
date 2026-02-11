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
import Index_Primitives

extension Bit.Vector {
    @inlinable
    public var pop: Property<Pop, Self>.View {
        mutating _read {
            yield unsafe Property<Pop, Self>.View(&self)
        }
        mutating _modify {
            var view = unsafe Property<Pop, Self>.View(&self)
            yield &view
        }
    }
}

extension Property.View where Tag == Bit.Vector.Pop, Base == Bit.Vector {
    /// Removes and returns the index of the lowest set bit.
    ///
    /// Scans words from the start, extracts the lowest set bit using
    /// Wegner/Kernighan (`w &= w &- 1`), clears it in the backing storage,
    /// and returns the global bit index.
    ///
    /// - Returns: The index of the lowest set bit, or `nil` if no bits are set.
    /// - Complexity: O(words) per call, O(words * popcount) total for full drain.
    @inlinable
    public func first() -> Bit.Index? {
        var wordIndex: Index_Primitives.Index<UInt> = .zero
        while unsafe wordIndex < base.pointee._wordCount {
            let word = unsafe base.pointee._words[wordIndex]
            if word != 0 {
                let bitPosition = word.trailingZeroBitCount
                // Wegner/Kernighan: clear lowest set bit in actual storage
                unsafe base.pointee._words[wordIndex] = word & (word &- 1)
                // Compute global bit index
                let wordAsCount = Index_Primitives.Index<UInt>.Count(wordIndex)
                let baseBitCount = wordAsCount * .bitsPerWord
                let globalIndex = baseBitCount.map(Ordinal.init) + Bit.Index.Count(UInt(bitPosition))
                guard unsafe globalIndex < base.pointee.capacity else { return nil }
                return globalIndex
            }
            wordIndex += .one
        }
        return nil
    }
}
