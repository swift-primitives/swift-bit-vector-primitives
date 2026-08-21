extension Bit.Vector.Bounded: Swift.Sequence {

    public struct Iterator: Iterator_Primitive.Iterator.`Protocol`, IteratorProtocol, Sendable {
        @usableFromInline
        let storage: ContiguousArray<UInt>

        @usableFromInline
        let count: Int

        @usableFromInline
        var index: Int

        @usableFromInline
        init(storage: ContiguousArray<UInt>, count: Int) {
            self.storage = storage
            self.count = count
            self.index = 0
        }
    }

    @inlinable
    public func makeIterator() -> Iterator {
        Iterator(storage: _storage, count: Int(clamping: _count))
    }
}

extension Bit.Vector.Bounded.Iterator {

    @inlinable
    public mutating func next() -> Bool? {
        guard index < count else { return nil }
        let wordIndex = index / UInt.bitWidth
        let bitIndex = index % UInt.bitWidth
        let mask: UInt = 1 << bitIndex
        defer { index += 1 }
        return (storage[wordIndex] & mask) != 0
    }
}
