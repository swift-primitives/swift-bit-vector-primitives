extension Bit.Vector.Static {

    @inlinable
    public mutating func toggle(_ index: Bit.Index) {
        precondition(index < Self.capacity, "Index out of bounds")
        let location = Bit.Pack<UInt>.Location(index: index, bitsPerWord: .bitsPerWord)
        _storage[location.word] ^= location.mask
    }
}
