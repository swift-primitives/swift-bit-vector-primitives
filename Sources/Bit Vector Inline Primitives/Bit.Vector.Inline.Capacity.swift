import Property_Primitives

extension Bit.Vector.Inline {

    public enum Capacity: Sendable {}
}

extension Bit.Vector.Inline.Capacity {

    public typealias View = Property<Self, Bit.Vector.Inline<wordCount>>.Inout.Typed<Bit>.Valued<
        wordCount
    >
}

extension Bit.Vector.Inline {

    @inlinable
    public var capacity: Capacity.View {
        mutating _read { yield.init(&self) }
    }
}

extension Property.Inout.Typed.Valued
where Tag == Bit.Vector.Inline<n>.Capacity, Base == Bit.Vector.Inline<n>, Element == Bit {

    @inlinable
    public var maximum: Bit.Index.Count { Bit.Vector.Inline<n>._capacity }

    @inlinable
    public var remaining: Bit.Index.Count {
        let count = base.value._count
        return Bit.Vector.Inline<n>._capacity.subtract.saturating(count)
    }
}
