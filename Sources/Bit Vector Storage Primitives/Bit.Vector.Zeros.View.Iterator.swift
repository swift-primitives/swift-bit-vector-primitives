import Index_Primitives

extension Bit.Vector.Zeros.View {

    @safe
    public struct Iterator: Iterator_Primitive.Iterator.`Protocol`, Copyable, ~Escapable {
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
        @_lifetime(copy view)
        package init(view: Bit.Vector.Zeros.View) {
            unsafe self._words = view._words
            self._wordCount = view._wordCount
            self._capacity = view._capacity
            self._wordIndex = .zero
            if view._wordCount > .zero {
                unsafe self._currentWord = ~view._words[.zero]
            } else {
                self._currentWord = 0
            }
        }
    }
}

extension Bit.Vector.Zeros.View.Iterator {

    @inlinable
    public mutating func next() -> Bit.Index? {

        while _currentWord == 0 {
            let next = _wordIndex.successor.saturating()
            guard next < _wordCount else { return nil }
            _wordIndex = next
            unsafe _currentWord = ~_words[_wordIndex]
        }

        let bitPosition = _currentWord.trailingZeroBitCount
        _currentWord &= _currentWord &- 1

        let wordAsCount = Index_Primitives.Index<UInt>.Count(_wordIndex)
        let baseBitCount = wordAsCount * .bitsPerWord
        let globalIndex =
            baseBitCount.map(Ordinal.init) + Bit.Index.Count(Cardinal(UInt(bitPosition)))

        guard globalIndex < _capacity else { return nil }
        return globalIndex
    }
}
