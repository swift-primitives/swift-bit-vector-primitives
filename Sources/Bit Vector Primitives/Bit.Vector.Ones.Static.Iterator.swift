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

extension Bit.Vector.Ones.Static {
    /// An iterator that produces set-bit indices from an `InlineArray` of words.
    ///
    /// Same Wegner/Kernighan algorithm as `Ones.View.Iterator` but reads from
    /// a copied `InlineArray` instead of a pointer.
    @safe
    public struct Iterator: Sequence.Iterator.`Protocol`, IteratorProtocol {
        @usableFromInline
        let _storage: InlineArray<wordCount, UInt>

        @usableFromInline
        var _wordIndex: Int

        @usableFromInline
        var _currentWord: UInt

        @inlinable
        package init(storage: InlineArray<wordCount, UInt>) {
            self._storage = storage
            self._wordIndex = 0
            if wordCount > 0 {
                self._currentWord = storage[0]
            } else {
                self._currentWord = 0
            }
        }

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

            let wordCount = Index_Primitives.Index<UInt>.Count(Cardinal(UInt(_wordIndex)))
            let baseBitCount = wordCount * .bitsPerWord
            return baseBitCount.map(Ordinal.init) + Bit.Index.Count(Cardinal(UInt(bitPosition)))
        }
    }
}
