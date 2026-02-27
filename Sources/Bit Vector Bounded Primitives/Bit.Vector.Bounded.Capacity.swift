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
    /// Tag type for `capacity.maximum`/`capacity.remaining` property accessors.
    public enum Capacity: Sendable {}
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
