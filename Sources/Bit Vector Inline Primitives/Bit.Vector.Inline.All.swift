import Property_Primitives

extension Bit.Vector.Inline {

    public enum All: Sendable {}
}

extension Bit.Vector.Inline.All {

    public typealias View = Property<Self, Bit.Vector.Inline<wordCount>>.Inout.Typed<Bit>.Valued<
        wordCount
    >
}

extension Bit.Vector.Inline {

    @inlinable
    public var all: All.View {
        mutating _read { yield.init(&self) }
    }
}

extension Property.Inout.Typed.Valued
where Tag == Bit.Vector.Inline<n>.All, Base == Bit.Vector.Inline<n>, Element == Bit {

    @inlinable
    public var `true`: Bool {
        let base = base.value
        guard base._count > .zero else { return true }
        return base.popcount == base._count
    }

    @inlinable
    public var `false`: Bool {
        base.value.popcount == .zero
    }
}
