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
    /// Tag type for `statistic.true`/`statistic.false` property accessors.
    public enum Statistic: Sendable {}
}

extension Bit.Vector.Inline.Statistic {
    /// The mutating property-view type for `statistic` accessors.
    public typealias View = Property<Self, Bit.Vector.Inline<wordCount>>.Inout.Typed<Bit>.Valued<wordCount>
}

// MARK: - Property: statistic.true / statistic.false

extension Bit.Vector.Inline {
    /// A property view exposing `statistic.true` and `statistic.false`.
    @inlinable
    public var statistic: Statistic.View {
        mutating _read { yield unsafe .init(&self) }
    }
}

extension Property.Inout.Typed.Valued
where Tag == Bit.Vector.Inline<n>.Statistic, Base == Bit.Vector.Inline<n>, Element == Bit {
    /// The number of `true` bits.
    @inlinable
    public var `true`: Bit.Index.Count { base.value.popcount }

    /// The number of `false` bits.
    @inlinable
    public var `false`: Bit.Index.Count { base.value._count.subtract.saturating(base.value.popcount) }
}
