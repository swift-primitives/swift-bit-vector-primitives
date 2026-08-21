import Affine_Primitives

extension Bit.Vector.Dynamic {

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

}
