import Index_Primitives

extension Bit.Vector.Ones {

    @safe

    public struct View: Copyable, ~Escapable {
        @usableFromInline
        let _words: UnsafeMutablePointer<UInt>

        @usableFromInline
        let _wordCount: Index_Primitives.Index<UInt>.Count

        @usableFromInline
        let _capacity: Bit.Index.Count

        @inlinable
        @_lifetime(borrow vector)
        package init(vector: borrowing Bit.Vector) {
            unsafe self._words = vector._words
            self._wordCount = vector._wordCount
            self._capacity = vector.capacity
        }
    }
}
