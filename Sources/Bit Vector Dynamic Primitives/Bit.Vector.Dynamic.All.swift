import Property_Primitives

extension Bit.Vector.Dynamic {

    public enum All: Sendable {}
}

extension Bit.Vector.Dynamic {

    @inlinable
    public var all: Property<All, Self> {
        Property(self)
    }
}

extension Property where Tag == Bit.Vector.Dynamic.All, Base == Bit.Vector.Dynamic {

    @inlinable
    public var `true`: Bool {
        guard base._count > .zero else { return true }
        return base.popcount == base._count
    }

    @inlinable
    public var `false`: Bool {
        base.popcount == .zero
    }
}
