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

extension Bit.Vector.Bounded {
    /// Tag type for `all.true`/`all.false` property accessors.
    public enum All: Sendable {}
}

// MARK: - Property: all.true / all.false

extension Bit.Vector.Bounded {
    /// A property view exposing `all.true` and `all.false`.
    @inlinable
    public var all: Property<All, Self> {
        Property(self)
    }
}

extension Property where Tag == Bit.Vector.Bounded.All, Base == Bit.Vector.Bounded {
    /// Whether all bits are `true`.
    @inlinable
    public var `true`: Bool {
        guard base._count > .zero else { return true }
        return base.popcount == base._count
    }

    /// Whether all bits are `false`.
    @inlinable
    public var `false`: Bool {
        base.popcount == .zero
    }
}
