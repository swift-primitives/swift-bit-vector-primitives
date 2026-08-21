import Affine_Primitives

extension Bit.Vector.Dynamic {

    @inlinable
    public init(_ bounded: Bit.Vector.Bounded) {
        self._storage = bounded._storage
        self._count = bounded._count
    }
}

extension Bit.Vector.Dynamic {

    @inlinable
    public init<let wordCount: Int>(_ inline: Bit.Vector.Inline<wordCount>) {
        let pack = Bit.Pack<UInt>(count: inline._count, bitsPerWord: .bitsPerWord)
        let end = pack.words.count.map(Ordinal.init)
        self._storage = ContiguousArray<UInt>()
        self._storage.reserveCapacity(pack.words.count)
        var w: Index<UInt> = .zero
        while w < end {
            self._storage.append(inline._storage[w])
            w += Index<UInt>.Count.one
        }
        self._count = inline._count
    }
}
