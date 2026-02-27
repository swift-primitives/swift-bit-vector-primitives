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

import Sequence_Primitives_Core

extension Bit.Vector.Ones {
    /// A sequence of set-bit indices for `Bit.Vector.Static`.
    ///
    /// Copies the `InlineArray` from the static vector so iteration does not
    /// require a pointer into stack storage (which would dangle on temporaries).
    ///
    /// Conforms to both `Sequence.Protocol` and `Swift.Sequence`, providing
    /// `forEach`, `map`, `filter`, `for-in`, and all stdlib sequence algorithms.
    @safe
    public struct Static<let wordCount: Int>: Copyable, Sendable {
        @usableFromInline
        let _storage: InlineArray<wordCount, UInt>

        @inlinable
        package init(storage: InlineArray<wordCount, UInt>) {
            self._storage = storage
        }
    }
}

// MARK: - Sequence.Protocol

extension Bit.Vector.Ones.Static: Sequence.`Protocol` {
    public typealias Element = Bit.Index

    @inlinable
    public func makeIterator() -> Iterator {
        Iterator(storage: _storage)
    }
}

// MARK: - Swift.Sequence

extension Bit.Vector.Ones.Static: Swift.Sequence {
    /// Disambiguates `underestimatedCount` between the default provided by
    /// `Sequence.Protocol where Self: Copyable` and `Swift.Sequence`.
    @inlinable
    public var underestimatedCount: Int { 0 }
}
