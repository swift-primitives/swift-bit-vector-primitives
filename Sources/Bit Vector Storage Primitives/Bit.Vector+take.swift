extension Bit.Vector {

    @inlinable
    public mutating func take() -> Bit.Vector {
        var empty = Bit.Vector(capacity: capacity)
        swap(&self, &empty)
        return empty
    }
}
