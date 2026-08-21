import Property_Primitives

extension Bit.Vector.Dynamic {

    public enum Statistic: Sendable {}
}

extension Bit.Vector.Dynamic {

    @inlinable
    public var statistic: Property<Statistic, Self> {
        Property(self)
    }
}

extension Property where Tag == Bit.Vector.Dynamic.Statistic, Base == Bit.Vector.Dynamic {

    @inlinable
    public var `true`: Bit.Index.Count { base.popcount }

    @inlinable
    public var `false`: Bit.Index.Count { base._count.subtract.saturating(base.popcount) }
}
