extension Bit.Vector: Bit.Vector.`Protocol` {

    @inlinable
    public var bitCapacity: Bit.Index.Count { capacity }

    @inlinable
    public borrowing func word(at index: Int) -> UInt {
        unsafe _words[index]
    }

    @inlinable
    public mutating func setWord(at index: Int, to value: UInt) {
        unsafe _words[index] = value
    }

}
