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

public import Sequence_Primitives_Core

// MARK: - Sequence.Protocol

extension Bit.Vector.Ones.View: Sequence.`Protocol` {
    public typealias Element = Bit.Index

    @inlinable
    public func makeIterator() -> Iterator {
        Iterator(view: self)
    }
}

// MARK: - Swift.Sequence

extension Bit.Vector.Ones.View: Swift.Sequence {
    /// Disambiguates `underestimatedCount` between the default provided by
    /// `Sequence.Protocol where Self: Copyable` and `Swift.Sequence`.
    @inlinable
    public var underestimatedCount: Int { 0 }

    /// Forces closure inlining during mandatory SIL passes by shadowing
    /// `Swift.Sequence.forEach` with `@inline(always)`.
    ///
    /// Without this, `Swift.Sequence.forEach` (which is `@inlinable` but not
    /// `@inline(always)`) leaves closures as separate `partial_apply` SIL
    /// entities. In class deinits with `~Copyable` generic parameters, the
    /// `partial_apply` captures `self` with `ForwardingConsume` semantics,
    /// and CopyPropagation cannot track the lifetime — causing a crash.
    @inline(always)
    @inlinable
    public func forEach(_ body: (Bit.Index) -> Void) {
        var iterator = makeIterator()
        while let element = iterator.next() {
            body(element)
        }
    }
}
