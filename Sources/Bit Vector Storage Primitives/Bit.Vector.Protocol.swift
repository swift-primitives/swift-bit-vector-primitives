extension Bit.Vector {

    public protocol `Protocol`: ~Copyable {

        var bitCapacity: Bit.Index.Count { get }

        borrowing func word(at index: Int) -> UInt

        mutating func setWord(at index: Int, to value: UInt)

        subscript(index: Bit.Index) -> Bool { get set }
    }
}
