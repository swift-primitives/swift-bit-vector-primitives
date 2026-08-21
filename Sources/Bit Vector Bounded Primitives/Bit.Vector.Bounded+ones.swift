extension Bit.Vector.Bounded {

    @inlinable
    public var ones: Bit.Vector.Ones.Bounded {
        Bit.Vector.Ones.Bounded(storage: _storage, capacity: _capacity)
    }
}
