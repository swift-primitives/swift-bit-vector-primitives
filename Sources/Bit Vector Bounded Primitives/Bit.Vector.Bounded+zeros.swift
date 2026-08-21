extension Bit.Vector.Bounded {

    @inlinable
    public var zeros: Bit.Vector.Zeros.Bounded {
        Bit.Vector.Zeros.Bounded(storage: _storage, capacity: _capacity)
    }
}
