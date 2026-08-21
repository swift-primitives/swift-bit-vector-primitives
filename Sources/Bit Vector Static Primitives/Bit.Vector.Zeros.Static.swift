import Affine_Primitives
public import Iterator_Chunk_Primitives
public import Iterator_Primitive
import Sequence_Primitives

extension Bit.Vector.Zeros {

    @safe
    public struct Static<let wordCount: Int>: Copyable, Sendable {
        @usableFromInline
        let _storage: InlineArray<wordCount, UInt>

        @inlinable
        package init(storage: InlineArray<wordCount, UInt>) {
            self._storage = storage
        }
    }
}

extension Bit.Vector.Zeros.Static {

    @inlinable
    public func first(max: Bit.Index.Count) -> Bit.Index? {
        for i in 0..<wordCount {
            let inverted = ~_storage[i]
            if inverted != 0 {
                let location = Bit.Pack<UInt>.Location(
                    word: .init(Ordinal(UInt(i))),
                    bit: .init(Affine.Discrete.Vector(inverted.trailingZeroBitCount))
                )
                let globalIndex = location.index(bitsPerWord: .bitsPerWord)
                guard globalIndex < max else { return nil }
                return globalIndex
            }
        }
        return nil
    }
}

extension Bit.Vector.Zeros.Static: Iterable {

    public typealias Element = Bit.Index

    @_implements(Iterable,Iterator)
    public typealias IterableIterator = Iterator_Primitive.Iterator.Materializing<Iterator>

    @inlinable
    @_lifetime(borrow self)
    @_implements(Iterable,makeIterator())
    public borrowing func iterableMakeIterator()
        -> Iterator_Primitive.Iterator.Materializing<Iterator>
    {
        Iterator_Primitive.Iterator.Materializing(Iterator(storage: _storage))
    }

    @inlinable
    public func makeIterator() -> Iterator {
        Iterator(storage: _storage)
    }
}

extension Bit.Vector.Zeros.Static: Swift.Sequence {}
