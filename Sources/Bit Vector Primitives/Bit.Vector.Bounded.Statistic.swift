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

// MARK: - Tag Types

extension Bit.Vector.Bounded {
    /// Tag type for `statistic.true`/`statistic.false` property accessors.
    public enum Statistic: Sendable {}

    /// Tag type for `all.true`/`all.false` property accessors.
    public enum All: Sendable {}

    /// Tag type for `capacity.maximum`/`capacity.remaining` property accessors.
    public enum Capacity: Sendable {}
}

// MARK: - Property: statistic.true / statistic.false

extension Bit.Vector.Bounded {
    @inlinable
    public var statistic: Property<Statistic, Self> {
        Property(self)
    }
}

extension Property where Tag == Bit.Vector.Bounded.Statistic, Base == Bit.Vector.Bounded {
    /// The number of `true` bits.
    @inlinable
    public var `true`: Bit.Index.Count { base.popcount }

    /// The number of `false` bits.
    @inlinable
    public var `false`: Bit.Index.Count { base._count.subtract.saturating(base.popcount) }
}

// MARK: - Property: all.true / all.false

extension Bit.Vector.Bounded {
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

// MARK: - Property: capacity.maximum / capacity.remaining

extension Bit.Vector.Bounded {
    @inlinable
    public var capacity: Property<Capacity, Self> {
        Property(self)
    }
}

extension Property where Tag == Bit.Vector.Bounded.Capacity, Base == Bit.Vector.Bounded {
    /// The maximum number of bits.
    @inlinable
    public var maximum: Bit.Index.Count { base._capacity }

    /// The number of remaining slots.
    @inlinable
    public var remaining: Bit.Index.Count { base._capacity.subtract.saturating(base._count) }
}
