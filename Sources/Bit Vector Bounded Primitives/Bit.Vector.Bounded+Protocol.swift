extension Bit.Vector.Bounded: Bit.Vector.`Protocol` {

    @inlinable
    public var bitCapacity: Bit.Index.Count { _capacity }

    @inlinable
    public borrowing func word(at index: Int) -> UInt {
        _storage[index]
    }

    @inlinable
    public mutating func setWord(at index: Int, to value: UInt) {
        _storage[index] = value
    }

}
