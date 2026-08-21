import Property_Primitives

extension Bit.Vector.Dynamic {

    public enum Toggle: Sendable {}
}

extension Bit.Vector.Dynamic {

    @inlinable
    public var toggle: Property<Toggle, Self>.Inout {
        mutating _read {
            yield Property<Toggle, Self>.Inout(&self)
        }
        mutating _modify {
            var accessor = Property<Toggle, Self>.Inout(&self)
            yield &accessor
        }
    }
}

extension Property.Inout where Tag == Bit.Vector.Dynamic.Toggle, Base == Bit.Vector.Dynamic {

    @inlinable
    public mutating func returning(_ index: Bit.Index) throws(Bit.Vector.Dynamic.Error) -> Bool {
        try base.value.toggle(index)
        return try base.value.get(index)
    }
}

extension Property.Inout where Tag == Bit.Vector.Set, Base == Bit.Vector.Dynamic {

    @inlinable
    public mutating func returning(_ index: Bit.Index) throws(Bit.Vector.Dynamic.Error) -> Bool {
        let previous = try base.value.get(index)
        try base.value.set(index)
        return previous
    }
}

extension Property.Inout where Tag == Bit.Vector.Clear, Base == Bit.Vector.Dynamic {

    @inlinable
    public mutating func returning(_ index: Bit.Index) throws(Bit.Vector.Dynamic.Error) -> Bool {
        let previous = try base.value.get(index)
        try base.value.clear(index)
        return previous
    }
}
