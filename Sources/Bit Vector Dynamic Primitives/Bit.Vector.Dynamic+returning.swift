// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-primitives open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

import Property_Primitives

// MARK: - Tag Type

extension Bit.Vector.Dynamic {
    /// Tag type for `toggle.returning(_:)` operation.
    public enum Toggle: Sendable {}
}

// MARK: - Property: toggle.returning

extension Bit.Vector.Dynamic {
    /// Property view for toggle operations with return values.
    ///
    /// ```swift
    /// var bits = Bit.Vector.Dynamic([true, false, true])
    /// let newValue = try bits.toggle.returning(1)  // true
    /// ```
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
    /// Toggles the bit at index and returns the new value.
    @inlinable
    public func returning(_ index: Bit.Index) throws(Bit.Vector.Dynamic.Error) -> Bool {
        try base.value.toggle(index)
        return try base.value.get(index)
    }
}

// MARK: - Property: set.returning

extension Property.Inout where Tag == Bit.Vector.Set, Base == Bit.Vector.Dynamic {
    /// Sets the bit at index and returns the previous value.
    @inlinable
    public func returning(_ index: Bit.Index) throws(Bit.Vector.Dynamic.Error) -> Bool {
        let previous = try base.value.get(index)
        try base.value.set(index)
        return previous
    }
}

// MARK: - Property: clear.returning

extension Property.Inout where Tag == Bit.Vector.Clear, Base == Bit.Vector.Dynamic {
    /// Clears the bit at index and returns the previous value.
    @inlinable
    public func returning(_ index: Bit.Index) throws(Bit.Vector.Dynamic.Error) -> Bool {
        let previous = try base.value.get(index)
        try base.value.clear(index)
        return previous
    }
}
