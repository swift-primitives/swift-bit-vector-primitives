public import Iterator_Chunk_Primitives
public import Iterator_Primitive
import Sequence_Primitives

extension Bit.Vector.Ones {

    @safe
    public struct Bounded: Copyable, Sendable {
        @usableFromInline
        let _storage: ContiguousArray<UInt>

        @usableFromInline
        let _capacity: Bit.Index.Count

        @inlinable
        package init(storage: ContiguousArray<UInt>, capacity: Bit.Index.Count) {
            self._storage = storage
            self._capacity = capacity
        }
    }
}

extension Bit.Vector.Ones.Bounded: Iterable {

    public typealias Element = Bit.Index

    @_implements(Iterable,Iterator)
    public typealias IterableIterator = Iterator_Primitive.Iterator.Materializing<Iterator>

    @inlinable
    @_lifetime(borrow self)
    @_implements(Iterable,makeIterator())
    public borrowing func iterableMakeIterator()
        -> Iterator_Primitive.Iterator.Materializing<Iterator>
    {
        Iterator_Primitive.Iterator.Materializing(Iterator(storage: _storage, capacity: _capacity))
    }

    @inlinable
    public func makeIterator() -> Iterator {
        Iterator(storage: _storage, capacity: _capacity)
    }
}

extension Bit.Vector.Ones.Bounded: Swift.Sequence {}
