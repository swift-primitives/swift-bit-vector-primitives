public import Iterator_Chunk_Primitives
public import Iterator_Primitive
import Sequence_Primitives

extension Bit.Vector.Ones.View: Iterable {

    public typealias Element = Bit.Index

    @_implements(Iterable,Iterator)
    public typealias IterableIterator = Iterator_Primitive.Iterator.Materializing<Iterator>

    @inlinable
    @_lifetime(borrow self)
    @_implements(Iterable,makeIterator())
    public borrowing func iterableMakeIterator()
        -> Iterator_Primitive.Iterator.Materializing<Iterator>
    {
        Iterator_Primitive.Iterator.Materializing(Iterator(view: copy self))
    }

    @inlinable
    @_lifetime(copy self)
    public borrowing func makeIterator() -> Iterator {
        Iterator(view: copy self)
    }
}

extension Bit.Vector.Ones.View {

    @inline(always)
    @inlinable
    public func forEach(_ body: (Bit.Index) -> Void) {
        var iterator: Iterator = makeIterator()
        while let element = iterator.next() {
            body(element)
        }
    }
}
