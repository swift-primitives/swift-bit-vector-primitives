extension Bit.Vector.Bounded: Equatable {

    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        guard lhs._count == rhs._count else { return false }
        let pack = Bit.Pack<UInt>(count: lhs._count, bitsPerWord: .bitsPerWord)
        let end = pack.words.count.map(Ordinal.init)
        var w: Index<UInt> = .zero
        while w < end {
            if lhs._storage[w] != rhs._storage[w] { return false }
            w += Index<UInt>.Count.one
        }
        return true
    }
}

extension Bit.Vector.Bounded: Hashable {

    @inlinable
    public func hash(into hasher: inout Hasher) {
        let pack = Bit.Pack<UInt>(count: _count, bitsPerWord: .bitsPerWord)
        let end = pack.words.count.map(Ordinal.init)
        hasher.combine(_count)
        var w: Index<UInt> = .zero
        while w < end {
            hasher.combine(_storage[w])
            w += Index<UInt>.Count.one
        }
    }
}

extension Bit.Vector.Bounded: CustomStringConvertible {

    public var description: String {
        let bits = prefix(64).map { $0 ? "1" : "0" }.joined()
        let suffix = Int(clamping: _count) > 64 ? "..." : ""
        return "Bit.Vector.Bounded(\(bits)\(suffix), capacity: \(Int(clamping: _capacity)))"
    }
}
