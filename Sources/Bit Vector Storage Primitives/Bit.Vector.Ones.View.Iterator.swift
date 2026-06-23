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

extension Bit.Vector.Ones.View {
    // SAFETY: Encapsulates unsafe internals behind a safe API; see
    // SAFETY: [MEM-SAFE-024] for the absorber-pattern taxonomy.
    /// An iterator that produces set-bit indices across all words.
    ///
    /// Uses Wegner/Kernighan (`w &= w &- 1`) per word to extract set bits
    /// in ascending order. Advances to the next word when all set bits in the
    /// current word are exhausted.
    ///
    /// - Complexity: O(popcount) total across all `next()` calls.
    @safe
    public struct Iterator: Iterator_Primitive.Iterator.`Protocol`, IteratorProtocol {
        @usableFromInline
        let _words: UnsafeMutablePointer<UInt>

        @usableFromInline
        let _wordCount: Index_Primitives.Index<UInt>.Count

        @usableFromInline
        let _capacity: Bit.Index.Count

        @usableFromInline
        var _wordIndex: Index_Primitives.Index<UInt>

        @usableFromInline
        var _currentWord: UInt

        @inlinable
        package init(view: Bit.Vector.Ones.View) {
            unsafe self._words = view._words
            self._wordCount = view._wordCount
            self._capacity = view._capacity
            self._wordIndex = .zero
            if view._wordCount > .zero {
                unsafe self._currentWord = view._words[.zero]
            } else {
                self._currentWord = 0
            }
        }

        /// Advances to and returns the next index, or `nil` when exhausted.
        @inlinable
        public mutating func next() -> Bit.Index? {
            // Advance to next word with set bits
            while _currentWord == 0 {
                let next = _wordIndex.successor.saturating()
                guard next < _wordCount else { return nil }
                _wordIndex = next
                unsafe _currentWord = _words[_wordIndex]
            }

            // Wegner/Kernighan: extract lowest set bit
            let bitPosition = _currentWord.trailingZeroBitCount
            _currentWord &= _currentWord &- 1

            // Compute global bit index via pack location
            let wordAsCount = Index_Primitives.Index<UInt>.Count(_wordIndex)
            let baseBitCount = wordAsCount * .bitsPerWord
            let globalIndex = baseBitCount.map(Ordinal.init) + Bit.Index.Count(Cardinal(UInt(bitPosition)))

            guard globalIndex < _capacity else { return nil }
            return globalIndex
        }
    }
}
