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
    /// Tag type for `capacity.maximum`/`capacity.remaining` property accessors.
    public enum Capacity: Sendable {}
}

extension Bit.Vector.Inline.Capacity {
    /// The mutating property-view type for `capacity` accessors.
    public typealias View = Property<Self, Bit.Vector.Inline<wordCount>>.Inout.Typed<Bit>.Valued<wordCount>
}

// MARK: - Property: capacity.maximum / capacity.remaining

extension Bit.Vector.Inline {
    /// A property view exposing `capacity.maximum` and `capacity.remaining`.
    @inlinable
    public var capacity: Capacity.View {
        mutating _read { yield unsafe .init(&self) }
    }
}

extension Property.Inout.Typed.Valued
where Tag == Bit.Vector.Inline<n>.Capacity, Base == Bit.Vector.Inline<n>, Element == Bit {
    /// The maximum number of bits.
    @inlinable
    public var maximum: Bit.Index.Count { Bit.Vector.Inline<n>._capacity }

    /// The number of remaining slots.
    @inlinable
    public var remaining: Bit.Index.Count {
        let count = base.value._count
        return Bit.Vector.Inline<n>._capacity.subtract.saturating(count)
    }
}
