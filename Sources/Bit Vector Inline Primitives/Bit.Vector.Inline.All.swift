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

extension Bit.Vector.Inline {
    /// Tag type for `all.true`/`all.false` property accessors.
    public enum All: Sendable {}
}

extension Bit.Vector.Inline.All {
    /// The mutating property-view type for `all` accessors.
    public typealias View = Property<Self, Bit.Vector.Inline<wordCount>>.Inout.Typed<Bit>.Valued<wordCount>
}

// MARK: - Property: all.true / all.false

extension Bit.Vector.Inline {
    /// A property view exposing `all.true` and `all.false`.
    @inlinable
    public var all: All.View {
        mutating _read { yield unsafe .init(&self) }
    }
}

extension Property.Inout.Typed.Valued
where Tag == Bit.Vector.Inline<n>.All, Base == Bit.Vector.Inline<n>, Element == Bit {
    /// Whether all bits are `true`.
    @inlinable
    public var `true`: Bool {
        let base = base.value
        guard base._count > .zero else { return true }
        return base.popcount == base._count
    }

    /// Whether all bits are `false`.
    @inlinable
    public var `false`: Bool {
        base.value.popcount == .zero
    }
}
