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

import Index_Primitives

extension Bit.Vector {
    /// Non-mutating accessor for iterating set bits.
    ///
    /// Returns a lightweight view that captures the word pointer, word count,
    /// and capacity. Safe to use from any context including `deinit`.
    @inlinable
    public var ones: Ones.View {
        unsafe Ones.View(words: _words, wordCount: _wordCount, capacity: capacity)
    }
}

extension Bit.Vector.Ones.View {
    /// Calls the closure for each index where the bit is set.
    ///
    /// - Parameter body: A closure that receives each set bit's index.
    /// - Complexity: O(popcount) — only visits set bits.
    @inlinable
    public func forEach(_ body: (Bit.Index) -> Void) {
        (.zero..<_wordCount).forEach { wordIndex in
            let wordBase = Bit.Index(Index_Primitives.Index<UInt>.Count(wordIndex) * .bitsPerWord)
            unsafe _words[wordIndex].set.forEach { bitIndex in
                let globalIndex = wordBase + Bit.Index.Count(Cardinal(UInt(bitIndex)))
                if globalIndex < _capacity {
                    body(globalIndex)
                }
            }
        }
    }
}
