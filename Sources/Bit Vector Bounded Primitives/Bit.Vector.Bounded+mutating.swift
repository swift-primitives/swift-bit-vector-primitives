import Affine_Primitives

extension Bit.Vector.Bounded {

    @inlinable
    public mutating func set(_ index: Bit.Index) throws(Self.Error) {
        guard index < _count else {
            throw .bounds(index: index, count: _count)
        }
        let loc = index.location(bitsPerWord: .bitsPerWord)
        _storage[loc.word] |= loc.mask
    }

    @inlinable
    public mutating func clear(_ index: Bit.Index) throws(Self.Error) {
        guard index < _count else {
            throw .bounds(index: index, count: _count)
        }
        let loc = index.location(bitsPerWord: .bitsPerWord)
        _storage[loc.word] &= ~loc.mask
    }

    @inlinable
    public mutating func toggle(_ index: Bit.Index) throws(Self.Error) {
        guard index < _count else {
            throw .bounds(index: index, count: _count)
        }
        let loc = index.location(bitsPerWord: .bitsPerWord)
        _storage[loc.word] ^= loc.mask
    }

    @inlinable
    public mutating func setAll() {
        let pack = Bit.Pack<UInt>(count: _count, bitsPerWord: .bitsPerWord)
        let end = pack.words.count.map(Ordinal.init)
        var w: Index<UInt> = .zero
        while w < end {
            _storage[w] = ~0
            w += Index<UInt>.Count.one
        }
        if pack.bits.unused > .zero && pack.words.count > .zero {

            let lastWord = try! end.predecessor.exact()
            let mask: UInt = ~0 >> pack.bits.unused
            _storage[lastWord] = mask
        }
    }
}
