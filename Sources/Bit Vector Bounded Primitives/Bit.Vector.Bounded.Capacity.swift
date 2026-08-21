import Property_Primitives

extension Bit.Vector.Bounded {

    public enum Capacity: Sendable {}
}

extension Bit.Vector.Bounded {

    @inlinable
    public var capacity: Property<Capacity, Self> {
        Property(self)
    }
}

extension Property where Tag == Bit.Vector.Bounded.Capacity, Base == Bit.Vector.Bounded {

    @inlinable
    public var maximum: Bit.Index.Count { base._capacity }

    @inlinable
    public var remaining: Bit.Index.Count { base._capacity.subtract.saturating(base._count) }
}
