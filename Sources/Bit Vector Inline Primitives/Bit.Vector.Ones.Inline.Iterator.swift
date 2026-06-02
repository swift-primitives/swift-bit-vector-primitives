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

extension Bit.Vector.Ones.Inline {
    // SAFETY: Safe by construction — backing storage uses only stdlib
    // SAFETY: safe types; `@safe` documents that this type performs no
    // SAFETY: unsafe operations.
    /// An iterator that produces set-bit indices from an `InlineArray` of words.
    ///
    /// Same Wegner/Kernighan algorithm as `Ones.Static.Iterator` but bounds-checks
    /// against the logical capacity (Inline has variable count).
    ///
    /// - Complexity: O(popcount) total across all `next()` calls.
    @safe
    public struct Iterator: Iterator_Primitive.Iterator.`Protocol`, IteratorProtocol {
        @usableFromInline
        let _storage: InlineArray<wordCount, UInt>

        @usableFromInline
        let _capacity: Bit.Index.Count

        @usableFromInline
        var _wordIndex: Int

        @usableFromInline
        var _currentWord: UInt

        @inlinable
        package init(storage: InlineArray<wordCount, UInt>, capacity: Bit.Index.Count) {
            self._storage = storage
            self._capacity = capacity
            self._wordIndex = 0
            if wordCount > 0 {
                self._currentWord = storage[0]
            } else {
                self._currentWord = 0
            }
        }

        /// Advances to and returns the next index, or `nil` when exhausted.
        @inlinable
        public mutating func next() -> Bit.Index? {
            // Advance to next word with set bits
            while _currentWord == 0 {
                _wordIndex += 1
                guard _wordIndex < wordCount else { return nil }
                _currentWord = _storage[_wordIndex]
            }

            // Wegner/Kernighan: extract lowest set bit
            let bitPosition = _currentWord.trailingZeroBitCount
            _currentWord &= _currentWord &- 1

            // Compute global bit index via pack location
            let wordCount = Index_Primitives.Index<UInt>.Count(Cardinal(UInt(_wordIndex)))
            let baseBitCount = wordCount * .bitsPerWord
            let globalIndex = baseBitCount.map(Ordinal.init) + Bit.Index.Count(Cardinal(UInt(bitPosition)))

            guard globalIndex < _capacity else { return nil }
            return globalIndex
        }
    }
}
