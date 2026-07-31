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

import Index_Primitives

extension Bit.Vector.Ones {
    /// A lightweight non-mutating view for iterating set bits.
    ///
    /// Captures the word pointer, word count, and capacity from `Bit.Vector`
    /// without requiring exclusive access. This enables `ones.forEach` to work
    /// from non-mutating contexts (including `deinit`).
    ///
    /// `~Escapable`, lifetime-dependent on the owning `Bit.Vector`: the view
    /// cannot outlive the vector it was borrowed from — escaping it past the
    /// vector's lifetime is rejected at compile time.
    @safe
    // WHY: Deliberately NOT `Sendable`. This view is a `Copyable` alias to the
    // WHY: same base pointer as its owning `Bit.Vector`, freely obtainable from
    // WHY: a borrow. A `Sendable` conformance here would defeat the removal of
    // WHY: `Sendable` on `Bit.Vector` itself — see `Bit.Vector.swift`.
    public struct View: Copyable, ~Escapable {
        @usableFromInline
        let _words: UnsafeMutablePointer<UInt>

        @usableFromInline
        let _wordCount: Index_Primitives.Index<UInt>.Count

        @usableFromInline
        let _capacity: Bit.Index.Count

        /// Creates a view borrowing the given vector's storage.
        ///
        /// The result's lifetime is tied to `vector`: it cannot escape past
        /// the vector's own lifetime.
        @inlinable
        @_lifetime(borrow vector)
        package init(vector: borrowing Bit.Vector) {
            unsafe self._words = vector._words
            self._wordCount = vector._wordCount
            self._capacity = vector.capacity
        }
    }
}
