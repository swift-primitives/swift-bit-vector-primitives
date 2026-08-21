import Property_Primitives

extension Bit.Vector.Bounded {

    public enum Statistic: Sendable {}
}

extension Bit.Vector.Bounded {

    @inlinable
    public var statistic: Property<Statistic, Self> {
        Property(self)
    }
}

extension Property where Tag == Bit.Vector.Bounded.Statistic, Base == Bit.Vector.Bounded {

    @inlinable
    public var `true`: Bit.Index.Count { base.popcount }

    @inlinable
    public var `false`: Bit.Index.Count { base._count.subtract.saturating(base.popcount) }
}
