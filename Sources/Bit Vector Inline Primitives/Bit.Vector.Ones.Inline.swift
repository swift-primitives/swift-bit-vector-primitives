public import Iterator_Chunk_Primitives
public import Iterator_Primitive
import Sequence_Primitives

extension Bit.Vector.Ones {

    @safe
    public struct Inline<let wordCount: Int>: Copyable, Sendable {
        @usableFromInline
        let _storage: InlineArray<wordCount, UInt>

        @usableFromInline
        let _capacity: Bit.Index.Count

        @inlinable
        package init(storage: InlineArray<wordCount, UInt>, capacity: Bit.Index.Count) {
            self._storage = storage
            self._capacity = capacity
        }
    }
}

extension Bit.Vector.Ones.Inline: Iterable {

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

extension Bit.Vector.Ones.Inline: Swift.Sequence {}
