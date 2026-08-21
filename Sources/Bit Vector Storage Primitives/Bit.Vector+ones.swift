import Index_Primitives

extension Bit.Vector {

    @inlinable
    public var ones: Ones.View {
        @_lifetime(borrow self)
        borrowing get {
            Ones.View(vector: self)
        }
    }
}
