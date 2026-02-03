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

extension Bit.Vector.Static {
    @inlinable
    public var ones: Property<Bit.Vector.Ones, Self> {
        Property(self)
    }
}

extension Property where Tag == Bit.Vector.Ones {
    /// Calls the closure for each index where the bit is set.
    ///
    /// - Parameter body: A closure that receives each set bit's index.
    /// - Complexity: O(popcount) — only visits set bits.
    @inlinable
    public func forEach<let wordCount: Int>(_ body: (Bit.Index) -> Void) where Base == Bit.Vector.Static<wordCount> {
        for wordIndex in 0..<wordCount {
            let wordBase = Bit.Index(Index_Primitives.Index<UInt>.Count(Cardinal(UInt(wordIndex))) * .bitsPerWord)
            base._storage[wordIndex].set.forEach { bitIndex in
                let globalIndex = wordBase + Bit.Index.Count(Cardinal(UInt(bitIndex)))
                body(globalIndex)
            }
        }
    }
}
