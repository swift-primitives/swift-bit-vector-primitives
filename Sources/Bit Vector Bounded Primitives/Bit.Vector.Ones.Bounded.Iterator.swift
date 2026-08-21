import Index_Primitives

extension Bit.Vector.Ones.Bounded {

    @safe
    public struct Iterator: Iterator_Primitive.Iterator.`Protocol`, IteratorProtocol {
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
                self._currentWord = storage[0]
            } else {
                self._currentWord = 0
            }
        }
    }
}

extension Bit.Vector.Ones.Bounded.Iterator {

    @inlinable
    public mutating func next() -> Bit.Index? {

        while _currentWord == 0 {
            _wordIndex += 1
            guard _wordIndex < _storage.count else { return nil }
            _currentWord = _storage[_wordIndex]
        }

        let bitPosition = _currentWord.trailingZeroBitCount
        _currentWord &= _currentWord &- 1

        let wordCount = Index_Primitives.Index<UInt>.Count(Cardinal(UInt(_wordIndex)))
        let baseBitCount = wordCount * .bitsPerWord
        let globalIndex =
            baseBitCount.map(Ordinal.init) + Bit.Index.Count(Cardinal(UInt(bitPosition)))

        guard globalIndex < _capacity else { return nil }
        return globalIndex
    }
}
