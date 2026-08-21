public import Iterator_Chunk_Primitives
public import Iterator_Primitive
import Sequence_Primitives

extension Bit.Vector.Ones {

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

extension Bit.Vector.Ones.Static: Iterable {

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

extension Bit.Vector.Ones.Static: Swift.Sequence {}
