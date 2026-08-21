extension Bit.Vector.Bounded {

    @inlinable
    public mutating func take() -> Bit.Vector.Bounded {
        var empty = Bit.Vector.Bounded(capacity: _capacity)
        swap(&self, &empty)
        return empty
    }
}
