import Index_Primitives

extension Bit.Vector {

    @inlinable
    public var zeros: Zeros.View {
        @_lifetime(borrow self)
        borrowing get {
            Zeros.View(vector: self)
        }
    }
}
