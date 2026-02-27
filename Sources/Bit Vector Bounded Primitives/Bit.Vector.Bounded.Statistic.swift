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
    /// Tag type for `statistic.true`/`statistic.false` property accessors.
    public enum Statistic: Sendable {}
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
