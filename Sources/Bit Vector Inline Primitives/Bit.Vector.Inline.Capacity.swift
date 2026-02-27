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
    public enum Capacity: Sendable {
        public typealias View = Property<Capacity, Bit.Vector.Inline<wordCount>>.View.Typed<Bit>.Valued<wordCount>
    }
}

// MARK: - Property: capacity.maximum / capacity.remaining

extension Bit.Vector.Inline {
    @inlinable
    public var capacity: Capacity.View {
        mutating _read { yield unsafe .init(&self) }
    }
}

extension Property.View.Typed.Valued
where Tag == Bit.Vector.Inline<n>.Capacity, Base == Bit.Vector.Inline<n>, Element == Bit {
    /// The maximum number of bits.
    @inlinable
    public var maximum: Bit.Index.Count { Bit.Vector.Inline<n>._capacity }

    /// The number of remaining slots.
    @inlinable
    public var remaining: Bit.Index.Count {
        let count = unsafe base.pointee._count
        return Bit.Vector.Inline<n>._capacity.subtract.saturating(count)
    }
}
