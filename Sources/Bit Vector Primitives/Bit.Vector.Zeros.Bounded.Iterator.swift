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

extension Bit.Vector.Zeros.Bounded {
    /// An iterator that produces clear-bit indices from a `ContiguousArray` of words.
    ///
    /// Same complement + Wegner/Kernighan algorithm as `Zeros.Static.Iterator` but
    /// reads from a copied `ContiguousArray` and bounds-checks against capacity.
    ///
    /// - Complexity: O(zero-count) total across all `next()` calls.
    @safe
    public struct Iterator: Sequence.Iterator.`Protocol`, IteratorProtocol {
        @usableFromInline
        let _storage: ContiguousArray<UInt>

        @usableFromInline
        let _capacity: Bit.Index.Count

        @usableFromInline
        var _wordIndex: Int

        @usableFromInline
        var _currentWord: UInt

        @inlinable
        package init(storage: ContiguousArray<UInt>, capacity: Bit.Index.Count) {
            self._storage = storage
            self._capacity = capacity
            self._wordIndex = 0
            if !storage.isEmpty {
                self._currentWord = ~storage[0]
            } else {
                self._currentWord = 0
            }
        }

        @inlinable
        public mutating func next() -> Bit.Index? {
            // Advance to next word with clear bits
            while _currentWord == 0 {
                _wordIndex += 1
                guard _wordIndex < _storage.count else { return nil }
                _currentWord = ~_storage[_wordIndex]
            }

            // Wegner/Kernighan: extract lowest set bit of complemented word
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
