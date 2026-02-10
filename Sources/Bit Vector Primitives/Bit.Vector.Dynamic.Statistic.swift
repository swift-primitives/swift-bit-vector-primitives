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

extension Bit.Vector.Dynamic {
    /// Tag type for `statistic.true`/`statistic.false` property accessors.
    public enum Statistic: Sendable {}

    /// Tag type for `all.true`/`all.false` property accessors.
    public enum All: Sendable {}
}

// MARK: - Property: statistic.true / statistic.false

extension Bit.Vector.Dynamic {
    /// Property accessor for count statistics.
    ///
    /// ```swift
    /// let bits = Bit.Vector.Dynamic([true, false, true, false, true])
    /// bits.statistic.true   // 3
    /// bits.statistic.false  // 2
    /// ```
    @inlinable
    public var statistic: Property<Statistic, Self> {
        Property(self)
    }
}

extension Property where Tag == Bit.Vector.Dynamic.Statistic, Base == Bit.Vector.Dynamic {
    /// The number of `true` bits.
    @inlinable
    public var `true`: Bit.Index.Count { base.popcount }

    /// The number of `false` bits.
    @inlinable
    public var `false`: Bit.Index.Count { base._count.subtract.saturating(base.popcount) }
}

// MARK: - Property: all.true / all.false

extension Bit.Vector.Dynamic {
    /// Property accessor for universality checks.
    ///
    /// ```swift
    /// let bits = Bit.Vector.Dynamic([true, true, true])
    /// bits.all.true   // true
    /// bits.all.false  // false
    /// ```
    @inlinable
    public var all: Property<All, Self> {
        Property(self)
    }
}

extension Property where Tag == Bit.Vector.Dynamic.All, Base == Bit.Vector.Dynamic {
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
