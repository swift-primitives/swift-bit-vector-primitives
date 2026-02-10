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

extension Bit.Vector.Inline {
    /// Tag type for `statistic.true`/`statistic.false` property accessors.
    public enum Statistic: Sendable {}

    /// Tag type for `all.true`/`all.false` property accessors.
    public enum All: Sendable {}

    /// Tag type for `capacity.maximum`/`capacity.remaining` property accessors.
    public enum Capacity: Sendable {}
}

// MARK: - Property: statistic.true / statistic.false

extension Bit.Vector.Inline {
    @inlinable
    public var statistic: Property<Statistic, Self>.View.Typed<Bit>.Valued<wordCount> {
        mutating _read {
            yield unsafe Property<Statistic, Self>.View.Typed<Bit>.Valued<wordCount>(&self)
        }
    }
}

extension Property.View.Typed.Valued
where Tag == Bit.Vector.Inline<n>.Statistic, Base == Bit.Vector.Inline<n>, Element == Bit {
    /// The number of `true` bits.
    @inlinable
    public var `true`: Bit.Index.Count { unsafe base.pointee.popcount }

    /// The number of `false` bits.
    @inlinable
    public var `false`: Bit.Index.Count { unsafe base.pointee._count.subtract.saturating(base.pointee.popcount) }
}

// MARK: - Property: all.true / all.false

extension Bit.Vector.Inline {
    @inlinable
    public var all: Property<All, Self>.View.Typed<Bit>.Valued<wordCount> {
        mutating _read {
            yield unsafe Property<All, Self>.View.Typed<Bit>.Valued<wordCount>(&self)
        }
    }
}

extension Property.View.Typed.Valued
where Tag == Bit.Vector.Inline<n>.All, Base == Bit.Vector.Inline<n>, Element == Bit {
    /// Whether all bits are `true`.
    @inlinable
    public var `true`: Bool {
        let base = unsafe base.pointee
        guard base._count > .zero else { return true }
        return base.popcount == base._count
    }

    /// Whether all bits are `false`.
    @inlinable
    public var `false`: Bool {
        unsafe base.pointee.popcount == .zero
    }
}

// MARK: - Property: capacity.maximum / capacity.remaining

extension Bit.Vector.Inline {
    @inlinable
    public var capacity: Property<Capacity, Self>.View.Typed<Bit>.Valued<wordCount> {
        mutating _read {
            yield unsafe Property<Capacity, Self>.View.Typed<Bit>.Valued<wordCount>(&self)
        }
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
